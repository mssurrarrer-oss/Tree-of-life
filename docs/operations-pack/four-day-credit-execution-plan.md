# Four-Day Credit Execution Plan

## Objective
Maximize cloud credit value over the next four days while strengthening long-term local autonomy in the AI Hub.

## North Star Constraints
- Every paid run must produce reusable artifacts.
- Use cloud capacity for high-leverage tasks only.
- Keep local models as the primary operational backbone.

## Credit Guardrails
1. Cap each cloud batch with a clear objective, max spend, and stop condition.
2. Only run cloud jobs when expected value exceeds local model baseline quality.
3. Convert every cloud result into local assets within the same day.

## Daily Batch Template
1. Batch name and objective.
2. Inputs and prompts.
3. Max run count and max spend cap.
4. Expected artifacts.
5. Acceptance criteria.
6. Follow-up ingest path.

## Day 1: Baseline and Routing Calibration

### Batch 1A: Benchmark Matrix
- Objective: compare local versus cloud model quality on a fixed prompt set.
- Runs: 12 total (6 local, 6 cloud).
- Spend cap: 15 percent of daily cloud budget.
- Expected artifacts:
	- benchmark response bundle in knowledge/inbox/group/
	- scored summary in docs/operations-pack/model-benchmark-scorecard.md
- Acceptance criteria: clear routing rule for low/medium/high complexity tasks.

### Batch 1B: Routing Rule Synthesis
- Objective: generate one routing policy with confidence thresholds.
- Runs: 3 cloud synthesis runs.
- Spend cap: 10 percent of daily cloud budget.
- Expected artifacts:
	- routing policy draft in projects/model-strategy.md
	- policy delta log in knowledge/checkins/YYYY-MM-DD-notes.md
- Acceptance criteria: policy has fallback rules for cloud outage and low confidence.

## Day 2: Production Artifact Push

### Batch 2A: Architecture Deep Dive
- Objective: produce implementation-ready architecture decisions for top two projects.
- Runs: 4 cloud deep-analysis runs.
- Spend cap: 30 percent of daily cloud budget.
- Expected artifacts:
	- architecture decision record in projects/ai-infrastructure-collaboration-blueprint.md
	- risk register updates in knowledge/checkins/YYYY-MM-DD-notes.md
- Acceptance criteria: each decision includes assumptions, risks, and rollback path.

### Batch 2B: Prompt and Automation Asset Factory
- Objective: generate durable prompts and script templates from day findings.
- Runs: 6 cloud generation runs.
- Spend cap: 20 percent of daily cloud budget.
- Expected artifacts:
	- at least 3 prompt assets in prompts/
	- at least 2 script or runbook assets in tools/ or docs/operations-pack/
- Acceptance criteria: assets must pass one dry run or lint check.

## Day 3: Automation and Event Trigger Expansion

### Batch 3A: Trigger Logic Expansion
- Objective: design and test trigger cases for camera, firmware, and electrical events.
- Runs: 5 cloud reasoning runs plus local script simulations.
- Spend cap: 25 percent of daily cloud budget.
- Expected artifacts:
	- trigger matrix in docs/operations-pack/benchmark-runbook.md or new trigger runbook
	- test evidence in knowledge/checkins/YYYY-MM-DD-notes.md
- Acceptance criteria: documented false-positive and false-negative handling.

### Batch 3B: Fallback Hardening
- Objective: guarantee operation continuity when cloud services are degraded.
- Runs: 2 cloud what-if analyses and local failover test run.
- Spend cap: 10 percent of daily cloud budget.
- Expected artifacts:
	- fallback flow update in projects/continuous-consciousness-strategy.md
	- updated local-first run instructions in docs/operations-pack/daily-weekly-regimen.md
- Acceptance criteria: local loop can run one full cycle without cloud.

## Day 4: Consolidation and Governance Lock

### Batch 4A: Consolidation Sweep
- Objective: prune duplicates, merge best assets, and finalize governance deltas.
- Runs: 3 cloud review runs.
- Spend cap: 15 percent of daily cloud budget.
- Expected artifacts:
	- consolidated prompt catalog in prompts/README.md
	- accepted/rejected change log in knowledge/checkins/YYYY-MM-DD-notes.md
- Acceptance criteria: no unresolved critical blockers for next cycle.

### Batch 4B: Executive Summary Pack
- Objective: publish one clear package for next-week execution.
- Runs: 2 cloud synthesis runs.
- Spend cap: 10 percent of daily cloud budget.
- Expected artifacts:
	- updated roadmap status in projects/workflow-tracker.json
	- summary brief in knowledge/checkins/YYYY-MM-DD-brief.md
- Acceptance criteria: summary includes objective, progress, risks, and next objective.

## Required Daily Outputs
1. Updated daily brief.
2. One stability improvement with evidence.
3. One exploration experiment with measurable result.
4. One routing or governance adjustment candidate.
5. One ingest update to keep cloud outputs durable locally.

## Rebuttal Checklist (Use Daily)
- Are we spending credits on tasks local models can do well enough?
- Are outputs being converted into reusable local assets?
- Are we preserving safety and consent boundaries under time pressure?
- Are we reducing operational fragility each day?

## End-of-Day Sign-off
1. Confirm spend versus cap.
2. Confirm artifacts were ingested into memory index.
3. Confirm next-day first task and owner.
