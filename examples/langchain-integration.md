# LangChain Integration Example

## Overview

Example of integrating Prometheus Loop with LangChain for building agentic systems.

## Installation

```bash
pip install langchain langchain-openai prometheus-loop
```

## Basic Integration

```python
from langchain.agents import AgentExecutor, create_openai_tools_agent
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate

# Import Prometheus Loop components
from prometheus_loop import (
    BasicAgent,
    SelfHealingSystem,
    SelfMonitoringSystem,
    SelfRetrySystem
)

# Initialize LangChain
llm = ChatOpenAI(model="gpt-4")
tools = [...]  # Your LangChain tools

# Initialize Prometheus Loop
healer = SelfHealingSystem()
monitor = SelfMonitoringSystem()
retry = SmartRetrySystem()

# Create agent
class LangChainAgent:
    def __init__(self):
        self.llm = llm
        self.tools = tools
        self.healer = healer
        self.monitor = monitor
        self.retry = retry
    
    def run(self, task: str) -> dict:
        # Monitor execution
        self.monitor.record_metric("task_started", 1)
        
        # Execute with retry and healing
        try:
            result = self.retry.execute_with_retry(
                lambda: self.execute_task(task),
                {"service": "langchain"}
            )
            
            self.monitor.record_metric("task_completed", 1)
            return result
            
        except Exception as e:
            # Try self-healing
            healing_result = self.healer.handle_error(e, {
                "action": lambda: self.execute_task(task)
            })
            
            self.monitor.record_metric("task_healed", 1 if healing_result["healed"] else 0)
            
            return healing_result
    
    def execute_task(self, task: str) -> dict:
        """Execute task using LangChain."""
        
        prompt = ChatPromptTemplate.from_messages([
            ("system", "You are a helpful assistant."),
            ("human", task)
        ])
        
        agent = create_openai_tools_agent(llm, tools, prompt)
        executor = AgentExecutor(agent=agent, tools=tools)
        
        return executor.invoke({"input": task})
```

## Usage

```python
agent = LangChainAgent()
result = agent.run("Fix the failing test")
print(result)
```
