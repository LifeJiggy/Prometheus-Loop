# Core-Only Diagrams

Simplified diagrams showing just the essential loop — no cross-cutting concerns. Use these when you need to explain the basic shape quickly.

## Files

| File | Description | Nodes |
|---|---|---|
| `agentic-ai-loop-core.mermaid` | v1 core loop (Concept level) | 8 |
| `agentic-ai-loop-v2-core.mermaid` | v2 core loop with safety (Production level) | 11 |
| `agentic-ai-loop-v3-core.mermaid` | v3 core loop with autonomy (Autonomous level) | 14 |

## How these differ from the full diagrams

| Diagram | What it shows | When to use |
|---|---|---|
| **Core-only** | Essential loop only, 10-15 nodes | Quick explanations, teaching, presentations |
| **Full diagrams** | Loop + all cross-cutting concerns | Implementation, deep dives, reference |

## v1 Core Loop

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

**The 7-step loop:** Prompt → Context → Plan → Reason → Act → Observe → Storage → Memory (loop back to Context)

## v2 Core Loop (with Safety)

```mermaid
flowchart TD
    A["1. Prompt"] --> B["2. Context"]
    B --> C["3. Plan"]
    C --> D["4. Reason"]
    D --> E{"5. Permission Gate"}
    E -->|allowed| F["6. Act"]
    E -->|high-stakes| HITL["Human approval"]
    HITL -->|approved| F
    HITL -->|rejected| C
    F --> G["7. Observe"]
    G -->|error| RETRY["Retry"]
    RETRY --> F
    G -->|plan wrong| C
    G -->|success| H{"8. Done?"}
    H -->|not done| I["9. Storage"]
    H -->|done| I
    I --> J["Memory"]
    J -.next cycle.-> B
```

**v2 additions:** Permission Gate, HITL, Retry, Goal Check

## v3 Core Loop (with Autonomy)

```mermaid
flowchart TD
    A["1. Prompt"] --> B["2. Context"]
    B --> C["3. Plan"]
    C --> D["4. Reason"]
    D --> E{"5. Permission Gate"}
    E -->|allowed| V{"6. Verify"}
    E -->|high-stakes| HITL["Human approval"]
    HITL -->|approved| V
    HITL -->|rejected| C
    V -->|passes| F["7. Act"]
    V -->|fails| C
    F --> G{"8. Observe"}
    G -->|error| RETRY["Retry"]
    RETRY --> F
    G -->|plan wrong| C
    G -->|self-healable| SH["Self-Heal"]
    SH --> F
    G -->|success| H{"9. Done?"}
    H -->|not done| I["10. Store"]
    H -->|done| I
    I --> J["Memory"]
    J --> PM["Persistent Memory"]
    PM -.next session.-> B
    J -.next cycle.-> C
```

**v3 additions:** Verify step, Self-Heal, Persistent Memory

## Related resources

| Resource | Description |
|---|---|
| [Core guide](../core/agentic-ai-loop-guide.md) | Full explanations for v1 loop |
| [Production guide](../production/agentic-ai-loop-v2-guide.md) | Full explanations for v2 loop |
| [Autonomous guide](../autonomous/agentic-ai-loop-v3-guide.md) | Full explanations for v3 loop |
| [Self-* capabilities](../shared/self/README.md) | 13 autonomous capabilities deep dives |
| [Shared resources](../shared/README.md) | Memory, planning, safety, evaluation deep dives |
