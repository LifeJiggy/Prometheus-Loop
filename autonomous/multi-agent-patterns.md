# Multi-Agent Orchestration Patterns

## Pattern 1: Fan-out/Fan-in

**Use when:** Task can be split into independent sub-tasks.

```python
def fan_out_fan_in(task, agents):
    """Split task across agents and merge results."""
    
    # Split task
    subtasks = split_task(task)
    
    # Execute in parallel
    results = []
    for subtask, agent in zip(subtasks, agents):
        result = agent.run(subtask)
        results.append(result)
    
    # Merge results
    merged = merge_results(results)
    
    return merged
```

## Pattern 2: Pipeline

**Use when:** Tasks must be executed in sequence.

```python
def pipeline(task, stages):
    """Execute task through pipeline stages."""
    
    current = task
    
    for stage_name, agent in stages:
        result = agent.run(current)
        current = result
    
    return current
```

## Pattern 3: Competitive

**Use when:** Multiple agents attempt same task, best wins.

```python
def competitive(task, agents):
    """Multiple agents compete, best result wins."""
    
    results = []
    for agent in agents:
        result = agent.run(task)
        results.append(result)
    
    # Select best
    best = max(results, key=lambda r: r.get("score", 0))
    
    return best
```

## Pattern 4: Consensus

**Use when:** Agents must agree on a result.

```python
def consensus(task, agents):
    """Agents vote on result."""
    
    votes = []
    for agent in agents:
        result = agent.run(task)
        votes.append(result)
    
    # Majority vote
    from collections import Counter
    vote_counts = Counter(votes)
    winner = vote_counts.most_common(1)[0][0]
    
    return winner
```

## Pattern 5: Specialist

**Use when:** Different agents handle different aspects.

```python
def specialist(task, specialists):
    """Route to specialist agent."""
    
    # Analyze task
    task_type = analyze_task(task)
    
    # Find specialist
    specialist = specialists.get(task_type)
    
    if specialist:
        return specialist.run(task)
    
    # Fallback to generalist
    return specialists["general"].run(task)
```

## Coordination Checklist

- [ ] Define agent roles and capabilities
- [ ] Establish communication protocols
- [ ] Handle conflicts and deadlocks
- [ ] Monitor agent health
- [ ] Aggregate results correctly
- [ ] Handle agent failures gracefully
