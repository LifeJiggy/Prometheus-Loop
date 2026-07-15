---
name: self-observing
description: Decision tracing, meta-cognition, and self-reflection
---

# Self-Observing

The agent's ability to monitor its own reasoning process, track its decisions, and reflect on its behavior — enabling meta-cognition and continuous self-improvement.

## Quick Start

When the user asks about understanding agent decisions:

1. **Trace decisions** — record what was decided and why
2. **Track reasoning** — log the reasoning chain
3. **Analyze outcomes** — compare expected vs actual
4. **Extract lessons** — identify what worked/didn't
5. **Update confidence** — adjust confidence levels

---

## Architecture

```
Task Started → Start Trace → Record Decision → Record Reasoning → Task Completed
                                                                         ↓
                                                              End Trace → Analyze Outcome
                                                                         ↓
                                                              Extract Lessons → Update Confidence
```

---

## Decision Tracer

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
        
        return {
            "trace_id": trace["id"],
            "decision_count": len(decisions),
            "decision_types": self.count_decision_types(decisions),
            "time_taken": self.calculate_time(trace),
            "outcome": trace.get("outcome", {})
        }
    
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

---

## Reasoning Tracker

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
        
        return {
            "chain_id": chain["id"],
            "step_count": len(steps),
            "step_types": self.count_step_types(steps),
            "conclusion": chain.get("conclusion", {}),
            "duration": self.calculate_duration(chain)
        }
    
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

---

## Outcome Analyzer

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
            failure_reason = outcome.get("failure_reason", "unknown")
            
            lessons.append({
                "type": "failure_analysis",
                "lesson": f"Action failed due to: {failure_reason}",
                "suggestion": self.suggest_fix(failure_reason)
            })
        else:
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

---

## Self-Reflection Engine

```python
class SelfReflectionEngine:
    """Enables agent to reflect on its performance."""
    
    def __init__(self):
        self.reflections = []
        self.insights = []
    
    def reflect(self, task: dict, outcome: dict, observations: dict) -> dict:
        """Reflect on task performance."""
        
        reflection = {
            "task": task,
            "outcome": outcome,
            "observations": observations,
            "strengths": self.identify_strengths(outcome),
            "weaknesses": self.identify_weaknesses(outcome),
            "lessons": self.extract_lessons(outcome),
            "improvements": self.suggest_improvements(outcome)
        }
        
        self.reflections.append(reflection)
        
        new_insights = self.extract_insights(reflection)
        self.insights.extend(new_insights)
        
        return reflection
    
    def identify_strengths(self, outcome: dict) -> list:
        """Identify what went well."""
        
        strengths = []
        
        if outcome.get("success"):
            strengths.append("Task completed successfully")
        if outcome.get("efficiency", 0) > 0.7:
            strengths.append("Efficient execution")
        if outcome.get("accuracy", 0) > 0.9:
            strengths.append("High accuracy")
        
        return strengths
    
    def identify_weaknesses(self, outcome: dict) -> list:
        """Identify what could improve."""
        
        weaknesses = []
        
        if not outcome.get("success"):
            weaknesses.append("Task failed")
        if outcome.get("efficiency", 0) < 0.5:
            weaknesses.append("Low efficiency")
        if outcome.get("attempts", 1) > 3:
            weaknesses.append("Required multiple attempts")
        
        return weaknesses
    
    def extract_lessons(self, outcome: dict) -> list:
        """Extract lessons from outcome."""
        
        lessons = []
        
        if outcome.get("success"):
            lessons.append({
                "type": "success_pattern",
                "lesson": "Current approach worked well"
            })
        else:
            lessons.append({
                "type": "failure_analysis",
                "lesson": f"Failed due to: {outcome.get('failure_reason', 'unknown')}"
            })
        
        return lessons
    
    def suggest_improvements(self, outcome: dict) -> list:
        """Suggest improvements."""
        
        improvements = []
        
        if not outcome.get("success"):
            improvements.append("Try alternative approach next time")
        if outcome.get("duration", 0) > 60:
            improvements.append("Look for optimization opportunities")
        
        return improvements
    
    def extract_insights(self, reflection: dict) -> list:
        """Extract insights from reflection."""
        
        insights = []
        
        for strength in reflection.get("strengths", []):
            insights.append({
                "type": "strength",
                "insight": strength,
                "timestamp": datetime.now().isoformat()
            })
        
        for lesson in reflection.get("lessons", []):
            insights.append({
                "type": "lesson",
                "insight": lesson.get("lesson", ""),
                "timestamp": datetime.now().isoformat()
            })
        
        return insights
    
    def get_reflection_stats(self) -> dict:
        """Get reflection statistics."""
        
        return {
            "total_reflections": len(self.reflections),
            "total_insights": len(self.insights),
            "recent_reflections": self.reflections[-5:]
        }
```

