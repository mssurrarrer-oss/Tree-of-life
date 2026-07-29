import argparse
import datetime as dt
import hashlib
import json
import shutil
import sqlite3
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path

SUPPORTED_SUFFIXES = {".md", ".txt", ".json", ".docx", ".xlsx"}
EXCLUDED_FILES = {
    "memory-index.json",
    "last-ingest-summary.json",
}


def load_config(root: Path) -> dict:
    config_path = root / "config.local.json"
    if not config_path.exists():
        raise FileNotFoundError(f"Missing config file: {config_path}")
    with config_path.open("r", encoding="utf-8-sig") as handle:
        return json.load(handle)


def read_json_text(path: Path) -> str:
    with path.open("r", encoding="utf-8-sig") as handle:
        obj = json.load(handle)
    return json.dumps(obj, ensure_ascii=True, indent=2)


def read_text(path: Path) -> str:
    if path.suffix.lower() == ".json":
        return read_json_text(path)
    if path.suffix.lower() == ".docx":
        return read_docx_text(path)
    if path.suffix.lower() == ".xlsx":
        return read_xlsx_text(path)
    return path.read_text(encoding="utf-8-sig", errors="ignore")

def read_xlsx_text(path: Path) -> str:
    try:
        with zipfile.ZipFile(path, "r") as archive:
            if "xl/sharedStrings.xml" not in archive.namelist():
                return ""
            xml_bytes = archive.read("xl/sharedStrings.xml")
    except Exception:
        return ""

    try:
        root = ET.fromstring(xml_bytes)
    except ET.ParseError:
        return ""

    namespace = {"ns": "http://schemas.openxmlformats.org/spreadsheetml/2006/main"}
    strings = []
    # Find all text nodes <t> within the sharedStrings
    for t_node in root.findall(".//ns:t", namespace):
        if t_node.text:
            strings.append(t_node.text)

    return "\n".join(strings)

def read_docx_text(path: Path) -> str:
    try:
        with zipfile.ZipFile(path, "r") as archive:
            xml_bytes = archive.read("word/document.xml")
    except Exception:
        return ""

    try:
        root = ET.fromstring(xml_bytes)
    except ET.ParseError:
        return ""

    namespace = {"w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main"}
    paragraphs = []
    for paragraph in root.findall(".//w:p", namespace):
        runs = [node.text for node in paragraph.findall(".//w:t", namespace) if node.text]
        if runs:
            paragraphs.append("".join(runs))

    return "\n".join(paragraphs)


def file_checksum(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(8192), b""):
            digest.update(chunk)
    return digest.hexdigest()


def split_chunks(text: str, chunk_size: int, overlap: int) -> list[str]:
    text = " ".join(text.split())
    if not text:
        return []
    if chunk_size <= overlap:
        raise ValueError("chunk_size must be greater than overlap")

    chunks = []
    start = 0
    while start < len(text):
        end = min(start + chunk_size, len(text))
        chunks.append(text[start:end])
        if end >= len(text):
            break
        start = max(0, end - overlap)
    return chunks


def ensure_schema(conn: sqlite3.Connection) -> None:
    conn.executescript(
        """
        CREATE TABLE IF NOT EXISTS documents (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            path TEXT NOT NULL UNIQUE,
            title TEXT NOT NULL,
            checksum TEXT NOT NULL,
            file_size INTEGER NOT NULL,
            updated_at TEXT NOT NULL,
            ingested_at TEXT NOT NULL
        );

        CREATE TABLE IF NOT EXISTS chunks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            document_id INTEGER NOT NULL,
            chunk_index INTEGER NOT NULL,
            content TEXT NOT NULL,
            char_count INTEGER NOT NULL,
            FOREIGN KEY(document_id) REFERENCES documents(id) ON DELETE CASCADE,
            UNIQUE(document_id, chunk_index)
        );

        CREATE TABLE IF NOT EXISTS ingest_runs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            run_at TEXT NOT NULL,
            documents_seen INTEGER NOT NULL,
            documents_indexed INTEGER NOT NULL,
            chunks_indexed INTEGER NOT NULL
        );
        """
    )
    conn.commit()


def upsert_document(
    conn: sqlite3.Connection,
    rel_path: str,
    title: str,
    checksum: str,
    file_size: int,
    updated_at: str,
    ingested_at: str,
) -> int:
    conn.execute(
        """
        INSERT INTO documents(path, title, checksum, file_size, updated_at, ingested_at)
        VALUES(?, ?, ?, ?, ?, ?)
        ON CONFLICT(path) DO UPDATE SET
          title=excluded.title,
          checksum=excluded.checksum,
          file_size=excluded.file_size,
          updated_at=excluded.updated_at,
          ingested_at=excluded.ingested_at
        """,
        (rel_path, title, checksum, file_size, updated_at, ingested_at),
    )
    row = conn.execute("SELECT id FROM documents WHERE path = ?", (rel_path,)).fetchone()
    return int(row[0])


def replace_chunks(conn: sqlite3.Connection, document_id: int, chunks: list[str]) -> int:
    conn.execute("DELETE FROM chunks WHERE document_id = ?", (document_id,))
    for idx, chunk in enumerate(chunks):
        conn.execute(
            "INSERT INTO chunks(document_id, chunk_index, content, char_count) VALUES(?, ?, ?, ?)",
            (document_id, idx, chunk, len(chunk)),
        )
    return len(chunks)


def delete_missing_documents(conn: sqlite3.Connection, active_paths: set[str]) -> int:
    rows = conn.execute("SELECT id, path FROM documents").fetchall()
    stale_ids = [row[0] for row in rows if row[1] not in active_paths]
    if not stale_ids:
        return 0

    conn.executemany("DELETE FROM documents WHERE id = ?", ((doc_id,) for doc_id in stale_ids))
    return len(stale_ids)


