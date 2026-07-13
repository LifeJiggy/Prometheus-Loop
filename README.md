# Prometheus Loop — Agentic AI Loop Guide & Diagrams

A comprehensive breakdown of what actually happens inside an agentic AI system — from the initial prompt to persisted memory — across three maturity levels: **Concept**, **Production**, and **Autonomous**. Now includes security, evaluation, testing, explainability, resource management, lifecycle, UX, streaming, ethics, and agent-as-a-service patterns.

This is the reference for building, teaching, or reasoning about agentic AI systems. It covers both the conceptual model (what the loop *is*) and the operational model (what you need to run it safely, autonomously, and securely).

## Repository Structure

```
Prometheus-Loop/
├── core/                          # Concept level (v1)
│   ├── README.md
│   ├── agentic-ai-loop-guide.md
│   ├── agentic-ai-loop.mermaid
│   └── agentic-ai-loop-core.mermaid
├── production/                    # Production level (v2)
│   ├── README.md
│   ├── agentic-ai-loop-v2-guide.md
│   ├── agentic-ai-loop-v2.mermaid
│   └── agentic-ai-loop-v2-core.mermaid
├── autonomous/                    # Autonomous level (v3)
│   ├── README.md
│   ├── agentic-ai-loop-v3-guide.md
│   ├── agentic-ai-loop-v3.mermaid
│   └── agentic-ai-loop-v3-core.mermaid
├── shared/                        # Common resources
│   ├── README.md
│   ├── evaluation-metrics.md
│   ├── observability.md
│   ├── cost-optimization.md
│   ├── ethics-compliance.md
│   └── multi-agent-patterns.md
├── examples/                      # Code snippets & case studies
│   ├── README.md
│   ├── code-snippets.md
│   ├── coding-agent-case-study.md
│   ├── research-agent-case-study.md
│   └── support-agent-case-study.md
├── LICENSE                        # MIT License
└── README.md                      # This file
```

## Quick Start

| Level | Best for | Start here |
|---|---|---|
| **Concept** (v1) | Teaching, prototyping | `core/README.md` |
| **Production** (v2) | Real deployments, human oversight | `production/README.md` |
| **Autonomous** (v3) | Minimal oversight, cost-sensitive | `autonomous/README.md` |

## How to view the diagrams

The diagrams are embedded below and render automatically on GitHub, Notion, Obsidian, and any Mermaid-compatible renderer. Each version has two diagrams:
- **Core** — simplified loop only (10 nodes, readable in 10 seconds)
- **Full** — loop + all cross-cutting concerns (comprehensive)

