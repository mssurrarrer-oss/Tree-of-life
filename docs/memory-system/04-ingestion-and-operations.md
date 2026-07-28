# Ingestion and Operations

## Drop zone workflow
1. Put new materials into knowledge/inbox or any subfolder under knowledge/
2. Run tools/run-memory-ingest.ps1
3. The system updates:
- knowledge/memory-index.json
- knowledge/memory-metadata.db
- knowledge/last-ingest-summary.json
4. Optional: run tools/run-memory-ingest.ps1 -ArchiveInbox to move supported inbox files into knowledge/processed/YYYY-MM-DD after indexing.

## What gets indexed
- .md
- .txt
- .json
- .docx

## Knowledge roots
- Primary: `knowledge/`
- Optional extra roots configured in `config.local.json` under `knowledge_extra_roots`.
- Default extra root: `projects/letter-research`
- .docx

## Chunking defaults
- chunk size: 900 characters
- overlap: 180 characters

## Operational habit
- Run ingest after any meaningful document import
- Keep source docs human-readable
- Use SQL queries to inspect chunk/doc history over time
- Archive older inbox documents instead of deleting them when you want a cleaner drop zone

## Next evolution path
- Add embeddings generation and vector index writes
- Add hybrid retrieval (semantic + keyword + metadata)
- Add scheduled ingestion with Windows Task Scheduler
