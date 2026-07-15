---
name: multi-agent-orchestration
description: Coordinate multiple agents for complex distributed tasks
---

# Multi-Agent Orchestration

Coordinating multiple specialized agents to accomplish complex tasks that exceed any single agent's capabilities.

## Quick Start

When the user asks about multi-agent systems:

1. **Register agents** — define capabilities
2. **Route tasks** — match tasks to agents
3. **Execute** — run in parallel
4. **Resolve conflicts** — handle disagreements
5. **Aggregate results** — combine outputs

---

## Architecture

```
Task → Decompose → Route to Agents → Execute in Parallel
                                              ↓
                                    Collect Results → Conflicts? → Resolve
                                              ↓
                                    Aggregate → Return Final Result
```

---

## Agent Registry

```python
class AgentRegistry:
    """Registry of available agents."""
    
    def __init__(self):
        self.agents = {}
        self.capabilities = defaultdict(list)
    
    def register(self, agent_id: str, agent, capabilities: list):
        """Register an agent."""
        
        self.agents[agent_id] = {
            "agent": agent,
            "capabilities": capabilities,
            "status": "idle",
            "current_task": None,
            "history": []
        }
        
        for cap in capabilities:
            self.capabilities[cap].append(agent_id)
    
    def unregister(self, agent_id: str):
        """Unregister an agent."""
        
        if agent_id in self.agents:
            agent_info = self.agents[agent_id]
            for cap in agent_info["capabilities"]:
                if agent_id in self.capabilities[cap]:
                    self.capabilities[cap].remove(agent_id)
            
            del self.agents[agent_id]
    
    def get_agent(self, agent_id: str):
        """Get an agent by ID."""
        return self.agents.get(agent_id, {}).get("agent")
    
    def get_available_agents(self, capability: str = None) -> list:
        """Get available agents, optionally filtered by capability."""
        
        available = []
        
        for agent_id, info in self.agents.items():
            if info["status"] == "idle":
                if capability is None or capability in info["capabilities"]:
                    available.append(agent_id)
        
        return available
    
    def get_agents_by_capability(self, capability: str) -> list:
        """Get all agents with a specific capability."""
        return self.capabilities.get(capability, [])
    
    def update_status(self, agent_id: str, status: str, task_id: str = None):
        """Update agent status."""
        
        if agent_id in self.agents:
            self.agents[agent_id]["status"] = status
            self.agents[agent_id]["current_task"] = task_id
    
    def get_stats(self) -> dict:
        """Get registry statistics."""
        
        total = len(self.agents)
        idle = sum(1 for a in self.agents.values() if a["status"] == "idle")
        busy = sum(1 for a in self.agents.values() if a["status"] == "busy")
        
        return {
            "total_agents": total,
            "idle": idle,
            "busy": busy,
            "capabilities": {cap: len(agents) for cap, agents in self.capabilities.items()}
        }
```

---

## Task Router

```python
class TaskRouter:
    """Routes tasks to appropriate agents."""
    
    def __init__(self, registry: AgentRegistry):
        self.registry = registry
        self.routing_history = []
    
    def route(self, task: dict) -> dict:
        """Route a task to the best agent."""
        
        required_caps = self.extract_capabilities(task)
        
        candidates = []
        for cap in required_caps:
            agents = self.registry.get_available_agents(cap)
            candidates.extend(agents)
        
        candidates = list(set(candidates))
        
        if not candidates:
            return {"routed": False, "reason": "No available agents"}
        
        scored = []
        for agent_id in candidates:
            score = self.score_agent(agent_id, task, required_caps)
            scored.append({"agent_id": agent_id, "score": score})
        
        scored.sort(key=lambda x: x["score"], reverse=True)
        best = scored[0]
        
        task_id = task.get("id", str(uuid4()))
        self.registry.update_status(best["agent_id"], "busy", task_id)
        
        self.routing_history.append({
            "task_id": task_id,
            "agent_id": best["agent_id"],
            "score": best["score"],
            "candidates": len(candidates),
            "timestamp": datetime.now().isoformat()
        })
        
        return {
            "routed": True,
            "agent_id": best["agent_id"],
            "score": best["score"],
            "task_id": task_id
        }
    
    def extract_capabilities(self, task: dict) -> list:
        """Extract required capabilities from task."""
        
        task_str = str(task).lower()
        
        capability_keywords = {
            "coding": ["code", "implement", "write", "develop"],
            "testing": ["test", "verify", "validate", "check"],
            "debugging": ["debug", "fix", "error", "bug"],
            "analysis": ["analyze", "review", "audit", "evaluate"],
            "research": ["research", "find", "search", "investigate"],
            "documentation": ["document", "explain", "describe", "readme"],
            "deployment": ["deploy", "release", "publish", "ship"],
            "security": ["security", "vulnerability", "attack", "protect"]
        }
        
        caps = []
        for cap, keywords in capability_keywords.items():
            if any(kw in task_str for kw in keywords):
                caps.append(cap)
        
        return caps if caps else ["general"]
    
    def score_agent(self, agent_id: str, task: dict, required_caps: list) -> float:
        """Score an agent for a task."""
        
        agent_info = self.registry.agents.get(agent_id, {})
        agent_caps = agent_info.get("capabilities", [])
        
        cap_match = sum(1 for cap in required_caps if cap in agent_caps) / len(required_caps)
        
        history = agent_info.get("history", [])
        if history:
            success_rate = sum(1 for h in history if h.get("success")) / len(history)
        else:
            success_rate = 0.5
        
        return cap_match * 0.7 + success_rate * 0.3
```