The `.mermaid` source files are also included for standalone use or editing at [mermaid.live](https://mermaid.live).

---

## v1 — Core Loop

The 7-step agentic loop: Prompt, Context, Plan, Reason, Act, Observe, Store/Memory, with foundational security awareness, evaluation metrics, and ethical considerations.

```mermaid
flowchart LR
    subgraph INPUT["Trigger"]
        A["1. Prompt: goal + system rules + tool defs"]
    end

    subgraph COGNITION["Cognitive Core"]
        B["2. Context: retrieved data, history, live inputs"]
        C["3. Plan: decompose goal to sub-tasks"]
        D["4. Reason: chain-of-thought, decide next move"]
    end

    subgraph EXECUTION["Execution Loop"]
        E["5. Act: call tool / API / run code"]
        F["6. Observe: capture result, success or failure"]
    end

    subgraph PERSIST["Persistence Layer"]
        G["7. Storage: raw logs, artifacts, DB"]
        H["Memory: curated, retrievable state"]
    end

    subgraph SECURITY["Security Awareness"]
        S1["Prompt injection: user input hijack"]
        S2["Indirect injection: adversarial RAG content"]
        S3["Tool abuse: unintended tool calls"]
    end

    subgraph EVAL["Evaluation"]
        E1["Completion rate: % tasks finished"]
        E2["Accuracy: % correct results"]
        E3["Cycle count: avg loops per task"]
    end

    subgraph QUALITY["Testing + Ethics"]
        T1["Smoke tests: 3 patterns"]
        T2["Health signals: cycle, token, output"]
        ETH["Ethics: transparency, harm, oversight"]
    end

    A --> B --> C --> D --> E --> F
    F --> G
    G --> H
    H -.next cycle.-> B
    F -.replan if failed.-> C

    SECURITY -.defends.-> E
    EVAL -.measures.-> F
    QUALITY -.validates.-> D

    style INPUT fill:#1a1a2e,color:#fff,stroke:#e94560
    style COGNITION fill:#16213e,color:#fff,stroke:#0f3460
    style EXECUTION fill:#0f3460,color:#fff,stroke:#e94560
    style PERSIST fill:#1a1a2e,color:#fff,stroke:#0f3460
    style SECURITY fill:#3d0000,color:#fff,stroke:#e94560,stroke-dasharray: 5 5
    style EVAL fill:#16213e,color:#fff,stroke:#0f3460,stroke-dasharray: 5 5
    style QUALITY fill:#2d132c,color:#fff,stroke:#e94560,stroke-dasharray: 5 5
```

**Guide:** [v1 guide](agentic-ai-loop-guide.md) — full explanations, failure modes, examples for each step.

---

## v2 — Safety Layers

Adds Permission Gate, HITL, Retry vs. Replan, Goal Check, Coordinator, plus operational layers: security, testing, explainability, resources, lifecycle, UX, streaming, composition, and ethics.

```mermaid
flowchart TD
    subgraph TRIGGER["Trigger"]
        A["1. Prompt"]
    end

    subgraph COGNITION["Cognitive Core"]
        B["2. Context"]
        C["3. Plan"]
        D["4. Reason"]
    end

    subgraph COORD["Coordinator - multi-agent only"]
        direction LR
        SA1["Sub-Agent A"]
        SA2["Sub-Agent B"]
        SAn["Sub-Agent N"]
    end

    subgraph GATE["Guardrail + Security"]
        E["5. Permission Gate: in scope? authorized?"]
        HITL["Human-in-the-loop: approval"]
        SEC["Security: injection detection, tool validation, memory integrity, exfil prevention"]
    end

    subgraph EXEC["Execution Loop"]
        F["6. Act"]
        G["7. Observe"]
        RETRY["Retry: tool/transient error"]
    end

    subgraph CHECK["Goal Check"]
        H["8. Done?"]
    end

    subgraph PERSIST["Persistence Layer"]
        I["9. Storage"]
        J["Memory"]
    end

    subgraph TESTING["Testing"]
        T1["Unit tests: gate, retry, goal check"]
        T2["Integration tests: full loop e2e"]
        T3["Chaos engineering: inject failures"]
        T4["Regression tests: compare to baseline"]
    end

    subgraph EXPLAIN["Explainability"]
        X1["Decision traces: why this action?"]
        X2["Audit logs: every action logged"]
        X3["Compliance: SOC2, GDPR, HIPAA, PCI"]
    end

    subgraph RESOURCES["Resource Management"]
        R1["Concurrency: N parallel tasks"]
        R2["Priority scheduling: P0-P3"]
        R3["Backpressure: load shedding"]
        R4["Dead letter queue: failed tasks"]
    end

    subgraph LIFECYCLE["Lifecycle"]
        L1["Deployment: blue-green, canary, rolling"]
        L2["Monitoring: alerts + metrics"]
        L3["Incident response: detect to contain to fix"]
    end

    subgraph UX_DESIGN["User Experience"]
        U1["Progress visibility: what is happening"]
        U2["Transparency: why this action"]
        U3["Correction: undo, redirect, pause"]
        U4["Trust calibration: capabilities + confidence"]
    end

    subgraph STREAM["Streaming Basics"]
        ST1["Progress reporting: step updates"]
        ST2["Status messages: start, middle, end, fail"]
    end

    subgraph COMPOSE["Composition Basics"]
        CP1["Tool integration: APIs, DBs, files"]
        CP2["Webhook triggers: external events"]
        CP3["Output consumers: CI/CD, dashboards"]
    end

    subgraph ETHICS["Ethics Basics"]
        ETH1["Transparency: label agent output"]
        ETH2["Harm prevention: do not act alone on high-stakes"]
        ETH3["Oversight: human can intervene"]
    end

    A --> B --> C --> D --> E
    C -.dispatch sub-tasks.-> COORD
    COORD -.results merge.-> D
    E -->|allowed| F
    E -->|high-stakes / out of policy| HITL
    HITL -->|approved| F
    HITL -->|rejected| C
    F --> G
    G -->|tool/transient error| RETRY
    RETRY --> F
    G -->|plan was wrong| C
    G -->|success| H
    H -->|not done| I
    H -->|done| I
    I --> J
    J -.next cycle, if not done.-> B

    SEC -.validates.-> E
    TESTING -.tests.-> G
    EXPLAIN -.traces.-> D
    RESOURCES -.manages.-> F
    LIFECYCLE -.deploys.-> A
    UX_DESIGN -.presents.-> G
    STREAM -.reports.-> F
    COMPOSE -.integrates.-> F
    ETHICS -.governs.-> E

    style TRIGGER fill:#1a1a2e,color:#fff,stroke:#e94560
    style COGNITION fill:#16213e,color:#fff,stroke:#0f3460
    style COORD fill:#2d132c,color:#fff,stroke:#e94560,stroke-dasharray: 5 5
    style GATE fill:#3d0000,color:#fff,stroke:#e94560
    style EXEC fill:#0f3460,color:#fff,stroke:#e94560
    style CHECK fill:#16213e,color:#fff,stroke:#0f3460
    style PERSIST fill:#1a1a2e,color:#fff,stroke:#0f3460
    style TESTING fill:#2d132c,color:#fff,stroke:#e94560,stroke-dasharray: 5 5
    style EXPLAIN fill:#16213e,color:#fff,stroke:#0f3460,stroke-dasharray: 5 5
    style RESOURCES fill:#1a1a2e,color:#fff,stroke:#0f3460,stroke-dasharray: 5 5
    style LIFECYCLE fill:#0f3460,color:#fff,stroke:#e94560,stroke-dasharray: 5 5
    style UX_DESIGN fill:#2d132c,color:#fff,stroke:#e94560,stroke-dasharray: 5 5
    style STREAM fill:#16213e,color:#fff,stroke:#0f3460,stroke-dasharray: 5 5
    style COMPOSE fill:#1a1a2e,color:#fff,stroke:#0f3460,stroke-dasharray: 5 5
    style ETHICS fill:#3d0000,color:#fff,stroke:#e94560,stroke-dasharray: 5 5
```

**Guide:** [v2 guide](agentic-ai-loop-v2-guide.md) — full explanations, implementation patterns, checklists.

---

## v3 — Autonomous Operation

Designed to minimize human touchpoints. Full autonomous system with Self-Healing, Adaptive Planning, Cost Optimization, Cross-Session Memory, Verification, Feedback Loops, Graceful Degradation, plus 11 cross-cutting concerns.

```mermaid
flowchart TD
    subgraph TRIGGER["Trigger"]
        A["1. Prompt"]
    end

    subgraph COGNITION["Cognitive Core"]
        B["2. Context + cross-session memory"]
        C["3. Adaptive Plan + learned strategies"]
        D["4. Reason + cost-optimized model"]
    end

    subgraph GATE["Guardrail + Verification + Security"]
        E["5. Permission Gate: scope? authorized?"]
        HITL["6. Human-in-the-loop: approval"]
        V["Verify: will this work?"]
        SEC["4-Layer Defense: injection, hierarchy, output validation, monitoring"]
    end

    subgraph EXEC["Execution Loop"]
        F["7. Act: sandboxed"]
        G["8. Observe"]
        SH["Self-Heal: diagnose + fix"]
        RETRY["Retry: transient error"]
    end

    subgraph CHECK["Goal Check + Budget"]
        H["9. Done? + budget check"]
    end

    subgraph PERSIST["Persistence Layer"]
        I["10. Store"]
        J["Memory: relevance scoring + integrity"]
        PM["Persistent Memory Store: cross-session"]
    end

    subgraph LEARN["Feedback + Learning"]
        FL["Feedback Loop: learns from outcomes"]
        CO["Cost Optimizer: model selection + caching"]
    end

    subgraph DEGRAD["Graceful Degradation"]
        GD["Fallback paths: L1-L7 when components fail"]
    end

    subgraph SECURITY["Full Adversarial Robustness"]
        S1["Threat model: 5 attacker types"]
        S2["Memory integrity: signed, audited"]
        S3["Sandboxing: process, container, VM, network"]
        S4["Red team testing: injection, tool abuse, exfil, boundary"]
    end

    subgraph EVAL["Evaluation Framework"]
        EV1["Task suites: 50-100 tasks"]
        EV2["8 metrics: completion, accuracy, cost..."]
        EV3["A/B comparison: baseline vs candidate"]
        EV4["Regression gate: block if >5% regress"]
    end

    subgraph TESTING["Testing Framework"]
        TP["Test pyramid: unit to integration to E2E"]
        CH["Chaos engineering: 8 failure scenarios"]
        LD["Load testing: concurrency + breaking point"]
        PB["Property-based: safety invariants"]
    end

    subgraph EXPLAIN["Explainability + Compliance"]
        X1["Decision traces: reasoning + context + memories"]
        X2["Audit logs: complete action history"]
        X3["7 regulations: GDPR, SOC2, HIPAA, PCI, AI Act..."]
        X4["Impact assessment: pre-deployment review"]
    end

    subgraph RESOURCES["Resource Management"]
        R1["Concurrency: N parallel tasks"]
        R2["Priority scheduling: P0-P3 + SLAs"]
        R3["Backpressure: load shedding"]
        R4["Dead letter queue: failed task handling"]
    end

    subgraph LIFECYCLE["Lifecycle"]
        L1["4 deployment strategies: blue-green, canary, rolling, shadow"]
        L2["Monitoring + alerting: 5 metric thresholds"]
        L3["Incident response: detect to contain to fix to review"]
    end

    subgraph UX_DESIGN["User Experience"]
        U1["Progress visibility: real-time updates"]
        U2["Transparency: action log + reasoning"]
        U3["Correction: undo, redirect, pause, cancel"]
        U4["Trust calibration: capabilities + confidence + risk"]
    end

    subgraph STREAM["Streaming + Real-Time"]
        ST1["Event-driven architecture: event bus + workers"]
        ST2["Streaming responses: SSE/WebSocket"]
        ST3["Interrupt handling: graceful cancel + state save"]
        ST4["Long-running tasks: heartbeat, checkpoint, timeout"]
    end

    subgraph COMPOSE["Agent Composition"]
        CP1["5 communication patterns: req-res, pub-sub, queue, shared, blackboard"]
        CP2["DAG orchestration: workflow graphs"]
        CP3["Shared state: optimistic locking + conflict resolution"]
    end

    subgraph ETHICS["Ethics + Compliance"]
        ETH1["5 principles: transparency, accountability, fairness, privacy, safety"]
        ETH2["Bias testing: demographics, phrasings, edge cases"]
        ETH3["Compliance checklist: 7 regulations documented"]
    end

    subgraph API_SERVICE["Agent-as-a-Service"]
        AP1["REST API: CRUD tasks"]
        AP2["Auth + rate limiting: API keys, tiers"]
        AP3["SLA guarantees: uptime + latency"]
    end

    A --> B --> C --> D --> E
    E -->|allowed| V
    E -->|high-stakes| HITL
    HITL -->|approved| V
    HITL -->|rejected| C
    V -->|passes| F
    V -->|fails| C
    F --> G
    G -->|transient error| RETRY
    RETRY --> F
    G -->|plan wrong| C
    G -->|self-healable| SH
    SH --> F
    G -->|success| H
    H -->|not done| I
    H -->|done| I
    I --> J
    J --> PM
    PM -.next session.-> B
    J -.next cycle.-> C

    FL -.learns from.-> G
    FL -.updates.-> C
    CO -.selects model.-> D
    CO -.monitors budget.-> H
    GD -.fallback for.-> E
    GD -.fallback for.-> G
    GD -.fallback for.-> PM

    SEC -.defends.-> E
    EVAL -.measures.-> G
    TESTING -.validates.-> F
    EXPLAIN -.traces.-> D
    RESOURCES -.manages.-> F
    LIFECYCLE -.deploys.-> A
    UX_DESIGN -.presents.-> G
    STREAM -.streams.-> F
    COMPOSE -.orchestrates.-> C
    ETHICS -.governs.-> E
    API_SERVICE -.exposes.-> F

    style TRIGGER fill:#1a1a2e,color:#fff,stroke:#e94560
    style COGNITION fill:#16213e,color:#fff,stroke:#0f3460
    style GATE fill:#3d0000,color:#fff,stroke:#e94560
    style EXEC fill:#0f3460,color:#fff,stroke:#e94560
    style CHECK fill:#16213e,color:#fff,stroke:#0f3460
    style PERSIST fill:#1a1a2e,color:#fff,stroke:#0f3460
    style LEARN fill:#2d132c,color:#fff,stroke:#e94560,stroke-dasharray: 5 5
    style DEGRAD fill:#1a1a2e,color:#fff,stroke:#0f3460,stroke-dasharray: 5 5
    style SECURITY fill:#3d0000,color:#fff,stroke:#e94560,stroke-dasharray: 5 5
    style EVAL fill:#16213e,color:#fff,stroke:#0f3460,stroke-dasharray: 5 5
    style TESTING fill:#2d132c,color:#fff,stroke:#e94560,stroke-dasharray: 5 5
    style EXPLAIN fill:#1a1a2e,color:#fff,stroke:#0f3460,stroke-dasharray: 5 5
    style RESOURCES fill:#0f3460,color:#fff,stroke:#e94560,stroke-dasharray: 5 5
    style LIFECYCLE fill:#16213e,color:#fff,stroke:#0f3460,stroke-dasharray: 5 5
    style UX_DESIGN fill:#2d132c,color:#fff,stroke:#e94560,stroke-dasharray: 5 5
    style STREAM fill:#1a1a2e,color:#fff,stroke:#0f3460,stroke-dasharray: 5 5
    style COMPOSE fill:#3d0000,color:#fff,stroke:#e94560,stroke-dasharray: 5 5
    style ETHICS fill:#0f3460,color:#fff,stroke:#e94560,stroke-dasharray: 5 5
    style API_SERVICE fill:#16213e,color:#fff,stroke:#0f3460,stroke-dasharray: 5 5
```

**Guide:** [v3 guide](agentic-ai-loop-v3-guide.md) — full explanations, implementation patterns, checklists.

---

## Suggested read order

1. **`agentic-ai-loop-guide.md`** — get the shape of the loop. Each step explains *what* it does, *why* it matters, *what goes wrong*, and *real examples* of it in action.
2. **`agentic-ai-loop-v2-guide.md`** — see what's needed to run it safely. Covers guardrails, error handling, multi-agent coordination, security at the gate level, testing, explainability, resource management, lifecycle, and UX.
3. **`agentic-ai-loop-v3-guide.md`** — see how to make it autonomous and robust. Covers self-healing, adaptive planning, cost optimization, cross-session memory, full adversarial defense, evaluation framework, testing framework, streaming, composition, ethics, and agent-as-a-service.
4. **README** (you are here) — overview and quick reference.

## TL;DR

> **v1:** Prompt → Context → Plan → Reason → Act → Observe → Store/Remember → loop
> **v2:** same loop, plus permission gate, HITL, retry vs. replan, goal check, coordinator, security at the gate level, testing, explainability, resource management, lifecycle, UX.
> **v3:** same loop, designed to minimize human touchpoints — self-healing, adaptive planning, cost optimization, cross-session memory, verification, multi-tenant isolation, feedback loops, graceful degradation, full adversarial robustness, evaluation framework, testing framework, streaming, agent composition, ethics & compliance, agent-as-a-service.

## Quick reference: step-by-step

| Step | What it does | v1 | v2 | v3 |
|---|---|---|---|---|
| **1. Prompt** | Task definition + system rules + tool schemas | Core | Core | Core |
| **2. Context** | RAG + history + tool outputs + memory | Core | Core | Core + cross-session memory |
| **3. Plan** | Decompose goal → ordered sub-tasks | Core | Core | Adaptive (learns from history) |
| **4. Reason** | Chain-of-thought, tool selection, decision | Core | Core | + cost-optimized model selection |
| **5. Permission Gate** | Scope/policy/blast-radius check before action | — | New | New + adversarial defense |
| **6. HITL** | Approval for high-stakes actions | — | New | New |
| **Verify** | Pre-execution correctness check | — | — | New |
| **7. Act** | Execute: API call, code run, file write | Core | Core | Core + sandboxed |
| **8. Observe** | Capture result, detect success/failure | Core | Core | Core + self-healing |
| **Self-Heal** | Diagnose and fix known failure patterns | — | — | New |
| **9. Retry vs. Replan** | Differentiate execution error from plan error | — | New | New |
| **10. Goal Check** | Termination condition: done? budget? stuck? | — | New | New + budget awareness |
| **11. Storage** | Raw persistence: logs, artifacts, DB | Core | Core | Core |
| **12. Memory** | Curated state for future cycles | Core | Core | Core + relevance scoring + integrity checks |
| **13. Coordinator** | Multi-agent dispatch, merge, conflict resolution | — | New | New |
| **Feedback Loop** | Learn from outcomes, improve policies | — | — | New |
| **Graceful Degradation** | Continue when components fail | — | — | New |

## Cross-cutting concerns (covered across all versions)

| Concern | v1 | v2 | v3 |
|---|---|---|---|
| **Security** | Basic awareness (3 vectors, minimum posture) | Gate-level (injection detection, tool validation, memory integrity, exfil prevention) | Full adversarial robustness (4-layer defense, sandboxing, red team) |
| **Evaluation** | Basic metrics (5 signals, evaluation loop, health check) | Observability + dashboard metrics | Full framework (task suites, 8 metrics, A/B comparison, regression gates) |
| **Testing** | Smoke tests (3 patterns, basic health signals) | Unit, integration, chaos, regression tests | Full pyramid + chaos engineering (8 scenarios) + load testing + property-based |
| **Explainability** | "Why did it do this?" (manual log reading) | Decision traces, audit logs, compliance requirements | Full traces + memory attribution + counterfactuals |
| **Resources** | Not needed (single task) | Concurrency, priority scheduling, backpressure, dead letter queues | Same, production-hardened |
| **Lifecycle** | Not addressed | Deployment strategies (4 types), monitoring, incident response | Same, with rollback |
| **UX** | Not addressed | Progress, transparency, correction mechanisms, trust calibration | Same, with streaming |
| **Streaming** | Not needed | Progress reporting basics | Event-driven architecture, streaming, interrupts, long-running tasks |
| **Composition** | Not needed | Tool integration, Coordinator basics | 5 communication patterns, DAG orchestration, shared state |
| **Ethics** | 3 questions, minimum ethical posture | Ethical controls (gate, HITL, observability), compliance basics | 5 principles, bias testing, 7 regulations, impact assessment |
| **Agent-as-a-Service** | Not addressed | Not addressed | API design, auth, rate limiting, SLA tiers |

## When to use which version

| Scenario | Use |
|---|---|
| Teaching the concept of agentic AI | **v1** — simple, clear, memorable |
| Building a prototype or PoC | **v1** — get the loop working first |
| Deploying against real systems | **v2** — you need the guardrails |
| Multi-agent orchestration | **v2** — Coordinator is essential |
| High-stakes or irreversible actions | **v2** — Permission Gate + HITL are non-negotiable |
| Long-running autonomous agents | **v2** — Goal Check prevents infinite loops |
| Production with minimal oversight | **v3** — designed to minimize human touchpoints |
| Cost-sensitive deployments | **v3** — dynamic model selection saves money |
| Recurring / cross-session tasks | **v3** — cross-session memory accumulates knowledge |
| Multi-user platforms | **v3** — multi-tenant isolation is required |
| Regulated industries (finance, health) | **v3** — explainability + compliance framework required |
| Security-critical deployments | **v3** — full adversarial robustness required |
| Agent exposed as API | **v3** — agent-as-a-service patterns required |
| Real-time / interactive agents | **v3** — streaming + interrupt handling required |

## Glossary

| Term | Definition |
|---|---|
| **Adaptive Planning** | Learning from history which planning strategies work best for which task types |
| **Adversarial robustness** | Defending against attacks that try to make the agent do something harmful |
| **Agentic AI** | An AI system that can plan, act, observe, and iterate — not just respond to prompts |
| **Blast radius** | How many systems, users, or data records an action could affect |
| **Chaos engineering** | Injecting failures to test agent resilience |
| **Circuit breaker** | A retry strategy that stops attempting after N failures, preventing resource waste |
| **Coordinator** | The orchestration layer that dispatches sub-tasks to multiple agents and merges results |
| **Cross-session memory** | Persistent memory that survives across separate agent sessions |
| **Dead letter queue** | Storage for tasks that can't be completed after max retries |
| **Decision trace** | A record of why the agent made a specific decision |
| **Fan-out / fan-in** | Splitting a task into parallel sub-tasks (fan-out) and merging results (fan-in) |
| **Graceful degradation** | Continuing to operate (at reduced capability) when components fail |
| **HITL** | Human-in-the-Loop — a checkpoint where a human approves or rejects an action before execution |
| **Memory poisoning** | Adversarial content injected into the agent's memory to corrupt future decisions |
| **Permission Gate** | A pre-execution check that evaluates whether an action is authorized, in-scope, and within policy |
| **Prompt injection** | Adversarial input that hijacks the agent's behavior by overriding instructions |
| **RAG** | Retrieval-Augmented Generation — pulling external documents into context to ground the model's reasoning |
| **Red team testing** | Regularly testing agent defenses against adversarial attacks |
| **Replan** | Restarting the Plan step because the strategy was wrong (vs. Retry, which re-executes the same action) |
| **Retry** | Re-executing the same action after a transient failure (timeout, rate limit, network error) |
| **Self-healing** | Automatic diagnosis and recovery from known failure patterns without human intervention |
| **Sandboxing** | Executing agent actions in isolated environments to limit blast radius |
| **Verification** | Pre-execution checks that prove an action will produce the expected result |

---

## Shared Resources

Common resources that apply across all maturity levels:

| Resource | Description |
|---|---|
| [Evaluation & Metrics](shared/evaluation-metrics.md) | Benchmarks, metric definitions, evaluation suites, A/B comparison templates |
| [Observability & Monitoring](shared/observability.md) | LangSmith, Phoenix, structured logs, dashboards, alert rules |
| [Cost Optimization](shared/cost-optimization.md) | Model routing, caching, context compression, budget enforcement |
| [Ethics & Compliance](shared/ethics-compliance.md) | GDPR, SOC 2, HIPAA, PCI DSS, EU AI Act checklists, bias testing |
| [Multi-Agent Patterns](shared/multi-agent-patterns.md) | Communication protocols, consensus, conflict resolution, workflow orchestration |

## Examples

Concrete implementations and case studies:

| Example | Description |
|---|---|
| [Code Snippets](examples/code-snippets.md) | Python pseudocode for Permission Gate, Goal Check, Self-Healing, Adaptive Planning, Cost Optimizer, Memory Manager |
| [Coding Agent Case Study](examples/coding-agent-case-study.md) | How the loop applies to bug fixing, feature implementation, refactoring |
| [Research Agent Case Study](examples/research-agent-case-study.md) | How the loop applies to paper research, synthesis, report writing |
| [Customer Support Case Study](examples/support-agent-case-study.md) | How the loop applies to inquiry handling, troubleshooting, escalation |

## License

MIT License — see [LICENSE](LICENSE) for details.
