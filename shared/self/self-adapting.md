# Self-Adapting Deep Dive

## Overview

Self-Adapting is the agent's ability to adjust its behavior, strategies, and configurations based on changing context, environmental conditions, and task requirements — without explicit reprogramming.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                     SELF-ADAPTING SYSTEM                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐        │
│  │ Context  │──▶│ Strategy │──▶│ Config   │──▶│ Verify   │        │
│  │ Detector │   │ Selector │   │ Adapter  │   │ Adaptation│       │
│  └──────────┘   └──────────┘   └──────────┘   └──────────┘        │
│       │              │              │               │                │
│       ▼              ▼              ▼               ▼                │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐        │
│  │  Env     │   │ Behavior │   │ Feature  │   │ Feedback │        │
│  │ Monitor  │   │ Library  │   │ Flags    │   │ Loop     │        │
│  └──────────┘   └──────────┘   └──────────┘   └──────────┘        │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    ADAPTATION MEMORY                         │   │
│  │  Context Patterns │ Successful Adaptations │ Performance Data │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

## Core Implementation

### Context Detector

```python
class ContextDetector:
    """Detects context changes that require adaptation."""
    
    def __init__(self):
        self.current_context = {}
        self.context_history = []
        self.change_callbacks = []
    
    def detect(self, new_context: dict) -> dict:
        """Detect context changes."""
        
        changes = {
            "added": {},
            "removed": {},
            "modified": {}
        }
        
        # Detect added keys
        for key in new_context:
            if key not in self.current_context:
                changes["added"][key] = new_context[key]
        
        # Detect removed keys
        for key in self.current_context:
            if key not in new_context:
                changes["removed"][key] = self.current_context[key]
        
        # Detect modified keys
        for key in new_context:
            if key in self.current_context:
                if new_context[key] != self.current_context[key]:
                    changes["modified"][key] = {
                        "old": self.current_context[key],
                        "new": new_context[key]
                    }
        
        # Update current context
        self.current_context = new_context.copy()
        self.context_history.append({
            "context": new_context,
            "changes": changes,
            "timestamp": datetime.now().isoformat()
        })
        
        # Notify callbacks if there are changes
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
        """Get current context."""
        
        return self.current_context.copy()
    
    def get_change_history(self, limit: int = 10) -> list:
        """Get recent context changes."""
        
        return self.context_history[-limit:]
```

### Strategy Selector

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
        
        # Sort by score
        candidates.sort(key=lambda x: x["score"], reverse=True)
        
        selected = candidates[0]
        
        # Update usage count
        self.strategies[selected["name"]]["usage_count"] += 1
        
        # Record selection
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
                # Numeric comparison with tolerance
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

### Configuration Adapter

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
        
        # Apply adapter if available
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
        
        # Adapt based on resource availability
        if context.get("memory_pressure") == "high":
            adapted["cache_size"] = min(adapted.get("cache_size", 100), 50)
            adapted["batch_size"] = min(adapted.get("batch_size", 10), 5)
        
        # Adapt based on performance
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
        """Get current adapted configuration."""
        
        return self.current_config.get(config_name, self.configs.get(config_name, {}))
```

### Main Self-Adapting System

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
        
        # Detect changes
        changes = self.context_detector.detect(context)
        
        if not any(changes.values()):
            return {"adapted": False, "reason": "No context changes"}
        
        # Select strategy
        selection = self.strategy_selector.select(context)
        
        if not selection["selected"]:
            return {"adapted": False, "reason": "No matching strategy"}
        
        # Adapt configurations
        adaptations = []
        for config_name in self.config_adapter.configs:
            result = self.config_adapter.adapt(config_name, context)
            if result["success"]:
                adaptations.append({
                    "config": config_name,
                    "adaptations": result["adaptations"]
                })
        
        # Record adaptation
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
        """Get adaptation report."""
        
        return {
            "total_adaptations": self.adaptation_count,
            "recent_adaptations": self.adaptation_history[-5:],
            "strategy_stats": {
                name: {
                    "usage": info["usage_count"],
                    "success_rate": info["success_rate"]
                }
                for name, info in self.strategy_selector.strategies.items()
            }
        }
```

