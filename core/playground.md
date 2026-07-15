# Visual Playground

## Interactive Examples

Run these examples to see the core loop in action.

### Example 1: Simple Q&A Agent

```python
# Simple Q&A - no tools, no memory
def simple_qa_agent(question: str) -> str:
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": question}]
    )
    return response.choices[0].message.content

# Try it
print(simple_qa_agent("What is the capital of France?"))
# Output: The capital of France is Paris.
```

### Example 2: Tool-Using Agent

```python
# Agent that reads files
def file_reader_agent(task: str) -> str:
    tools = [{
        "type": "function",
        "function": {
            "name": "read_file",
            "description": "Read a file",
            "parameters": {
                "type": "object",
                "properties": {
                    "path": {"type": "string", "description": "File path"}
                }
            }
        }
    }]
    
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": task}],
        tools=tools
    )
    
    return response.choices[0].message.content

# Try it
print(file_reader_agent("Read the README file"))
```

### Example 3: Memory-Enabled Agent

```python
class MemoryAgent:
    def __init__(self):
        self.memory = []
    
    def run(self, task: str) -> str:
        # Check memory
        context = self.build_context(task)
        
        # Get response
        response = client.chat.completions.create(
            model="gpt-4",
            messages=[{"role": "user", "content": context}]
        )
        
        result = response.choices[0].message.content
        
        # Store in memory
        self.memory.append({"task": task, "result": result})
        
        return result
    
    def build_context(self, task: str) -> str:
        """Build context from memory."""
        relevant = [m for m in self.memory if task.lower() in str(m["task"]).lower()]
        return f"Task: {task}\nRelevant memories: {relevant}"

# Try it
agent = MemoryAgent()
print(agent.run("What is Python?"))
print(agent.run("What are its main features?"))  # Uses memory from first call
```

### Example 4: Self-Healing Agent

```python
import time
import random

def self_healing_agent(task: str, max_retries: int = 3) -> str:
    """Agent that heals from failures."""
    
    for attempt in range(max_retries):
        try:
            # Simulate random failures
            if random.random() < 0.3:
                raise ConnectionError("API timeout")
            
            result = client.chat.completions.create(
                model="gpt-4",
                messages=[{"role": "user", "content": task}]
            )
            return result.choices[0].message.content
            
        except Exception as e:
            print(f"Attempt {attempt + 1} failed: {e}")
            
            # Self-healing: backoff
            wait_time = 2 ** attempt
            print(f"Waiting {wait_time} seconds...")
            time.sleep(wait_time)
    
    return "Failed after all attempts"

# Try it (may take a few attempts)
print(self_healing_agent("What is machine learning?"))
```

## Playground Tips

1. **Start simple** — begin with basic Q&A
2. **Add complexity gradually** — tools, then memory, then healing
3. **Test edge cases** — what happens with bad input?
4. **Monitor performance** — track token usage and latency
5. **Iterate** — refine based on results
