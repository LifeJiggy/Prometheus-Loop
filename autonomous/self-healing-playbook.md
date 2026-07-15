# Self-Healing Playbook

## Healing Strategies

### Strategy 1: Retry with Backoff

```python
def retry_with_backoff(action, max_retries=3, base_delay=1.0):
    """Retry with exponential backoff."""
    
    import time
    
    for attempt in range(max_retries):
        try:
            return action()
        except Exception as e:
            if attempt == max_retries - 1:
                raise e
            
            delay = base_delay * (2 ** attempt)
            time.sleep(delay)
    
    raise Exception("Max retries exceeded")
```

### Strategy 2: Fallback

```python
def with_fallback(primary, fallback):
    """Execute with fallback."""
    
    try:
        return primary()
    except Exception as e:
        print(f"Primary failed: {e}, trying fallback")
        return fallback()
```

### Strategy 3: Circuit Breaker

```python
class CircuitBreaker:
    def __init__(self, threshold=5, timeout=60):
        self.threshold = threshold
        self.timeout = timeout
        self.failures = 0
        self.last_failure = None
        self.state = "closed"
    
    def execute(self, action):
        """Execute with circuit breaker."""
        
        if self.state == "open":
            if time.time() - self.last_failure > self.timeout:
                self.state = "half-open"
            else:
                raise Exception("Circuit breaker open")
        
        try:
            result = action()
            self.record_success()
            return result
        except Exception as e:
            self.record_failure()
            raise e
    
    def record_success(self):
        self.failures = 0
        self.state = "closed"
    
    def record_failure(self):
        self.failures += 1
        self.last_failure = time.time()
        if self.failures >= self.threshold:
            self.state = "open"
```

## Healing Checklist

- [ ] Identify failure type
- [ ] Check if retryable
- [ ] Apply appropriate strategy
- [ ] Verify fix worked
- [ ] Log healing attempt
- [ ] Update patterns if successful

## Common Healing Patterns

| Error Type | Strategy | Implementation |
|---|---|---|
| Connection timeout | Retry with backoff | Exponential backoff |
| Rate limit | Wait and retry | Respect rate limit headers |
| Service unavailable | Circuit breaker | Stop calling, retry later |
| Invalid input | Fix parameters | Validate before calling |
| Resource exhausted | Free resources | Cleanup, compress, cache |
