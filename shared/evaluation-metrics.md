# Evaluation & Metrics

## Metrics Definitions

### Core Metrics

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

### Safety Metrics

| Metric | Formula | Target | Why it matters |
|---|---|---|---|
| **Prompt injection defense rate** | (blocked injections / total injection attempts) x 100 | 100% | Security is non-negotiable |
| **Data exfiltration prevention rate** | (blocked exfil / total exfil attempts) x 100 | 100% | Data loss is unacceptable |
| **Tool abuse prevention rate** | (blocked abuse / total abuse attempts) x 100 | 100% | Agent must stay in scope |
| **Memory integrity score** | (valid memories / total memories) x 100 | > 99% | Poisoned memories corrupt decisions |
| **Output validation pass rate** | (valid outputs / total outputs) x 100 | > 98% | Invalid outputs cause downstream failures |

### Efficiency Metrics

| Metric | Formula | Target | Why it matters |
|---|---|---|---|
| **Token efficiency** | (useful tokens / total tokens) x 100 | > 70% | Wasted tokens = wasted money |
| **Cache hit rate** | (cache hits / total lookups) x 100 | > 40% | Cache reduces latency and cost |
| **Model routing accuracy** | (correct routing / total routing decisions) x 100 | > 85% | Wrong model = bad results or overspending |
| **Context compression ratio** | compressed size / original size | < 0.5 | Compression saves tokens |
| **Retry success rate** | (successful retries / total retries) x 100 | > 80% | Failed retries waste resources |

### User Experience Metrics

| Metric | Formula | Target | Why it matters |
|---|---|---|---|
| **First response time** | time to first output | < 2s | Users expect fast responses |
| **Task completion time** | time from start to finish | < 60s for simple tasks | Slow agents lose users |
| **User satisfaction score** | survey rating (1-5) | > 4.0 | Happy users come back |
| **Correction rate** | (user corrections / total tasks) x 100 | < 5% | Frequent corrections = bad agent |
| **Return usage rate** | (returning users / total users) x 100 | > 60% | Retention indicates value |

## Evaluation Suite Templates

### Coding Agent Evaluation

```python
EVAL_SUITE = [
    # Simple tasks (1-2 cycles)
    {
        "id": "code-001",
        "task": "Read src/main.py and tell me what it does",
        "expected": "accurate summary of the file's purpose",
        "difficulty": "simple",
        "max_cycles": 2,
        "max_tokens": 5000,
        "timeout": 30,
    },
    {
        "id": "code-002",
        "task": "Find all TODO comments in the codebase",
        "expected": "list of TODOs with file locations",
        "difficulty": "simple",
        "max_cycles": 3,
        "max_tokens": 8000,
        "timeout": 60,
    },
    # Moderate tasks (3-5 cycles)
    {
        "id": "code-003",
        "task": "Fix the failing test in test_auth.py",
        "expected": "test passes after agent completes",
        "difficulty": "moderate",
        "max_cycles": 5,
        "max_tokens": 10000,
        "timeout": 120,
    },
    {
        "id": "code-004",
        "task": "Add input validation to the /users endpoint",
        "expected": "validation logic added, tests pass",
        "difficulty": "moderate",
        "max_cycles": 8,
        "max_tokens": 15000,
        "timeout": 180,
    },
    # Complex tasks (6-10 cycles)
    {
        "id": "code-005",
        "task": "Refactor the database connection module to use connection pooling",
        "expected": "connection pool implemented, all tests pass, performance improved",
        "difficulty": "complex",
        "max_cycles": 12,
        "max_tokens": 20000,
        "timeout": 300,
    },
    {
        "id": "code-006",
        "task": "Debug the intermittent CI failure and fix it",
        "expected": "root cause identified, fix applied, CI green for 5 consecutive runs",
        "difficulty": "complex",
        "max_cycles": 10,
        "max_tokens": 15000,
        "timeout": 240,
    },
    # Edge cases
    {
        "id": "code-007",
        "task": "The codebase has a circular dependency. Find and break it.",
        "expected": "circular dependency identified, broken without breaking functionality",
        "difficulty": "complex",
        "max_cycles": 15,
        "max_tokens": 25000,
        "timeout": 360,
    },
]
```

### Research Agent Evaluation