## Usage Examples

### Example 1: Adapt to Load

```python
adapter = SelfAdaptingSystem()

# Register strategies
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

# Detect and adapt
result = adapter.detect_and_adapt({"load": "high"})
if result["adapted"]:
    print(f"Adapted to high load: {result['strategy']}")
```

## Best Practices

1. **Define clear adaptation triggers** — know when to adapt
2. **Have fallback strategies** — if adaptation fails
3. **Track adaptation success** — learn what works
4. **Avoid over-adaptation** — don't change too much at once
5. **Test adaptations** — verify changes don't break things
6. **Version configurations** — track what changed
7. **Human oversight for critical changes** — some adaptations need review
8. **Monitor adaptation effects** — ensure adaptations help

## Advanced Adaptation Patterns

### Context-Aware Model Selection

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
        
        # Analyze task complexity
        complexity = self.assess_complexity(task)
        
        # Check constraints
        budget = context.get("budget_remaining", float('inf'))
        latency_required = context.get("latency_required", "normal")
        
        # Select model
        if budget < 1.0 or latency_required == "fast":
            selected = "fast"
        elif complexity > 0.7 or context.get("quality_required") == "high":
            selected = "powerful"
        else:
            selected = "balanced"
        
        # Verify budget
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
        
        # Calculate optimal batch size
        if metrics.get("cpu_usage", 0) > 80:
            # High CPU - reduce batch size
            self.current_batch = max(self.min_batch, self.current_batch - 5)
        elif metrics.get("memory_usage", 0) > 80:
            # High memory - reduce batch size
            self.current_batch = max(self.min_batch, self.current_batch - 5)
        elif metrics.get("queue_depth", 0) > 100:
            # Large queue - increase batch size
            self.current_batch = min(self.max_batch, self.current_batch + 5)
        elif metrics.get("error_rate", 0) > 0.1:
            # High errors - reduce batch size
            self.current_batch = max(self.min_batch, self.current_batch - 3)
        
        return self.current_batch
    
    def get_stats(self) -> dict:
        """Get batching statistics."""
        
        return {
            "current_batch": self.current_batch,
            "min_batch": self.min_batch,
            "max_batch": self.max_batch,
            "adjustments": len(self.metrics)
        }