---

## Conflict Resolver

```python
class ConflictResolver:
    """Resolves conflicts between agents."""
    
    def __init__(self, strategy: str = "voting"):
        self.strategy = strategy
        self.resolution_history = []
    
    def resolve(self, conflicts: list) -> dict:
        """Resolve conflicts using specified strategy."""
        
        if self.strategy == "voting":
            return self.resolve_by_voting(conflicts)
        elif self.strategy == "priority":
            return self.resolve_by_priority(conflicts)
        elif self.strategy == "merge":
            return self.resolve_by_merge(conflicts)
        elif self.strategy == "human":
            return self.resolve_by_human(conflicts)
        
        return {"resolved": False, "reason": f"Unknown strategy: {self.strategy}"}
    
    def resolve_by_voting(self, conflicts: list) -> dict:
        """Resolve by majority voting."""
        
        votes = defaultdict(list)
        for conflict in conflicts:
            output = str(conflict.get("output"))
            votes[output].append(conflict)
        
        winner = max(votes.items(), key=lambda x: len(x[1]))
        
        return {
            "resolved": True,
            "strategy": "voting",
            "winning_output": winner[0],
            "votes": len(winner[1]),
            "total_votes": len(conflicts)
        }
    
    def resolve_by_priority(self, conflicts: list) -> dict:
        """Resolve by agent priority."""
        
        sorted_conflicts = sorted(
            conflicts,
            key=lambda c: c.get("priority", 0),
            reverse=True
        )
        
        return {
            "resolved": True,
            "strategy": "priority",
            "winning_output": sorted_conflicts[0].get("output"),
            "winner": sorted_conflicts[0].get("agent_id")
        }
    
    def resolve_by_merge(self, conflicts: list) -> dict:
        """Resolve by merging outputs."""
        
        merged = {}
        for conflict in conflicts:
            output = conflict.get("output", {})
            if isinstance(output, dict):
                merged.update(output)
        
        return {
            "resolved": True,
            "strategy": "merge",
            "merged_output": merged
        }
    
    def resolve_by_human(self, conflicts: list) -> dict:
        """Escalate to human."""
        
        return {
            "resolved": False,
            "strategy": "human",
            "requires_human": True,
            "conflicts": conflicts
        }
```

---

## Result Aggregator

```python
class ResultAggregator:
    """Aggregates results from multiple agents."""
    
    def __init__(self):
        self.aggregation_history = []
    
    def aggregate(self, results: list, strategy: str = "combine") -> dict:
        """Aggregate results using specified strategy."""
        
        if strategy == "combine":
            return self.combine(results)
        elif strategy == "best":
            return self.select_best(results)
        elif strategy == "merge":
            return self.merge(results)
        
        return {"aggregated": False}
    
    def combine(self, results: list) -> dict:
        """Combine all results."""
        
        combined = {
            "results": results,
            "count": len(results),
            "successful": sum(1 for r in results if r.get("success"))
        }
        
        all_data = [r.get("data") for r in results if r.get("data")]
        combined["data"] = all_data
        
        return combined
    
    def select_best(self, results: list) -> dict:
        """Select the best result."""
        
        if not results:
            return {"selected": None}
        
        scored = [(r, r.get("score", 1.0 if r.get("success") else 0.0)) for r in results]
        scored.sort(key=lambda x: x[1], reverse=True)
        
        return {
            "selected": scored[0][0],
            "score": scored[0][1],
            "alternatives": len(results) - 1
        }
    
    def merge(self, results: list) -> dict:
        """Merge results."""
        
        merged = {}
        for result in results:
            if isinstance(result, dict):
                for key, value in result.items():
                    if key not in merged:
                        merged[key] = []
                    merged[key].append(value)
        
        return {"merged": merged}
```

---

## Main Multi-Agent Orchestrator

