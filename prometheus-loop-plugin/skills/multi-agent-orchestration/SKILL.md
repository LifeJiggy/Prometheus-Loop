---
name: multi-agent-orchestration
description: Coordinate multiple agents for complex distributed tasks
---

# Multi-Agent Orchestration

Coordinating multiple specialized agents to accomplish complex tasks.

## Quick Start

When the user asks about multi-agent systems:

1. **Register agents** — define capabilities
2. **Route tasks** — match tasks to agents
3. **Execute** — run in parallel
4. **Resolve conflicts** — handle disagreements
5. **Aggregate results** — combine outputs

## Patterns

| Pattern | When to use |
|---|---|
| **Fan-out/fan-in** | Independent parallel tasks |
| **Pipeline** | Sequential dependent tasks |
| **Competitive** | Best result wins |
| **Specialist** | Route by capability |

## Usage

```python
orchestrator = MultiAgentOrchestrator()

# Register agents
orchestrator.register_agent("coder", CoderAgent(), ["coding", "debugging"])
orchestrator.register_agent("tester", TesterAgent(), ["testing"])

# Submit and execute
task_id = orchestrator.submit_task({"type": "code_review"})
results = orchestrator.execute()
```

## Further Reading

- [Full implementation](../shared/self/multi-agent-orchestration.md) — Agent registry, task routing
- [Multi-Agent Patterns](../shared/multi-agent-patterns.md) — Communication protocols
