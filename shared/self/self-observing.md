# Self-Observing Deep Dive

## Overview

Self-Observing is the agent's ability to monitor its own reasoning process, track its decisions, and reflect on its behavior — enabling meta-cognition and continuous self-improvement.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                     SELF-OBSERVING SYSTEM                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐        │
│  │Decision  │──▶│ Reasoning│──▶│ Outcome  │──▶│ Reflect  │        │
│  │ Tracer   │   │ Tracker  │   │ Analyzer │   │ on Process│       │
│  └──────────┘   └──────────┘   └──────────┘   └──────────┘        │
│       │              │              │               │                │
│       ▼              ▼              ▼               ▼                │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐        │
│  │  What    │   │  Why     │   │  Was it  │   │  How to  │        │
│  │ Happened │   │ Happened │   │  Right?  │   │ Improve  │        │
│  └──────────┘   └──────────┘   └──────────┘   └──────────┘        │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    OBSERVATION LOG                           │   │
│  │  Decision History │ Reasoning Chains │ Reflection Insights   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

## Core Implementation

### Decision Tracer

```python
class DecisionTracer:
    """Traces agent decisions."""
    
    def __init__(self):
        self.traces = []
        self.current_trace = None
    
    def start_trace(self, task: dict) -> str:
        """Start tracing a new decision."""
        
        trace_id = str(uuid4())
        
        self.current_trace = {
            "id": trace_id,
            "task": task,
            "decisions": [],
            "start_time": datetime.now().isoformat(),
            "end_time": None,
            "outcome": None
        }
        
        return trace_id
    
    def record_decision(self, decision: dict):
        """Record a decision in the current trace."""
        
        if self.current_trace:
            self.current_trace["decisions"].append({
                **decision,
                "timestamp": datetime.now().isoformat()
            })
    
    def end_trace(self, outcome: dict):
        """End the current trace."""
        
        if self.current_trace:
            self.current_trace["end_time"] = datetime.now().isoformat()
            self.current_trace["outcome"] = outcome
            
            self.traces.append(self.current_trace)
            self.current_trace = None
    
    def get_trace(self, trace_id: str) -> dict:
        """Get a specific trace."""
        
        for trace in self.traces:
            if trace["id"] == trace_id:
                return trace
        
        return None
    
    def get_recent_traces(self, limit: int = 10) -> list:
        """Get recent traces."""
        
        return self.traces[-limit:]
    
    def analyze_trace(self, trace: dict) -> dict:
        """Analyze a trace for insights."""
        
        decisions = trace.get("decisions", [])
        
        analysis = {
            "trace_id": trace["id"],
            "decision_count": len(decisions),
            "decision_types": self.count_decision_types(decisions),
            "time_taken": self.calculate_time(trace),
            "outcome": trace.get("outcome", {})
        }
        
        return analysis
    
    def count_decision_types(self, decisions: list) -> dict:
        """Count decisions by type."""
        
        counts = defaultdict(int)
        for decision in decisions:
            decision_type = decision.get("type", "unknown")
            counts[decision_type] += 1
        
        return dict(counts)
    
    def calculate_time(self, trace: dict) -> float:
        """Calculate time taken for trace."""
        
        start = datetime.fromisoformat(trace["start_time"])
        end = datetime.fromisoformat(trace["end_time"]) if trace.get("end_time") else datetime.now()
        
        return (end - start).total_seconds()
```

### Reasoning Tracker

