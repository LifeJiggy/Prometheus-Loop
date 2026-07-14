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

## Advanced Planning Patterns

### Hierarchical Planning

```python
class HierarchicalPlanner:
    """Plans at multiple levels of abstraction."""
    
    def __init__(self):
        self.levels = ["strategic", "tactical", "operational"]
        self.plans = {}
    
    def create_hierarchical_plan(self, goal: str) -> dict:
        """Create a multi-level plan."""
        
        # Strategic level (high-level goals)
        strategic = self.create_strategic_plan(goal)
        
        # Tactical level (break down into phases)
        tactical = self.create_tactical_plan(strategic)
        
        # Operational level (specific actions)
        operational = self.create_operational_plan(tactical)
        
        plan = {
            "goal": goal,
            "strategic": strategic,
            "tactical": tactical,
            "operational": operational,
            "created_at": datetime.now().isoformat()
        }
        
        self.plans[plan.get("id", str(uuid4()))] = plan
        
        return plan
    
    def create_strategic_plan(self, goal: str) -> dict:
        """Create high-level strategic plan."""
        
        return {
            "objective": goal,
            "approach": "divide_and_conquer",
            "phases": ["analysis", "implementation", "validation"],
            "success_criteria": ["goal_met", "quality_acceptable"]
        }
    
    def create_tactical_plan(self, strategic: dict) -> list:
        """Create tactical plan from strategic plan."""
        
        tactics = []
        
        for phase in strategic.get("phases", []):
            tactic = {
                "phase": phase,
                "tasks": self.decompose_phase(phase),
                "dependencies": [],
                "resources_needed": []
            }
            tactics.append(tactic)
        
        return tactics
    
    def create_operational_plan(self, tactical: list) -> list:
        """Create operational plan from tactical plan."""
        
        operations = []
        
        for tactic in tactical:
            for task in tactic.get("tasks", []):
                operation = {
                    "task": task,
                    "action": self.determine_action(task),
                    "parameters": {},
                    "expected_outcome": "",
                    "rollback": ""
                }
                operations.append(operation)
        
        return operations
    
    def decompose_phase(self, phase: str) -> list:
        """Decompose a phase into tasks."""
        
        decompositions = {
            "analysis": ["gather_requirements", "analyze_constraints", "identify_risks"],
            "implementation": ["design_solution", "write_code", "integrate_components"],
            "validation": ["test_solution", "review_code", "document_results"]
        }
        
        return decompositions.get(phase, [phase])
    
    def determine_action(self, task: str) -> str:
        """Determine action for a task."""
        
        actions = {
            "gather_requirements": "interview_stakeholders",
            "analyze_constraints": "review_specifications",
            "identify_risks": "risk_assessment",
            "design_solution": "create_architecture",
            "write_code": "implement_solution",
            "integrate_components": "run_integration_tests",
            "test_solution": "execute_test_suite",
            "review_code": "code_review",
            "document_results": "write_documentation"
        }
        
        return actions.get(task, "unknown")
```

### Dynamic Plan Adaptation

```python
class DynamicPlanAdapter:
    """Dynamically adapts plans based on feedback."""
    
    def __init__(self):
        self.adaptation_history = []
        self.adaptation_rules = []
    
    def add_rule(self, condition: callable, adaptation: callable):
        """Add an adaptation rule."""
        
        self.adaptation_rules.append({
            "condition": condition,
            "adaptation": adaptation
        })
    
    def adapt_plan(self, plan: dict, context: dict) -> dict:
        """Adapt plan based on context."""
        
        adaptations = []
        
        for rule in self.adaptation_rules:
            if rule["condition"](plan, context):
                adapted_plan = rule["adaptation"](plan, context)
                adaptations.append({
                    "rule": rule,
                    "adapted_plan": adapted_plan
                })
        
        if adaptations:
            # Apply most relevant adaptation
            best = adaptations[0]["adapted_plan"]
            
            self.adaptation_history.append({
                "original": plan,
                "adapted": best,
                "timestamp": datetime.now().isoformat()
            })
            
            return best
        
        return plan
    
    def add_default_rules(self):
        """Add default adaptation rules."""
        
        # Rule: If step fails, try alternative
        self.add_rule(
            lambda plan, ctx: ctx.get("step_failed"),
            lambda plan, ctx: self.add_alternative_steps(plan, ctx)
        )
        
        # Rule: If time is running out, simplify
        self.add_rule(
            lambda plan, ctx: ctx.get("time_pressure", False),
            lambda plan, ctx: self.simplify_plan(plan)
        )
    
    def add_alternative_steps(self, plan: dict, context: dict) -> dict:
        """Add alternative steps for failed steps."""
        
        adapted = plan.copy()
        
        for step in adapted.get("steps", []):
            if step.get("id") == context.get("failed_step"):
                step["alternative"] = True
                step["notes"] = "Trying alternative approach"
        
        return adapted
    
    def simplify_plan(self, plan: dict) -> dict:
        """Simplify plan to reduce time."""
        
        adapted = plan.copy()
        
        # Remove non-essential steps
        adapted["steps"] = [
            s for s in adapted.get("steps", [])
            if s.get("priority", "medium") != "low"
        ]
        
        return adapted
```

