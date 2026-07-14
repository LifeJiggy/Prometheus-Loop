# Production

The safety-hardened agentic loop. Use this for real deployments.

## What this covers

Everything in Core, plus:
- Permission Gate (authorization)
- Human-in-the-Loop (approval)
- Retry vs. Replan (failure handling)
- Goal Check (termination)
- Coordinator (multi-agent)
- Security at gate level
- Unit, integration, chaos, regression tests
- Explainability (decision traces, audit logs)
- Resource management (concurrency, scheduling)
- Lifecycle (deployment, monitoring, incident response)
- UX (progress, transparency, correction)
- Streaming basics
- Composition basics
- Ethics basics

## Files

| File | Description |
|---|---|
| `agentic-ai-loop-v2-guide.md` | Full guide with implementation patterns |
| `agentic-ai-loop-v2.mermaid` | Full diagram with 9 cross-cutting subgraphs |
| `agentic-ai-loop-v2-core.mermaid` | Simplified diagram (loop + safety only) |

## When to use

- Deploying against real systems
- Multi-agent orchestration
- High-stakes or irreversible actions
- Production with human oversight

## Deep dives

- [Memory Systems](../shared/memory-systems.md)
- [Planning & Reasoning](../shared/planning-reasoning.md)
- [Safety & Guardrails](../shared/safety-guardrails.md)
- [Multi-Agent Orchestration](../shared/multi-agent-orchestration.md)
- [Evaluation Framework](../shared/evaluation-framework.md)
- [Production Concerns](../shared/production-concerns.md)
- [Observability](../shared/observability.md)
- [Cost Optimization](../shared/cost-optimization.md)
- [Ethics & Compliance](../shared/ethics-compliance.md)