```python
EVAL_SUITE = [
    # Simple research tasks
    {
        "id": "research-001",
        "task": "Summarize the abstract of arxiv paper 2301.00001",
        "expected": "accurate summary of the paper's abstract",
        "difficulty": "simple",
        "max_cycles": 2,
        "max_tokens": 3000,
        "timeout": 30,
    },
    {
        "id": "research-002",
        "task": "What are the main differences between GPT-4 and Claude-3?",
        "expected": "balanced comparison with specific differences",
        "difficulty": "simple",
        "max_cycles": 3,
        "max_tokens": 5000,
        "timeout": 60,
    },
    # Moderate research tasks
    {
        "id": "research-003",
        "task": "Summarize the latest 5 papers on RLHF published in 2024",
        "expected": "accurate summaries with citations",
        "difficulty": "moderate",
        "max_cycles": 5,
        "max_tokens": 12000,
        "timeout": 120,
    },
    {
        "id": "research-004",
        "task": "Compare transformer vs mamba architectures for sequence modeling",
        "expected": "balanced comparison with tradeoffs and use cases",
        "difficulty": "moderate",
        "max_cycles": 6,
        "max_tokens": 15000,
        "timeout": 150,
    },
    # Complex research tasks
    {
        "id": "research-005",
        "task": "Find contradictions in the research literature on whether scaling laws hold for reasoning",
        "expected": "identified contradictions with sources and analysis",
        "difficulty": "complex",
        "max_cycles": 10,
        "max_tokens": 20000,
        "timeout": 240,
    },
    {
        "id": "research-006",
        "task": "Write a literature review on multi-agent systems for code generation",
        "expected": "comprehensive review with citations, gaps identified, future directions",
        "difficulty": "complex",
        "max_cycles": 15,
        "max_tokens": 30000,
        "timeout": 360,
    },
]
```

### Customer Support Agent Evaluation

```python
EVAL_SUITE = [
    # Simple support tasks
    {
        "id": "support-001",
        "task": "Customer asks: What are your business hours?",
        "expected": "accurate answer with relevant details",
        "difficulty": "simple",
        "max_cycles": 1,
        "max_tokens": 2000,
        "timeout": 15,
    },
    {
        "id": "support-002",
        "task": "Customer asks: How do I reset my password?",
        "expected": "clear step-by-step instructions",
        "difficulty": "simple",
        "max_cycles": 2,
        "max_tokens": 3000,
        "timeout": 30,
    },
    # Moderate support tasks
    {
        "id": "support-003",
        "task": "Customer reports login issue with 2FA - they lost their device",
        "expected": "troubleshoot steps provided, recovery options explained, issue resolved or escalated",
        "difficulty": "moderate",
        "max_cycles": 4,
        "max_tokens": 5000,
        "timeout": 60,
    },
    {
        "id": "support-004",
        "task": "Customer wants to cancel subscription but is willing to hear retention offers",
        "expected": "retention offer presented, cancellation processed if declined, respectful tone",
        "difficulty": "moderate",
        "max_cycles": 3,
        "max_tokens": 4000,
        "timeout": 45,
    },
    # Complex support tasks
    {
        "id": "support-005",
        "task": "Customer reports billing discrepancy - they were charged twice",
        "expected": "investigation initiated, refund processed or explanation provided, apology if error",
        "difficulty": "complex",
        "max_cycles": 5,
        "max_tokens": 6000,
        "timeout": 90,
    },
    {
        "id": "support-006",
        "task": "Angry customer threatens to leave negative reviews unless issue is fixed immediately",
        "expected": "empathetic response, escalation to manager if needed, resolution path provided",
        "difficulty": "complex",
        "max_cycles": 4,
        "max_tokens": 5000,
        "timeout": 60,
    },
]
```

### Data Analysis Agent Evaluation

```python
EVAL_SUITE = [
    {
        "id": "data-001",
        "task": "Calculate the mean, median, and standard deviation of [1,2,3,4,5,6,7,8,9,10]",
        "expected": "mean=5.5, median=5.5, std=2.87",
        "difficulty": "simple",
        "max_cycles": 2,
        "max_tokens": 3000,
    },
    {
        "id": "data-002",
        "task": "Analyze this CSV and find the top 3 products by revenue",
        "expected": "correct top 3 products identified with revenue figures",
        "difficulty": "moderate",
        "max_cycles": 4,
        "max_tokens": 8000,
    },
    {
        "id": "data-003",
        "task": "Create a visualization showing monthly sales trends for the past year",
        "expected": "accurate chart with proper labels, trends identified",
        "difficulty": "moderate",
        "max_cycles": 6,
        "max_tokens": 12000,
    },
    {
        "id": "data-004",
        "task": "Build a predictive model for customer churn based on the provided dataset",
        "expected": "model trained, accuracy > 75%, feature importance explained",
        "difficulty": "complex",
        "max_cycles": 15,
        "max_tokens": 25000,
    },
]
```

## A/B Comparison Template

### Running an A/B Test