### Plan Comparison

```python
class PlanComparator:
    """Compares different plans."""
    
    def __init__(self):
        self.comparison_history = []
    
    def compare(self, plan1: dict, plan2: dict) -> dict:
        """Compare two plans."""
        
        comparison = {
            "plan1": self.analyze_plan(plan1),
            "plan2": self.analyze_plan(plan2),
            "recommendation": self.make_recommendation(plan1, plan2)
        }
        
        self.comparison_history.append(comparison)
        
        return comparison
    
    def analyze_plan(self, plan: dict) -> dict:
        """Analyze a plan."""
        
        steps = plan.get("steps", [])
        
        return {
            "step_count": len(steps),
            "estimated_duration": plan.get("estimated_duration", 0),
            "complexity": self.estimate_complexity(steps),
            "risks": self.identify_risks(steps)
        }
    
    def estimate_complexity(self, steps: list) -> str:
        """Estimate plan complexity."""
        
        if len(steps) <= 3:
            return "simple"
        elif len(steps) <= 7:
            return "moderate"
        else:
            return "complex"
    
    def identify_risks(self, steps: list) -> list:
        """Identify risks in plan."""
        
        risks = []
        
        for step in steps:
            if step.get("priority") == "high":
                risks.append(f"High priority step: {step.get('description', 'unknown')}")
        
        return risks
    
    def make_recommendation(self, plan1: dict, plan2: dict) -> str:
        """Make recommendation based on comparison."""
        
        analysis1 = self.analyze_plan(plan1)
        analysis2 = self.analyze_plan(plan2)
        
        # Recommend based on fewer steps and lower complexity
        if analysis1["step_count"] < analysis2["step_count"]:
            return "plan1"
        elif analysis2["step_count"] < analysis1["step_count"]:
            return "plan2"
        
        return "either"
```

### Plan Validation

```python
class PlanValidator:
    """Validates plans before execution."""
    
    def __init__(self):
        self.validation_rules = []
        self.validation_history = []
    
    def add_rule(self, rule: callable):
        """Add a validation rule."""
        
        self.validation_rules.append(rule)
    
    def validate(self, plan: dict) -> dict:
        """Validate a plan."""
        
        violations = []
        
        for rule in self.validation_rules:
            result = rule(plan)
            if not result.get("valid", True):
                violations.append(result)
        
        is_valid = len(violations) == 0
        
        validation = {
            "plan_id": plan.get("id"),
            "valid": is_valid,
            "violations": violations,
            "timestamp": datetime.now().isoformat()
        }
        
        self.validation_history.append(validation)
        
        return validation
    
    def add_default_rules(self):
        """Add default validation rules."""
        
        # Rule: Plan must have at least one step
        self.add_rule(
            lambda plan: {"valid": len(plan.get("steps", [])) > 0, 
                         "reason": "Plan must have at least one step"}
        )
        
        # Rule: Steps must have descriptions
        self.add_rule(
            lambda plan: {"valid": all(s.get("description") for s in plan.get("steps", [])),
                         "reason": "All steps must have descriptions"}
        )
```

## Integration

| Capability | Integration |
|---|---|
| **Self-Improving** | Improved strategies inform better planning |
| **Self-Adapting** | Adaptation triggers replanning |
| **Self-Observing** | Observations track plan execution |
| **Self-Remembering** | Plan templates persist across sessions |
| **Self-Governing** | Governance constrains planning |
