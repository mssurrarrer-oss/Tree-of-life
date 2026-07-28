# Model Benchmark & Performance Testing Runbook

## Current Configuration (Gemma 4 12B Q8)
- **Quantization:** Q8_0 K/V Cache
- **Batch Size:** Physical = 512, Evaluation = 2048
- **Concurrent Predictions:** 4
- **GPU Layers:** 32 layers on GPU
- **CPU Threads:** 12 threads (currently using)
- **Memory Usage:** ~40% GPU, ~25% CPU

## Testing Scenarios to Document

### 1. F32 vs Q8 Comparison on Small Models
**Question:** What performance difference would full precision (F32) make for the smallest models (~0.8B)?

*   **Expected Results:**
    *   F32: Maximum accuracy but highest memory usage
    *   Q4_K_M: Best balance of speed and accuracy for most tasks
    *   Q2/Q3: Fastest but prone to hallucinations on complex reasoning

### 2. CPU Thread Optimization
**Question:** What's the optimal number of CPU threads?

*   **Test Range:** 12 → 16 → 18 → 20 threads
*   **Benchmark Metrics:**
    *   Token generation speed (tokens/second)
    *   Memory pressure on system RAM
    *   Impact on other tasks (browsing, etc.)

### 3. Tarot Interpretation Accuracy Test
**Question:** How does quantization affect complex semantic analysis?

*   **Test Prompt:** "Interpret the Ten of Swords card considering recovery from the drug age"
*   **Comparison Points:**
    *   Q2: Prone to oversimplification, may miss spiritual nuance
    *   Q4_K_M: Good balance, accurate but slightly less nuanced
    *   Q8_0: Maintains full philosophical depth and historical context

### 4. Letter Interpretation Depth Test
**Question:** How does quantization affect our multi-layered letter theory?

*   **Test Prompt:** "Explain the N/Z duality using the Ankh Wheel logic"
*   **Metrics:**
    *   Accuracy of quadrant assignments (NE/SW)
    *   Precision in gender-participation mapping
    *   Consistency across multiple generations

## Performance Metrics to Track

| Metric | Q2/Q3 | Q4_K_M | Q5_K_M | Q8_0 | F32 |
|--------|-------|--------|--------|------|-----|
| Token Speed (tok/s) | High | Medium-High | Medium | Low-Medium | Very Low |
| Memory Usage | Minimal | Moderate | Higher | High | Maximum |
| Hallucination Rate | High | Medium | Lower | Very Low | None |
| Complex Reasoning | Poor | Good | Better | Excellent | Perfect |

## Notes for Future Experiments
- Track how 12B vs 0.8B models perform at same quantization level
- Document optimal settings for Tarot readings vs letter analysis tasks
- Monitor impact of increasing CPU threads beyond current 12
