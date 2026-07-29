# Daily and Weekly Regimen

## Daily cycle (30 to 90 minutes)
1. Check-in and triage
- Run `tools/run-daily-checkin.ps1` to refresh state artifacts.
- Review `knowledge/checkins/YYYY-MM-DD-inbox-triage.md`.

2. Conversation imports
- Drop historical chats into `knowledge/inbox/import-drop/`.
- Confirm `knowledge/checkins/YYYY-MM-DD-imports.log` for routed files.

3. Ingest
- Run memory ingest for new files and conversation imports.
- Verify `knowledge/last-ingest-summary.json` updated.

4. Seed and plan
- Generate day seed from date + workspace state.
- Select exactly two tasks:
  - Stability task: cleanup, test hardening, docs quality, validation.
  - Exploration task: novel prompting, model routing trial, feature experiment.

5. Execute and capture
- Run both tasks with concise evidence logs.
- Save outputs, deltas, and blockers.

6. Evaluate
- Score model outputs using the scorecard.
- Record routing recommendation updates.

7. Cost and risk accounting
- Append cloud run costs with `tools/log-cloud-spend.ps1`.
- Review `knowledge/checkins/YYYY-MM-DD-cloud-spend.md`.

8. Care safety simulation (as needed)
- Run `tools/run-care-alert-simulation.ps1` when trigger thresholds change.
- Review high-severity action routing.

9. Constitution candidate
- Add one candidate update only if evidence supports it.

## Weekly cycle (60 to 180 minutes)
1. Memory hygiene
- Archive stale notes and duplicate chunks.
- Keep active memory lean and high signal.

2. Benchmark sweep
- Run a standard benchmark set across active models.
- Compare by latency, accuracy, alignment, and actionability.

3. Governance review
- Approve/reject constitution candidates.
- Publish updated version metadata.

4. Roadmap update
- Move priorities in `projects/workflow-tracker.json`.
- Set one measurable objective for next week.

## Monthly reset
- Rotate benchmark prompts to avoid overfitting.
- Reassess toolchain and extension value.
- Remove automation that does not produce clear value.
