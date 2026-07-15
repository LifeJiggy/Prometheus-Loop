---
name: self-improving
description: Learn from successes and failures to optimize strategies over time
---

# Self-Improving

The agent's ability to learn from every task and improve its performance over time without retraining the underlying model.

## Quick Start

When the user asks about making agents learn:

1. **Record tasks** — log every task execution with results
2. **Extract patterns** — identify what worked and what didn't
3. **Optimize strategies** — update approaches based on patterns
4. **Measure improvement** — track success rates over time

---

## Architecture

```
Task Completed → Record → Extract Patterns → Analyze Successes → Optimize Strategy → Update Store
                        ↓
                  Analyze Failures → Identify Improvements
```

---

## Task Recorder

```python
class TaskRecorder:
    """Records task executions for learning."""
    
    def __init__(self):
        self.records = []
        self.task_index = defaultdict(list)
    
    def record(self, task: dict, result: dict, metrics: dict):
        """Record a task execution."""
        
        record = {
            "id": str(uuid4()),
            "task": task,
            "result": result,
            "metrics": metrics,
            "success": result.get("success", False),
            "duration": metrics.get("duration", 0),
            "tokens_used": metrics.get("tokens", 0),
            "cost": metrics.get("cost", 0),
            "timestamp": datetime.now().isoformat()
        }
        
        self.records.append(record)
        
        task_type = self.classify_task(task)
        self.task_index[task_type].append(record["id"])
        
        return record["id"]
    
    def classify_task(self, task: dict) -> str:
        """Classify task type."""
        
        task_str = str(task).lower()
        
        classifications = {
            "code_generation": ["generate", "create", "write code", "implement"],
            "bug_fix": ["fix", "bug", "error", "broken", "debug"],
            "refactoring": ["refactor", "clean", "reorganize", "optimize"],
            "testing": ["test", "verify", "validate", "check"],
            "documentation": ["document", "explain", "describe", "readme"],
            "analysis": ["analyze", "review", "audit", "evaluate"],
            "research": ["research", "find", "search", "investigate"],
            "data_processing": ["process", "transform", "convert", "parse"],
            "deployment": ["deploy", "release", "publish", "ship"]
        }
        
        for task_type, keywords in classifications.items():
            if any(keyword in task_str for keyword in keywords):
                return task_type
        
        return "general"
    
    def get_records_by_type(self, task_type: str) -> list:
        """Get all records for a task type."""
        
        record_ids = self.task_index.get(task_type, [])
        return [r for r in self.records if r["id"] in record_ids]
    
    def get_success_rate(self, task_type: str) -> float:
        """Get success rate for a task type."""
        
        records = self.get_records_by_type(task_type)
        if not records:
            return 0.0
        
        successes = sum(1 for r in records if r["success"])
        return successes / len(records)
    
    def get_average_metrics(self, task_type: str) -> dict:
        """Get average metrics for a task type."""
        
        records = self.get_records_by_type(task_type)
        if not records:
            return {}
        
        successful = [r for r in records if r["success"]]
        if not successful:
            return {}
        
        return {
            "avg_duration": sum(r["duration"] for r in successful) / len(successful),
            "avg_tokens": sum(r["tokens_used"] for r in successful) / len(successful),
            "avg_cost": sum(r["cost"] for r in successful) / len(successful),
            "sample_size": len(successful)
        }
```

---

## Pattern Extractor