```python
class ReasoningTracker:
    """Tracks reasoning chains."""
    
    def __init__(self):
        self.chains = []
        self.current_chain = None
    
    def start_chain(self, context: dict) -> str:
        """Start tracking a reasoning chain."""
        
        chain_id = str(uuid4())
        
        self.current_chain = {
            "id": chain_id,
            "context": context,
            "steps": [],
            "start_time": datetime.now().isoformat()
        }
        
        return chain_id
    
    def add_step(self, step: dict):
        """Add a reasoning step."""
        
        if self.current_chain:
            self.current_chain["steps"].append({
                **step,
                "timestamp": datetime.now().isoformat(),
                "step_number": len(self.current_chain["steps"]) + 1
            })
    
    def end_chain(self, conclusion: dict):
        """End the reasoning chain."""
        
        if self.current_chain:
            self.current_chain["end_time"] = datetime.now().isoformat()
            self.current_chain["conclusion"] = conclusion
            
            self.chains.append(self.current_chain)
            self.current_chain = None
    
    def get_chain(self, chain_id: str) -> dict:
        """Get a specific chain."""
        
        for chain in self.chains:
            if chain["id"] == chain_id:
                return chain
        
        return None
    
    def analyze_chain(self, chain: dict) -> dict:
        """Analyze a reasoning chain."""
        
        steps = chain.get("steps", [])
        
        analysis = {
            "chain_id": chain["id"],
            "step_count": len(steps),
            "step_types": self.count_step_types(steps),
            "conclusion": chain.get("conclusion", {}),
            "duration": self.calculate_duration(chain)
        }
        
        return analysis
    
    def count_step_types(self, steps: list) -> dict:
        """Count steps by type."""
        
        counts = defaultdict(int)
        for step in steps:
            step_type = step.get("type", "unknown")
            counts[step_type] += 1
        
        return dict(counts)
    
    def calculate_duration(self, chain: dict) -> float:
        """Calculate chain duration."""
        
        start = datetime.fromisoformat(chain["start_time"])
        end = datetime.fromisoformat(chain.get("end_time", chain["start_time"]))
        
        return (end - start).total_seconds()
```

### Outcome Analyzer

```python
class OutcomeAnalyzer:
    """Analyzes outcomes of decisions."""
    
    def __init__(self):
        self.analyses = []
    
    def analyze(self, decision: dict, outcome: dict) -> dict:
        """Analyze an outcome."""
        
        analysis = {
            "decision": decision,
            "outcome": outcome,
            "success": outcome.get("success", False),
            "expected_vs_actual": self.compare_expected_actual(decision, outcome),
            "lessons_learned": self.extract_lessons(decision, outcome),
            "timestamp": datetime.now().isoformat()
        }
        
        self.analyses.append(analysis)
        
        return analysis
    
    def compare_expected_actual(self, decision: dict, outcome: dict) -> dict:
        """Compare expected vs actual results."""
        
        expected = decision.get("expected_outcome")
        actual = outcome.get("actual_outcome")
        
        if expected is None or actual is None:
            return {"comparison": "insufficient_data"}
        
        return {
            "expected": expected,
            "actual": actual,
            "match": expected == actual,
            "difference": str(expected) != str(actual)
        }
    
    def extract_lessons(self, decision: dict, outcome: dict) -> list:
        """Extract lessons from the outcome."""
        
        lessons = []
        
        if not outcome.get("success"):
            # Extract failure lessons
            failure_reason = outcome.get("failure_reason", "unknown")
            
            lessons.append({
                "type": "failure_analysis",
                "lesson": f"Action failed due to: {failure_reason}",
                "suggestion": self.suggest_fix(failure_reason)
            })
        else:
            # Extract success lessons
            lessons.append({
                "type": "success_pattern",
                "lesson": f"Action succeeded: {decision.get('action', 'unknown')}",
                "reinforcement": "This approach works for similar tasks"
            })
        
        return lessons
    
    def suggest_fix(self, failure_reason: str) -> str:
        """Suggest a fix for a failure."""
        
        suggestions = {
            "timeout": "Consider increasing timeout or using async",
            "permission": "Check access rights and credentials",
            "not_found": "Verify resource exists and path is correct",
            "invalid_input": "Validate input before processing"
        }
        
        for keyword, suggestion in suggestions.items():
            if keyword in str(failure_reason).lower():
                return suggestion
        
        return "Investigate root cause"
    
    def get_statistics(self) -> dict:
        """Get analysis statistics."""
        
        if not self.analyses:
            return {"total": 0}
        
        successful = sum(1 for a in self.analyses if a["success"])
        
        return {
            "total": len(self.analyses),
            "successful": successful,
            "success_rate": successful / len(self.analyses),
            "recent_lessons": self.get_recent_lessons()
        }
    
    def get_recent_lessons(self, limit: int = 5) -> list:
        """Get recent lessons learned."""
        
        recent = self.analyses[-limit:]
        lessons = []
        
        for analysis in recent:
            lessons.extend(analysis.get("lessons_learned", []))
        
        return lessons
```

### Main Self-Observing System

