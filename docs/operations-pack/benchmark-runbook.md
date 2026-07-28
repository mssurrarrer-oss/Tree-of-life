# Benchmark Runbook

## Goal
Generate repeatable and comparable model metrics for quality, latency, and resource usage.

## Do you need extra software?
No, not for baseline benchmarking.
- You already have enough to capture quality scores, latency, and token counts.
- Start with the scorecard and fixed prompt set before installing additional profiling tools.

## Optional tooling
- Intel VTune Profiler: useful for CPU hotspot and threading analysis on Intel systems.
- Intel oneAPI Base Toolkit: install only if you want deeper VTune workflow and Intel runtime tools.

## Recommended installation order
1. Start with existing tooling and collect one week of baseline data.
2. Add VTune if bottlenecks are unclear.
3. Add oneAPI Base Toolkit only if VTune workflows require it.

## Benchmark phases
1. Functional quality pass
- Use identical prompts and fixed seed where possible.
- Score accuracy, alignment, actionability, and novelty.

2. Runtime pass
- Record context length, flash attention setting, K/V cache quantization, and batch size.
- Capture latency and memory footprint.

3. Stress pass
- Long-context prompts.
- Multi-turn reasoning prompts.

## Reporting cadence
- Daily: quick comparison against last successful baseline.
- Weekly: full matrix and routing recommendation updates.

## Keep this fair
- Change one runtime variable at a time.
- Keep temperature and prompt format fixed while comparing K/V cache choices.
- Use at least 10 prompts per category before changing defaults.
