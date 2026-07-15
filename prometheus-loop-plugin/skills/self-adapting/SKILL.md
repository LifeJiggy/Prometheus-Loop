---
name: self-adapting
description: Context-aware behavior adjustment and configuration adaptation
---

# Self-Adapting

The agent's ability to adjust behavior, strategies, and configurations based on changing context, environmental conditions, and task requirements — without explicit reprogramming.

## Quick Start

When the user asks about making agents work in different environments:

1. **Detect context** — identify environmental changes
2. **Select strategy** — choose appropriate behavior
3. **Adapt config** — adjust parameters
4. **Verify** — confirm adaptation worked

---

## Architecture

```
Context Change → Detect Change → Select Strategy → Adapt Configuration
                                                        ↓
                                              Apply Changes → Verify Adaptation
                                                                    ↓
                                                          Record Adaptation → Update Success Rate
```

---

## Context Detector

```python
class ContextDetector:
    """Detects context changes that require adaptation."""
    
    def __init__(self):
        self.current_context = {}
        self.context_history = []
        self.change_callbacks = []
    
    def detect(self, new_context: dict) -> dict:
        """Detect context changes."""
        
        changes = {"added": {}, "removed": {}, "modified": {}}
        
        for key in new_context:
            if key not in self.current_context:
                changes["added"][key] = new_context[key]
        
        for key in self.current_context:
            if key not in new_context:
                changes["removed"][key] = self.current_context[key]
        
        for key in new_context:
            if key in self.current_context:
                if new_context[key] != self.current_context[key]:
                    changes["modified"][key] = {
                        "old": self.current_context[key],
                        "new": new_context[key]
                    }
        
        self.current_context = new_context.copy()
        self.context_history.append({
            "context": new_context,
            "changes": changes,
            "timestamp": datetime.now().isoformat()
        })
        
        if any(changes.values()):
            self.notify_callbacks(changes)
        
        return changes
    
    def register_callback(self, callback: callable):
        """Register a callback for context changes."""
        self.change_callbacks.append(callback)
    
    def notify_callbacks(self, changes: dict):
        """Notify registered callbacks."""
        for callback in self.change_callbacks:
            try:
                callback(changes)
            except Exception as e:
                print(f"Callback error: {e}")
    
    def get_context(self) -> dict:
        return self.current_context.copy()
```

---

## Strategy Selector

```python
class StrategySelector:
    """Selects appropriate strategies based on context."""
    
    def __init__(self):
        self.strategies = {}
        self.selection_history = []
    
    def register_strategy(self, name: str, strategy: dict, conditions: dict):
        """Register a strategy with conditions."""
        
        self.strategies[name] = {
            "strategy": strategy,
            "conditions": conditions,
            "usage_count": 0,
            "success_rate": 0.0
        }
    
    def select(self, context: dict) -> dict:
        """Select the best strategy for the context."""
        
        candidates = []
        
        for name, info in self.strategies.items():
            score = self.evaluate_conditions(info["conditions"], context)
            if score > 0:
                candidates.append({
                    "name": name,
                    "score": score,
                    "strategy": info["strategy"]
                })
        
        if not candidates:
            return {"selected": None, "reason": "No matching strategy"}
        
        candidates.sort(key=lambda x: x["score"], reverse=True)
        selected = candidates[0]
        
        self.strategies[selected["name"]]["usage_count"] += 1
        
        self.selection_history.append({
            "strategy": selected["name"],
            "context": context,
            "score": selected["score"],
            "timestamp": datetime.now().isoformat()
        })
        
        return {
            "selected": selected["name"],
            "strategy": selected["strategy"],
            "score": selected["score"]
        }
    
    def evaluate_conditions(self, conditions: dict, context: dict) -> float:
        """Evaluate how well conditions match context."""
        
        score = 0.0
        total_conditions = len(conditions)
        
        for key, expected in conditions.items():
            actual = context.get(key)
            
            if actual is None:
                continue
            
            if isinstance(expected, list):
                if actual in expected:
                    score += 1.0
            elif actual == expected:
                score += 1.0
            elif isinstance(expected, (int, float)) and isinstance(actual, (int, float)):
                if abs(actual - expected) / max(abs(expected), 1) < 0.1:
                    score += 0.8
        
        return score / total_conditions if total_conditions > 0 else 0.0
    
    def update_success_rate(self, strategy_name: str, success: bool):
        """Update strategy success rate."""
        
        if strategy_name in self.strategies:
            info = self.strategies[strategy_name]
            total = info["usage_count"]
            successes = info["success_rate"] * (total - 1) + (1 if success else 0)
            info["success_rate"] = successes / total if total > 0 else 0.0
```

