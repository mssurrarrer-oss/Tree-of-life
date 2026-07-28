# Seed-Orchestration Specification

## Purpose
Generate dynamic, state-aware tasks that balance reliability and innovation in each cycle.

## Inputs
- Date and time
- Open priorities from `projects/workflow-tracker.json`
- Recent ingest summary from `knowledge/last-ingest-summary.json`
- Optional random salt from operator

## Seed formula
seed = SHA256(date + topPriority + ingestDocCount + optionalSalt)

## Task selection policy
Each cycle must produce:
1. One Stability Task
2. One Exploration Task

### Stability Task categories
- validation
- cleanup
- test hardening
- documentation clarity
- memory hygiene

### Exploration Task categories
- prompt experiment
- model routing experiment
- retrieval experiment
- automation experiment
- UX flow experiment

## Constraints
- Total tasks per cycle: 2 to 4
- At least one task must be deliverable within 30 minutes.
- At least one task must produce reusable artifact output.

## Evidence requirement
Each completed task should capture:
- objective
- actions
- result
- next action

## Failure handling
If task fails:
- record reason
- classify as tooling, data, or method failure
- generate one fallback task in same category