```python
class MultiAgentOrchestrator:
    """Main multi-agent orchestrator."""
    
    def __init__(self):
        self.registry = AgentRegistry()
        self.router = TaskRouter(self.registry)
        self.conflict_resolver = ConflictResolver()
        self.aggregator = ResultAggregator()
        self.tasks = {}
        self.task_queue = []
    
    def register_agent(self, agent_id: str, agent, capabilities: list):
        """Register an agent."""
        self.registry.register(agent_id, agent, capabilities)
    
    def submit_task(self, task: dict) -> str:
        """Submit a task."""
        
        task_id = task.get("id", str(uuid4()))
        
        self.tasks[task_id] = {
            "id": task_id,
            "task": task,
            "status": "pending",
            "assigned_agent": None,
            "result": None
        }
        
        self.task_queue.append(task_id)
        
        return task_id
    
    def execute(self) -> dict:
        """Execute all pending tasks."""
        
        results = {}
        
        while self.task_queue:
            task_id = self.task_queue.pop(0)
            task_info = self.tasks[task_id]
            
            routing = self.router.route(task_info["task"])
            
            if not routing["routed"]:
                results[task_id] = {"success": False, "reason": routing["reason"]}
                continue
            
            agent_id = routing["agent_id"]
            agent = self.registry.get_agent(agent_id)
            
            try:
                result = agent.run(task_info["task"])
                task_info["result"] = result
                task_info["status"] = "completed"
                results[task_id] = result
                
                self.registry.agents[agent_id]["history"].append({
                    "task_id": task_id,
                    "success": result.get("success", False),
                    "timestamp": datetime.now().isoformat()
                })
            except Exception as e:
                results[task_id] = {"success": False, "error": str(e)}
            finally:
                self.registry.update_status(agent_id, "idle")
        
        return results
    
    def get_stats(self) -> dict:
        """Get orchestrator statistics."""
        
        return {
            "registry": self.registry.get_stats(),
            "tasks": {
                "total": len(self.tasks),
                "pending": len(self.task_queue),
                "completed": sum(1 for t in self.tasks.values() if t["status"] == "completed")
            },
            "routing_history": len(self.router.routing_history)
        }
```

---

## Usage Examples

### Basic Orchestration

```python
orchestrator = MultiAgentOrchestrator()

orchestrator.register_agent("coder", CoderAgent(), ["coding", "debugging"])
orchestrator.register_agent("tester", TesterAgent(), ["testing"])
orchestrator.register_agent("reviewer", ReviewerAgent(), ["analysis", "security"])

task_id = orchestrator.submit_task({
    "type": "code_review",
    "description": "Review and test the new feature"
})

results = orchestrator.execute()
print(f"Results: {results}")
```

### Dynamic Agent Spawning

```python
class AgentSpawner:
    """Dynamically spawns agents based on demand."""
    
    def __init__(self, registry: AgentRegistry):
        self.registry = registry
        self.max_agents = 10
    
    def spawn_agent(self, capabilities: list, config: dict = None) -> str:
        """Spawn a new agent with specified capabilities."""
        
        if len(self.registry.agents) >= self.max_agents:
            return None
        
        agent_id = f"agent_{str(uuid4())[:8]}"
        
        agent = self.create_agent(capabilities, config)
        
        self.registry.register(agent_id, agent, capabilities)
        
        return agent_id
    
    def create_agent(self, capabilities: list, config: dict = None):
        """Create an agent based on capabilities."""
        
        class DynamicAgent:
            def __init__(self, caps, cfg):
                self.capabilities = caps
                self.config = cfg or {}
            
            def run(self, task):
                return {"success": True, "output": f"Executed with {self.capabilities}"}
        
        return DynamicAgent(capabilities, config)
```

---

## Best Practices

1. **Specialize agents** — each agent should excel at something
2. **Balance workload** — distribute tasks evenly
3. **Handle conflicts gracefully** — have clear resolution strategies
4. **Aggregate intelligently** — combine results meaningfully
5. **Monitor agent health** — detect and handle failing agents
6. **Scale dynamically** — add/remove agents as needed
7. **Log everything** — you need to debug coordination issues
8. **Test the orchestrator** — simulate failures to verify resilience

---

## Integration

| Capability | How it integrates |
|---|---|
| **Self-Healing** | Healing individual agent failures |
| **Self-Monitoring** | Monitoring agent and orchestrator health |
| **Self-Improving** | Learning optimal routing and coordination |
| **Self-Planning** | Planning task decomposition and distribution |
| **Self-Governing** | Enforcing coordination policies |

---

## Advanced Orchestration Patterns

### Dynamic Agent Spawning

