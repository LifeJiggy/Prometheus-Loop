---
name: prometheus-loop-guide
description: Core agentic AI loop guide with 7-step framework, self-* capabilities, and implementation patterns
---

# Prometheus Loop Guide

The foundational agentic AI loop with 7 steps: Prompt, Context, Plan, Reason, Act, Observe, Store/Memory.

## Quick Start

When the user asks about building an agent, use this guide:

1. **Understand the loop** — 7 steps that form the core of any agent
2. **Add safety layers** — Permission Gate, HITL, Retry (v2)
3. **Add autonomy** — Self-Healing, Self-Planning, Self-Improvement (v3)

## The 7-Step Loop

```
Prompt → Context → Plan → Reason → Act → Observe → Store/Remember → (loop)
```

### Step 1: Prompt
The instruction that kicks off a cycle. Includes user message, system prompt, tool definitions, and few-shot examples.

### Step 2: Context
Everything pulled in before reasoning: RAG documents, conversation history, live data, tool outputs, memory from previous cycles.

### Step 3: Plan
Break the goal into ordered sub-tasks. Skip on simple tasks; keep for anything with more than one moving part.

### Step 4: Reason
Chain-of-thought, weighing options, deciding what to do next. This is the inference step.

### Step 5: Act
Call an API, run code, write a file, send a request. No action step means no agent.

### Step 6: Observe
Capture what happened — success, failure, returned data, side effects.

### Step 7: Storage & Memory
- **Storage**: Raw persistence (logs, artifacts, DB)
- **Memory**: Curated subset pulled back into Context next cycle

## Self-* Capabilities

| Layer | Capabilities |
|---|---|
| **Detection** | Self-Monitoring, Self-Observing |
| **Diagnosis** | Self-Debugging, Self-Healing |
| **Adaptation** | Self-Adapting, Self-Retry, Self-Planning |
| **Evolution** | Self-Improving, Self-Evolution, Self-Refactoring |
| **Governance** | Self-Governing, Multi-Agent, Self-Remembering |

## Usage Examples

```python
# Basic agent loop
agent = AgenticLoop(llm, tools, memory)
result = agent.run("Fix the failing test")

# With self-healing
healer = SelfHealingSystem()
try:
    result = api_call()
except Exception as e:
    healing_result = healer.handle_error(e, {"action": api_call})

# With self-improving
improver = SelfImprovementSystem()
improver.record_task(task, result, metrics)
recommendation = improver.get_recommendation(new_task)
```

## Further Reading

- [Self-Healing](../shared/self/self-healing.md) — Error diagnosis and recovery
- [Self-Planning](../shared/self/self-planning.md) — Goal decomposition and plan generation
- [Self-Improving](../shared/self/self-improving.md) — Learning from successes and failures
- [Safety & Guardrails](../shared/safety-guardrails.md) — Threat modeling and protection