---

## Configuration Adapter

```python
class ConfigAdapter:
    """Adapts configuration based on context."""
    
    def __init__(self):
        self.configs = {}
        self.adapters = {}
        self.current_config = {}
    
    def register_config(self, name: str, config: dict):
        """Register a configuration."""
        self.configs[name] = config
    
    def register_adapter(self, config_name: str, adapter_fn: callable):
        """Register an adapter function for a config."""
        self.adapters[config_name] = adapter_fn
    
    def adapt(self, config_name: str, context: dict) -> dict:
        """Adapt configuration based on context."""
        
        if config_name not in self.configs:
            return {"success": False, "reason": f"Config not found: {config_name}"}
        
        base_config = self.configs[config_name].copy()
        
        if config_name in self.adapters:
            adapted_config = self.adapters[config_name](base_config, context)
        else:
            adapted_config = self.default_adapt(base_config, context)
        
        self.current_config[config_name] = adapted_config
        
        return {
            "success": True,
            "config": adapted_config,
            "adaptations": self.get_adaptations(base_config, adapted_config)
        }
    
    def default_adapt(self, config: dict, context: dict) -> dict:
        """Default adaptation logic."""
        
        adapted = config.copy()
        
        if context.get("memory_pressure") == "high":
            adapted["cache_size"] = min(adapted.get("cache_size", 100), 50)
            adapted["batch_size"] = min(adapted.get("batch_size", 10), 5)
        
        if context.get("latency") == "high":
            adapted["timeout"] = adapted.get("timeout", 30) * 2
            adapted["retries"] = min(adapted.get("retries", 3) + 1, 5)
        
        return adapted
    
    def get_adaptations(self, original: dict, adapted: dict) -> list:
        """Get list of adaptations made."""
        
        adaptations = []
        
        for key in adapted:
            if key in original:
                if adapted[key] != original[key]:
                    adaptations.append({
                        "key": key,
                        "old": original[key],
                        "new": adapted[key]
                    })
            else:
                adaptations.append({
                    "key": key,
                    "old": None,
                    "new": adapted[key]
                })
        
        return adaptations
    
    def get_current_config(self, config_name: str) -> dict:
        return self.current_config.get(config_name, self.configs.get(config_name, {}))
```

---

## Advanced Adaptation Patterns

### Dynamic Model Selection

```python
class ModelSelector:
    """Selects the best model based on context."""
    
    def __init__(self):
        self.models = {
            "fast": {"model": "gpt-4o-mini", "cost": 0.15, "quality": 0.7},
            "balanced": {"model": "gpt-4o", "cost": 2.50, "quality": 0.85},
            "powerful": {"model": "claude-3-opus", "cost": 15.0, "quality": 0.95}
        }
        self.selection_history = []
    
    def select(self, task: dict, context: dict) -> dict:
        """Select model based on task and context."""
        
        complexity = self.assess_complexity(task)
        budget = context.get("budget_remaining", float('inf'))
        latency_required = context.get("latency_required", "normal")
        
        if budget < 1.0 or latency_required == "fast":
            selected = "fast"
        elif complexity > 0.7 or context.get("quality_required") == "high":
            selected = "powerful"
        else:
            selected = "balanced"
        
        model_cost = self.models[selected]["cost"]
        if model_cost > budget:
            selected = "fast"
        
        self.selection_history.append({
            "task": str(task)[:50],
            "selected": selected,
            "complexity": complexity,
            "timestamp": datetime.now().isoformat()
        })
        
        return {
            "model": self.models[selected]["model"],
            "tier": selected,
            "estimated_cost": model_cost
        }
    
    def assess_complexity(self, task: dict) -> float:
        """Assess task complexity (0-1)."""
        
        task_str = str(task).lower()
        
        simple_indicators = ["read", "list", "simple", "quick"]
        complex_indicators = ["analyze", "complex", "integrate", "optimize", "security"]
        
        simple_score = sum(1 for ind in simple_indicators if ind in task_str)
        complex_score = sum(1 for ind in complex_indicators if ind in task_str)
        
        total = simple_score + complex_score
        if total == 0:
            return 0.5
        
        return complex_score / total
```

