# /loop — Agentic AI Loop Command

Use this command to interact with the Prometheus Loop framework.

## Usage

```
/loop guide          # Show the 7-step loop overview
/loop self           # Show self-* capabilities summary
/loop [capability]   # Show specific capability (e.g., /loop self-healing)
/loop example [v1|v2|v3]  # Show example for specific loop version
```

## What it does

When the user types `/loop`, provide:

1. **Loop overview** — the 7-step framework
2. **Self-* capabilities** — 13 autonomous capabilities
3. **Examples** — real-world use cases for each version
4. **Deep dives** — links to detailed implementations

## The 7-Step Loop

```
Prompt → Context → Plan → Reason → Act → Observe → Store/Remember → (loop)
```

## Self-* Capabilities by Layer

| Layer | Capabilities |
|---|---|
| Detection | Self-Monitoring, Self-Observing |
| Diagnosis | Self-Debugging, Self-Healing |
| Adaptation | Self-Adapting, Self-Retry, Self-Planning |
| Evolution | Self-Improving, Self-Evolution, Self-Refactoring |
| Governance | Self-Governing, Multi-Agent, Self-Remembering |

## Loop Versions

| Version | Adds | Use when |
|---|---|---|
| **v1 (Core)** | Basic 7-step loop | Teaching, prototyping |
| **v2 (Production)** | Safety, HITL, retry, goal check | Real deployments |
| **v3 (Autonomous)** | Self-healing, learning, adaptation | Minimal oversight |

## Quick Examples

```python
# v1: Simple agent
agent = AgenticLoop(llm, tools, memory)
result = agent.run("Fix the failing test")

# v2: With safety
governor = SelfGoverningSystem()
governor.setup_default_policies()
result = governor.check_action(action)

# v3: With self-healing
healer = SelfHealingSystem()
healing = healer.handle_error(error, context)
```

## File Locations

- **Guides**: `core/`, `production/`, `autonomous/`
- **Deep dives**: `shared/self/` (13 capabilities, 700+ lines each)
- **Examples**: `examples/` (8 case studies)
- **Summaries**: `core-only/` (quick reference)