```python
class PatternExtractor:
    """Extracts patterns from task records."""
    
    def __init__(self):
        self.patterns = {}
    
    def extract_patterns(self, records: list) -> dict:
        """Extract patterns from task records."""
        
        return {
            "success_patterns": self.extract_success_patterns(records),
            "failure_patterns": self.extract_failure_patterns(records),
            "timing_patterns": self.extract_timing_patterns(records),
            "cost_patterns": self.extract_cost_patterns(records)
        }
    
    def extract_success_patterns(self, records: list) -> list:
        """Extract patterns from successful tasks."""
        
        successful = [r for r in records if r["success"]]
        
        return [{
            "task_approach": r["result"].get("approach", "unknown"),
            "tools_used": r["result"].get("tools_used", []),
            "parameters": r["result"].get("parameters", {}),
            "duration": r["duration"],
            "tokens": r["tokens_used"]
        } for r in successful]
    
    def extract_failure_patterns(self, records: list) -> list:
        """Extract patterns from failed tasks."""
        
        failed = [r for r in records if not r["success"]]
        
        return [{
            "error_type": r["result"].get("error_type", "unknown"),
            "error_message": r["result"].get("error_message", ""),
            "failed_at_step": r["result"].get("failed_at_step", 0),
            "attempted_approach": r["result"].get("approach", "unknown")
        } for r in failed]
    
    def extract_timing_patterns(self, records: list) -> dict:
        """Extract timing patterns."""
        
        successful = [r for r in records if r["success"]]
        
        if not successful:
            return {}
        
        durations = [r["duration"] for r in successful]
        
        return {
            "avg_duration": sum(durations) / len(durations),
            "min_duration": min(durations),
            "max_duration": max(durations),
            "p50_duration": sorted(durations)[len(durations) // 2],
            "p95_duration": sorted(durations)[int(len(durations) * 0.95)]
        }
    
    def extract_cost_patterns(self, records: list) -> dict:
        """Extract cost patterns."""
        
        successful = [r for r in records if r["success"]]
        
        if not successful:
            return {}
        
        costs = [r["cost"] for r in successful]
        tokens = [r["tokens_used"] for r in successful]
        
        return {
            "avg_cost": sum(costs) / len(costs),
            "total_cost": sum(costs),
            "avg_tokens": sum(tokens) / len(tokens)
        }
```

---

## Strategy Optimizer

```python
class StrategyOptimizer:
    """Optimizes strategies based on patterns."""
    
    def __init__(self, llm=None):
        self.llm = llm
        self.strategy_library = {}
        self.optimization_history = []
    
    def optimize_strategy(self, task_type: str, patterns: dict, current_strategy: dict) -> dict:
        """Optimize strategy for a task type."""
        
        analysis = self.analyze_patterns(patterns)
        suggestions = self.generate_suggestions(analysis, current_strategy)
        optimized = self.apply_optimization(current_strategy, suggestions)
        
        self.optimization_history.append({
            "task_type": task_type,
            "original": current_strategy,
            "optimized": optimized,
            "suggestions": suggestions,
            "timestamp": datetime.now().isoformat()
        })
        
        return optimized
    
    def analyze_patterns(self, patterns: dict) -> dict:
        """Analyze patterns to find insights."""
        
        success_patterns = patterns.get("success_patterns", [])
        failure_patterns = patterns.get("failure_patterns", [])
        
        return {
            "success_count": len(success_patterns),
            "failure_count": len(failure_patterns),
            "success_rate": len(success_patterns) / max(1, len(success_patterns) + len(failure_patterns)),
            "common_success_approaches": self.find_common(success_patterns, "task_approach"),
            "common_failure_reasons": self.find_common(failure_patterns, "error_type"),
            "timing": patterns.get("timing_patterns", {}),
            "cost": patterns.get("cost_patterns", {})
        }
    
    def find_common(self, items: list, key: str) -> list:
        """Find most common values for a key."""
        
        counter = defaultdict(int)
        for item in items:
            value = item.get(key, "unknown")
            counter[value] += 1
        
        return sorted(counter.items(), key=lambda x: x[1], reverse=True)[:5]
    
    def generate_suggestions(self, analysis: dict, current_strategy: dict) -> list:
        """Generate optimization suggestions."""
        
        suggestions = []
        
        if analysis["common_success_approaches"]:
            best_approach = analysis["common_success_approaches"][0][0]
            if best_approach != current_strategy.get("approach"):
                suggestions.append({
                    "type": "approach",
                    "current": current_strategy.get("approach"),
                    "suggested": best_approach,
                    "reason": "Most successful approach for this task type"
                })
        
        if analysis["timing"]:
            avg_duration = analysis["timing"].get("avg_duration", 0)
            if avg_duration > 60:
                suggestions.append({
                    "type": "optimization",
                    "suggestion": "Consider parallelizing steps to reduce duration",
                    "reason": f"Average duration is {avg_duration:.1f}s"
                })
        
        if analysis["cost"]:
            avg_tokens = analysis["cost"].get("avg_tokens", 0)
            if avg_tokens > 10000:
                suggestions.append({
                    "type": "cost",
                    "suggestion": "Consider using a cheaper model for simple steps",
                    "reason": f"Average token usage is {avg_tokens:.0f}"
                })
        
        return suggestions
    
    def apply_optimization(self, strategy: dict, suggestions: list) -> dict:
        """Apply optimizations to strategy."""
        
        optimized = strategy.copy()
        
        for suggestion in suggestions:
            if suggestion["type"] == "approach":
                optimized["approach"] = suggestion["suggested"]
            elif suggestion["type"] == "optimization":
                optimized.setdefault("optimizations", []).append(suggestion["suggestion"])
            elif suggestion["type"] == "cost":
                optimized.setdefault("cost_optimizations", []).append(suggestion["suggestion"])
        
        return optimized
```

