# Quick Reference Card

## The 7-Step Loop

```
Prompt → Context → Plan → Reason → Act → Observe → Store/Remember → (loop)
```

## Self-* Capabilities

| Layer | Capabilities | One-liner |
|---|---|---|
| **Detection** | Self-Monitoring, Self-Observing | Track metrics, trace decisions |
| **Diagnosis** | Self-Debugging, Self-Healing | Fix errors, recover from failures |
| **Adaptation** | Self-Adapting, Self-Retry, Self-Planning | Adjust to context, retry smart, plan ahead |
| **Evolution** | Self-Improving, Self-Evolution, Self-Refactoring | Learn, grow, clean up |
| **Governance** | Self-Governing, Multi-Agent, Self-Remembering | Enforce rules, coordinate, remember |

## Key Concepts

| Concept | Definition |
|---|---|
| **Context Window** | Maximum text a model can process |
| **Token** | Unit of text (~4 characters) |
| **RAG** | Retrieval-Augmented Generation |
| **HITL** | Human-in-the-Loop |
| **Circuit Breaker** | Stops calling failing services |
| **Self-Healing** | Automatic error recovery |

## Common Patterns

| Pattern | When to Use |
|---|---|
| **Retry with backoff** | Transient errors |
| **Circuit breaker** | Service failures |
| **Fallback** | Alternative approaches |
| **Caching** | Repeated queries |
| **Batching** | Multiple similar operations |

## Maturity Levels

| Level | Adds | Use When |
|---|---|---|
| **Concept** | Basic loop | Teaching, prototyping |
| **Production** | Safety, HITL, retry | Real deployments |
| **Autonomous** | Self-healing, learning | Minimal oversight |

## Quick Commands

```bash
# Install plugin
bash install.sh --all

# Use in CLI/IDE
/loop                    # Overview
/loop self-healing       # Specific capability
/loop guide              # Implementation guide
```
