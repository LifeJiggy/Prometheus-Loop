# Cost Optimization Playbook

## Cost Drivers

| Driver | Impact | Optimization |
|---|---|---|
| **Model selection** | 10-50x cost difference | Use cheaper models for simple tasks |
| **Context length** | Linear cost increase | Compress, cache, truncate |
| **Retry loops** | 2-5x cost increase | Fix root cause, not symptoms |
| **Unnecessary calls** | 100% waste | Cache, batch, skip |

## Optimization Strategies

### 1. Model Routing

```python
def select_model(task_complexity: str) -> str:
    """Select cheapest model for task."""
    
    models = {
        "simple": "gpt-4o-mini",  # $0.15/1M tokens
        "moderate": "gpt-4o",     # $2.50/1M tokens
        "complex": "gpt-4o"       # $2.50/1M tokens
    }
    
    return models.get(task_complexity, "gpt-4o")
```

### 2. Context Compression

```python
def compress_context(context: str, max_tokens: int = 4000) -> str:
    """Compress context to fit within limits."""
    
    # Simple truncation
    if len(context.split()) > max_tokens:
        words = context.split()[:max_tokens]
        return " ".join(words)
    
    return context
```

### 3. Caching

```python
from functools import lru_cache

@lru_cache(maxsize=1000)
def cached_llm_call(prompt: str) -> str:
    """Cache LLM responses."""
    return llm.complete(prompt)
```

### 4. Batching

```python
def batch_process(tasks: list) -> list:
    """Process multiple tasks in batch."""
    
    # Combine prompts
    combined_prompt = "\n".join([f"Task {i}: {task}" for i, task in enumerate(tasks)])
    
    # Single LLM call
    result = llm.complete(combined_prompt)
    
    # Parse results
    return parse_batch_result(result)
```

## Cost Tracking

```python
class CostTracker:
    def __init__(self, budget: float):
        self.budget = budget
        self.spent = 0.0
    
    def record(self, tokens: int, model: str):
        """Record cost."""
        cost = self.calculate_cost(tokens, model)
        self.spent += cost
        
        if self.spent > self.budget * 0.8:
            print(f"Warning: Approaching budget limit ({self.spent:.2f}/{self.budget:.2f})")
    
    def calculate_cost(self, tokens: int, model: str) -> float:
        """Calculate cost."""
        rates = {
            "gpt-4o-mini": 0.15 / 1_000_000,
            "gpt-4o": 2.50 / 1_000_000
        }
        return tokens * rates.get(model, 2.50 / 1_000_000)
    
    def get_summary(self) -> dict:
        """Get cost summary."""
        return {
            "budget": self.budget,
            "spent": self.spent,
            "remaining": self.budget - self.spent,
            "percentage": (self.spent / self.budget) * 100
        }
```

## Cost Reduction Tips

1. **Use GPT-4o-mini for simple tasks** — 16x cheaper than GPT-4o
2. **Cache frequently used prompts** — avoid redundant API calls
3. **Compress context** — reduce token usage
4. **Batch operations** — combine multiple tasks into one call
5. **Monitor costs** — track and alert on budget usage