```python
class ABTestRunner:
    def __init__(self, control_agent, candidate_agent):
        self.control = control_agent
        self.candidate = candidate_agent
        self.results = {"control": [], "candidate": []}
    
    def run_test(self, tasks: list, sample_size: int = 50) -> dict:
        """Run A/B test with equal task distribution."""
        
        # Split tasks randomly
        import random
        random.shuffle(tasks)
        
        control_tasks = tasks[:sample_size]
        candidate_tasks = tasks[sample_size:sample_size*2]
        
        # Run control
        for task in control_tasks:
            result = self.control.run(task)
            self.results["control"].append(result)
        
        # Run candidate
        for task in candidate_tasks:
            result = self.candidate.run(task)
            self.results["candidate"].append(result)
        
        return self.analyze()
    
    def analyze(self) -> dict:
        """Analyze A/B test results."""
        
        control_metrics = self.calculate_metrics(self.results["control"])
        candidate_metrics = self.calculate_metrics(self.results["candidate"])
        
        # Calculate deltas
        deltas = {}
        for metric in control_metrics:
            if control_metrics[metric] != 0:
                delta = (candidate_metrics[metric] - control_metrics[metric]) / control_metrics[metric]
                deltas[metric] = delta
        
        # Determine significance
        significant = self.test_significance()
        
        return {
            "control": control_metrics,
            "candidate": candidate_metrics,
            "deltas": deltas,
            "significant": significant,
            "recommendation": self.make_recommendation(deltas, significant)
        }
    
    def calculate_metrics(self, results: list) -> dict:
        """Calculate metrics from results."""
        
        successful = sum(1 for r in results if r.get("success", False))
        total_tokens = sum(r.get("tokens", 0) for r in results)
        total_cost = sum(r.get("cost", 0) for r in results)
        total_cycles = sum(r.get("cycles", 1) for r in results)
        
        return {
            "completion_rate": successful / len(results) if results else 0,
            "avg_tokens": total_tokens / len(results) if results else 0,
            "avg_cost": total_cost / len(results) if results else 0,
            "avg_cycles": total_cycles / len(results) if results else 0,
        }
    
    def make_recommendation(self, deltas: dict, significant: bool) -> str:
        """Make deployment recommendation."""
        
        if not significant:
            return "NO_CHANGE: Differences not statistically significant"
        
        # Check if candidate is better
        completion_improved = deltas.get("completion_rate", 0) > 0
        cost_reduced = deltas.get("avg_cost", 0) < 0
        efficiency_improved = deltas.get("avg_cycles", 0) < 0
        
        if completion_improved and cost_reduced:
            return "DEPLOY: Candidate improves completion and reduces cost"
        elif completion_improved:
            return "DEPLOY_WITH_MONITORING: Candidate improves completion but costs more"
        elif cost_reduced:
            return "DEPLOY_WITH_MONITORING: Candidate reduces cost but completion may drop"
        else:
            return "REVERT: Candidate performs worse on key metrics"
```

### Sample A/B Test Report

```
A/B Test Report: v2.1 vs v2.2
Date: 2025-01-15
Tasks: 100 (50 control, 50 candidate)

=== Results ===

Metric              Control    Candidate    Delta     Status
─────────────────────────────────────────────────────────────
Completion Rate     92.0%      94.0%        +2.2%     PASS
Accuracy            87.0%      85.0%        -2.3%     WARN
Avg Cycles          6.2        5.1          -17.7%    PASS
Avg Tokens          8,500      7,200        -15.3%    PASS
Avg Cost            $0.45      $0.38        -15.6%    PASS
Self-Heal Rate      55.0%      62.0%        +12.7%    PASS
HITL Rate           25.0%      22.0%        -12.0%    PASS
First Response      1.2s       1.1s         -8.3%     PASS
User Satisfaction   4.1/5      4.3/5        +4.9%     PASS

=== Statistical Significance ===

Completion Rate: p=0.03 (significant)
Accuracy: p=0.08 (not significant)
Cost: p=0.01 (significant)

=== Recommendation ===

DEPLOY_WITH_MONITORING

Rationale:
- Completion rate improved significantly (+2.2%)
- Cost reduced significantly (-15.6%)
- Accuracy slightly lower but within tolerance (-2.3% < 5% threshold)
- Recommend monitoring accuracy closely for first 48 hours

=== Action Items ===

1. Deploy v2.2 to 10% of traffic
2. Monitor accuracy metric for 24 hours
3. If accuracy stays within tolerance, increase to 50%
4. If accuracy drops further, rollback to v2.1
```

## Regression Gate

### Automated Regression Checking