### Dynamic Batch Sizing

```python
class DynamicBatchSizer:
    """Dynamically adjusts batch sizes based on load."""
    
    def __init__(self, min_batch: int = 1, max_batch: int = 50):
        self.min_batch = min_batch
        self.max_batch = max_batch
        self.current_batch = min_batch
        self.metrics = []
    
    def adjust(self, metrics: dict) -> int:
        """Adjust batch size based on metrics."""
        
        self.metrics.append(metrics)
        
        if metrics.get("cpu_usage", 0) > 80:
            self.current_batch = max(self.min_batch, self.current_batch - 5)
        elif metrics.get("memory_usage", 0) > 80:
            self.current_batch = max(self.min_batch, self.current_batch - 5)
        elif metrics.get("queue_depth", 0) > 100:
            self.current_batch = min(self.max_batch, self.current_batch + 5)
        elif metrics.get("error_rate", 0) > 0.1:
            self.current_batch = max(self.min_batch, self.current_batch - 3)
        
        return self.current_batch
```

### Adaptive Timeout Management

```python
class AdaptiveTimeoutManager:
    """Dynamically adjusts timeouts based on performance."""
    
    def __init__(self, default_timeout: int = 30):
        self.default_timeout = default_timeout
        self.timeouts = {}
        self.latency_history = defaultdict(list)
    
    def get_timeout(self, operation: str) -> int:
        return self.timeouts.get(operation, self.default_timeout)
    
    def record_latency(self, operation: str, latency: float):
        """Record operation latency."""
        
        self.latency_history[operation].append(latency)
        
        if len(self.latency_history[operation]) > 100:
            self.latency_history[operation] = self.latency_history[operation][-100:]
        
        self.adapt_timeout(operation)
    
    def adapt_timeout(self, operation: str):
        """Adapt timeout based on latency history."""
        
        latencies = self.latency_history.get(operation, [])
        if len(latencies) < 5:
            return
        
        sorted_latencies = sorted(latencies)
        p95_index = int(len(sorted_latencies) * 0.95)
        p95_latency = sorted_latencies[p95_index]
        
        new_timeout = max(30, int(p95_latency * 2))
        self.timeouts[operation] = new_timeout
```

---

## Main Self-Adapting System

```python
class SelfAdaptingSystem:
    """Main self-adapting orchestrator."""
    
    def __init__(self):
        self.context_detector = ContextDetector()
        self.strategy_selector = StrategySelector()
        self.config_adapter = ConfigAdapter()
        self.adaptation_history = []
        self.adaptation_count = 0
    
    def detect_and_adapt(self, context: dict) -> dict:
        """Detect context changes and adapt."""
        
        changes = self.context_detector.detect(context)
        
        if not any(changes.values()):
            return {"adapted": False, "reason": "No context changes"}
        
        selection = self.strategy_selector.select(context)
        
        if not selection["selected"]:
            return {"adapted": False, "reason": "No matching strategy"}
        
        adaptations = []
        for config_name in self.config_adapter.configs:
            result = self.config_adapter.adapt(config_name, context)
            if result["success"]:
                adaptations.append({
                    "config": config_name,
                    "adaptations": result["adaptations"]
                })
        
        adaptation = {
            "changes": changes,
            "strategy": selection["selected"],
            "adaptations": adaptations,
            "timestamp": datetime.now().isoformat()
        }
        
        self.adaptation_history.append(adaptation)
        self.adaptation_count += 1
        
        return {
            "adapted": True,
            "strategy": selection["selected"],
            "adaptations": adaptations,
            "adaptation_id": self.adaptation_count
        }
    
    def get_adaptation_report(self) -> dict:
        return {
            "total_adaptations": self.adaptation_count,
            "recent_adaptations": self.adaptation_history[-5:],
            "strategy_stats": {
                name: {"usage": info["usage_count"], "success_rate": info["success_rate"]}
                for name, info in self.strategy_selector.strategies.items()
            }
        }
```

