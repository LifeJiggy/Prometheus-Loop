---
name: self-evolution
description: Acquire new skills, adapt architecture, and evolve capabilities over time
---

# Self-Evolution

The agent's ability to adapt its architecture, capabilities, and strategies over time to handle new domains, challenges, and requirements — without being explicitly redesigned by humans.

## Quick Start

When the user asks about making agents handle new tasks:

1. **Detect gap** — identify missing capabilities
2. **Learn** — acquire new skill from task patterns
3. **Test** — verify new capability works
4. **Register** — add to capability library

---

## Architecture

```
New Task → Capability Exists? → Use Existing
                    ↓ No
            Can Learn? → Learn Capability → Acquire Skill
                    ↓ No
            Evolve Architecture → Adapt Components → Test → Register
```

---

## Skill Discovery System

```python
class SkillDiscovery:
    """Discovers new skills from successful task patterns."""
    
    def __init__(self):
        self.discovered_skills = {}
        self.skill_candidates = []
    
    def analyze_task(self, task: dict, result: dict, approach: str):
        """Analyze task for potential new skills."""
        
        if not result.get("success"):
            return
        
        skill = {
            "task_pattern": self.extract_pattern(task),
            "approach": approach,
            "tools_used": result.get("tools_used", []),
            "success_count": 1,
            "discovered_at": datetime.now().isoformat()
        }
        
        existing = self.find_similar_skill(skill)
        
        if existing:
            self.discovered_skills[existing]["success_count"] += 1
        else:
            self.skill_candidates.append(skill)
            
            if len(self.skill_candidates) >= 3:
                self.promote_skill(skill)
    
    def extract_pattern(self, task: dict) -> str:
        """Extract pattern from task."""
        
        task_str = str(task).lower()
        
        patterns = {
            "file_operation": ["read", "write", "file", "open"],
            "api_call": ["api", "request", "fetch", "endpoint"],
            "data_transform": ["transform", "convert", "parse", "process"],
            "code_generation": ["generate", "create", "write code", "implement"],
            "analysis": ["analyze", "review", "evaluate", "assess"]
        }
        
        for pattern, keywords in patterns.items():
            if any(kw in task_str for kw in keywords):
                return pattern
        
        return "general"
    
    def find_similar_skill(self, skill: dict) -> str:
        """Find similar existing skill."""
        
        for skill_id, existing in self.discovered_skills.items():
            if existing["task_pattern"] == skill["task_pattern"]:
                return skill_id
        
        return None
    
    def promote_skill(self, skill: dict):
        """Promote a skill candidate to discovered skill."""
        
        skill_id = str(uuid4())
        self.discovered_skills[skill_id] = skill
    
    def get_skills(self, pattern: str = None) -> list:
        """Get discovered skills."""
        
        skills = list(self.discovered_skills.values())
        
        if pattern:
            skills = [s for s in skills if s["task_pattern"] == pattern]
        
        return sorted(skills, key=lambda s: s["success_count"], reverse=True)
```

---

## Architecture Evolution Engine

```python
class ArchitectureEvolution:
    """Evolves agent architecture based on requirements."""
    
    def __init__(self):
        self.architectures = []
        self.fitness_scores = {}
    
    def evaluate_fitness(self, architecture: dict, tasks: list) -> float:
        """Evaluate fitness of an architecture."""
        
        score = 0.0
        
        required_caps = set()
        for task in tasks:
            required_caps.update(self.extract_capabilities(task))
        
        available_caps = set(architecture.get("capabilities", []))
        coverage = len(required_caps & available_caps) / len(required_caps) if required_caps else 1.0
        score += coverage * 0.4
        
        components = len(architecture.get("components", []))
        score += max(0, 1 - components / 20) * 0.2
        
        return score
    
    def extract_capabilities(self, task: dict) -> set:
        """Extract required capabilities."""
        
        task_str = str(task).lower()
        capabilities = set()
        
        if "code" in task_str:
            capabilities.add("coding")
        if "test" in task_str:
            capabilities.add("testing")
        if "analyze" in task_str:
            capabilities.add("analysis")
        if "deploy" in task_str:
            capabilities.add("deployment")
        
        return capabilities if capabilities else {"general"}
    
    def evolve(self, parent: dict, mutation_rate: float = 0.1) -> dict:
        """Create evolved architecture from parent."""
        
        import random
        
        child = parent.copy()
        
        if random.random() < mutation_rate:
            if random.random() < 0.5 and child.get("components"):
                child["components"].pop(random.randint(0, len(child["components"]) - 1))
            else:
                new_components = ["logging", "monitoring", "caching", "retry"]
                child["components"] = child.get("components", []) + [random.choice(new_components)]
        
        child["id"] = str(uuid4())
        child["parent_id"] = parent.get("id")
        
        return child
```

