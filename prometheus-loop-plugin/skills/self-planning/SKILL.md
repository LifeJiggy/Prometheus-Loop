---
name: self-planning
description: Autonomous goal decomposition, plan generation, and adaptive replanning
---

# Self-Planning

The agent's ability to autonomously create, adapt, and execute plans for complex tasks — breaking down goals into ordered sub-tasks, selecting strategies, and adjusting plans based on outcomes.

## Quick Start

When the user asks about handling complex tasks:

1. **Analyze goal** — understand what needs to be done
2. **Decompose** — break into ordered sub-tasks
3. **Execute** — work through the plan step by step
4. **Track progress** — monitor completion
5. **Replan** — adjust if something goes wrong

---

## Architecture

```
Goal → Analyze → Classify → Assess Complexity → Generate Plan → Initialize Tracking
                                                                    ↓
Execute Steps ←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←
      ↓
Step Success? → Update Progress → Plan Complete? → Report Success
      ↓
Step Failed → Need Replan? → Replan → Execute Steps
```

---

## Goal Analyzer

```python
class GoalAnalyzer:
    """Analyzes goals to understand requirements."""
    
    def __init__(self):
        self.goal_history = []
    
    def analyze(self, goal: str) -> dict:
        """Analyze a goal."""
        
        analysis = {
            "goal": goal,
            "type": self.classify_goal(goal),
            "complexity": self.assess_complexity(goal),
            "required_capabilities": self.identify_capabilities(goal),
            "estimated_steps": self.estimate_steps(goal),
            "dependencies": self.identify_dependencies(goal)
        }
        
        self.goal_history.append(analysis)
        
        return analysis
    
    def classify_goal(self, goal: str) -> str:
        """Classify goal type."""
        
        goal_lower = goal.lower()
        
        goal_types = {
            "creation": ["create", "build", "generate", "implement"],
            "fix": ["fix", "repair", "debug", "resolve"],
            "improvement": ["improve", "optimize", "enhance", "refactor"],
            "analysis": ["analyze", "review", "audit", "evaluate"],
            "learning": ["learn", "understand", "research", "investigate"],
            "maintenance": ["update", "maintain", "monitor", "check"]
        }
        
        for goal_type, keywords in goal_types.items():
            if any(kw in goal_lower for kw in keywords):
                return goal_type
        
        return "general"
    
    def assess_complexity(self, goal: str) -> str:
        """Assess goal complexity."""
        
        complex_indicators = ["multiple", "integrate", "system", "architecture", "scale"]
        simple_indicators = ["single", "simple", "quick", "one", "basic"]
        
        goal_lower = goal.lower()
        
        complex_score = sum(1 for ind in complex_indicators if ind in goal_lower)
        simple_score = sum(1 for ind in simple_indicators if ind in goal_lower)
        
        if complex_score > simple_score:
            return "complex"
        elif simple_score > complex_score:
            return "simple"
        else:
            return "moderate"
    
    def identify_capabilities(self, goal: str) -> list:
        """Identify required capabilities."""
        
        capabilities = []
        
        capability_keywords = {
            "coding": ["code", "program", "implement", "develop"],
            "testing": ["test", "verify", "validate"],
            "research": ["research", "find", "search"],
            "analysis": ["analyze", "evaluate", "assess"],
            "documentation": ["document", "explain", "describe"],
            "deployment": ["deploy", "release", "ship"]
        }
        
        goal_lower = goal.lower()
        
        for cap, keywords in capability_keywords.items():
            if any(kw in goal_lower for kw in keywords):
                capabilities.append(cap)
        
        return capabilities if capabilities else ["general"]
    
    def estimate_steps(self, goal: str) -> int:
        """Estimate number of steps needed."""
        
        complexity = self.assess_complexity(goal)
        
        estimates = {"simple": 3, "moderate": 7, "complex": 15}
        return estimates.get(complexity, 5)
    
    def identify_dependencies(self, goal: str) -> list:
        """Identify dependencies."""
        
        dependencies = []
        
        dep_keywords = {
            "data": ["requires", "needs", "depends on", "uses"],
            "tools": ["requires tool", "needs library", "depends on API"],
            "knowledge": ["requires understanding", "needs expertise"]
        }
        
        goal_lower = goal.lower()
        
        for dep_type, keywords in dep_keywords.items():
            if any(kw in goal_lower for kw in keywords):
                dependencies.append(dep_type)
        
        return dependencies
```

