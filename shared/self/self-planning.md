# Self-Planning Deep Dive

## Overview

Self-Planning is the agent's ability to autonomously create, adapt, and execute plans for complex tasks — breaking down goals into ordered sub-tasks, selecting strategies, and adjusting plans based on outcomes.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                     SELF-PLANNING SYSTEM                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐        │
│  │   Goal   │──▶│  Plan    │──▶│  Execute │──▶│ Evaluate │        │
│  │ Analyzer │   │ Generator│   │  Monitor │   │ & Adapt  │        │
│  └──────────┘   └──────────┘   └──────────┘   └──────────┘        │
│       │              │              │               │                │
│       ▼              ▼              ▼               ▼                │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐        │
│  │  Task    │   │ Strategy │   │ Progress │   │  Replan  │        │
│  │Decompose │   │ Selector │   │ Tracker  │   │  Engine  │        │
│  └──────────┘   └──────────┘   └──────────┘   └──────────┘        │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    PLAN LIBRARY                              │   │
│  │  Task Templates │ Strategy Patterns │ Success Metrics        │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

## Core Implementation

### Goal Analyzer

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
        
        # Simple heuristic based on length and keywords
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
        
        estimates = {
            "simple": 3,
            "moderate": 7,
            "complex": 15
        }
        
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

### Plan Generator

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
        
        # Get template
        template = self.plan_templates.get(goal_type, self.plan_templates.get("creation"))
        
        # Adapt based on complexity
        plan_steps = self.adapt_plan(template, complexity, goal_analysis)
        
        # Create plan
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
            # Add more detailed steps
            steps = self.add_detailed_steps(steps)
        elif complexity == "simple":
            # Simplify by combining steps
            steps = self.simplify_steps(steps)
        
        # Add step IDs
        for i, step in enumerate(steps):
            step["id"] = f"step_{i+1}"
            step["status"] = "pending"
        
        return steps
    
    def add_detailed_steps(self, steps: list) -> list:
        """Add detailed steps for complex goals."""
        
        detailed = []
        
        for step in steps:
            detailed.append(step)
            
            # Add validation steps after key actions
            if step["step"] in ["implement", "fix"]:
                detailed.append({
                    "step": f"validate_{step['step']}",
                    "description": f"Validate {step['description']}",
                    "validation": True
                })
        
        return detailed
    
    def simplify_steps(self, steps: list) -> list:
        """Simplify steps for simple goals."""
        
        # Combine related steps
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
        """Check if two steps can be combined."""
        
        combinable = [
            ("design", "implement"),
            ("test", "verify"),
            ("analyze", "report")
        ]
        
        return (step1["step"], step2["step"]) in combinable
    
    def estimate_duration(self, steps: list) -> int:
        """Estimate duration in minutes."""
        
        durations = {
            "requirements": 5,
            "design": 10,
            "implement": 30,
            "test": 15,
            "deploy": 10,
            "diagnose": 15,
            "isolate": 10,
            "fix": 20,
            "verify": 10,
            "document": 5,
            "gather_data": 10,
            "analyze": 20,
            "synthesize": 15,
            "report": 10
        }
        
        total = sum(durations.get(step["step"], 10) for step in steps)
        
        return total
```

### Progress Tracker

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
        """Get progress for a plan."""
        
        return self.progress.get(plan_id, {})
    
    def get_completion_percentage(self, plan_id: str) -> float:
        """Get completion percentage."""
        
        prog = self.progress.get(plan_id, {})
        total = prog.get("total_steps", 0)
        completed = prog.get("completed_steps", 0)
        
        return (completed / total * 100) if total > 0 else 0
    
    def is_complete(self, plan_id: str) -> bool:
        """Check if plan is complete."""
        
        prog = self.progress.get(plan_id, {})
        return prog.get("completed_steps", 0) >= prog.get("total_steps", 0)
```

### Replan Engine