---

## Main Self-Improvement System

```python
class SelfImprovementSystem:
    """Main self-improvement orchestrator."""
    
    def __init__(self, llm=None):
        self.recorder = TaskRecorder()
        self.extractor = PatternExtractor()
        self.optimizer = StrategyOptimizer(llm)
        self.strategy_store = {}
        self.improvement_history = []
    
    def record_task(self, task: dict, result: dict, metrics: dict):
        """Record a completed task."""
        
        record_id = self.recorder.record(task, result, metrics)
        
        task_type = self.recorder.classify_task(task)
        records = self.recorder.get_records_by_type(task_type)
        
        if len(records) % 10 == 0:
            self.analyze_and_improve(task_type)
    
    def analyze_and_improve(self, task_type: str):
        """Analyze patterns and improve strategies."""
        
        records = self.recorder.get_records_by_type(task_type)
        
        if len(records) < 5:
            return
        
        patterns = self.extractor.extract_patterns(records)
        
        current_strategy = self.strategy_store.get(task_type, {
            "approach": "standard",
            "parameters": {}
        })
        
        optimized = self.optimizer.optimize_strategy(task_type, patterns, current_strategy)
        
        self.strategy_store[task_type] = optimized
        
        self.improvement_history.append({
            "task_type": task_type,
            "records_analyzed": len(records),
            "success_rate": self.recorder.get_success_rate(task_type),
            "strategy_updated": optimized != current_strategy,
            "timestamp": datetime.now().isoformat()
        })
    
    def get_recommendation(self, task: dict) -> dict:
        """Get recommendation for a new task."""
        
        task_type = self.recorder.classify_task(task)
        
        if task_type in self.strategy_store:
            strategy = self.strategy_store[task_type]
            success_rate = self.recorder.get_success_rate(task_type)
            
            return {
                "recommendation": "use_learned_strategy",
                "strategy": strategy,
                "confidence": min(success_rate, 0.95),
                "historical_success_rate": success_rate,
                "task_type": task_type
            }
        
        return {
            "recommendation": "use_default_strategy",
            "strategy": {"approach": "standard", "parameters": {}},
            "confidence": 0.5,
            "historical_success_rate": 0.0,
            "task_type": task_type
        }
    
    def get_improvement_report(self) -> dict:
        """Generate improvement report."""
        
        report = {
            "total_tasks": len(self.recorder.records),
            "task_types": {},
            "overall_success_rate": 0,
            "improvements_made": len(self.improvement_history),
            "strategies_learned": len(self.strategy_store)
        }
        
        all_types = set(self.recorder.classify_task(r["task"]) for r in self.recorder.records)
        
        for task_type in all_types:
            records = self.recorder.get_records_by_type(task_type)
            report["task_types"][task_type] = {
                "count": len(records),
                "success_rate": self.recorder.get_success_rate(task_type),
                "avg_metrics": self.recorder.get_average_metrics(task_type),
                "has_strategy": task_type in self.strategy_store
            }
        
        if self.recorder.records:
            successes = sum(1 for r in self.recorder.records if r["success"])
            report["overall_success_rate"] = successes / len(self.recorder.records)
        
        return report
    
    def export_knowledge(self) -> dict:
        """Export learned knowledge for persistence."""
        
        return {
            "strategies": self.strategy_store,
            "improvement_history": self.improvement_history[-100:],
            "task_statistics": {
                task_type: {
                    "success_rate": self.recorder.get_success_rate(task_type),
                    "avg_metrics": self.recorder.get_average_metrics(task_type)
                }
                for task_type in self.strategy_store.keys()
            }
        }
    
    def import_knowledge(self, knowledge: dict):
        """Import knowledge from previous sessions."""
        
        self.strategy_store.update(knowledge.get("strategies", {}))
        self.improvement_history.extend(knowledge.get("improvement_history", []))
```

