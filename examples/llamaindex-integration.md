# LlamaIndex Integration Example

## Overview

Example of integrating Prometheus Loop with LlamaIndex for building RAG-based agentic systems.

## Installation

```bash
pip install llama-index llama-index-llms-openai prometheus-loop
```

## Basic Integration

```python
from llama_index.core import VectorStoreIndex, SimpleDirectoryReader
from llama_index.llms.openai import OpenAI

# Import Prometheus Loop components
from prometheus_loop import (
    BasicAgent,
    SelfHealingSystem,
    SelfMemorySystem
)

# Initialize LlamaIndex
llm = OpenAI(model="gpt-4")
documents = SimpleDirectoryReader("./data").load_data()
index = VectorStoreIndex.from_documents(documents)
query_engine = index.as_query_engine()

# Initialize Prometheus Loop
healer = SelfHealingSystem()
memory = SelfMemorySystem()

# Create agent
class LlamaIndexAgent:
    def __init__(self):
        self.llm = llm
        self.query_engine = query_engine
        self.healer = healer
        self.memory = memory
    
    def run(self, task: str) -> dict:
        """Run agent with RAG."""
        
        # Retrieve relevant context
        relevant_docs = self.query_engine.retrieve(task)
        
        # Check memory for similar past tasks
        past_solutions = self.memory.recall({"task": task})
        
        # Combine context
        context = {
            "documents": relevant_docs,
            "past_solutions": past_solutions
        }
        
        # Execute with healing
        try:
            result = self.execute_with_context(task, context)
            
            # Store successful approach
            self.memory.store({
                "task": task,
                "approach": "direct",
                "success": True,
                "context": context
            })
            
            return result
            
        except Exception as e:
            # Try self-healing
            healing_result = self.healer.handle_error(e, {
                "action": lambda: self.execute_with_context(task, context)
            })
            
            return healing_result
    
    def execute_with_context(self, task: str, context: dict) -> dict:
        """Execute task with context."""
        
        # Build prompt with context
        prompt = f"""
        Task: {task}
        
        Relevant documents:
        {context['documents']}
        
        Past solutions:
        {context['past_solutions']}
        """
        
        # Query LLM
        response = self.llm.complete(prompt)
        
        return {"success": True, "response": str(response)}
```

## Usage

```python
agent = LlamaIndexAgent()
result = agent.run("What are the latest advances in RLHF?")
print(result)
```
