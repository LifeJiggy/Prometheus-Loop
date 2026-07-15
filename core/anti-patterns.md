# Anti-Patterns Guide

## What NOT to Do

### Anti-Pattern 1: No Observation

**Bad:**
```python
def bad_agent(task: str) -> str:
    result = call_tool(task)
    return result  # Never checked if it worked
```

**Good:**
```python
def good_agent(task: str) -> str:
    result = call_tool(task)
    
    # Observe the result
    if result["success"]:
        return result["output"]
    else:
        # Handle failure
        return handle_error(result["error"])
```

### Anti-Pattern 2: No Memory

**Bad:**
```python
def bad_agent(task: str) -> str:
    #每次都从头开始
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": task}]
    )
    return response.choices[0].message.content
```

**Good:**
```python
def good_agent(task: str) -> str:
    # Check memory first
    context = build_context(task)
    
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": context}]
    )
    
    result = response.choices[0].message.content
    
    # Store in memory
    memory.store(task, result)
    
    return result
```

### Anti-Pattern 3: No Planning

**Bad:**
```python
def bad_agent(task: str) -> str:
    # Jump straight to action
    return call_tool(task)
```

**Good:**
```python
def good_agent(task: str) -> str:
    # Plan first
    plan = create_plan(task)
    
    # Execute plan
    for step in plan["steps"]:
        result = execute_step(step)
        if not result["success"]:
            return handle_error(result["error"])
    
    return result
```

### Anti-Pattern 4: No Error Handling

**Bad:**
```python
def bad_agent(task: str) -> str:
    result = call_tool(task)  # What if it fails?
    return result
```

**Good:**
```python
def good_agent(task: str) -> str:
    try:
        result = call_tool(task)
        return result
    except ConnectionError:
        return retry_with_backoff(task)
    except TimeoutError:
        return use_cached_result(task)
    except Exception as e:
        return handle_error(e)
```

### Anti-Pattern 5: Context Overflow

**Bad:**
```python
def bad_agent(task: str) -> str:
    # Dump everything into context
    context = f"Task: {task}\nAll documents: {all_docs}\nAll memories: {all_memories}"
    # This might exceed token limit!
```

**Good:**
```python
def good_agent(task: str) -> str:
    # Retrieve only relevant context
    relevant_docs = retrieve_relevant(task, all_docs, top_k=5)
    relevant_memories = memory.retrieve(task, top_k=3)
    
    context = f"Task: {task}\nRelevant docs: {relevant_docs}\nRelevant memories: {relevant_memories}"
    # Context is manageable
```

### Anti-Pattern 6: Infinite Loops

**Bad:**
```python
def bad_agent(task: str) -> str:
    while True:  # No exit condition!
        result = attempt_task(task)
        if result["success"]:
            return result
        # What if it never succeeds?
```

**Good:**
```python
def good_agent(task: str, max_cycles: int = 10) -> str:
    for cycle in range(max_cycles):
        result = attempt_task(task)
        if result["success"]:
            return result
    
    return "Failed after maximum attempts"
```

### Anti-Pattern 7: Hardcoded Values

**Bad:**
```python
def bad_agent(task: str) -> str:
    model = "gpt-4"  # Always use expensive model
    max_retries = 3  # Always retry 3 times
    timeout = 30  # Always 30 second timeout
```

**Good:**
```python
def good_agent(task: str) -> str:
    # Adapt based on task
    complexity = assess_complexity(task)
    
    if complexity == "simple":
        model = "gpt-4o-mini"
    else:
        model = "gpt-4"
    
    max_retries = 3 if complexity == "simple" else 5
    timeout = 15 if complexity == "simple" else 60
```

### Anti-Pattern 8: No Logging

**Bad:**
```python
def bad_agent(task: str) -> str:
    result = call_tool(task)
    return result  # No record of what happened
```

**Good:**
```python
def good_agent(task: str) -> str:
    logger.info(f"Starting task: {task}")
    
    result = call_tool(task)
    
    logger.info(f"Task completed: {result['success']}")
    logger.info(f"Tokens used: {result['tokens']}")
    
    return result
```

### Anti-Pattern 9: Ignoring User Feedback

**Bad:**
```python
def bad_agent(task: str) -> str:
    result = call_tool(task)
    return result  # Never asks for feedback
```

**Good:**
```python
def good_agent(task: str) -> str:
    result = call_tool(task)
    
    # Ask for feedback
    feedback = input("Was this helpful? (y/n): ")
    
    # Store feedback
    memory.store(f"feedback_{task}", feedback)
    
    return result
```

### Anti-Pattern 10: No Security

**Bad:**
```python
def bad_agent(task: str) -> str:
    # Execute whatever the user asks
    result = eval(task)  # Dangerous!
    return result
```

**Good:**
```python
def good_agent(task: str) -> str:
    # Validate input
    if not validate_input(task):
        return "Invalid input"
    
    # Check permissions
    if not check_permissions(task):
        return "Permission denied"
    
    # Execute safely
    result = call_tool(task)
    return result
```
