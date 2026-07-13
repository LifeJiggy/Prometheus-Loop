# Multi-Agent Patterns

## Communication Protocols

### Request-Response

```python
class Agent:
    def request(self, target_agent: str, task: str) -> dict:
        """Send request to another agent and wait for response."""
        response = message_bus.send(
            to=target_agent,
            message={"task": task, "request_id": uuid4()},
            timeout=30
        )
        return response
```

### Publish-Subscribe

```python
class Agent:
    def publish(self, event_type: str, data: dict):
        """Publish event for all subscribers."""
        event_bus.publish(
            topic=event_type,
            data=data,
            timestamp=datetime.now()
        )
    
    def subscribe(self, event_type: str, handler: callable):
        """Subscribe to events."""
        event_bus.subscribe(topic=event_type, handler=handler)
```

### Message Queue

```python
class Agent:
    def enqueue(self, queue: str, task: dict):
        """Add task to queue for processing."""
        message_queue.put(queue=queue, message=task)
    
    def dequeue(self, queue: str) -> dict:
        """Get next task from queue."""
        return message_queue.get(queue=queue, timeout=5)
```

## Consensus Patterns

### Majority Vote

```python
def consensus_vote(agents: list, task: str) -> str:
    """Get consensus from multiple agents."""
    votes = [agent.run(task) for agent in agents]
    
    # Count votes
    vote_counts = Counter(votes)
    
    # Return majority
    return vote_counts.most_common(1)[0][0]
```

### Confidence Weighting

```python
def weighted_consensus(agents: list, task: str) -> str:
    """Weight votes by agent confidence."""
    results = []
    
    for agent in agents:
        result, confidence = agent.run_with_confidence(task)
        results.append((result, confidence))
    
    # Weight by confidence
    weighted = {}
    for result, confidence in results:
        weighted[result] = weighted.get(result, 0) + confidence
    
    return max(weighted, key=weighted.get)
```

### Domain Priority

```python
def domain_consensus(agents: dict, task: str, domain: str) -> str:
    """Use domain expert for domain-specific tasks."""
    # Route to domain expert
    expert = agents.get(domain, agents["general"])
    
    # Get expert opinion
    expert_result = expert.run(task)
    
    # Validate with other agents
    validations = [
        agent.validate(expert_result)
        for name, agent in agents.items()
        if name != domain
    ]
    
    # Return if majority agree
    if sum(validations) > len(validations) / 2:
        return expert_result
    
    # Fall back to majority vote
    return consensus_vote(list(agents.values()), task)
```

## Conflict Resolution

### Merge and Re-evaluate

```python
def merge_and_revaluate(results: list, validator_agent) -> dict:
    """Merge conflicting results and validate."""
    # Merge partial results
    merged = {}
    for result in results:
        for key, value in result.items():
            if key not in merged:
                merged[key] = []
            merged[key].append(value)
    
    # Resolve conflicts
    resolved = {}
    for key, values in merged.items():
        if len(set(values)) == 1:
            resolved[key] = values[0]  # No conflict
        else:
            # Conflict - use validator
            resolved[key] = validator_agent.resolve(key, values)
    
    return resolved
```

### Last-Write-Wins with Versioning

```python
class SharedState:
    def __init__(self):
        self.state = {}
        self.versions = {}
    
    def write(self, key: str, value: any, agent_id: str):
        """Write to shared state with versioning."""
        if key in self.versions:
            self.versions[key] += 1
        else:
            self.versions[key] = 1
        
        self.state[key] = {
            "value": value,
            "version": self.versions[key],
            "agent": agent_id,
            "timestamp": datetime.now()
        }
    
    def read(self, key: str) -> any:
        """Read from shared state."""
        return self.state.get(key, {}).get("value")
    
    def detect_conflict(self, key: str) -> bool:
        """Check if key was modified by multiple agents."""
        if key not in self.state:
            return False
        
        # Check for concurrent writes
        recent_writes = [
            entry for entry in self.log
            if entry["key"] == key
            and entry["timestamp"] > datetime.now() - timedelta(seconds=5)
        ]
        
        agents = set(entry["agent"] for entry in recent_writes)
        return len(agents) > 1
```

## Workflow Orchestration

### DAG Execution

```python
class Workflow:
    def __init__(self):
        self.nodes = {}
        self.edges = {}
    
    def add_node(self, name: str, agent: Agent, deps: list):
        """Add node to workflow."""
        self.nodes[name] = agent
        self.edges[name] = deps
    
    def execute(self, inputs: dict) -> dict:
        """Execute workflow in dependency order."""
        # Topological sort
        order = self.topological_sort()
        
        results = inputs.copy()
        
        for node in order:
            agent = self.nodes[node]
            deps = self.edges[node]
            
            # Gather inputs from dependencies
            node_inputs = {dep: results[dep] for dep in deps}
            
            # Execute
            results[node] = agent.run(node_inputs)
        
        return results
```

### Pipeline Execution

```python
class Pipeline:
    def __init__(self):
        self.stages = []
    
    def add_stage(self, name: str, agent: Agent):
        """Add stage to pipeline."""
        self.stages.append((name, agent))
    
    def execute(self, initial_input: any) -> any:
        """Execute pipeline sequentially."""
        current = initial_input
        
        for name, agent in self.stages:
            current = agent.run(current)
        
        return current
```

## Example: Code Review System

```python
# Fan-out: parallel code review
review_workflow = Workflow()

review_workflow.add_node("security", SecurityAgent(), [])
review_workflow.add_node("performance", PerformanceAgent(), [])
review_workflow.add_node("style", StyleAgent(), [])
review_workflow.add_node("merge", MergeAgent(), ["security", "performance", "style"])

# Execute
results = review_workflow.execute({"pr": pr_data})

# Results:
# {
#   "security": {"issues": [...]},
#   "performance": {"issues": [...]},
#   "style": {"issues": [...]},
#   "merge": {"all_issues": [...], "priority": "high"}
# }
```
