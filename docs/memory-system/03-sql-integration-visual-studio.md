# SQL Integration with Visual Studio Community

## Short answer
Yes. SQL can be integrated cleanly into this memory system.

## Best practical options
1. SQLite (recommended first)
- Easiest local metadata store
- Portable single-file DB
- Works well with VS Code + SQLTools + SQLite extensions

2. SQL Server Express / LocalDB
- Good if you want tighter Microsoft ecosystem alignment
- Can be managed from Visual Studio and SSMS
- Better fit when schema complexity and reporting grow

## How SQL fits memory retrieval
Store in SQL:
- document registry (path, checksum, source, tags, mode)
- chunk metadata (chunk_id, document_id, token_count)
- retrieval logs (query, selected chunks, timestamp)
- agent events (mode switches, suggestions, outcomes)

Keep vectors in:
- Chroma (or equivalent vector DB)

## Hybrid design
- SQL answers structure/history questions
- Vector DB answers semantic similarity questions
- Combined query path gives better traceability and relevance

## When to move from SQLite to SQL Server
- Concurrent users/processes increase
- Reporting needs become complex
- You require stronger enterprise-style governance controls
