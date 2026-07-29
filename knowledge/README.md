# Knowledge Base

This folder is the starter corpus for your local retrieval workflow.

Add text files, markdown notes, and research documents here.
The hub can later use these files as the basis for local RAG-style search and memory retrieval.

Operational structure:
- `knowledge/inbox/` for newly added source files.
- `knowledge/inbox/import-drop/` for raw conversation exports to be auto-routed.
- `knowledge/inbox/personal/` for private personal lane items.
- `knowledge/inbox/group/` for shared mission lane items.
- `knowledge/processed/` for archived source files moved by `tools/run-memory-ingest.ps1 -ArchiveInbox`.
- `knowledge/cloud-spend-ledger.csv` for cloud usage and cost tracking.