---

## Usage Examples

### Basic Usage

```python
improver = SelfImprovementSystem(llm=my_llm)

improver.record_task(
    task={"type": "bug_fix", "description": "Fix null pointer"},
    result={"success": True, "approach": "read_test_first"},
    metrics={"duration": 45, "tokens": 3000, "cost": 0.15}
)

recommendation = improver.get_recommendation(
    {"type": "bug_fix", "description": "Fix timeout in api.py"}
)
print(f"Recommendation: {recommendation['recommendation']}")
print(f"Confidence: {recommendation['confidence']:.1%}")
```

### Batch Analysis

```python
improver = SelfImprovementSystem()

for task_batch in task_batches:
    for task in task_batch:
        result = execute_task(task)
        improver.record_task(task, result["output"], result["metrics"])

report = improver.get_improvement_report()
print(f"Overall success rate: {report['overall_success_rate']:.1%}")
print(f"Strategies learned: {report['strategies_learned']}")
```

---

## Best Practices

1. **Record everything** — more data = better patterns
2. **Wait for enough data** — don't optimize on < 5 samples
3. **Track both success and failure** — failures teach more
4. **Version strategies** — track what changed and why
5. **Validate optimizations** — test before fully adopting
6. **Export knowledge** — persist learning across sessions
7. **Monitor for regression** — ensure improvements don't break things
8. **Human oversight** — review significant strategy changes

---

## Integration

| Capability | How it integrates |
|---|---|
| **Self-Healing** | Healing patterns feed into improvement |
| **Self-Monitoring** | Metrics drive optimization decisions |
| **Self-Planning** | Improved strategies inform better plans |
| **Self-Adapting** | Adaptation patterns are learned |
| **Self-Remembering** | Knowledge persists across sessions |

---

## Advanced Improvement Patterns

### Pattern Analysis Techniques

**Success Pattern Extraction:**
- What approach was used?
- Which tools were called?
- What parameters were passed?
- How long did it take?
- How many tokens were used?

**Failure Pattern Extraction:**
- What approach was attempted?
- Where did it fail?
- What error occurred?
- What was the root cause?
- What would have worked?

### Strategy Optimization Methods

**Method 1: Rule-based optimization**
```python
# Simple rules derived from patterns
if success_rate < 0.5:
    try_alternative_approach()
elif avg_tokens > 10000:
    use_cheaper_model()
elif avg_duration > 60:
    parallelize_steps()
```

**Method 2: Statistical optimization**
```python
# Use statistics to guide decisions
if success_rate(task_type) < 0.7:
    strategy = most_successful_strategy(task_type)
    apply_strategy(strategy)
```

**Method 3: LLM-based optimization**
```python
# Use LLM to suggest improvements
prompt = f"""
Analyze these task results and suggest improvements:
{task_results}

What patterns do you see? What should we do differently?
"""
suggestions = llm.call(prompt)
```

### Improvement Tracking

**What to track:**
- Success rate over time
- Average tokens per task
- Average duration per task
- Cost per task
- Strategy usage patterns
- Failure patterns