```python
class ReplanEngine:
    """Handles plan adaptation and replanning."""
    
    def __init__(self, plan_generator: PlanGenerator):
        self.plan_generator = plan_generator
        self.replan_history = []
    
    def should_replan(self, plan: dict, outcome: dict) -> bool:
        """Determine if replanning is needed."""
        
        # Failed step
        if not outcome.get("success"):
            return True
        
        # Step took too long
        if outcome.get("duration", 0) > plan.get("max_step_duration", 300):
            return True
        
        # Goal changed
        if outcome.get("goal_changed"):
            return True
        
        return False
    
    def replan(self, original_plan: dict, outcome: dict, goal_analysis: dict) -> dict:
        """Create a new plan based on outcome."""
        
        # Record replan
        self.replan_history.append({
            "original_plan": original_plan["id"],
            "outcome": outcome,
            "timestamp": datetime.now().isoformat()
        })
        
        # Generate new plan
        new_plan = self.plan_generator.generate_plan(goal_analysis)
        
        # Adjust based on what we learned
        new_plan = self.adjust_from_outcome(new_plan, outcome)
        
        return new_plan
    
    def adjust_from_outcome(self, plan: dict, outcome: dict) -> dict:
        """Adjust plan based on outcome."""
        
        # If a step failed, try different approach
        if not outcome.get("success"):
            failed_step = outcome.get("failed_step")
            
            for step in plan["steps"]:
                if step["id"] == failed_step:
                    step["alternative"] = True
                    step["notes"] = f"Previous approach failed: {outcome.get('failure_reason')}"
        
        return plan
```

### Main Self-Planning System

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
        
        # Analyze goal
        analysis = self.goal_analyzer.analyze(goal)
        
        # Generate plan
        plan = self.plan_generator.generate_plan(analysis)
        
        # Initialize tracking
        self.progress_tracker.initialize(plan)
        
        # Store plan
        self.active_plans[plan["id"]] = plan
        
        return plan
    
    def execute_step(self, plan_id: str, step_id: str) -> dict:
        """Execute a plan step."""
        
        plan = self.active_plans.get(plan_id)
        if not plan:
            return {"success": False, "reason": "Plan not found"}
        
        # Find the step
        step = None
        for s in plan["steps"]:
            if s["id"] == step_id:
                step = s
                break
        
        if not step:
            return {"success": False, "reason": "Step not found"}
        
        # Update progress
        self.progress_tracker.update_step(plan_id, step_id, "in_progress")
        
        # Execute (placeholder - would call actual execution)
        result = {"success": True, "output": f"Completed {step['description']}"}
        
        # Update progress
        status = "completed" if result["success"] else "failed"
        self.progress_tracker.update_step(plan_id, step_id, status)
        
        # Check if replanning needed
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

## Usage Examples

### Example 1: Plan and Execute

```python
planner = SelfPlanningSystem(llm=my_llm)

# Create plan
plan = planner.create_plan("Implement a user authentication system")
print(f"Plan created with {len(plan['steps'])} steps")

# Execute steps
for step in plan["steps"]:
    result = planner.execute_step(plan["id"], step["id"])
    print(f"Step {step['id']}: {'Success' if result['success'] else 'Failed'}")

# Check status
status = planner.get_plan_status(plan["id"])
print(f"Progress: {status['progress']:.1f}%")
```

## Best Practices

1. **Start with clear goals** — ambiguous goals produce bad plans
2. **Be flexible** — plans should adapt to new information
3. **Track progress** — know where you are in the plan
4. **Replan when needed** — don't stick to a failing plan
5. **Learn from plans** — store successful plans as templates
6. **Estimate realistically** — better to overestimate than underestimate
7. **Break down complex tasks** — large tasks need decomposition
8. **Validate assumptions** — check that prerequisites are met

## Integration

| Capability | Integration |
|---|---|
| **Self-Improving** | Improved strategies inform better planning |
| **Self-Adapting** | Adaptation triggers replanning |
| **Self-Observing** | Observations track plan execution |
| **Self-Remembering** | Plan templates persist across sessions |
| **Self-Governing** | Governance constrains planning |