```

### Load Balancing Adaptation

```python
class LoadBalancer:
    """Adapts load distribution across workers."""
    
    def __init__(self):
        self.workers = {}
        self.load_history = defaultdict(list)
    
    def register_worker(self, worker_id: str, capacity: int):
        """Register a worker."""
        
        self.workers[worker_id] = {
            "capacity": capacity,
            "current_load": 0,
            "status": "healthy"
        }
    
    def distribute(self, task: dict) -> str:
        """Distribute task to best worker."""
        
        # Find worker with lowest load ratio
        best_worker = None
        best_ratio = float('inf')
        
        for worker_id, info in self.workers.items():
            if info["status"] != "healthy":
                continue
            
            ratio = info["current_load"] / info["capacity"]
            if ratio < best_ratio:
                best_ratio = ratio
                best_worker = worker_id
        
        if best_worker:
            self.workers[best_worker]["current_load"] += 1
        
        return best_worker
    
    def update_status(self, worker_id: str, status: str):
        """Update worker status."""
        
        if worker_id in self.workers:
            self.workers[worker_id]["status"] = status
            if status == "healthy":
                self.workers[worker_id]["current_load"] = 0
    
    def get_load_distribution(self) -> dict:
        """Get current load distribution."""
        
        return {
            worker_id: {
                "load": info["current_load"],
                "capacity": info["capacity"],
                "utilization": info["current_load"] / info["capacity"] if info["capacity"] > 0 else 0
            }
            for worker_id, info in self.workers.items()
        }
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
        """Get adapted timeout for an operation."""
        
        if operation in self.timeouts:
            return self.timeouts[operation]
        
        return self.default_timeout
    
    def record_latency(self, operation: str, latency: float):
        """Record operation latency."""
        
        self.latency_history[operation].append(latency)
        
        # Keep only recent history
        if len(self.latency_history[operation]) > 100:
            self.latency_history[operation] = self.latency_history[operation][-100:]
        
        # Adapt timeout based on latency
        self.adapt_timeout(operation)
    
    def adapt_timeout(self, operation: str):
        """Adapt timeout based on latency history."""
        
        latencies = self.latency_history.get(operation, [])
        if len(latencies) < 5:
            return
        
        # Calculate p95 latency
        sorted_latencies = sorted(latencies)
        p95_index = int(len(sorted_latencies) * 0.95)
        p95_latency = sorted_latencies[p95_index]
        
        # Set timeout to 2x p95 with minimum
        new_timeout = max(30, int(p95_latency * 2))
        
        self.timeouts[operation] = new_timeout
    
    def get_stats(self) -> dict:
        """Get timeout statistics."""
        
        stats = {}
        for operation, latencies in self.latency_history.items():
            if latencies:
                stats[operation] = {
                    "current_timeout": self.get_timeout(operation),
                    "avg_latency": sum(latencies) / len(latencies),
                    "p95_latency": sorted(latencies)[int(len(latencies) * 0.95)],
                    "samples": len(latencies)
                }
        
        return stats
```

### Adaptive Retry Configuration

```python
class AdaptiveRetryConfig:
    """Dynamically adjusts retry configuration."""
    
    def __init__(self):
        self.configs = {}
        self.failure_history = defaultdict(list)
    
    def get_config(self, operation: str) -> dict:
        """Get adapted retry config for an operation."""
        
        if operation in self.configs:
            return self.configs[operation]
        
        return {
            "max_retries": 3,
            "base_delay": 1.0,
            "max_delay": 60.0,
            "backoff_multiplier": 2.0
        }
    
    def record_outcome(self, operation: str, success: bool, attempts: int):
        """Record operation outcome."""
        
        self.failure_history[operation].append({
            "success": success,
            "attempts": attempts,
            "timestamp": datetime.now().isoformat()
        })
        
        # Adapt config based on history
        self.adapt_config(operation)
    
    def adapt_config(self, operation: str):
        """Adapt retry config based on history."""
        
        history = self.failure_history.get(operation, [])
        if len(history) < 5:
            return
        
        # Calculate success rate
        recent = history[-10:]
        success_rate = sum(1 for h in recent if h["success"]) / len(recent)
        avg_attempts = sum(h["attempts"] for h in recent) / len(recent)
        
        # Adapt
        if success_rate < 0.5:
            # Low success rate - more aggressive retries
            self.configs[operation] = {
                "max_retries": 5,
                "base_delay": 0.5,
                "max_delay": 30.0,
                "backoff_multiplier": 1.5
            }
        elif success_rate > 0.9 and avg_attempts < 2:
            # High success rate, few attempts - less aggressive
            self.configs[operation] = {
                "max_retries": 2,
                "base_delay": 2.0,
                "max_delay": 30.0,
                "backoff_multiplier": 2.0
            }
    
    def get_stats(self) -> dict:
        """Get retry configuration statistics."""
        
        return {
            "configs": self.configs,
            "operations_tracked": len(self.failure_history)
        }
```

### Integration

| Capability | Integration |
|---|---|
| **Self-Improving** | Improved strategies inform adaptation |
| **Self-Monitoring** | Monitoring detects need for adaptation |
| **Self-Planning** | Plans adapt based on context |
| **Self-Evolution** | Adaptation is a form of evolution |
| **Self-Governing** | Governance constrains adaptations |
| **Self-Remembering** | Adaptation patterns are remembered |