---

## Knowledge Transfer System

```python
class KnowledgeTransfer:
    """Transfers knowledge between different domains."""
    
    def __init__(self):
        self.knowledge_base = {}
        self.transfer_history = []
    
    def store_knowledge(self, domain: str, knowledge: dict):
        """Store knowledge for a domain."""
        
        if domain not in self.knowledge_base:
            self.knowledge_base[domain] = []
        
        self.knowledge_base[domain].append({
            **knowledge,
            "stored_at": datetime.now().isoformat()
        })
    
    def transfer(self, source_domain: str, target_domain: str) -> list:
        """Transfer knowledge between domains."""
        
        source_knowledge = self.knowledge_base.get(source_domain, [])
        transferred = []
        
        for knowledge in source_knowledge:
            if self.is_transferable(knowledge, target_domain):
                transferred.append({
                    **knowledge,
                    "source_domain": source_domain,
                    "target_domain": target_domain
                })
        
        if target_domain not in self.knowledge_base:
            self.knowledge_base[target_domain] = []
        
        self.knowledge_base[target_domain].extend(transferred)
        
        return transferred
    
    def is_transferable(self, knowledge: dict, target_domain: str) -> bool:
        """Check if knowledge is transferable."""
        
        knowledge_str = str(knowledge).lower()
        domain_keywords = {
            "coding": ["code", "function", "class"],
            "testing": ["test", "assert", "validate"],
            "analysis": ["analyze", "review", "evaluate"]
        }
        
        keywords = domain_keywords.get(target_domain, [])
        return any(kw in knowledge_str for kw in keywords)
```

---

## Fitness Tracking

```python
class FitnessTracker:
    """Tracks fitness of different approaches."""
    
    def __init__(self):
        self.fitness_history = defaultdict(list)
    
    def record(self, approach: str, fitness: float):
        """Record fitness for an approach."""
        
        self.fitness_history[approach].append({
            "fitness": fitness,
            "timestamp": datetime.now().isoformat()
        })
    
    def get_average_fitness(self, approach: str) -> float:
        """Get average fitness for an approach."""
        
        history = self.fitness_history.get(approach, [])
        if not history:
            return 0.0
        
        return sum(h["fitness"] for h in history) / len(history)
    
    def get_best_approach(self) -> str:
        """Get approach with highest average fitness."""
        
        if not self.fitness_history:
            return None
        
        return max(
            self.fitness_history.keys(),
            key=lambda a: self.get_average_fitness(a)
        )
```

---

## Main Self-Evolution System

```python
class SelfEvolutionSystem:
    """Main self-evolution orchestrator."""
    
    def __init__(self, llm=None):
        self.skill_discovery = SkillDiscovery()
        self.architecture_evolution = ArchitectureEvolution()
        self.knowledge_transfer = KnowledgeTransfer()
        self.fitness_tracker = FitnessTracker()
        self.evolution_history = []
    
    def evaluate_and_evolve(self, task: dict, result: dict) -> dict:
        """Evaluate results and evolve if needed."""
        
        if not result.get("evolution_needed"):
            return {"evolved": False, "reason": "No evolution needed"}
        
        candidates = self.skill_discovery.get_skills()
        
        if not candidates:
            return {"evolved": False, "reason": "No evolution candidates"}
        
        analysis = self.skill_discovery.analyze_task(task, result, result.get("approach", "standard"))
        
        evolution = {
            "task": task,
            "result": result,
            "analysis": analysis,
            "timestamp": datetime.now().isoformat()
        }
        
        self.evolution_history.append(evolution)
        
        return {"evolved": True, "analysis": analysis}
    
    def acquire(self, capability: str, task: dict) -> dict:
        """Attempt to acquire a new capability."""
        
        if capability in self.skill_discovery.discovered_skills:
            return {"acquired": True, "source": "already_known", "capability": capability}
        
        if self.llm:
            learning = self.learn_from_task(capability, task)
        else:
            learning = self.learn_heuristic(capability, task)
        
        if learning.get("success"):
            self.skill_discovery.discovered_skills[capability] = {
                "learned_from": task,
                "learned_at": datetime.now().isoformat(),
                "confidence": learning.get("confidence", 0.5)
            }
            
            return {"acquired": True, "source": "learned", "capability": capability}
        
        return {"acquired": False, "reason": learning.get("reason", "Learning failed")}
    
    def learn_from_task(self, capability: str, task: dict) -> dict:
        """Learn capability from task using LLM."""
        
        if not self.llm:
            return {"success": False, "reason": "No LLM available"}
        
        prompt = f"""
        Learn how to perform this capability based on the task:
        
        Capability: {capability}
        Task: {task}
        
        Provide:
        1. Step-by-step approach
        2. Required tools
        3. Common pitfalls
        4. Confidence level (0-1)
        
        Return JSON with: approach, tools, pitfalls, confidence
        """
        
        try:
            response = self.llm.call(prompt)
            return json.loads(response)
        except:
            return {"success": False, "reason": "LLM learning failed"}
    
    def learn_heuristic(self, capability: str, task: dict) -> dict:
        """Learn capability heuristically."""
        
        approaches = {
            "data_analysis": {"approach": "Use pandas for data manipulation", "confidence": 0.6},
            "web_scraping": {"approach": "Use requests + beautifulsoup", "confidence": 0.6},
            "file_processing": {"approach": "Use built-in file operations", "confidence": 0.7}
        }
        
        if capability in approaches:
            return {"success": True, **approaches[capability]}
        
        return {"success": False, "reason": "No heuristic available"}
    
    def get_capabilities(self) -> list:
        """Get list of acquired capabilities."""
        return list(self.skill_discovery.discovered_skills.keys())
    
    def get_evolution_summary(self) -> dict:
        """Get evolution summary."""
        
        return {
            "total_evolutions": len(self.evolution_history),
            "capabilities_acquired": len(self.skill_discovery.discovered_skills),
            "knowledge_domains": len(self.knowledge_transfer.knowledge_base),
            "recent_evolutions": self.evolution_history[-5:]
        }
```

