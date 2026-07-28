# Extensions and Tools for Memory Upgrade

## VS Code extensions (high value)
1. Continue for model routing and coding assistant workflows
2. SQLTools for SQLite/MySQL/Postgres query workflows
3. SQLite Viewer for quick database inspection
4. Markdown All in One for writing and maintaining large knowledge docs
5. Todo Tree for action extraction across notes and code

## Core local components
- Chroma DB for semantic memory retrieval
- SQLite for metadata, indexing status, and retrieval logs
- Optional reranker model for better relevance

## Optional components
- Qdrant if you want a stronger standalone vector DB later
- Weaviate if you need richer semantic schema features
- Elasticsearch/OpenSearch if keyword-heavy workloads become primary

## Recommendation for your current phase
Start with:
- Chroma + SQLite + local embeddings
Then scale to:
- Qdrant or a service-backed vector DB only if required by volume/performance

## Pieces OS note
Pieces OS can complement this as workflow memory capture, but keep your own curated knowledge base and retrieval pipeline as the source of truth.
