# Model Benchmark Scorecard

Use this scorecard to compare local and cloud models fairly.

## Run metadata
- Date:
- Prompt set version:
- Hardware target:
- Runtime route:
- Evaluator:
- Context length:
- Temperature:
- Top P:
- Flash Attention: on | off
- K cache quantization: f16 | q8 | q6 | q5 | q4
- V cache quantization: f16 | q8 | q6 | q5 | q4
- KV cache shared/other runtime mode:

## Test matrix
| Model | Task type | Tokens in/out | Latency (s) | Accuracy (1-5) | Alignment (1-5) | Actionability (1-5) | Novelty (1-5) | Notes |
|---|---|---:|---:|---:|---:|---:|---:|---|
| Gemma 4 E4B | planning |  |  |  |  |  |  |  |
| Gemma 4 12B | planning |  |  |  |  |  |  |  |
| Qwen (selected) | analysis |  |  |  |  |  |  |  |

## Runtime metrics
| Model | Prompt set | TTFT (ms) | Tok/s | Peak RAM/VRAM | Context used | Flash Attention | K cache | V cache | Notes |
|---|---|---:|---:|---:|---:|---|---|---|---|
|  |  |  |  |  |  |  |  |  |  |

## Composite score
Use weighted score to choose default routing.

Score = 0.30 * Accuracy + 0.25 * Alignment + 0.25 * Actionability + 0.10 * Novelty + 0.10 * SpeedScore

Where:
- SpeedScore maps latency to 1 to 5 against your own baseline.

## Controlled K/V tests
Use same prompt set, seed, and decoding settings.

1. Baseline: f16/f16
2. Efficiency pass: q8/q8
3. Memory pass: q4/q4
4. Optional mixed pass: q8/q4 and q4/q8

Pick the lowest-memory profile that keeps quality within an acceptable delta.

## Decision rule
- Default route: highest composite for routine work.
- Escalation route: highest alignment and accuracy for high-stakes work.
- Exploration route: highest novelty with acceptable alignment.

## Provenance logging
For each run, log:
- Model identifier and quantization
- Runtime/software version
- Prompt set hash
- Evaluator identity

## Retrospective notes
- What improved this week?
- What regressed and why?
- What routing change is recommended?