---

## Usage Examples

### Acquire New Capability

```python
evolver = SelfEvolutionSystem(llm=my_llm)

result = evolver.acquire("image_processing", {
    "type": "analyze_photo",
    "input": "photo.jpg"
})

if result["acquired"]:
    print(f"Learned: {result['capability']}")
```

### Transfer Knowledge

```python
evolver.knowledge_transfer.store_knowledge("coding", {
    "pattern": "Always check for null before accessing properties"
})

evolver.knowledge_transfer.transfer("coding", "testing")

print(f"Knowledge domains: {list(evolver.knowledge_transfer.knowledge_base.keys())}")
```

---

## Best Practices

1. **Evolve incrementally** — small changes are safer
2. **Test new capabilities** — verify before relying on them
3. **Track fitness** — measure if evolution helps
4. **Allow rollback** — undo bad evolutions
5. **Learn from failures** — don't repeat failed evolutions
6. **Balance exploration vs exploitation** — try new things but use what works
7. **Human oversight for major changes** — significant evolutions need review
8. **Document evolutions** — track what changed and why

---

## Integration

| Capability | How it integrates |
|---|---|
| **Self-Improving** | Improvement informs evolution needs |
| **Self-Debugging** | Debugging identifies missing capabilities |
| **Self-Refactoring** | Refactoring enables architectural changes |
| **Self-Adapting** | Adaptation is a form of evolution |
| **Self-Remembering** | Evolution history persists across sessions |

---

## Advanced Evolution Patterns

### Capability Acquisition Methods

**Method 1: Learn from task patterns**
```python
# Agent encounters task type it hasn't seen before
# It analyzes successful approaches and stores them
evolver.acquire("data_visualization", task)
```

**Method 2: Transfer from related domain**
```python
# Agent transfers knowledge from coding to testing
evolver.knowledge_transfer.transfer("coding", "testing")
```

**Method 3: External learning**
```python
# Agent learns from external documentation
evolver.learn_from_documentation("pandas documentation")
```

### Architecture Mutation Strategies

| Strategy | Description | When to use |
|---|---|---|
| **Component addition** | Add new capability module | Missing capability detected |
| **Component removal** | Remove unused capability | Optimization needed |
| **Parameter tuning** | Adjust existing parameters | Performance improvement |
| **Connection rewiring** | Change how components interact | Better efficiency |
| **Hybrid creation** | Combine existing components | New capability needed |

### Fitness Evaluation

**Fitness metrics:**
- Task success rate (0-1)
- Resource efficiency (0-1)
- Adaptability score (0-1)
- Robustness score (0-1)
- Cost efficiency (0-1)

**Overall fitness calculation:**
```python
fitness = (
    success_rate * 0.4 +
    efficiency * 0.2 +
    adaptability * 0.2 +
    robustness * 0.1 +
    cost_efficiency * 0.1
)
```

### Evolutionary Operators

**Mutation:**
- Randomly modify one component
- Add or remove a capability
- Adjust a parameter

**Crossover:**
- Combine two successful architectures
- Take best parts from each

**Selection:**
- Keep top N performers
- Remove bottom M performers
- Tournament selection

### Knowledge Base Management

**What to store:**
- Successful task patterns
- Failed approach patterns
- Domain-specific knowledge
- Tool usage patterns
- Optimization strategies