---

## Main Self-Observing System

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
        
        return {"trace_id": trace_id, "chain_id": chain_id}
    
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
        
        self.decision_tracer.end_trace(outcome)
        self.reasoning_tracker.end_chain({"outcome": outcome})
        
        if self.decision_tracer.traces:
            last_trace = self.decision_tracer.traces[-1]
            analysis = self.outcome_analyzer.analyze(
                last_trace.get("decisions", [{}])[-1] if last_trace.get("decisions") else {},
                outcome
            )
        else:
            analysis = {"success": outcome.get("success", False)}
        
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

---

## Usage Examples

### Observe a Task

```python
observer = SelfObservingSystem()

obs = observer.observe_task({"type": "code_generation", "prompt": "Write a parser"})

observer.record_decision({
    "type": "tool_selection",
    "choice": "python_parser",
    "reason": "Task involves Python code"
})

observer.record_reasoning({
    "type": "approach",
    "thought": "Using AST-based parsing for reliability"
})

result = observer.complete_observation({"success": True, "output": "def parse(code): ..."})

insights = observer.get_insights()
print(f"Success rate: {insights['success_rate']:.1%}")
```

---

## Best Practices

1. **Trace everything** — comprehensive tracing enables better insights
2. **Analyze regularly** — don't just store, analyze
3. **Extract actionable lessons** — insights should drive improvement
4. **Share observations** — lessons should inform future decisions
5. **Balance detail vs performance** — don't let tracing slow down execution
6. **Store persistently** — observations should survive restarts
7. **Visualize patterns** — make insights accessible
8. **Act on insights** — observation without action is wasted

---

## Integration

| Capability | How it integrates |
|---|---|
| **Self-Improving** | Observations drive improvement |
| **Self-Debugging** | Traces help debug issues |
| **Self-Monitoring** | Monitoring provides observation data |
| **Self-Planning** | Insights inform better planning |
| **Self-Governing** | Observations verify policy compliance |

---

## Advanced Observation Patterns

### Decision Quality Scoring

```python
class DecisionQualityScorer:
    """Scores the quality of decisions."""
    
    def __init__(self):
        self.scoring_history = []
    
    def score(self, decision: dict, outcome: dict) -> dict:
        """Score a decision's quality."""
        
        factors = {
            "completeness": self.score_completeness(decision),
            "efficiency": self.score_efficiency(decision, outcome),
            "correctness": self.score_correctness(outcome),
            "documentation": self.score_documentation(decision)
        }
        
        overall = sum(factors.values()) / len(factors)
        
        score_result = {
            "factors": factors,
            "overall": overall,
            "grade": self.get_grade(overall),
            "timestamp": datetime.now().isoformat()
        }
        
        self.scoring_history.append(score_result)
        
        return score_result
    
    def score_completeness(self, decision: dict) -> float:
        """Score how complete the decision is."""
        
        score = 0.0
        
        if decision.get("reasoning"):
            score += 0.3
        if decision.get("alternatives"):
            score += 0.2
        if decision.get("expected_outcome"):
            score += 0.2
        if decision.get("risks"):
            score += 0.15
        if decision.get("dependencies"):
            score += 0.15
        
        return score
    
    def score_efficiency(self, decision: dict, outcome: dict) -> float:
        """Score decision efficiency."""
        
        if outcome.get("duration", 0) == 0:
            return 0.5
        
        # Compare to baseline
        baseline_duration = 60  # seconds
        actual_duration = outcome.get("duration", baseline_duration)
        
        if actual_duration <= baseline_duration:
            return 1.0
        elif actual_duration <= baseline_duration * 2:
            return 0.7
        else:
            return 0.3
    
    def score_correctness(self, outcome: dict) -> float:
        """Score decision correctness."""
        
        if outcome.get("success"):
            return 1.0
        elif outcome.get("partial_success"):
            return 0.5
        else:
            return 0.0
    
    def score_documentation(self, decision: dict) -> float:
        """Score decision documentation."""
        
        score = 0.0
        
        if decision.get("reasoning"):
            score += 0.4
        if decision.get("alternatives"):
            score += 0.3
        if decision.get("risks"):
            score += 0.2
        if decision.get("dependencies"):
            score += 0.1
        
        return score
    
    def get_grade(self, score: float) -> str:
        """Get letter grade from score."""
        
        if score >= 0.9:
            return "A"
        elif score >= 0.8:
            return "B"
        elif score >= 0.7:
            return "C"
        elif score >= 0.6:
            return "D"
        else:
            return "F"
```

### Confidence Tracker