```python
class SelfObservingSystem:
    """Main self-observing orchestrator."""
    
    def __init__(self):
        self.decision_tracer = DecisionTracer()
        self.reasoning_tracker = ReasoningTracker()
        self.outcome_analyzer = OutcomeAnalyzer()
        self.observation_log = []
    
    def observe_task(self, task: dict) -> dict:
        """Set up observation for a task."""
        
        trace_id = self.decision_tracer.start_trace(task)
        chain_id = self.reasoning_tracker.start_chain({"task": task})
        
        return {
            "trace_id": trace_id,
            "chain_id": chain_id
        }
    
    def record_decision(self, decision: dict):
        """Record a decision."""
        
        self.decision_tracer.record_decision(decision)
        self.reasoning_tracker.add_step({
            "type": "decision",
            "content": decision
        })
    
    def record_reasoning(self, reasoning: dict):
        """Record reasoning."""
        
        self.reasoning_tracker.add_step({
            "type": "reasoning",
            "content": reasoning
        })
    
    def complete_observation(self, outcome: dict) -> dict:
        """Complete observation for a task."""
        
        # End traces
        self.decision_tracer.end_trace(outcome)
        self.reasoning_tracker.end_chain({"outcome": outcome})
        
        # Analyze outcome
        if self.decision_tracer.traces:
            last_trace = self.decision_tracer.traces[-1]
            analysis = self.outcome_analyzer.analyze(
                last_trace.get("decisions", [{}])[-1] if last_trace.get("decisions") else {},
                outcome
            )
        else:
            analysis = {"success": outcome.get("success", False)}
        
        # Record observation
        observation = {
            "outcome": outcome,
            "analysis": analysis,
            "timestamp": datetime.now().isoformat()
        }
        
        self.observation_log.append(observation)
        
        return observation
    
    def get_insights(self) -> dict:
        """Get insights from observations."""
        
        stats = self.outcome_analyzer.get_statistics()
        
        return {
            "total_observations": len(self.observation_log),
            "success_rate": stats.get("success_rate", 0),
            "recent_lessons": stats.get("recent_lessons", []),
            "decision_patterns": self.analyze_decision_patterns()
        }
    
    def analyze_decision_patterns(self) -> dict:
        """Analyze patterns in decisions."""
        
        patterns = defaultdict(int)
        
        for trace in self.decision_tracer.get_recent_traces(50):
            for decision in trace.get("decisions", []):
                decision_type = decision.get("type", "unknown")
                patterns[decision_type] += 1
        
        return dict(patterns)
    
    def get_observation_report(self) -> dict:
        """Get observation report."""
        
        return {
            "total_observations": len(self.observation_log),
            "trace_count": len(self.decision_tracer.traces),
            "chain_count": len(self.reasoning_tracker.chains),
            "analysis_stats": self.outcome_analyzer.get_statistics(),
            "recent_observations": self.observation_log[-5:]
        }
```

## Usage Examples

### Example 1: Observe a Task

```python
observer = SelfObservingSystem()

# Set up observation
obs = observer.observe_task({"type": "code_generation", "prompt": "Write a parser"})

# Record decisions
observer.record_decision({
    "type": "tool_selection",
    "choice": "python_parser",
    "reason": "Task involves Python code"
})

# Record reasoning
observer.record_reasoning({
    "type": "approach",
    "thought": "Using AST-based parsing for reliability"
})

# Complete observation
result = observer.complete_observation({
    "success": True,
    "output": "def parse(code): ..."
})

# Get insights
insights = observer.get_insights()
print(f"Success rate: {insights['success_rate']:.1%}")
```

## Best Practices

1. **Trace everything** — comprehensive tracing enables better insights
2. **Analyze regularly** — don't just store, analyze
3. **Extract actionable lessons** — insights should drive improvement
4. **Share observations** — lessons should inform future decisions
5. **Balance detail vs performance** — don't let tracing slow down execution
6. **Store persistently** — observations should survive restarts
7. **Visualize patterns** — make insights accessible
8. **Act on insights** — observation without action is wasted

## Integration

| Capability | Integration |
|---|---|
| **Self-Improving** | Observations drive improvement |
| **Self-Debugging** | Traces help debug issues |
| **Self-Monitoring** | Monitoring provides observation data |
| **Self-Planning** | Insights inform better planning |
| **Self-Governing** | Observations verify policy compliance |