**Tracking implementation:**
```python
class ImprovementTracker:
    def __init__(self):
        self.metrics_history = []
    
    def record(self, task_type: str, metrics: dict):
        """Record metrics for a task type."""
        
        self.metrics_history.append({
            "task_type": task_type,
            "metrics": metrics,
            "timestamp": datetime.now().isoformat()
        })
    
    def get_trend(self, task_type: str, metric: str, window: int = 10) -> dict:
        """Get trend for a metric."""
        
        records = [r for r in self.metrics_history if r["task_type"] == task_type]
        
        if len(records) < window:
            return {"trend": "insufficient_data"}
        
        recent = records[-window:]
        values = [r["metrics"].get(metric, 0) for r in recent]
        
        recent_avg = sum(values[-3:]) / 3 if len(values) >= 3 else values[-1]
        older_avg = sum(values[:3]) / 3 if len(values) >= 3 else values[0]
        
        if recent_avg > older_avg * 1.1:
            trend = "improving"
        elif recent_avg < older_avg * 0.9:
            trend = "degrading"
        else:
            trend = "stable"
        
        return {
            "trend": trend,
            "recent_avg": recent_avg,
            "older_avg": older_avg,
            "values": values
        }
```

### A/B Testing for Improvements

```python
class ABTester:
    """Compare two approaches statistically."""
    
    def __init__(self):
        self.experiments = {}
    
    def create_experiment(self, name: str, control: callable, treatment: callable):
        """Create an A/B test."""
        
        self.experiments[name] = {
            "control": control,
            "treatment": treatment,
            "control_results": [],
            "treatment_results": []
        }
    
    def run_experiment(self, name: str, tasks: list) -> dict:
        """Run A/B test."""
        
        import random
        experiment = self.experiments[name]
        
        random.shuffle(tasks)
        half = len(tasks) // 2
        
        for task in tasks[:half]:
            result = experiment["control"](task)
            experiment["control_results"].append(result)
        
        for task in tasks[half:]:
            result = experiment["treatment"](task)
            experiment["treatment_results"].append(result)
        
        return self.analyze(name)
    
    def analyze(self, name: str) -> dict:
        """Analyze experiment results."""
        
        experiment = self.experiments[name]
        
        control_rate = sum(1 for r in experiment["control_results"] if r.get("success")) / len(experiment["control_results"])
        treatment_rate = sum(1 for r in experiment["treatment_results"] if r.get("success")) / len(experiment["treatment_results"])
        
        return {
            "control_success_rate": control_rate,
            "treatment_success_rate": treatment_rate,
            "improvement": treatment_rate - control_rate,
            "winner": "treatment" if treatment_rate > control_rate else "control"
        }
```

### Improvement Report Generation

```python
class ImprovementReporter:
    """Generates improvement reports."""
    
    def generate_report(self, tracker: ImprovementTracker) -> dict:
        """Generate improvement report."""
        
        report = {
            "summary": {},
            "task_type_details": {},
            "recommendations": []
        }
        
        # Calculate summary
        all_records = tracker.metrics_history
        if all_records:
            report["summary"]["total_tasks"] = len(all_records)
            report["summary"]["avg_success_rate"] = sum(
                r["metrics"].get("success", 0) for r in all_records
            ) / len(all_records)
        
        # Analyze each task type
        task_types = set(r["task_type"] for r in all_records)
        
        for task_type in task_types:
            type_records = [r for r in all_records if r["task_type"] == task_type]
            
            report["task_type_details"][task_type] = {
                "count": len(type_records),
                "avg_success_rate": sum(
                    r["metrics"].get("success", 0) for r in type_records
                ) / len(type_records),
                "trend": tracker.get_trend(task_type, "success")
            }
        
        # Generate recommendations
        for task_type, details in report["task_type_details"].items():
            if details["avg_success_rate"] < 0.7:
                report["recommendations"].append({
                    "task_type": task_type,
                    "recommendation": f"Improve {task_type} approach",
                    "current_rate": details["avg_success_rate"]
                })
        
        return report
```

### Improvement Best Practices

1. **Record everything** — more data enables better patterns
2. **Wait for sufficient data** — don't optimize on < 5 samples
3. **Track both success and failure** — failures teach more
4. **Validate improvements** — test before fully adopting
5. **Export knowledge** — persist learning across sessions
6. **Monitor for regression** — ensure improvements don't break things
7. **Human oversight** — review significant strategy changes
8. **Document changes** — track what was improved and why

---

## Further Reading

- **Self-Evolution** — Acquiring new capabilities
- **Self-Monitoring** — Metrics for optimization
- **Memory Systems** — Persisting learned knowledge
- **Self-Planning** — Using improvements in planning
- **Self-Adapting** — Adapting based on improvements
