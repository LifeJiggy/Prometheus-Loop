---
name: self-observing
description: Decision tracing, meta-cognition, and self-reflection
---

# Self-Observing

The agent's ability to monitor its own reasoning process and reflect on its behavior.

## Quick Start

When the user asks about understanding agent decisions:

1. **Trace decisions** — record what was decided and why
2. **Track reasoning** — log the reasoning chain
3. **Analyze outcomes** — compare expected vs actual
4. **Extract lessons** — identify what worked/didn't
5. **Update confidence** — adjust confidence levels

## Usage

```python
observer = SelfObservingSystem()

# Set up observation
obs = observer.observe_task({"type": "code_generation", "prompt": "Write a parser"})

# Record decisions
observer.record_decision({
    "type": "tool_selection",
    "choice": "python_parser",
    "reason": "Task involves Python code"
})

# Complete observation
result = observer.complete_observation({"success": True})

# Get insights
insights = observer.get_insights()
print(f"Success rate: {insights['success_rate']:.1%}")
```

## Further Reading

- [Full implementation](../shared/self/self-observing.md) — Meta-cognition, behavior tracking
