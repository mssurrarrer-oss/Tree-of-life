# Inbox Lifecycle and Archiving

## Purpose
Keep knowledge/inbox focused on newly added material while preserving indexed source history.

## Standard flow
1. Add or update source files under knowledge/inbox.
2. Run normal ingest:
   - tools/run-memory-ingest.ps1
3. Optionally archive supported inbox files after ingest:
   - tools/run-memory-ingest.ps1 -ArchiveInbox
4. Verify status:
   - tools/inbox-status.ps1

## What archive mode does
- Moves supported ingest files from knowledge/inbox to knowledge/processed/YYYY-MM-DD/
- Re-runs indexing against the full knowledge tree
- Writes ingest summary fields:
  - documentsDeleted
  - archivedInboxFiles

## Why this is safe
- Ingest now removes stale document rows when files no longer exist at old paths.
- Processed files remain indexed because they still live under knowledge/.

## Recommended habits
- Keep inbox as a drop zone, not long-term storage.
- Run archive mode at end of day or end of import batch.
- Keep unsupported binaries in separate folders until converted.