```python
class DynamicSpawner:
    """Spawns agents based on current demand."""
    
    def __init__(self, registry: AgentRegistry, max_agents: int = 10):
        self.registry = registry
        self.max_agents = max_agents
        self.spawn_history = []
    
    def spawn_if_needed(self, pending_tasks: list) -> list:
        """Spawn agents if needed for pending tasks."""
        
        spawned = []
        
        # Analyze pending tasks
        required_caps = set()
        for task in pending_tasks:
            required_caps.update(self.extract_capabilities(task))
        
        # Check available agents
        available_caps = set()
        for agent_info in self.registry.agents.values():
            if agent_info["status"] == "idle":
                available_caps.update(agent_info["capabilities"])
        
        # Find gaps
        missing = required_caps - available_caps
        
        for cap in missing:
            if len(self.registry.agents) < self.max_agents:
                agent_id = self.spawn_agent(cap)
                spawned.append(agent_id)
        
        return spawned
    
    def spawn_agent(self, capability: str) -> str:
        """Spawn a new agent with capability."""
        
        agent_id = f"agent_{str(uuid4())[:8]}"
        
        class DynamicAgent:
            def __init__(self, cap):
                self.capability = cap
            
            def run(self, task):
                return {"success": True, "output": f"Executed: {self.capability}"}
        
        agent = DynamicAgent(capability)
        self.registry.register(agent_id, agent, [capability])
        
        self.spawn_history.append({
            "agent_id": agent_id,
            "capability": capability,
            "timestamp": datetime.now().isoformat()
        })
        
        return agent_id
```

### Load Balancing

```python
class LoadBalancer:
    """Distributes work across agents."""
    
    def __init__(self):
        self.agent_loads = defaultdict(int)
        self.task_assignments = {}
    
    def assign_task(self, task: dict, available_agents: list) -> str:
        """Assign task to least loaded agent."""
        
        if not available_agents:
            return None
        
        best_agent = min(available_agents, key=lambda a: self.agent_loads[a])
        
        task_id = task.get("id", str(uuid4()))
        self.task_assignments[task_id] = best_agent
        self.agent_loads[best_agent] += 1
        
        return best_agent
    
    def complete_task(self, task_id: str):
        """Mark task as completed."""
        
        if task_id in self.task_assignments:
            agent_id = self.task_assignments[task_id]
            self.agent_loads[agent_id] = max(0, self.agent_loads[agent_id] - 1)
            del self.task_assignments[task_id]
    
    def get_load_distribution(self) -> dict:
        """Get current load distribution."""
        
        return {
            agent_id: load
            for agent_id, load in self.agent_loads.items()
        }
    
    def get_average_load(self) -> float:
        """Get average load across agents."""
        
        if not self.agent_loads:
            return 0.0
        
        return sum(self.agent_loads.values()) / len(self.agent_loads)
```

### Orchestration Metrics

| Metric | Description | Target |
|---|---|---|
| Task throughput | Tasks completed per minute | Depends on complexity |
| Agent utilization | % agents busy | 60-80% |
| Conflict rate | % tasks with conflicts | < 10% |
| Rebalancing frequency | Load rebalances per hour | < 5 |
| Result quality | Quality of aggregated results | > 85% |

### Common Orchestration Pitfalls

| Pitfall | Description | Prevention |
|---|---|---|
| Agent starvation | Some agents never get tasks | Load balancing |
| Hot spots | One agent gets too many tasks | Dynamic load balancing |
| Deadlock | Agents waiting on each other | Timeout + detection |
| Race conditions | Concurrent modifications | Locking + versioning |
| Result conflicts | Agents disagree on results | Conflict resolution strategy |
| Resource exhaustion | Too many agents spawned | Max agent limits |

---

## Quick Reference

| Concept | Description |
|---|---|
| **Agent Registry** | Manages available agents and capabilities |
| **Task Router** | Matches tasks to appropriate agents |
| **Conflict Resolver** | Handles disagreements between agents |
| **Result Aggregator** | Combines outputs from multiple agents |
| **Dynamic Spawning** | Creates agents based on demand |
| **Load Balancer** | Distributes work evenly |
| **Fan-out/Fan-in** | Parallel execution with result merging |
| **Pipeline** | Sequential agent execution |
| **Competitive** | Multiple agents attempt same task |

---

## Further Reading

- **Multi-Agent Patterns** — Communication protocols, consensus
- **Self-Planning** — Task decomposition
- **Production Concerns** — Scaling multi-agent systems
- **Self-Monitoring** — Tracking orchestration metrics
- **Self-Governing** — Enforcing coordination policies

---

## Summary

Multi-Agent Orchestration enables complex tasks to be accomplished by coordinating multiple specialized agents. By registering capabilities, routing tasks intelligently, resolving conflicts, and aggregating results, orchestrators can leverage the strengths of multiple agents to solve problems that exceed any single agent's capabilities.

### Key Takeaways

- Specialized agents outperform generalists for specific tasks
- Load balancing prevents agent starvation and hot spots
- Conflict resolution strategies must match the use case
- Dynamic spawning enables elastic scaling
- Monitoring is essential for multi-agent reliability
