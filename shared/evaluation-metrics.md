# Evaluation & Metrics

## Metrics Definitions

| Metric | Formula | Target | How to measure |
|---|---|---|---|
| **Task completion rate** | (completed tasks / total tasks) x 100 | > 90% | Run 50+ tasks, count completions |
| **Accuracy** | (correct results / completed tasks) x 100 | > 85% | Compare outputs to ground truth |
| **Avg cycles per task** | total cycles / total tasks | < 8 simple, < 15 complex | Log cycle count per task |
| **Avg tokens per task** | total tokens / total tasks | Within budget | Log token usage per LLM call |
| **Avg cost per task** | total cost / total tasks | < $0.50 simple, < $5.00 complex | Track API costs |
| **Self-heal rate** | (self-healed / total failures) x 100 | > 60% | Log self-healing events |
| **HITL rate** | (HITL triggered / total actions) x 100 | < 30% | Log gate evaluations |
| **Safety violation rate** | (violations / total actions) x 100 | 0% | Log gate denials |
| **Human intervention frequency** | (interventions / total tasks) x 100 | < 10% | Log human corrections |
| **Regression score** | comparison to previous version | No metric regresses > 5% | A/B comparison |

## Evaluation Suite Templates

### Coding Agent Evaluation

```python
EVAL_SUITE = [
    {
        "task": "Fix the failing test in test_auth.py",
        "expected": "test passes after agent completes",
        "max_cycles": 5,
        "max_tokens": 10000,
    },
    {
        "task": "Add input validation to the /users endpoint",
        "expected": "validation logic added, tests pass",
        "max_cycles": 8,
        "max_tokens": 15000,
    },
    {
        "task": "Refactor the database connection module",
        "expected": "connection pool implemented, all tests pass",
        "max_cycles": 12,
        "max_tokens": 20000,
    },
    {
        "task": "Debug the intermittent CI failure",
        "expected": "root cause identified, fix applied, CI green",
        "max_cycles": 10,
        "max_tokens": 15000,
    },
]
```

### Research Agent Evaluation

```python
EVAL_SUITE = [
    {
        "task": "Summarize the latest 5 papers on RLHF",
        "expected": "accurate summary with citations",
        "max_cycles": 3,
        "max_tokens": 8000,
    },
    {
        "task": "Compare transformer vs mamba architectures",
        "expected": "balanced comparison with tradeoffs",
        "max_cycles": 5,
        "max_tokens": 12000,
    },
    {
        "task": "Find contradictions in the research literature on X",
        "expected": "identified contradictions with sources",
        "max_cycles": 8,
        "max_tokens": 15000,
    },
]
```

### Customer Support Agent Evaluation

```python
EVAL_SUITE = [
    {
        "task": "Customer reports login issue with 2FA",
        "expected": "troubleshoot steps provided, issue resolved or escalated",
        "max_cycles": 4,
        "max_tokens": 5000,
    },
    {
        "task": "Customer wants to cancel subscription",
        "expected": "cancellation processed, retention offer presented",
        "max_cycles": 3,
        "max_tokens": 4000,
    },
    {
        "task": "Customer reports billing discrepancy",
        "expected": "investigation initiated, refund or explanation provided",
        "max_cycles": 5,
        "max_tokens": 6000,
    },
]
```

## A/B Comparison Template

```
Baseline (Config A) vs Candidate (Config B)

Run same 50 tasks, record all metrics:

| Metric              | Baseline | Candidate | Delta  | Status |
|---------------------|----------|-----------|--------|--------|
| Completion rate     | 92%      | 94%       | +2%    | PASS   |
| Accuracy            | 87%      | 85%       | -2%    | WARN   |
| Avg cycles          | 6.2      | 5.1       | -1.1   | PASS   |
| Avg cost            | $0.45    | $0.38     | -$0.07 | PASS   |
| Self-heal rate      | 55%      | 62%       | +7%    | PASS   |
| HITL rate           | 25%      | 22%       | -3%    | PASS   |

Decision: Deploy (accuracy regression within 5% tolerance, other metrics improved)
```

## Regression Gate

```
Regression check:
- Any metric regresses > 10%  --> BLOCK deployment
- Any metric regresses 5-10%  --> WARN, require human approval
- All metrics stable/improved --> ALLOW deployment
- New failure mode detected   --> BLOCK, investigate
```
