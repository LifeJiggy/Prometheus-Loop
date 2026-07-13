# Cost Optimization Strategies

## Model Routing

Route tasks to the cheapest model that can handle them:

```python
def select_model(task_complexity: str, task_type: str) -> str:
    """Select the cheapest model that can handle the task."""
    
    complexity_map = {
        "simple": "gpt-4o-mini",      # $0.15/1M input
        "moderate": "gpt-4o",          # $2.50/1M input
        "complex": "gpt-4o",           # $2.50/1M input
        "critical": "gpt-4o",          # $2.50/1M input + verification
    }
    
    # Override for specific task types
    task_overrides = {
        "code_review": "gpt-4o-mini",     # Simple pattern matching
        "architecture_design": "gpt-4o",  # Complex reasoning
        "bug_fix": "gpt-4o-mini",         # Usually straightforward
        "security_audit": "gpt-4o",       # Needs careful reasoning
    }
    
    return task_overrides.get(task_type, complexity_map[task_complexity])
```

## Caching Strategies

### Response Cache

```python
import hashlib
from functools import lru_cache

def cache_key(task: str, context: str) -> str:
    """Generate cache key from task + context."""
    content = f"{task}:{context}"
    return hashlib.sha256(content.encode()).hexdigest()

@lru_cache(maxsize=1000)
def cached_llm_call(task: str, context: str) -> str:
    """Cache LLM responses for identical inputs."""
    return llm.call(task, context)
```

### Tool Result Cache

```python
# Cache tool results with TTL
tool_cache = TTLCache(maxsize=500, ttl=3600)  # 1 hour TTL

def cached_tool_call(tool_name: str, params: dict) -> dict:
    """Cache tool results to avoid redundant calls."""
    key = f"{tool_name}:{hashlib.md5(str(params).encode()).hexdigest()}"
    
    if key in tool_cache:
        return tool_cache[key]
    
    result = tools[tool_name](params)
    tool_cache[key] = result
    return result
```

### Semantic Cache

```python
# Cache based on semantic similarity
from sentence_transformers import SentenceTransformer

model = SentenceTransformer('all-MiniLM-L6-v2')
semantic_cache = {}

def semantic_cached_call(task: str, threshold: float = 0.95) -> str:
    """Return cached result if a semantically similar task exists."""
    task_embedding = model.encode(task)
    
    for cached_task, cached_result in semantic_cache.items():
        similarity = cosine_similarity(task_embedding, cached_task)
        if similarity > threshold:
            return cached_result
    
    result = llm.call(task)
    semantic_cache[task] = (task_embedding, result)
    return result
```

## Context Compression

```python
def compress_context(context: list, max_tokens: int = 4000) -> str:
    """Compress context to fit within token limits."""
    
    # Strategy 1: Summarize old context
    if total_tokens(context) > max_tokens:
        old_context = context[:-3]  # Everything except last 3 messages
        recent_context = context[-3:]
        
        summary = llm.call(f"Summarize this conversation: {old_context}")
        context = [{"role": "system", "content": summary}] + recent_context
    
    # Strategy 2: Extract relevant chunks
    relevant_chunks = retrieve_relevant(task, context, top_k=5)
    
    # Strategy 3: Remove redundant information
    deduplicated = deduplicate(context)
    
    return format_context(deduplicated)
```

## Batching

```python
async def batch_process(tasks: list, batch_size: int = 10) -> list:
    """Process multiple tasks in parallel batches."""
    
    results = []
    for i in range(0, len(tasks), batch_size):
        batch = tasks[i:i+batch_size]
        
        # Process batch in parallel
        batch_results = await asyncio.gather(*[
            process_task(task) for task in batch
        ])
        
        results.extend(batch_results)
    
    return results
```

## Cost Tracking

```python
class CostTracker:
    def __init__(self, budget: float):
        self.budget = budget
        self.spent = 0.0
        self.calls = []
    
    def log_call(self, model: str, tokens: int, cost: float):
        """Log an LLM call and track costs."""
        self.spent += cost
        self.calls.append({
            "model": model,
            "tokens": tokens,
            "cost": cost,
            "timestamp": datetime.now()
        })
        
        if self.spent > self.budget * 0.8:
            self.alert("Approaching budget limit")
    
    def get_summary(self) -> dict:
        """Get cost summary."""
        return {
            "total_spent": self.spent,
            "budget_remaining": self.budget - self.spent,
            "avg_cost_per_call": self.spent / len(self.calls) if self.calls else 0,
            "calls_by_model": self._calls_by_model()
        }
```

## Budget Enforcement

```python
def check_budget(task_cost: float, tracker: CostTracker) -> bool:
    """Check if task can be executed within budget."""
    
    if tracker.spent + task_cost > tracker.budget:
        # Option 1: Block
        raise BudgetExceededException("Budget exceeded")
        
        # Option 2: Degrade
        return use_cheaper_model()
        
        # Option 3: Warn and continue
        logger.warning(f"Budget warning: {tracker.spent + task_cost}/{tracker.budget}")
        return True
    
    return True
```
