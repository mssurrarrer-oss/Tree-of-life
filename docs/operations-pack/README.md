# AI-Hub Operations Pack

This pack provides a practical system to run AI-Hub as a reliable, evolving local AI operation.

## Pack contents
- `living-constitution-template.md`: a governed document format for principles and updates.
- `daily-weekly-regimen.md`: repeatable cycle for ingest, evaluation, and improvement.
- `model-benchmark-scorecard.md`: unified scorecard for cross-model testing.
- `seed-orchestration-spec.md`: random-seed and state-aware task generation method.
- `benchmark-runbook.md`: benchmark method, runtime controls, and optional tooling guidance.

## Recommended daily loop
1. Run ingestion for new notes and conversations.
2. Generate the day seed and select one stability task and one exploration task.
3. Execute tasks with evidence capture.
4. Score outputs from active models.
5. Write one constitution candidate update if backed by evidence.

## Recommended weekly loop
1. Prune stale context from active memory.
2. Consolidate repeated findings into durable guidance.
3. Review benchmark trends and model routing.
4. Approve or reject constitution candidates.

## Next integrations
- Attach this pack to automation in `tools/`.
- Store runtime metrics in local SQLite.
- Route small, medium, and large models based on scorecard confidence.
