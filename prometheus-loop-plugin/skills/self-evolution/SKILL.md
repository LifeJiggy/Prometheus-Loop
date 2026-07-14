---
name: self-evolution
description: Acquire new skills, adapt architecture, and evolve capabilities over time
---

# Self-Evolution

The agent's ability to adapt its architecture and capabilities to handle new domains.

## Quick Start

When the user asks about making agents handle new tasks:

1. **Detect gap** — identify missing capabilities
2. **Learn** — acquire new skill from task patterns
3. **Test** — verify new capability works
4. **Register** — add to capability library

## Usage

```python
evolver = SelfEvolutionSystem(llm=my_llm)

# Attempt to acquire new capability
result = evolver.acquire("image_processing", {
    "type": "analyze_photo",
    "input": "photo.jpg"
})

if result["acquired"]:
    print(f"Learned: {result['capability']}")
```

## Further Reading

- [Full implementation](../shared/self/self-evolution.md) — Skill discovery, architecture adaptation
