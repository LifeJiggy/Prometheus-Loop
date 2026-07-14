---
name: self-planning
description: Autonomous goal decomposition, plan generation, and adaptive replanning
---

# Self-Planning

The agent's ability to autonomously create, adapt, and execute plans for complex tasks.

## Quick Start

When the user asks about handling complex tasks:

1. **Analyze goal** — understand what needs to be done
2. **Decompose** — break into ordered sub-tasks
3. **Execute** — work through the plan step by step
4. **Track progress** — monitor completion
5. **Replan** — adjust if something goes wrong

## Planning Patterns

| Pattern | When to use |
|---|---|
| **Sequential** | Tasks with clear ordering |
| **Parallel** | Independent sub-tasks |
| **Hierarchical** | Large tasks with sub-sub-tasks |
| **Adaptive** | Tasks that change based on results |

## Usage

```python
planner = SelfPlanningSystem(llm=my_llm)

# Create plan
plan = planner.create_plan("Implement user authentication")
print(f"Plan has {len(plan['steps'])} steps")

# Execute steps
for step in plan["steps"]:
    result = planner.execute_step(plan["id"], step["id"])
    if not result["success"]:
        # Replan if needed
        planner.replan(plan["id"], result)
```

## Further Reading

- [Full implementation](../shared/self/self-planning.md) — Hierarchical planning, dynamic replanning
- [Planning & Reasoning](../shared/planning-reasoning.md) — CoT, ToT, ReAct techniques
