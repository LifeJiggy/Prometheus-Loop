# Migration Guide

## Migrating from Other Frameworks

### From LangChain

```python
# Before (LangChain)
from langchain.agents import AgentExecutor
agent = AgentExecutor(agent=agent, tools=tools)
result = agent.invoke({"input": task})

# After (Prometheus Loop)
from prometheus_loop import BasicAgent
agent = BasicAgent(llm, tools, memory)
result = agent.run(task)
```

### From CrewAI

```python
# Before (CrewAI)
from crewai import Agent, Task, Crew
agent = Agent(role="Researcher", goal="Research")
task = Task(description="Research topic", agent=agent)
crew = Crew(agents=[agent], tasks=[task])
result = crew.kickoff()

# After (Prometheus Loop)
from prometheus_loop import MultiAgentOrchestrator
orchestrator = MultiAgentOrchestrator()
orchestrator.register_agent("researcher", researcher, ["research"])
task_id = orchestrator.submit_task({"type": "research", "topic": "AI trends"})
result = orchestrator.execute()
```

### From AutoGPT

```python
# Before (AutoGPT)
from autogpt import Agent
agent = Agent()
result = agent.run(task)

# After (Prometheus Loop)
from prometheus_loop import BasicAgent
agent = BasicAgent(llm, tools, memory)
result = agent.run(task)
```

## Migrating Between Versions

### v1 to v2

```python
# v1
agent = BasicAgent(llm, tools, memory)
result = agent.run(task)

# v2
from prometheus_loop import BasicAgent, PermissionGate, HITL
gate = PermissionGate()
hitl = HITL()
agent = BasicAgent(llm, tools, memory, gate, hitl)
result = agent.run(task)
```

### v2 to v3

```python
# v2
agent = BasicAgent(llm, tools, memory, gate, hitl)
result = agent.run(task)

# v3
from prometheus_loop import (
    BasicAgent, PermissionGate, HITL,
    SelfHealingSystem, SelfImprovementSystem
)
healer = SelfHealingSystem()
improver = SelfImprovementSystem()
agent = BasicAgent(llm, tools, memory, gate, hitl, healer, improver)
result = agent.run(task)
```

## Data Migration

### Exporting from Other Frameworks

```python
# Export from LangChain
def export_langchain(agent):
    return {
        "config": agent.config,
        "tools": agent.tools,
        "memory": agent.memory
    }

# Import to Prometheus Loop
def import_to_prometheus(data):
    return BasicAgent(
        llm=data["config"]["llm"],
        tools=data["tools"],
        memory=data["memory"]
    )
```

## Testing After Migration

1. Run existing test suite
2. Compare metrics with previous framework
3. Verify all features work correctly
4. Check performance benchmarks
5. Review security implications
