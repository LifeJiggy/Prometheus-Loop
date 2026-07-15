# Core (Concept)

The foundational agentic loop. Start here if you're new to agentic AI.

> **Self-* Capabilities:** Core level focuses on understanding. For autonomous capabilities, see [self/](../shared/self/) folder.

## What this covers

- 7-step loop: Prompt, Context, Plan, Reason, Act, Observe, Store/Memory
- Basic security awareness
- Basic evaluation metrics
- Smoke testing patterns
- Explainability basics
- Ethics basics

## Architecture

```mermaid
flowchart LR
    A["1. Prompt"] --> B["2. Context"]
    B --> C["3. Plan"]
    C --> D["4. Reason"]
    D --> E["5. Act"]
    E --> F["6. Observe"]
    F --> G["7. Storage"]
    G --> H["Memory"]
    H -.next cycle.-> B
    F -.replan.-> C
```

## Core Files

| File | Description | Lines |
|---|---|---|
| `agentic-ai-loop-guide.md` | Full guide with explanations, failure modes, examples | 774 |
| `agentic-ai-loop.mermaid` | Full diagram with security, evaluation, testing subgraphs | - |
| `agentic-ai-loop-core.mermaid` | Simplified diagram (loop only, 10 nodes) | - |

## Enhancements (10 files)

| Enhancement | Description | Lines |
|---|---|---|
| `tutorial.md` | Interactive step-by-step tutorial | 150+ |
| `playground.md` | Visual examples to run | 120+ |
| `quiz.md` | Knowledge check with 10 questions | 100+ |
| `cheat-sheet.md` | Quick reference card | 80+ |
| `patterns.md` | 10 common patterns library | 200+ |
| `anti-patterns.md` | 10 anti-patterns to avoid | 180+ |
| `comparison.md` | Prometheus Loop vs LangChain/CrewAI/AutoGPT | 120+ |
| `learning-path.md` | Structured learning journey | 100+ |
| `community-examples.md` | Showcase of community contributions | 150+ |
| `code-snippets.md` | 10 essential code snippets | 200+ |

## When to use

- Teaching the concept of agentic AI
- Building a prototype or PoC
- Understanding the fundamentals before going deeper

## Shared resources for Core level

### Memory & Planning

| Resource | What you learn | Diagram |
|---|---|---|
| [Memory Systems](../shared/memory-systems.md) | Short/long-term memory, vector stores, forgetting | [mermaid](../shared/memory-systems.mermaid) |
| [Planning & Reasoning](../shared/planning-reasoning.md) | CoT, ToT, ReAct, meta-reasoning | [mermaid](../shared/planning-reasoning.mermaid) |

### Evaluation & Safety

| Resource | What you learn | Diagram |
|---|---|---|
| [Evaluation Metrics](../shared/evaluation-metrics.md) | Core metrics, evaluation suites, A/B testing | [mermaid](../shared/evaluation-metrics.mermaid) |
| [Safety & Guardrails](../shared/safety-guardrails.md) | Threat modeling, sandboxing, adversarial testing | [mermaid](../shared/safety-guardrails.mermaid) |
| [Ethics & Compliance](../shared/ethics-compliance.md) | Ethical principles, bias testing, compliance | [mermaid](../shared/ethics-compliance.mermaid) |

## Self-* capabilities for Core level

| Capability | What you learn | Deep dive | Diagram |
|---|---|---|---|
| **Self-Monitoring** | Basic metrics and health checks | [self-monitoring.md](../shared/self/self-monitoring.md) | [mermaid](../shared/self/self-monitoring.mermaid) |
| **Self-Remembering** | Simple storage and retrieval | [self-remembering.md](../shared/self/self-remembering.md) | [mermaid](../shared/self/self-remembering.mermaid) |
| **Self-Planning** | Basic goal decomposition | [self-planning.md](../shared/self/self-planning.md) | [mermaid](../shared/self/self-planning.mermaid) |

**Why these three?** They form the foundation: you need to *remember* what happened, *monitor* your performance, and *plan* your next steps.

## How it all connects

```mermaid
flowchart TD
    subgraph Core["Core Level"]
        A1["7-Step Loop"]
        A2["Basic Security"]
        A3["Basic Evaluation"]
    end

    subgraph Shared["Shared Knowledge"]
        B1["Memory Systems"]
        B2["Planning & Reasoning"]
        B3["Evaluation Metrics"]
    end

    subgraph Self["Self-* Basics"]
        C1["Self-Monitoring"]
        C2["Self-Remembering"]
        C3["Self-Planning"]
    end

    A1 --> B1
    A1 --> B2
    A3 --> B3
    A1 --> C1
    A1 --> C2
    A1 --> C3
```

## Next level

Ready to go deeper? See [Production](../production/README.md) for safety, testing, and deployment.
