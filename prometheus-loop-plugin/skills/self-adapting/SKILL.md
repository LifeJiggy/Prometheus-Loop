---
name: self-adapting
description: Context-aware behavior adjustment and configuration adaptation
---

# Self-Adapting

The agent's ability to adjust behavior, strategies, and configurations based on changing context.

## Quick Start

When the user asks about making agents work in different environments:

1. **Detect context** — identify environmental changes
2. **Select strategy** — choose appropriate behavior
3. **Adapt config** — adjust parameters
4. **Verify** — confirm adaptation worked

## Adaptation Triggers

| Trigger | Response |
|---|---|
| **High load** | Reduce batch size, increase timeouts |
| **Low resources** | Use cheaper model, compress context |
| **New environment** | Load environment-specific config |
| **Performance degradation** | Switch to more reliable strategy |

## Usage

```python
adapter = SelfAdaptingSystem()

# Register strategies
adapter.strategy_selector.register_strategy(
    "high_load",
    {"concurrency": 2, "batch_size": 5},
    {"load": "high"}
)

# Detect and adapt
result = adapter.detect_and_adapt({"load": "high"})
if result["adapted"]:
    print(f"Adapted: {result['strategy']}")
```

## Further Reading

- [Full implementation](../shared/self/self-adapting.md) — Model selection, load balancing
- [Self-Monitoring](self-monitoring.md) — Detect when adaptation is needed
