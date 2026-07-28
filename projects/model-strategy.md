# Model Strategy

## Preferred local and cloud collaborators
- Gemma 4: strong fit for careful, professional reasoning and structured work.
- Qwen 3+: valuable for broad perspective, memory-rich interaction, and long-context reasoning.
- Gemini: useful as a cloud collaborator and cross-checking partner.
- Microsoft Copilot and Office 365 Copilot: valuable for productivity and document workflows.
- Other local/open models: useful for experimentation, specialization, and redundancy.

## Recommended approach
- Use a consistent model stack across daily tasks where practical.
- Keep local models for private or latency-sensitive workflows.
- Use cloud models for broader retrieval, brainstorming, and external collaboration.
- Compare answers across models when the topic is important or high-stakes.

## RAG and knowledge foundation
- Start with a small curated corpus of documents, notes, and research files.
- Use embeddings and a vector database to support retrieval over your own knowledge base.
- Keep the retrieval layer simple at first, then expand as the workflow proves itself.
- Use RAG to support language analysis, personal knowledge organization, and project memory.
