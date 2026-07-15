# Cost Optimization Strategies

## Model Selection

### Cost Tiers

| Tier | Model | Cost (per 1M tokens) | Use Case |
|---|---|---|---|
| **Budget** | GPT-4o-mini | $0.15 | Simple tasks, classification |
| **Standard** | GPT-4o | $2.50 | General purpose |
| **Premium** | GPT-4o + verification | $5.00 | Critical tasks |
| **Enterprise** | Custom models | Variable | High-volume, specialized |

### Smart Routing

```python
def select_model(task: dict, budget: float) -> str:
    """Select model based on task and budget."""
    
    complexity = assess_complexity(task)
    
    if budget < 0.10:
        return "gpt-4o-mini"
    elif complexity > 0.7:
        return "gpt-4o"
    elif budget > 1.0:
        return "gpt-4o"
    else:
        return "gpt-4o-mini"
```

## Caching Strategies

### Response Cache

```python
from functools import lru_cache

@lru_cache(maxsize=1000)
def cached_llm_call(prompt: str) -> str:
    """Cache LLM responses."""
    return llm.complete(prompt)
```

### Semantic Cache

```python
class SemanticCache:
    def __init__(self, threshold=0.95):
        self.threshold = threshold
        self.cache = {}
    
    def get(self, query: str) -> str:
        """Get cached result if similar query exists."""
        
        for cached_query, cached_result in self.cache.items():
            similarity = self.compute_similarity(query, cached_query)
            if similarity > self.threshold:
                return cached_result
        
        return None
    
    def set(self, query: str, result: str):
        """Store in cache."""
        self.cache[query] = result
```

## Context Compression

```python
def compress_context(context: str, max_tokens: int = 4000) -> str:
    """Compress context to fit within limits."""
    
    tokens = len(context.split())
    
    if tokens <= max_tokens:
        return context
    
    # Strategy 1: Truncate
    truncated = " ".join(context.split()[:max_tokens])
    
    # Strategy 2: Summarize
    summary = llm.complete(f"Summarize: {context}")
    
    # Strategy 3: Extract key points
    key_points = llm.complete(f"Extract key points: {context}")
    
    # Use shortest that fits
    options = [truncated, summary, key_points]
    return min(options, key=lambda x: len(x.split()))
```

## Cost Tracking

```python
class CostTracker:
    def __init__(self, daily_budget: float, task_budget: float):
        self.daily_budget = daily_budget
        self.task_budget = task_budget
        self.daily_spent = 0.0
        self.task_spent = 0.0
        self.history = []
    
    def record(self, tokens: int, model: str):
        """Record cost."""
        
        cost = self.calculate_cost(tokens, model)
        
        self.daily_spent += cost
        self.task_spent += cost
        
        self.history.append({
            "tokens": tokens,
            "model": model,
            "cost": cost,
            "timestamp": datetime.now().isoformat()
        })
        
        # Check limits
        if self.task_spent > self.task_budget:
            raise Exception("Task budget exceeded")
        
        if self.daily_spent > self.daily_budget * 0.9:
            print(f"Warning: Approaching daily budget ({self.daily_spent:.2f}/{self.daily_budget:.2f})")
    
    def calculate_cost(self, tokens: int, model: str) -> float:
        """Calculate cost."""
        
        rates = {
            "gpt-4o-mini": 0.15 / 1_000_000,
            "gpt-4o": 2.50 / 1_000_000
        }
        
        return tokens * rates.get(model, 2.50 / 1_000_000)
    
    def get_report(self) -> dict:
        """Get cost report."""
        
        return {
            "daily": {
                "budget": self.daily_budget,
                "spent": self.daily_spent,
                "remaining": self.daily_budget - self.daily_spent
            },
            "task": {
                "budget": self.task_budget,
                "spent": self.task_spent,
                "remaining": self.task_budget - self.task_spent
            },
            "total_calls": len(self.history),
            "avg_cost_per_call": sum(h["cost"] for h in self.history) / len(self.history) if self.history else 0
        }
```

## Cost Optimization Checklist

- [ ] Use cheapest model for simple tasks
- [ ] Cache frequent queries
- [ ] Compress context
- [ ] Batch operations
- [ ] Monitor costs
- [ ] Set budget alerts
- [ ] Review cost reports regularly