---

## Plan Generator

```python
class PlanGenerator:
    """Generates execution plans."""
    
    def __init__(self, llm=None):
        self.llm = llm
        self.plan_templates = self.load_templates()
    
    def load_templates(self) -> dict:
        """Load plan templates."""
        
        return {
            "creation": [
                {"step": "requirements", "description": "Gather requirements"},
                {"step": "design", "description": "Design solution"},
                {"step": "implement", "description": "Implement solution"},
                {"step": "test", "description": "Test implementation"},
                {"step": "deploy", "description": "Deploy solution"}
            ],
            "fix": [
                {"step": "diagnose", "description": "Diagnose the issue"},
                {"step": "isolate", "description": "Isolate root cause"},
                {"step": "fix", "description": "Apply fix"},
                {"step": "verify", "description": "Verify fix works"},
                {"step": "document", "description": "Document solution"}
            ],
            "analysis": [
                {"step": "gather_data", "description": "Gather relevant data"},
                {"step": "analyze", "description": "Analyze data"},
                {"step": "synthesize", "description": "Synthesize findings"},
                {"step": "report", "description": "Report results"}
            ]
        }
    
    def generate_plan(self, goal_analysis: dict) -> dict:
        """Generate a plan for a goal."""
        
        goal_type = goal_analysis["type"]
        complexity = goal_analysis["complexity"]
        
        template = self.plan_templates.get(goal_type, self.plan_templates.get("creation"))
        plan_steps = self.adapt_plan(template, complexity, goal_analysis)
        
        plan = {
            "id": str(uuid4()),
            "goal": goal_analysis["goal"],
            "goal_type": goal_type,
            "complexity": complexity,
            "steps": plan_steps,
            "estimated_duration": self.estimate_duration(plan_steps),
            "required_capabilities": goal_analysis["required_capabilities"],
            "status": "created",
            "created_at": datetime.now().isoformat()
        }
        
        return plan
    
    def adapt_plan(self, template: list, complexity: str, analysis: dict) -> list:
        """Adapt template based on complexity."""
        
        steps = template.copy()
        
        if complexity == "complex":
            steps = self.add_detailed_steps(steps)
        elif complexity == "simple":
            steps = self.simplify_steps(steps)
        
        for i, step in enumerate(steps):
            step["id"] = f"step_{i+1}"
            step["status"] = "pending"
        
        return steps
    
    def add_detailed_steps(self, steps: list) -> list:
        """Add detailed steps for complex goals."""
        
        detailed = []
        
        for step in steps:
            detailed.append(step)
            
            if step["step"] in ["implement", "fix"]:
                detailed.append({
                    "step": f"validate_{step['step']}",
                    "description": f"Validate {step['description']}",
                    "validation": True
                })
        
        return detailed
    
    def simplify_steps(self, steps: list) -> list:
        """Simplify steps for simple goals."""
        
        simplified = []
        skip_next = False
        
        for i, step in enumerate(steps):
            if skip_next:
                skip_next = False
                continue
            
            if i < len(steps) - 1 and self.can_combine(step, steps[i+1]):
                combined = {
                    "step": f"{step['step']}_{steps[i+1]['step']}",
                    "description": f"{step['description']} and {steps[i+1]['description']}"
                }
                simplified.append(combined)
                skip_next = True
            else:
                simplified.append(step)
        
        return simplified
    
    def can_combine(self, step1: dict, step2: dict) -> bool:
        combinable = [("design", "implement"), ("test", "verify"), ("analyze", "report")]
        return (step1["step"], step2["step"]) in combinable
    
    def estimate_duration(self, steps: list) -> int:
        """Estimate duration in minutes."""
        
        durations = {
            "requirements": 5, "design": 10, "implement": 30,
            "test": 15, "deploy": 10, "diagnose": 15,
            "isolate": 10, "fix": 20, "verify": 10,
            "document": 5, "gather_data": 10, "analyze": 20,
            "synthesize": 15, "report": 10
        }
        
        return sum(durations.get(step["step"], 10) for step in steps)
```

