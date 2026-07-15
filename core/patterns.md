# Common Patterns Library

## Pattern 1: Tool Selection

**When to use:** Agent needs to choose between multiple tools.

```python
def select_tool(task: str, tools: list) -> dict:
    """Select the best tool for a task."""
    
    # Analyze task
    task_type = analyze_task_type(task)
    
    # Match to tools
    for tool in tools:
        if tool["category"] == task_type:
            return tool
    
    # Fallback to general tool
    return tools[0]
```

## Pattern 2: Context Enrichment

**When to use:** Agent needs more context than provided.

```python
def enrich_context(task: str, initial_context: dict) -> dict:
    """Enrich context with additional information."""
    
    # Add relevant documents
    docs = retrieve_relevant(task)
    
    # Add memory
    memories = memory.retrieve(task)
    
    # Add user preferences
    preferences = get_user_preferences()
    
    return {
        **initial_context,
        "documents": docs,
        "memories": memories,
        "preferences": preferences
    }
```

## Pattern 3: Error Classification

**When to use:** Agent needs to handle different error types differently.

```python
def classify_error(error: Exception) -> dict:
    """Classify an error type."""
    
    error_type = type(error).__name__
    
    classifications = {
        "ConnectionError": {"retryable": True, "severity": "medium"},
        "TimeoutError": {"retryable": True, "severity": "medium"},
        "PermissionError": {"retryable": False, "severity": "high"},
        "FileNotFoundError": {"retryable": False, "severity": "low"},
        "ValueError": {"retryable": False, "severity": "medium"}
    }
    
    return classifications.get(error_type, {"retryable": False, "severity": "unknown"})
```

## Pattern 4: Progress Tracking

**When to use:** Long-running tasks need progress updates.

```python
class ProgressTracker:
    def __init__(self):
        self.steps = []
        self.current = 0
    
    def add_step(self, description: str):
        """Add a step to track."""
        self.steps.append({"description": description, "status": "pending"})
    
    def start_step(self, index: int):
        """Mark step as started."""
        self.steps[index]["status"] = "in_progress"
    
    def complete_step(self, index: int):
        """Mark step as completed."""
        self.steps[index]["status"] = "completed"
        self.current = index + 1
    
    def get_progress(self) -> dict:
        """Get current progress."""
        completed = sum(1 for s in self.steps if s["status"] == "completed")
        return {
            "total": len(self.steps),
            "completed": completed,
            "percentage": completed / len(self.steps) * 100 if self.steps else 0
        }
```

## Pattern 5: Caching

**When to use:** Repeated queries should be cached.

```python
from functools import lru_cache

@lru_cache(maxsize=1000)
def cached_query(query: str) -> str:
    """Cache query results."""
    return expensive_operation(query)

# Or with TTL
from cachetools import TTLCache

cache = TTLCache(maxsize=1000, ttl=300)  # 5 minute TTL

def cached_with_ttl(query: str) -> str:
    """Cache with time-to-live."""
    if query in cache:
        return cache[query]
    
    result = expensive_operation(query)
    cache[query] = result
    return result
```

## Pattern 6: Rate Limiting

**When to use:** API calls need rate limiting.

```python
import time
from collections import deque

class RateLimiter:
    def __init__(self, max_calls: int, time_window: int):
        self.max_calls = max_calls
        self.time_window = time_window
        self.calls = deque()
    
    def can_call(self) -> bool:
        """Check if a call is allowed."""
        now = time.time()
        
        # Remove old calls
        while self.calls and self.calls[0] < now - self.time_window:
            self.calls.popleft()
        
        # Check limit
        if len(self.calls) >= self.max_calls:
            return False
        
        self.calls.append(now)
        return True
    
    def wait_if_needed(self):
        """Wait if rate limit would be exceeded."""
        if not self.can_call():
            wait_time = self.time_window - (time.time() - self.calls[0])
            time.sleep(wait_time)
```

## Pattern 7: Circuit Breaker

**When to use:** Prevent cascade failures.

