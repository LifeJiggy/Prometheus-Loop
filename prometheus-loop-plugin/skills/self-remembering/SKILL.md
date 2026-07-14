---
name: self-remembering
description: Memory lifecycle management - store, retrieve, consolidate, and forget intelligently
---

# Self-Remembering

The agent's ability to manage its own memory lifecycle.

## Quick Start

When the user asks about agent memory:

1. **Filter** — decide what to remember
2. **Score** — assess relevance
3. **Store** — save to memory
4. **Retrieve** — find relevant memories
5. **Consolidate** — merge related memories
6. **Forget** — remove stale memories

## Memory Types

| Type | Purpose | Lifetime |
|---|---|---|
| **Working** | Current task context | Session |
| **Episodic** | Past experiences | Long-term |
| **Semantic** | Facts and knowledge | Persistent |
| **Procedural** | How to do things | Persistent |

## Usage

```python
rememberer = SelfRememberingSystem(llm=my_llm)

# Remember something
rememberer.remember({
    "type": "preference",
    "content": "User prefers dark mode",
    "importance": 0.8
})

# Recall relevant memories
memories = rememberer.recall({"type": "preference"})

# Consolidate periodically
rememberer.consolidate()
```

## Further Reading

- [Full implementation](../shared/self/self-remembering.md) — Consolidation, forgetting, validation
- [Memory Systems](../shared/memory-systems.md) — Vector stores, graph memory
