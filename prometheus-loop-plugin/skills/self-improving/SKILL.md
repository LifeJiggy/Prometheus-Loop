---
name: self-improving
description: Learn from successes and failures to optimize strategies over time
---

# Self-Improving

The agent's ability to learn from every task and get better over time without retraining.

## Quick Start

When the user asks about making agents learn:

1. **Record tasks** — log every task execution with results
2. **Extract patterns** — identify what worked and what didn't
3. **Optimize strategies** — update approaches based on patterns
4. **Measure improvement** — track success rates over time

## Implementation

```python
class SelfImprovementSystem:
    def __init__(self, llm=None):
        self.recorder = TaskRecorder()
        self.extractor = PatternExtractor()
        self.optimizer = StrategyOptimizer(llm)
    
    def record_task(self, task: dict, result: dict, metrics: dict):
        """Record task for learning."""
        self.recorder.record(task, result, metrics)
        
        # Periodically analyze and improve
        task_type = self.recorder.classify_task(task)
        if self.recorder.get_count(task_type) % 10 == 0:
            self.analyze_and_improve(task_type)
    
    def get_recommendation(self, task: dict) -> dict:
        """Get recommendation based on learned patterns."""
        task_type = self.recorder.classify_task(task)
        
        if task_type in self.strategy_store:
            return {
                "recommendation": "use_learned_strategy",
                "strategy": self.strategy_store[task_type],
                "confidence": self.recorder.get_success_rate(task_type)
            }
        
        return {"recommendation": "use_default", "confidence": 0.5}
```

## Usage

```python
improver = SelfImprovementSystem(llm=my_llm)

# Record tasks as they complete
improver.record_task(task, result, metrics)

# Get recommendations for new tasks
recommendation = improver.get_recommendation(new_task)
```

## Further Reading

- [Full implementation](../shared/self/self-improving.md) — Pattern extraction, A/B testing
- [Self-Evolution](self-evolution.md) — Acquiring new capabilities