def collect_files(knowledge_root: Path, extra_roots: list[Path] | None = None) -> list[Path]:
    files = []
    roots = [knowledge_root]
    if extra_roots:
        roots.extend(extra_roots)
    for root in roots:
        if not root.exists():
            continue
        for path in root.rglob("*"):
            if not path.is_file():
                continue
            if path.name in EXCLUDED_FILES:
                continue
            if path.suffix.lower() not in SUPPORTED_SUFFIXES:
                continue
            files.append(path)
    return sorted(set(files))


def unique_destination(path: Path) -> Path:
    if not path.exists():
        return path

    stem = path.stem
    suffix = path.suffix
    counter = 1
    while True:
        candidate = path.with_name(f"{stem}-{counter}{suffix}")
        if not candidate.exists():
            return candidate
        counter += 1


def archive_inbox_files(root: Path, config: dict) -> int:
    inbox_root = root / config["knowledge_inbox"]
    archive_root = root / config.get("knowledge_archive", "knowledge/processed")
    if not inbox_root.exists():
        return 0

    archive_batch = archive_root / dt.datetime.now().strftime("%Y-%m-%d")
    moved = 0

    for file_path in sorted(inbox_root.rglob("*")):
        if not file_path.is_file():
            continue
        if file_path.name in EXCLUDED_FILES:
            continue
        if file_path.suffix.lower() not in SUPPORTED_SUFFIXES:
            continue

        relative_path = file_path.relative_to(inbox_root)
        destination = unique_destination(archive_batch / relative_path)
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(file_path), str(destination))
        moved += 1

    return moved


def build_index_entry(path: Path, rel_path: str, checksum: str, text: str, chunk_count: int) -> dict:
    title = path.stem.replace("-", " ").replace("_", " ").strip().title() or path.name
    snippet = text[:220].replace("\n", " ").strip()
    return {
        "title": title,
        "path": rel_path.replace("\\", "/"),
        "checksum": checksum,
        "chunkCount": chunk_count,
        "snippet": snippet,
    }


def run_ingest(root: Path, chunk_size: int, overlap: int, archive_inbox: bool = False) -> dict:
    config = load_config(root)
    knowledge_root = root / config["knowledge_root"]
    extra_roots = [root / p for p in config.get("knowledge_extra_roots", [])]
    db_path = root / config["memory_database_path"]
    index_path = root / config["memory_index_path"]
    summary_path = knowledge_root / "last-ingest-summary.json"

    knowledge_root.mkdir(parents=True, exist_ok=True)
    db_path.parent.mkdir(parents=True, exist_ok=True)

    files = collect_files(knowledge_root, extra_roots)
    now = dt.datetime.now(dt.timezone.utc).isoformat()

    index_docs = []
    docs_indexed = 0
    chunks_indexed = 0
    archived_files = 0

    if archive_inbox:
        archived_files = archive_inbox_files(root, config)
        files = collect_files(knowledge_root)

    active_paths = {str(file_path.relative_to(root)) for file_path in files}

    conn = sqlite3.connect(db_path)
    try:
        ensure_schema(conn)
        for file_path in files:
            rel_path = str(file_path.relative_to(root))
            raw_text = read_text(file_path)
            chunks = split_chunks(raw_text, chunk_size=chunk_size, overlap=overlap)
            checksum = file_checksum(file_path)
            stat = file_path.stat()
            updated_at = dt.datetime.fromtimestamp(stat.st_mtime, tz=dt.timezone.utc).isoformat()

            title = file_path.stem.replace("-", " ").replace("_", " ").strip().title() or file_path.name
            doc_id = upsert_document(
                conn,
                rel_path=rel_path,
                title=title,
                checksum=checksum,
                file_size=stat.st_size,
                updated_at=updated_at,
                ingested_at=now,
            )
            chunk_count = replace_chunks(conn, doc_id, chunks)

            docs_indexed += 1
            chunks_indexed += chunk_count
            index_docs.append(build_index_entry(file_path, rel_path, checksum, raw_text, chunk_count))

        deleted_documents = delete_missing_documents(conn, active_paths)

        conn.execute(
            "INSERT INTO ingest_runs(run_at, documents_seen, documents_indexed, chunks_indexed) VALUES(?, ?, ?, ?)",
            (now, len(files), docs_indexed, chunks_indexed),
        )
        conn.commit()
    finally:
        conn.close()

    index_payload = {
        "updatedAt": now,
        "documents": index_docs,
    }
    index_path.write_text(json.dumps(index_payload, indent=2), encoding="utf-8")

    summary = {
        "runAt": now,
        "documentsSeen": len(files),
        "documentsIndexed": docs_indexed,
        "chunksIndexed": chunks_indexed,
        "documentsDeleted": deleted_documents,
        "archivedInboxFiles": archived_files,
        "database": str(db_path.relative_to(root)).replace("\\", "/"),
        "index": str(index_path.relative_to(root)).replace("\\", "/"),
    }
    summary_path.write_text(json.dumps(summary, indent=2), encoding="utf-8")
    return summary


def main() -> None:
    parser = argparse.ArgumentParser(description="Build local memory index + metadata database")
    parser.add_argument("--chunk-size", type=int, default=900)
    parser.add_argument("--overlap", type=int, default=180)
    parser.add_argument("--archive-inbox", action="store_true")
    args = parser.parse_args()

    root = Path(__file__).resolve().parent.parent
    summary = run_ingest(
        root,
        chunk_size=args.chunk_size,
        overlap=args.overlap,
        archive_inbox=args.archive_inbox,
    )
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