---

## Progress Tracker

```python
class ProgressTracker:
    """Tracks plan execution progress."""
    
    def __init__(self):
        self.progress = {}
    
    def initialize(self, plan: dict):
        """Initialize tracking for a plan."""
        
        self.progress[plan["id"]] = {
            "plan_id": plan["id"],
            "total_steps": len(plan["steps"]),
            "completed_steps": 0,
            "current_step": None,
            "step_status": {},
            "start_time": datetime.now().isoformat()
        }
    
    def update_step(self, plan_id: str, step_id: str, status: str):
        """Update step status."""
        
        if plan_id in self.progress:
            self.progress[plan_id]["step_status"][step_id] = {
                "status": status,
                "timestamp": datetime.now().isoformat()
            }
            
            if status == "completed":
                self.progress[plan_id]["completed_steps"] += 1
            
            if status == "in_progress":
                self.progress[plan_id]["current_step"] = step_id
    
    def get_progress(self, plan_id: str) -> dict:
        return self.progress.get(plan_id, {})
    
    def get_completion_percentage(self, plan_id: str) -> float:
        prog = self.progress.get(plan_id, {})
        total = prog.get("total_steps", 0)
        completed = prog.get("completed_steps", 0)
        return (completed / total * 100) if total > 0 else 0
    
    def is_complete(self, plan_id: str) -> bool:
        prog = self.progress.get(plan_id, {})
        return prog.get("completed_steps", 0) >= prog.get("total_steps", 0)
```

---

## Replan Engine

```python
class ReplanEngine:
    """Handles plan adaptation and replanning."""
    
    def __init__(self, plan_generator: PlanGenerator):
        self.plan_generator = plan_generator
        self.replan_history = []
    
    def should_replan(self, plan: dict, outcome: dict) -> bool:
        """Determine if replanning is needed."""
        
        if not outcome.get("success"):
            return True
        
        if outcome.get("duration", 0) > plan.get("max_step_duration", 300):
            return True
        
        if outcome.get("goal_changed"):
            return True
        
        return False
    
    def replan(self, original_plan: dict, outcome: dict, goal_analysis: dict) -> dict:
        """Create a new plan based on outcome."""
        
        self.replan_history.append({
            "original_plan": original_plan["id"],
            "outcome": outcome,
            "timestamp": datetime.now().isoformat()
        })
        
        new_plan = self.plan_generator.generate_plan(goal_analysis)
        new_plan = self.adjust_from_outcome(new_plan, outcome)
        
        return new_plan
    
    def adjust_from_outcome(self, plan: dict, outcome: dict) -> dict:
        """Adjust plan based on outcome."""
        
        if not outcome.get("success"):
            failed_step = outcome.get("failed_step")
            
            for step in plan["steps"]:
                if step["id"] == failed_step:
                    step["alternative"] = True
                    step["notes"] = f"Previous approach failed: {outcome.get('failure_reason')}"
        
        return plan
```

---

## Main Self-Planning System