```python
class CircuitBreaker:
    def __init__(self, failure_threshold: int = 5, recovery_timeout: int = 60):
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.failure_count = 0
        self.last_failure_time = None
        self.state = "closed"
    
    def record_failure(self):
        """Record a failure."""
        self.failure_count += 1
        self.last_failure_time = time.time()
        
        if self.failure_count >= self.failure_threshold:
            self.state = "open"
    
    def record_success(self):
        """Record a success."""
        self.failure_count = 0
        self.state = "closed"
    
    def can_execute(self) -> bool:
        """Check if execution is allowed."""
        if self.state == "closed":
            return True
        
        if self.state == "open":
            if time.time() - self.last_failure_time > self.recovery_timeout:
                self.state = "half-open"
                return True
            return False
        
        return True  # half-open
```

## Pattern 8: Memory Management

**When to use:** Agent needs to remember things across interactions.

```python
class SimpleMemory:
    def __init__(self):
        self.memories = []
        self.max_size = 1000
    
    def store(self, key: str, value: any, importance: float = 0.5):
        """Store a memory."""
        self.memories.append({
            "key": key,
            "value": value,
            "importance": importance,
            "timestamp": time.time()
        })
        
        # Evict if over size
        if len(self.memories) > self.max_size:
            self.evict()
    
    def retrieve(self, query: str, top_k: int = 5) -> list:
        """Retrieve relevant memories."""
        
        scored = []
        for memory in self.memories:
            score = self.score_relevance(memory, query)
            scored.append((score, memory))
        
        scored.sort(key=lambda x: x[0], reverse=True)
        return [memory for _, memory in scored[:top_k]]
    
    def score_relevance(self, memory: dict, query: str) -> float:
        """Score relevance of memory to query."""
        
        # Simple keyword matching
        query_words = set(query.lower().split())
        memory_words = set(str(memory["key"]).lower().split())
        
        overlap = len(query_words & memory_words)
        return overlap / max(len(query_words), 1)
    
    def evict(self):
        """Evict least important memories."""
        
        # Sort by importance
        self.memories.sort(key=lambda m: m["importance"])
        
        # Remove bottom 10%
        remove_count = max(1, len(self.memories) // 10)
        self.memories = self.memories[remove_count:]
```

## Pattern 9: Observability

**When to use:** Need to understand what the agent is doing.

```python
class SimpleObservability:
    def __init__(self):
        self.metrics = {}
        self.traces = []
    
    def record_metric(self, name: str, value: float):
        """Record a metric."""
        if name not in self.metrics:
            self.metrics[name] = []
        self.metrics[name].append({"value": value, "timestamp": time.time()})
    
    def start_trace(self, name: str):
        """Start a trace."""
        self.traces.append({
            "name": name,
            "start_time": time.time(),
            "events": []
        })
    
    def add_event(self, event: str):
        """Add event to current trace."""
        if self.traces:
            self.traces[-1]["events"].append({
                "event": event,
                "timestamp": time.time()
            })
    
    def end_trace(self):
        """End current trace."""
        if self.traces:
            self.traces[-1]["end_time"] = time.time()
```

## Pattern 10: Error Recovery

**When to use:** Agent needs to recover from failures gracefully.

```python
class ErrorRecovery:
    def __init__(self):
        self.recovery_strategies = {}
    
    def register_strategy(self, error_type: str, strategy: callable):
        """Register a recovery strategy."""
        self.recovery_strategies[error_type] = strategy
    
    def recover(self, error: Exception, context: dict) -> dict:
        """Attempt recovery from error."""
        
        error_type = type(error).__name__
        
        # Try registered strategy
        if error_type in self.recovery_strategies:
            return self.recovery_strategies[error_type](error, context)
        
        # Try generic recovery
        return self.generic_recovery(error, context)
    
    def generic_recovery(self, error: Exception, context: dict) -> dict:
        """Generic recovery strategy."""
        
        # Log error
        print(f"Error: {error}")
        
        # Try simplifying the task
        simplified_task = f"Simply answer: {context.get('task', 'unknown')}"
        
        try:
            result = client.chat.completions.create(
                model="gpt-4",
                messages=[{"role": "user", "content": simplified_task}]
            )
            return {"success": True, "result": result.choices[0].message.content}
        except Exception as e:
            return {"success": False, "error": str(e)}
```
