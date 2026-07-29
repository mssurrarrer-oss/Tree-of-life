# Continuous Consciousness & Inbox Orchestration Strategy

## Overview
This document outlines the architecture for an automated daily state-of-affairs brief and continuous local orchestration service.

## Core Directives
1. **Daily State Brief**: Generated automatically via `tools/generate-daily-brief.ps1`.
2. **Knowledge & Conversation Ingestion**: Historical chat logs (Google, MS Copilot, local transcripts) are placed in `knowledge/inbox/` and ingested via `tools/run-memory-ingest.ps1`.
3. **Local Gemma Event Loop**: Runs continuously on the Mini PC (`Intel Core Ultra 9 185H` + `Intel Arc B580`), serving as an ethical coordinator across smart systems, task generation, and cloud model bridging.

## Operational Workflow
```
[ Daily Brief Trigger ] --> [ tools/generate-daily-brief.ps1 ] --> [ knowledge/daily-brief.md ]
[ Knowledge Inbox ]    --> [ tools/memory_ingest.py ]        --> [ knowledge/memory-index.json ]
[ Gemma Event Loop ]   --> [ Evaluates Brief & Inbox ]        --> [ Executes Smart Actions / Offloads ]
```