**Storage format:**
```json
{
  "domain": "coding",
  "pattern": "bug_fix",
  "approach": "read_test_first",
  "success_rate": 0.85,
  "sample_size": 42,
  "last_updated": "2025-01-15"
}
```

### Evolution Safety

**Guardrails:**
- Never evolve core safety components
- Require human approval for major changes
- Maintain rollback capability
- Test evolved capabilities before deployment
- Monitor for regression

**Rollback strategy:**
```python
class EvolutionRollback:
    def __init__(self):
        self.snapshots = []
    
    def snapshot(self, architecture):
        """Save current state."""
        self.snapshots.append({
            "architecture": copy.deepcopy(architecture),
            "timestamp": datetime.now()
        })
    
    def rollback(self):
        """Restore previous state."""
        if self.snapshots:
            return self.snapshots.pop()["architecture"]
        return None
```

### Real-World Evolution Examples

**Example 1: Adding API integration**
```
Task: "Call the weather API"
Gap: No weather API capability
Evolution: Learn API calling pattern from existing tools
Result: New weather_api capability added
```

**Example 2: Improving code review**
```
Task: "Review code for security"
Pattern: Security reviews consistently fail on OWASP checks
Evolution: Add specialized security analysis capability
Result: Security review success rate improves from 60% to 85%
```

**Example 3: Adapting to new framework**
```
Task: "Work with React components"
Gap: No React knowledge
Evolution: Transfer from JavaScript knowledge, learn React patterns
Result: New React capability with 70% initial success rate
```

### Evolution Metrics

| Metric | Description | Target |
|---|---|---|
| Evolution rate | New capabilities per month | 2-5 |
| Success rate improvement | Change in success after evolution | > 10% |
| Capability coverage | % of task types with capabilities | > 80% |
| Evolution success rate | % of evolutions that improve performance | > 70% |
| Rollback rate | % of evolutions rolled back | < 10% |

### Common Evolution Pitfalls

| Pitfall | Description | Prevention |
|---|---|---|
| Over-specialization | Too narrow capabilities | Maintain general capabilities |
| Catastrophic forgetting | New learning overwrites old | Use elastic weight consolidation |
| Local optima | Stuck in suboptimal state | Periodic random exploration |
| Resource bloat | Too many capabilities | Regular pruning and consolidation |
| Safety regression | Evolution weakens safety | Safety-first evolution policy |

### Evolution Policy

**What can evolve:**
- Task-specific capabilities
- Tool usage patterns
- Planning strategies
- Error handling approaches

**What should not evolve:**
- Core safety rules
- Permission boundaries
- Human oversight requirements
- Audit logging mechanisms

**Evolution approval process:**
1. Propose evolution
2. Evaluate risk
3. Test in sandbox
4. Human approval if high-risk
5. Deploy with monitoring
6. Rollback if issues

---

## Real-World Case Studies

### Case Study 1: Adding API Integration

**Scenario:** Agent needs to call a weather API but has no API capability.

**Evolution process:**
1. Detect gap: No weather API capability
2. Learn: Analyze existing API calling patterns
3. Create: New weather_api capability
4. Test: Verify with mock API
5. Deploy: Add to capability library

**Result:**
- Initial success rate: 60%
- After 10 uses: 85%
- After 50 uses: 92%

### Case Study 2: Improving Code Review

**Scenario:** Security reviews consistently fail on OWASP checks.

**Evolution process:**
1. Analyze: 40% of security reviews miss OWASP issues
2. Diagnose: No specialized OWASP knowledge
3. Evolve: Add OWASP-specific analysis capability
4. Test: Verify on known vulnerable code
5. Deploy: Integrate into security review process

**Result:**
- Before: 60% OWASP detection rate
- After: 85% OWASP detection rate
- Improvement: +25%

### Case Study 3: Adapting to New Framework

**Scenario:** Agent needs to work with React components but has no React knowledge.

**Evolution process:**
1. Detect gap: No React capability
2. Transfer: Transfer from JavaScript knowledge
3. Learn: Study React patterns and best practices
4. Create: New React capability
5. Test: Verify on sample React code
6. Deploy: Add to capability library

**Result:**
- Initial success rate: 70%
- After 20 uses: 82%
- After 100 uses: 88%

---

## Further Reading

- **Self-Improving** — Learning from outcomes
- **Self-Refactoring** — Code structure improvement
- **Memory Systems** — Persisting evolved knowledge
- **Self-Monitoring** — Tracking evolution metrics
- **Self-Governing** — Ensuring evolution stays safe

---

## Summary

Self-Evolution enables agents to grow beyond their initial capabilities. By detecting capability gaps, learning new skills, and adapting architecture, agents can handle increasingly complex tasks without explicit human redesign.