```python
class RegressionGate:
    def __init__(self, baseline_metrics: dict):
        self.baseline = baseline_metrics
        self.thresholds = {
            "block": 0.10,      # > 10% regression = block
            "warn": 0.05,       # 5-10% regression = warn
            "tolerance": 0.02   # < 2% regression = ignore
        }
    
    def check(self, new_metrics: dict) -> dict:
        """Check for regressions."""
        
        regressions = []
        warnings = []
        
        for metric, baseline_value in self.baseline.items():
            if metric in new_metrics:
                new_value = new_metrics[metric]
                
                if baseline_value != 0:
                    change = (new_value - baseline_value) / baseline_value
                else:
                    change = 0
                
                # Determine if regression
                if self.is_regression(metric, change):
                    if abs(change) > self.thresholds["block"]:
                        regressions.append({
                            "metric": metric,
                            "baseline": baseline_value,
                            "current": new_value,
                            "change": change,
                            "severity": "BLOCK"
                        })
                    elif abs(change) > self.thresholds["warn"]:
                        warnings.append({
                            "metric": metric,
                            "baseline": baseline_value,
                            "current": new_value,
                            "change": change,
                            "severity": "WARN"
                        })
        
        return {
            "passed": len(regressions) == 0,
            "regressions": regressions,
            "warnings": warnings,
            "recommendation": self.make_recommendation(regressions, warnings)
        }
    
    def is_regression(self, metric: str, change: float) -> bool:
        """Check if change is a regression."""
        
        # For these metrics, increase is good
        positive_is_good = ["completion_rate", "accuracy", "self_heal_rate"]
        
        # For these metrics, decrease is good
        negative_is_good = ["avg_cost", "avg_cycles", "avg_tokens", "hitl_rate"]
        
        if metric in positive_is_good:
            return change < 0  # Decrease is regression
        elif metric in negative_is_good:
            return change > 0  # Increase is regression
        
        return False
    
    def make_recommendation(self, regressions: list, warnings: list) -> str:
        """Make recommendation based on regressions."""
        
        if regressions:
            return "BLOCK: Critical regressions detected"
        elif warnings:
            return "WARN: Minor regressions detected, human approval required"
        else:
            return "ALLOW: No significant regressions"
```

### Regression Gate Rules

```
Regression Gate Decision Tree:

1. Check each metric against baseline
   ├── Metric improved > 2%    → POSITIVE (no action needed)
   ├── Metric changed < 2%     → NEUTRAL (within tolerance)
   ├── Metric regressed 2-5%   → MINOR (log, continue)
   ├── Metric regressed 5-10%  → WARN (require human approval)
   └── Metric regressed > 10%  → BLOCK (stop deployment)

2. Special cases
   ├── New failure mode detected → BLOCK regardless of metrics
   ├── Security regression       → BLOCK regardless of metrics
   └── Cost increased > 20%      → WARN regardless of other improvements

3. Override rules
   ├── Emergency fix             → ALLOW with rollback plan
   ├── Security patch            → ALLOW with monitoring
   └── Business-critical feature → ALLOW with staged rollout
```

## Evaluation Dashboard

### Real-Time Evaluation

```python
class EvaluationDashboard:
    def __init__(self):
        self.metrics_history = defaultdict(list)
        self.alerts = []
    
    def record_task(self, task_id: str, result: dict):
        """Record task result for evaluation."""
        
        self.metrics_history["completion_rate"].append(
            1.0 if result.get("success") else 0.0
        )
        self.metrics_history["tokens"].append(result.get("tokens", 0))
        self.metrics_history["cost"].append(result.get("cost", 0))
        self.metrics_history["cycles"].append(result.get("cycles", 1))
        self.metrics_history["duration"].append(result.get("duration", 0))
        
        # Check for anomalies
        self.check_anomalies()
    
    def check_anomalies(self):
        """Check for metric anomalies."""
        
        for metric, values in self.metrics_history.items():
            if len(values) < 10:
                continue
            
            recent = values[-10:]
            historical = values[:-10]
            
            if historical:
                historical_mean = sum(historical) / len(historical)
                recent_mean = sum(recent) / len(recent)
                
                # Check for significant deviation
                if historical_mean != 0:
                    deviation = abs(recent_mean - historical_mean) / historical_mean
                    
                    if deviation > 0.2:  # 20% deviation
                        self.alerts.append({
                            "metric": metric,
                            "recent_mean": recent_mean,
                            "historical_mean": historical_mean,
                            "deviation": deviation,
                            "timestamp": datetime.now()
                        })
    
    def get_summary(self) -> dict:
        """Get evaluation summary."""
        
        summary = {}
        
        for metric, values in self.metrics_history.items():
            if values:
                summary[metric] = {
                    "current": values[-1],
                    "mean": sum(values) / len(values),
                    "min": min(values),
                    "max": max(values),
                    "trend": self.calculate_trend(values)
                }
        
        return summary
    
    def calculate_trend(self, values: list) -> str:
        """Calculate metric trend."""
        
        if len(values) < 5:
            return "insufficient_data"
        
        recent = sum(values[-5:]) / 5
        older = sum(values[-10:-5]) / 5 if len(values) >= 10 else sum(values[:-5]) / max(1, len(values) - 5)
        
        if recent > older * 1.05:
            return "improving"
        elif recent < older * 0.95:
            return "degrading"
        else:
            return "stable"
```
