# Interactive Tutorial

## Learn by Doing

This tutorial walks you through building your first agent step by step.

## Step 1: Setup

```python
# Install dependencies
pip install openai

# Set API key
export OPENAI_API_KEY="your-key-here"
```

## Step 2: Basic Agent

```python
from openai import OpenAI

client = OpenAI()

def simple_agent(task: str) -> str:
    """Simplest possible agent."""
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": task}]
    )
    return response.choices[0].message.content

# Test it
result = simple_agent("What is 2+2?")
print(result)
```

## Step 3: Add Tools

```python
import json

def read_file(path: str) -> str:
    """Read a file."""
    with open(path, 'r') as f:
        return f.read()

def write_file(path: str, content: str) -> str:
    """Write a file."""
    with open(path, 'w') as f:
        f.write(content)
    return f"Written to {path}"

tools = {
    "read_file": read_file,
    "write_file": write_file
}

def agent_with_tools(task: str) -> str:
    """Agent that can use tools."""
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": task}],
        functions=[{
            "name": "read_file",
            "description": "Read a file",
            "parameters": {
                "type": "object",
                "properties": {
                    "path": {"type": "string"}
                }
            }
        }]
    )
    
    # Handle tool calls
    if response.choices[0].message.function_call:
        func_name = response.choices[0].message.function_call.name
        func_args = json.loads(response.choices[0].message.function_call.arguments)
        
        if func_name in tools:
            result = tools[func_name](**func_args)
            return result
    
    return response.choices[0].message.content
```

## Step 4: Add Memory

```python
class Memory:
    def __init__(self):
        self.memories = []
    
    def store(self, key: str, value: any):
        """Store a memory."""
        self.memories.append({"key": key, "value": value})
    
    def retrieve(self, query: str) -> list:
        """Retrieve relevant memories."""
        return [m for m in self.memories if query.lower() in str(m["key"]).lower()]

memory = Memory()

def agent_with_memory(task: str) -> str:
    """Agent with memory."""
    # Check memory
    relevant = memory.retrieve(task)
    
    # Build context
    context = f"Task: {task}\nRelevant memories: {relevant}"
    
    # Get response
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": context}]
    )
    
    result = response.choices[0].message.content
    
    # Store result
    memory.store(task, result)
    
    return result
```

## Step 5: Add Self-Healing

```python
import time

def self_healing_agent(task: str, max_retries: int = 3) -> str:
    """Agent with self-healing."""
    
    for attempt in range(max_retries):
        try:
            result = agent_with_tools(task)
            return result
        except Exception as e:
            print(f"Attempt {attempt + 1} failed: {e}")
            
            # Self-heal: wait and retry with backoff
            wait_time = 2 ** attempt
            time.sleep(wait_time)
            
            # Try alternative approach
            if attempt == max_retries - 1:
                # Last resort: simplify the task
                simple_task = f"Simply answer: {task}"
                return agent_with_tools(simple_task)
    
    return "Failed after all attempts"
```

## Congratulations!

You've built a basic agent with:
- Tool usage
- Memory
- Self-healing

## Next Steps

1. Read the [Architecture Guide](architecture.md) for deeper understanding
2. Explore the [Self-* Capabilities](../shared/self/) for advanced features
3. Try the [Examples](../examples/) for real-world use cases