```python
class SelfPlanningSystem:
    """Main self-planning orchestrator."""
    
    def __init__(self, llm=None):
        self.goal_analyzer = GoalAnalyzer()
        self.plan_generator = PlanGenerator(llm)
        self.progress_tracker = ProgressTracker()
        self.replan_engine = ReplanEngine(self.plan_generator)
        self.active_plans = {}
        self.plan_history = []
    
    def create_plan(self, goal: str) -> dict:
        """Create a plan for a goal."""
        
        analysis = self.goal_analyzer.analyze(goal)
        plan = self.plan_generator.generate_plan(analysis)
        
        self.progress_tracker.initialize(plan)
        self.active_plans[plan["id"]] = plan
        
        return plan
    
    def execute_step(self, plan_id: str, step_id: str) -> dict:
        """Execute a plan step."""
        
        plan = self.active_plans.get(plan_id)
        if not plan:
            return {"success": False, "reason": "Plan not found"}
        
        step = None
        for s in plan["steps"]:
            if s["id"] == step_id:
                step = s
                break
        
        if not step:
            return {"success": False, "reason": "Step not found"}
        
        self.progress_tracker.update_step(plan_id, step_id, "in_progress")
        
        result = {"success": True, "output": f"Completed {step['description']}"}
        
        status = "completed" if result["success"] else "failed"
        self.progress_tracker.update_step(plan_id, step_id, status)
        
        if not result["success"]:
            if self.replan_engine.should_replan(plan, result):
                analysis = self.goal_analyzer.analyze(plan["goal"])
                new_plan = self.replan_engine.replan(plan, result, analysis)
                self.active_plans[new_plan["id"]] = new_plan
                return {"success": False, "replanned": True, "new_plan_id": new_plan["id"]}
        
        return result
    
    def get_plan_status(self, plan_id: str) -> dict:
        """Get plan status."""
        
        plan = self.active_plans.get(plan_id)
        if not plan:
            return {"status": "not_found"}
        
        progress = self.progress_tracker.get_progress(plan_id)
        
        return {
            "plan_id": plan_id,
            "goal": plan["goal"],
            "status": plan["status"],
            "progress": self.progress_tracker.get_completion_percentage(plan_id),
            "current_step": progress.get("current_step"),
            "is_complete": self.progress_tracker.is_complete(plan_id)
        }
    
    def get_planning_report(self) -> dict:
        """Get planning report."""
        
        return {
            "total_plans": len(self.active_plans) + len(self.plan_history),
            "active_plans": len(self.active_plans),
            "completed_plans": len(self.plan_history),
            "replans": len(self.replan_engine.replan_history)
        }
```

---

## Usage Examples

### Basic Planning

```python
planner = SelfPlanningSystem(llm=my_llm)

plan = planner.create_plan("Implement a user authentication system")
print(f"Plan created with {len(plan['steps'])} steps")

for step in plan["steps"]:
    result = planner.execute_step(plan["id"], step["id"])
    print(f"Step {step['id']}: {'Success' if result['success'] else 'Failed'}")

status = planner.get_plan_status(plan["id"])
print(f"Progress: {status['progress']:.1f}%")
```

---

## Best Practices

1. **Start with clear goals** — ambiguous goals produce bad plans
2. **Be flexible** — plans should adapt to new information
3. **Track progress** — know where you are in the plan
4. **Replan when needed** — don't stick to a failing plan
5. **Learn from plans** — store successful plans as templates
6. **Estimate realistically** — better to overestimate than underestimate
7. **Break down complex tasks** — large tasks need decomposition
8. **Validate assumptions** — check that prerequisites are met

---

## Integration

| Capability | How it integrates |
|---|---|
| **Self-Improving** | Improved strategies inform better planning |
| **Self-Adapting** | Adaptation triggers replanning |
| **Self-Observing** | Observations track plan execution |
| **Self-Remembering** | Plan templates persist across sessions |
| **Self-Governing** | Governance constrains planning |

---

## Advanced Planning Patterns

### Hierarchical Planning

**When to use:**
- Large, complex tasks
- Multiple levels of abstraction
- Different stakeholders at different levels

**How it works:**
```
Strategic Level (weeks)
├── Phase 1: Research (days)
│   ├── Task 1.1: Literature review
│   ├── Task 1.2: Stakeholder interviews
│   └── Task 1.3: Competitive analysis
├── Phase 2: Design (days)
│   ├── Task 2.1: Architecture design
│   ├── Task 2.2: UI/UX design
│   └── Task 2.3: API design
└── Phase 3: Implementation (weeks)
    ├── Task 3.1: Backend development
    ├── Task 3.2: Frontend development
    └── Task 3.3: Integration testing
```

### Dynamic Planning

**When to use:**
- Tasks that change based on results
- Uncertain environments
- Multiple possible paths