```python
class ConfidenceTracker:
    """Tracks confidence in decisions over time."""
    
    def __init__(self):
        self.confidence_history = defaultdict(list)
    
    def record(self, decision_type: str, confidence: float, outcome: dict):
        """Record confidence and outcome."""
        
        self.confidence_history[decision_type].append({
            "confidence": confidence,
            "success": outcome.get("success", False),
            "timestamp": datetime.now().isoformat()
        })
    
    def get_calibration(self, decision_type: str) -> dict:
        """Check if confidence is well-calibrated."""
        
        history = self.confidence_history.get(decision_type, [])
        
        if len(history) < 10:
            return {"calibration": "insufficient_data"}
        
        # Check if high confidence correlates with success
        high_conf = [h for h in history if h["confidence"] > 0.7]
        low_conf = [h for h in history if h["confidence"] <= 0.7]
        
        high_success_rate = sum(1 for h in high_conf if h["success"]) / len(high_conf) if high_conf else 0
        low_success_rate = sum(1 for h in low_conf if h["success"]) / len(low_conf) if low_conf else 0
        
        # Well-calibrated: high confidence should have higher success rate
        calibration_gap = high_success_rate - low_success_rate
        
        return {
            "calibration_gap": calibration_gap,
            "well_calibrated": calibration_gap > 0.1,
            "high_confidence_success_rate": high_success_rate,
            "low_confidence_success_rate": low_success_rate
        }
```

### Meta-Cognition Engine

```python
class MetaCognitionEngine:
    """Enables agent to think about its own thinking."""
    
    def __init__(self):
        self.thinking_history = []
    
    def evaluate_thinking(self, reasoning_chain: dict) -> dict:
        """Evaluate quality of reasoning."""
        
        evaluation = {
            "clarity": self.assess_clarity(reasoning_chain),
            "completeness": self.assess_completeness(reasoning_chain),
            "consistency": self.assess_consistency(reasoning_chain),
            "efficiency": self.assess_efficiency(reasoning_chain)
        }
        
        evaluation["overall"] = sum(evaluation.values()) / len(evaluation)
        
        self.thinking_history.append(evaluation)
        
        return evaluation
    
    def assess_clarity(self, chain: dict) -> float:
        """Assess clarity of reasoning."""
        
        steps = chain.get("steps", [])
        if not steps:
            return 0.0
        
        defined_steps = sum(1 for s in steps if s.get("description"))
        return defined_steps / len(steps)
    
    def assess_completeness(self, chain: dict) -> float:
        """Assess completeness of reasoning."""
        
        steps = chain.get("steps", [])
        required = ["observation", "analysis", "decision", "action"]
        present = sum(1 for r in required if any(r in str(s).lower() for s in steps))
        
        return present / len(required)
    
    def assess_consistency(self, chain: dict) -> float:
        """Assess consistency of reasoning."""
        
        steps = chain.get("steps", [])
        if len(steps) < 2:
            return 1.0
        
        contradictions = 0
        for i, step1 in enumerate(steps):
            for step2 in steps[i+1:]:
                if self.contradicts(step1, step2):
                    contradictions += 1
        
        return max(0, 1 - contradictions / len(steps))
    
    def assess_efficiency(self, chain: dict) -> float:
        """Assess efficiency of reasoning."""
        
        steps = chain.get("steps", [])
        if not steps:
            return 0.0
        
        unique_steps = len(set(str(s) for s in steps))
        return unique_steps / len(steps)
    
    def contradicts(self, step1: dict, step2: dict) -> bool:
        """Check if two steps contradict each other."""
        
        str1 = str(step1).lower()
        str2 = str(step2).lower()
        
        contradictions = [
            ("yes", "no"), ("true", "false"),
            ("allow", "deny"), ("enable", "disable")
        ]
        
        for pos, neg in contradictions:
            if pos in str1 and neg in str2:
                return True
            if neg in str1 and pos in str2:
                return True
        
        return False
```

### Observation Best Practices

1. **Trace everything** — comprehensive tracing enables better insights
2. **Analyze regularly** — don't just store, analyze
3. **Extract actionable lessons** — insights should drive improvement
4. **Share observations** — lessons should inform future decisions
5. **Balance detail vs performance** — don't let tracing slow down execution
6. **Store persistently** — observations should survive restarts
7. **Visualize patterns** — make insights accessible
8. **Act on insights** — observation without action is wasted

### Observation Metrics

| Metric | Description | Target |
|---|---|---|
| Decision quality score | Average quality of decisions | > 0.8 |
| Confidence calibration | High confidence correlates with success | Gap > 0.1 |
| Insight generation rate | Insights per task | > 0.5 |
| Observation coverage | % decisions observed | 100% |
| Reflection frequency | Reflections per session | > 1 |

---

## Further Reading

- **Self-Improving** — Learning from observations
- **Self-Monitoring** — Metrics for observation
- **Observability** — Production-grade observation patterns
- **Self-Debugging** — Using observations for debugging
- **Self-Planning** — Using insights for planning