---

## Usage Examples

### Basic Adaptation

```python
adapter = SelfAdaptingSystem()

adapter.strategy_selector.register_strategy(
    "high_load",
    {"concurrency": 2, "batch_size": 5},
    {"load": "high"}
)

adapter.strategy_selector.register_strategy(
    "low_load",
    {"concurrency": 10, "batch_size": 20},
    {"load": "low"}
)

result = adapter.detect_and_adapt({"load": "high"})
if result["adapted"]:
    print(f"Adapted to high load: {result['strategy']}")
```

---

## Best Practices

1. **Define clear adaptation triggers** — know when to adapt
2. **Have fallback strategies** — if adaptation fails
3. **Track adaptation success** — learn what works
4. **Avoid over-adaptation** — don't change too much at once
5. **Test adaptations** — verify changes don't break things
6. **Version configurations** — track what changed
7. **Human oversight for critical changes** — some adaptations need review
8. **Monitor adaptation effects** — ensure adaptations help

---

## Integration

| Capability | How it integrates |
|---|---|
| **Self-Improving** | Improved strategies inform adaptation |
| **Self-Monitoring** | Monitoring detects need for adaptation |
| **Self-Planning** | Plans adapt based on context |
| **Self-Evolution** | Adaptation is a form of evolution |
| **Self-Governing** | Governance constrains adaptations |

---

## Advanced Adaptation Patterns

### Context-Aware Model Selection

```python
class ContextAwareModelSelector:
    """Selects model based on multiple context factors."""
    
    def __init__(self):
        self.models = {
            "mini": {"cost": 0.15, "quality": 0.7, "speed": "fast"},
            "standard": {"cost": 2.50, "quality": 0.85, "speed": "medium"},
            "premium": {"cost": 15.0, "quality": 0.95, "speed": "slow"}
        }
    
    def select(self, context: dict) -> str:
        """Select model based on context."""
        
        # Factor 1: Task complexity
        complexity = context.get("complexity", 0.5)
        
        # Factor 2: Budget
        budget = context.get("budget_remaining", float('inf'))
        
        # Factor 3: Latency requirement
        latency = context.get("latency_required", "normal")
        
        # Factor 4: Quality requirement
        quality = context.get("quality_required", "normal")
        
        # Decision matrix
        if complexity < 0.3 and budget < 1.0:
            return "mini"
        elif complexity > 0.7 or quality == "high":
            return "premium"
        elif latency == "fast":
            return "mini"
        else:
            return "standard"
```

### Dynamic Resource Allocation

