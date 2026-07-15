# CrewAI Integration Example

## Overview

Example of integrating Prometheus Loop with CrewAI for building multi-agent systems.

## Installation

```bash
pip install crewai prometheus-loop
```

## Basic Integration

```python
from crewai import Agent, Task, Crew

# Import Prometheus Loop components
from prometheus_loop import (
    MultiAgentOrchestrator,
    SelfMonitoringSystem,
    SelfImprovementSystem
)

# Initialize Prometheus Loop
orchestrator = MultiAgentOrchestrator()
monitor = SelfMonitoringSystem()
improver = SelfImprovementSystem()

# Define CrewAI agents
researcher = Agent(
    role="Researcher",
    goal="Research the topic thoroughly",
    backstory="Expert in finding and analyzing information"
)

writer = Agent(
    role="Writer",
    goal="Write comprehensive content",
    backstory="Expert in creating engaging content"
)

reviewer = Agent(
    role="Reviewer",
    goal="Review and improve content quality",
    backstory="Expert in content quality and accuracy"
)

# Create tasks
research_task = Task(
    description="Research the latest AI trends",
    agent=researcher
)

writing_task = Task(
    description="Write a comprehensive report based on the research",
    agent=writer
)

review_task = Task(
    description="Review and improve the report",
    agent=reviewer
)

# Create crew
crew = Crew(
    agents=[researcher, writer, reviewer],
    tasks=[research_task, writing_task, review_task],
    verbose=True
)

# Execute with monitoring
monitor.record_metric("crew_started", 1)
result = crew.kickoff()
monitor.record_metric("crew_completed", 1)

print(result)
```

## Integration with Prometheus Loop

```python
class CrewAgent:
    def __init__(self):
        self.orchestrator = orchestrator
        self.monitor = monitor
        self.improver = improver
    
    def run(self, task: str) -> dict:
        """Run crew with monitoring and improvement."""
        
        # Get recommendation from past experience
        recommendation = self.improver.get_recommendation({"task": task})
        
        # Monitor execution
        self.monitor.record_metric("crew_task_started", 1)
        
        # Create and execute crew
        crew = self.create_crew(task, recommendation)
        result = crew.kickoff()
        
        # Record for improvement
        self.improver.record_task(
            task={"task": task},
            result={"success": True, "output": str(result)},
            metrics={"duration": 0, "tokens": 0, "cost": 0}
        )
        
        self.monitor.record_metric("crew_task_completed", 1)
        
        return {"success": True, "output": str(result)}
    
    def create_crew(self, task: str, recommendation: dict) -> Crew:
        """Create crew based on task and recommendation."""
        
        # Adapt crew based on recommendation
        if recommendation.get("strategy"):
            # Use recommended configuration
            pass
        
        # Create agents and tasks
        researcher = Agent(role="Researcher", goal="Research")
        writer = Agent(role="Writer", goal="Write")
        
        research_task = Task(description=f"Research: {task}", agent=researcher)
        write_task = Task(description="Write report", agent=writer)
        
        return Crew(
            agents=[researcher, writer],
            tasks=[research_task, write_task]
        )
```

## Usage

```python
agent = CrewAgent()
result = agent.run("Research and write about AI trends")
print(result)
```
