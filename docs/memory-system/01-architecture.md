# Memory Retrieval Architecture (Local-First)

## Objective
Build a memory system that grows over time without forcing repeated restarts.

## Core design
1. Source layer
- Folder-based documents in knowledge/
- Chat logs, notes, project docs, transcripts

2. Processing layer
- Ingestion parser (markdown, txt, json)
- Chunking strategy (e.g., 600-1000 tokens with overlap)
- Metadata extraction (source, date, tags, mode)

3. Storage layer
- Vector store for semantic retrieval
- SQL store for metadata, lineage, versions, and audit trail

4. Retrieval layer
- Hybrid retrieval: semantic + keyword + metadata filters
- Reranking step for relevance
- Mode-aware retrieval (language, creative, ethics, memory, etc.)

5. Agent layer
- Short-term working memory
- Retrieval hooks per mode
- Suggestion engine + scheduled refresh

## Recommended stack now
- Vector: Chroma (fast local startup)
- SQL metadata: SQLite (simple and portable)
- Embeddings: local embeddings model via Ollama or sentence-transformers
- Orchestration: lightweight Python scripts + Task Scheduler

## Why this architecture
- Easy to evolve gradually
- Keeps local control and privacy
- Supports deep auditability and long-term continuity