```python
class DynamicResourceAllocator:
    """Dynamically allocates resources based on demand."""
    
    def __init__(self):
        self.resources = {
            "cpu": {"total": 100, "allocated": 0},
            "memory": {"total": 1000, "allocated": 0},
            "network": {"total": 100, "allocated": 0}
        }
    
    def allocate(self, task: dict) -> dict:
        """Allocate resources for a task."""
        
        requirements = self.estimate_requirements(task)
        
        allocation = {}
        for resource, needed in requirements.items():
            available = self.resources[resource]["total"] - self.resources[resource]["allocated"]
            
            if needed <= available:
                allocation[resource] = needed
                self.resources[resource]["allocated"] += needed
            else:
                allocation[resource] = available
                self.resources[resource]["allocated"] = self.resources[resource]["total"]
        
        return allocation
    
    def release(self, allocation: dict):
        """Release allocated resources."""
        
        for resource, amount in allocation.items():
            self.resources[resource]["allocated"] -= amount
    
    def estimate_requirements(self, task: dict) -> dict:
        """Estimate resource requirements for a task."""
        
        complexity = task.get("complexity", 0.5)
        
        return {
            "cpu": int(10 + complexity * 40),
            "memory": int(100 + complexity * 400),
            "network": int(10 + complexity * 30)
        }
```

### Adaptive Error Handling

```python
class AdaptiveErrorHandler:
    """Adapts error handling based on error patterns."""
    
    def __init__(self):
        self.error_patterns = {}
        self.handling_strategies = {}
    
    def record_error(self, error_type: str, handling: str, success: bool):
        """Record error handling outcome."""
        
        if error_type not in self.error_patterns:
            self.error_patterns[error_type] = {}
        
        if handling not in self.error_patterns[error_type]:
            self.error_patterns[error_type][handling] = {"attempts": 0, "successes": 0}
        
        self.error_patterns[error_type][handling]["attempts"] += 1
        if success:
            self.error_patterns[error_type][handling]["successes"] += 1
    
    def get_best_strategy(self, error_type: str) -> str:
        """Get best handling strategy for error type."""
        
        if error_type not in self.error_patterns:
            return "retry"
        
        strategies = self.error_patterns[error_type]
        
        best_strategy = None
        best_rate = 0
        
        for strategy, stats in strategies.items():
            if stats["attempts"] > 0:
                rate = stats["successes"] / stats["attempts"]
                if rate > best_rate:
                    best_rate = rate
                    best_strategy = strategy
        
        return best_strategy or "retry"
```

### Adaptation Safety Rules

1. **Never adapt safety-critical components** — permission gates, HITL
2. **Require approval for major changes** — architecture modifications
3. **Test adaptations in sandbox** — verify before deploying
4. **Maintain rollback capability** — undo if adaptation fails
5. **Monitor adaptation effects** — track if adaptations help
6. **Document all adaptations** — track what changed and why
7. **Human oversight for novel contexts** — don't adapt to unknown situations
8. **Limit adaptation frequency** — prevent rapid, destabilizing changes

### Adaptation Metrics

| Metric | Description | Target |
|---|---|---|
| Adaptation frequency | Changes per day | 1-5 |
| Adaptation success rate | % that improve performance | > 70% |
| Adaptation latency | Time to adapt | < 30s |
| Rollback rate | % that need rollback | < 10% |
| Performance improvement | Change after adaptation | > 5% |

### Common Adaptation Pitfalls

| Pitfall | Description | Prevention |
|---|---|---|
| Over-adaptation | Changing too much too fast | Limit changes per session |
| Adaptation loops | Adaptations cancel each other out | Track adaptation history |
| Context blindness | Adapting to wrong context signals | Validate context quality |
| Safety regression | Adaptations weaken safety | Safety-first adaptation policy |
| Resource exhaustion | Adaptations consume too many resources | Budget limits on adaptations |

---

## Further Reading

- **Self-Monitoring** — Detect when adaptation is needed
- **Self-Improving** — Learn from adaptation outcomes
- **Cost Optimization** — Adapt model selection based on context
- **Self-Governing** — Ensuring adaptations stay safe
- **Self-Evolution** — Adaptation as a form of evolution

---

## Quick Reference

| Concept | Description |
|---|---|
| **Context detection** | Identifying environmental changes |
| **Strategy selection** | Choosing appropriate behavior |
| **Configuration adaptation** | Adjusting parameters |
| **Model routing** | Selecting optimal model per task |
| **Batch sizing** | Dynamic batch size adjustment |
| **Timeout management** | Adaptive timeout settings |
| **Error handling** | Context-aware error strategies |