**How it works:**
```python
class DynamicPlanner:
    def plan(self, goal: str, context: dict) -> dict:
        # Initial plan
        plan = self.create_initial_plan(goal, context)
        
        # Monitor and adapt
        while not self.is_complete(plan):
            observation = self.observe(plan)
            
            if observation["needs_replan"]:
                plan = self.replan(plan, observation)
            else:
                self.advance_plan(plan)
        
        return plan
```

### Meta-Planning

**When to use:**
- Complex tasks requiring strategy selection
- Multiple valid approaches
- Uncertain which strategy will work

**How it works:**
```python
class MetaPlanner:
    def plan(self, goal: str) -> dict:
        # Analyze goal
        analysis = self.analyze_goal(goal)
        
        # Select strategy
        strategy = self.select_strategy(analysis)
        
        # Create plan using strategy
        plan = self.execute_strategy(strategy, goal)
        
        return plan
    
    def select_strategy(self, analysis: dict) -> str:
        """Select planning strategy based on analysis."""
        
        if analysis["complexity"] < 0.3:
            return "sequential"
        elif analysis["has_dependencies"]:
            return "hierarchical"
        elif analysis["uncertain"]:
            return "dynamic"
        else:
            return "parallel"
```

### Plan Validation

**What to validate:**
- All dependencies are met
- Resources are available
- Steps are in correct order
- Success criteria are defined
- Rollback plan exists

**Validation checklist:**
- [ ] Goal is clear and measurable
- [ ] All prerequisites are met
- [ ] Required resources are available
- [ ] Steps are ordered correctly
- [ ] Each step has success criteria
- [ ] Failure modes are identified
- [ ] Rollback plan exists
- [ ] Time estimates are realistic

### Plan Metrics

| Metric | Description | Target |
|---|---|---|
| Plan accuracy | % plans that succeed first time | > 70% |
| Replan rate | % plans that need replanning | < 30% |
| Plan duration | Time from plan to completion | Within estimate |
| Step success rate | % steps that succeed | > 90% |
| Resource efficiency | Actual vs estimated resources | < 1.5x |

### Common Planning Pitfalls

| Pitfall | Description | Prevention |
|---|---|---|
| Over-planning | Planning every detail | Plan high-level, details emerge |
| Under-planning | No plan at all | Always have at least a rough plan |
| Rigid plans | Not adapting to new info | Build in flexibility |
| Missing dependencies | Steps fail due to unmet prerequisites | Validate dependencies upfront |
| Unrealistic estimates | Plans take much longer than expected | Add buffer time |
| No rollback | Can't recover from failure | Always have a fallback |

---

## Quick Reference

| Concept | Description |
|---|---|
| **Goal Analyzer** | Analyzes goals to understand requirements |
| **Plan Generator** | Creates execution plans |
| **Progress Tracker** | Monitors plan completion |
| **Replan Engine** | Adapts plans based on outcomes |
| **Sequential Planning** | Tasks with clear ordering |
| **Parallel Planning** | Independent sub-tasks |
| **Hierarchical Planning** | Large tasks with sub-tasks |
| **Dynamic Planning** | Tasks that change based on results |
| **Meta-Planning** | Selecting the right planning strategy |

---

## Further Reading

- **Planning & Reasoning** — CoT, ToT, ReAct techniques
- **Self-Improving** — Learning from plan outcomes
- **Self-Adapting** — Adapting plans to context
- **Self-Monitoring** — Tracking plan execution
- **Multi-Agent Orchestration** — Planning for distributed systems

---

## Summary

Self-Planning enables agents to autonomously decompose complex goals into actionable steps, track progress, and adapt when things go wrong. By combining goal analysis, plan generation, progress tracking, and replanning, agents can handle sophisticated tasks without constant human guidance.

### Key Takeaways

- Clear goals produce better plans
- Plans should be flexible and adaptive
- Progress tracking enables course correction
- Replanning handles unexpected situations
- Learning from plans improves future planning

### Implementation Checklist

- [ ] Goal analyzer configured
- [ ] Plan generator loaded with templates
- [ ] Progress tracker initialized
- [ ] Replan engine ready
- [ ] Plan history being recorded
- [ ] Goal analyzer configured
- [ ] Plan templates loaded
