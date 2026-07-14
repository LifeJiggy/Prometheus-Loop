# Self-Retry Deep Dive

## Overview

Self-Retry is the agent's ability to intelligently retry failed operations, adapting its strategy based on error type, history, and context. Unlike simple retry, it knows when to retry, when to back off, when to escalate, and when to give up.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                       SELF-RETRY SYSTEM                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐        │
│  │  Error   │──▶│ Retryable│──▶│ Strategy │──▶│ Execute  │        │
│  │ Detector │   │ Checker  │   │ Selector │   │ + Wait   │        │
│  └──────────┘   └──────────┘   └──────────┘   └──────────┘        │
│       │              │              │               │                │
│       ▼              ▼              ▼               ▼                │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐        │
│  │ Error    │   │ Check    │   │ Backoff  │   │ Circuit  │        │
│  │ Classify │   │ History  │   │ Strategy │   │ Breaker  │        │
│  └──────────┘   └──────────┘   └──────────┘   └──────────┘        │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    LEARNING LAYER                            │   │
│  │  Retry History ← Success Patterns ← Circuit Breaker Stats   │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

## Core Implementation

### Retryable Error Detector

```python
class RetryableDetector:
    """Determines if an error is retryable."""
    
    RETRYABLE_ERRORS = {
        # Network errors
        "ConnectionError": {"retryable": True, "category": "network"},
        "ConnectionRefusedError": {"retryable": True, "category": "network"},
        "ConnectionResetError": {"retryable": True, "category": "network"},
        "TimeoutError": {"retryable": True, "category": "network"},
        "SocketTimeout": {"retryable": True, "category": "network"},
        
        # Service errors
        "TemporaryError": {"retryable": True, "category": "service"},
        "ServiceUnavailable": {"retryable": True, "category": "service"},
        
        # Rate limiting
        "RateLimitError": {"retryable": True, "category": "rate_limit"},
        "TooManyRequests": {"retryable": True, "category": "rate_limit"},
        
        # Server errors
        "InternalServerError": {"retryable": True, "category": "server"},
        "BadGateway": {"retryable": True, "category": "server"},
        "GatewayTimeout": {"retryable": True, "category": "server"},
    }
    
    NON_RETRYABLE_ERRORS = {
        # Auth errors
        "PermissionError": {"retryable": False, "escalate": True},
        "AuthenticationError": {"retryable": False, "escalate": True},
        "AuthorizationError": {"retryable": False, "escalate": True},
        
        # Data errors
        "FileNotFoundError": {"retryable": False, "escalate": False},
        "KeyError": {"retryable": False, "escalate": False},
        "ValueError": {"retryable": False, "escalate": False},
        "TypeError": {"retryable": False, "escalate": False},
        
        # Resource errors
        "MemoryError": {"retryable": False, "escalate": True},
        "OutOfMemoryError": {"retryable": False, "escalate": True},
        
        # Syntax errors
        "SyntaxError": {"retryable": False, "escalate": False},
        "IndentationError": {"retryable": False, "escalate": False},
    }
    
    RETRYABLE_STATUS_CODES = {
        408: "Request Timeout",
        429: "Too Many Requests",
        500: "Internal Server Error",
        502: "Bad Gateway",
        503: "Service Unavailable",
        504: "Gateway Timeout",
    }
    
    def is_retryable(self, error: Exception, context: dict = None) -> dict:
        """Determine if error is retryable."""
        
        error_type = type(error).__name__
        error_msg = str(error)
        
        # Check explicit retryable errors
        if error_type in self.RETRYABLE_ERRORS:
            return {
                "retryable": True,
                "category": self.RETRYABLE_ERRORS[error_type]["category"],
                "reason": f"Known retryable error: {error_type}"
            }
        
        # Check explicit non-retryable errors
        if error_type in self.NON_RETRYABLE_ERRORS:
            info = self.NON_RETRYABLE_ERRORS[error_type]
            return {
                "retryable": False,
                "escalate": info.get("escalate", False),
                "reason": f"Known non-retryable error: {error_type}"
            }
        
        # Check status codes
        status_code = getattr(error, 'status_code', None)
        if status_code in self.RETRYABLE_STATUS_CODES:
            return {
                "retryable": True,
                "category": "http",
                "reason": f"Retryable HTTP status: {status_code}"
            }
        
        # Check error message patterns
        retryable_patterns = [
            "timeout", "timed out", "connection", "refused",
            "temporary", "try again", "retry", "rate limit",
            "too many requests", "service unavailable"
        ]
        
        for pattern in retryable_patterns:
            if pattern in error_msg.lower():
                return {
                    "retryable": True,
                    "category": "pattern_match",
                    "reason": f"Error message matches retryable pattern: {pattern}"
                }
        
        # Default: not retryable
        return {
            "retryable": False,
            "reason": "Unknown error type, defaulting to non-retryable"
        }
    
    def should_escalate(self, error: Exception) -> bool:
        """Determine if error should be escalated."""
        
        error_type = type(error).__name__
        
        # Always escalate these
        escalate_errors = [
            "PermissionError", "AuthenticationError", "AuthorizationError",
            "MemoryError", "OutOfMemoryError", "SecurityError"
        ]
        
        return error_type in escalate_errors
```

### Backoff Strategy Engine

```python
class BackoffStrategy:
    """Implements various backoff strategies."""
    
    def __init__(self, strategy: str = "exponential"):
        self.strategy = strategy
        self.attempt = 0
    
    def get_delay(self, attempt: int, config: dict = None) -> float:
        """Calculate delay for given attempt."""
        
        config = config or {}
        
        if self.strategy == "fixed":
            return self.fixed_backoff(attempt, config)
        elif self.strategy == "linear":
            return self.linear_backoff(attempt, config)
        elif self.strategy == "exponential":
            return self.exponential_backoff(attempt, config)
        elif self.strategy == "exponential_with_jitter":
            return self.exponential_with_jitter(attempt, config)
        elif self.strategy == "fibonacci":
            return self.fibonacci_backoff(attempt, config)
        else:
            return self.exponential_backoff(attempt, config)
    
    def fixed_backoff(self, attempt: int, config: dict) -> float:
        """Fixed delay between retries."""
        return config.get("delay", 1.0)
    
    def linear_backoff(self, attempt: int, config: dict) -> float:
        """Linear increasing delay."""
        base_delay = config.get("base_delay", 1.0)
        return base_delay * (attempt + 1)
    
    def exponential_backoff(self, attempt: int, config: dict) -> float:
        """Exponential increasing delay."""
        base_delay = config.get("base_delay", 1.0)
        max_delay = config.get("max_delay", 60.0)
        multiplier = config.get("multiplier", 2.0)
        
        delay = base_delay * (multiplier ** attempt)
        return min(delay, max_delay)
    
    def exponential_with_jitter(self, attempt: int, config: dict) -> float:
        """Exponential backoff with random jitter."""
        import random
        
        base_delay = config.get("base_delay", 1.0)
        max_delay = config.get("max_delay", 60.0)
        multiplier = config.get("multiplier", 2.0)
        
        delay = base_delay * (multiplier ** attempt)
        jitter = random.uniform(0, delay * 0.5)
        
        return min(delay + jitter, max_delay)
    
    def fibonacci_backoff(self, attempt: int, config: dict) -> float:
        """Fibonacci sequence backoff."""
        base_delay = config.get("base_delay", 1.0)
        max_delay = config.get("max_delay", 60.0)
        
        fib = self.fibonacci(attempt + 1)
        delay = base_delay * fib
        
        return min(delay, max_delay)
    
    def fibonacci(self, n: int) -> int:
        """Calculate fibonacci number."""
        if n <= 1:
            return n
        a, b = 0, 1
        for _ in range(2, n + 1):
            a, b = b, a + b
        return b
```

### Circuit Breaker

```python
class CircuitBreaker:
    """Prevents repeated calls to failing services."""
    
    def __init__(self, failure_threshold: int = 5, recovery_timeout: int = 60):
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.state = "closed"  # closed, open, half-open
        self.failure_count = 0
        self.success_count = 0
        self.last_failure_time = None
        self.half_open_max = 3
    
    def record_success(self):
        """Record a successful call."""
        
        if self.state == "half-open":
            self.success_count += 1
            if self.success_count >= self.half_open_max:
                self.state = "closed"
                self.failure_count = 0
                self.success_count = 0
        elif self.state == "closed":
            self.failure_count = max(0, self.failure_count - 1)
    
    def record_failure(self):
        """Record a failed call."""
        
        self.failure_count += 1
        self.last_failure_time = time.time()
        
        if self.failure_count >= self.failure_threshold:
            self.state = "open"
    
    def can_execute(self) -> dict:
        """Check if execution is allowed."""
        
        if self.state == "closed":
            return {"allowed": True, "state": "closed"}
        
        elif self.state == "open":
            # Check if recovery timeout has passed
            if self.last_failure_time:
                elapsed = time.time() - self.last_failure_time
                if elapsed >= self.recovery_timeout:
                    self.state = "half-open"
                    self.success_count = 0
                    return {"allowed": True, "state": "half-open"}
            
            return {
                "allowed": False,
                "state": "open",
                "retry_after": self.recovery_timeout - elapsed if self.last_failure_time else 0
            }
        
        elif self.state == "half-open":
            return {"allowed": True, "state": "half-open", "limit": self.half_open_max}
        
        return {"allowed": False, "state": "unknown"}
    
    def reset(self):
        """Reset circuit breaker."""
        
        self.state = "closed"
        self.failure_count = 0
        self.success_count = 0
        self.last_failure_time = None
    
    def get_stats(self) -> dict:
        """Get circuit breaker statistics."""
        
        return {
            "state": self.state,
            "failure_count": self.failure_count,
            "success_count": self.success_count,
            "failure_threshold": self.failure_threshold,
            "recovery_timeout": self.recovery_timeout
        }
```

### Smart Retry System

```python
class SmartRetrySystem:
    """Main retry system with smart strategies."""
    
    def __init__(self, config: dict = None):
        self.config = config or self.get_default_config()
        self.detector = RetryableDetector()
        self.circuit_breakers = {}
        self.retry_history = []
        self.metrics = defaultdict(int)
    
    def execute_with_retry(self, action: callable, context: dict = None) -> dict:
        """Execute an action with smart retry logic."""
        
        context = context or {}
        service = context.get("service", "default")
        
        # Check circuit breaker
        cb = self.get_circuit_breaker(service)
        cb_status = cb.can_execute()
        
        if not cb_status["allowed"]:
            return {
                "success": False,
                "reason": f"Circuit breaker is {cb_status['state']}",
                "retry_after": cb_status.get("retry_after", 0)
            }
        
        max_attempts = self.config.get("max_attempts", 3)
        backoff = BackoffStrategy(self.config.get("backoff_strategy", "exponential"))
        
        attempts = []
        last_error = None
        
        for attempt in range(max_attempts):
            try:
                start_time = time.time()
                result = action()
                duration = time.time() - start_time
                
                # Success
                cb.record_success()
                self.metrics["success"] += 1
                
                attempt_info = {
                    "attempt": attempt + 1,
                    "success": True,
                    "duration": duration,
                    "timestamp": datetime.now().isoformat()
                }
                attempts.append(attempt_info)
                
                return {
                    "success": True,
                    "result": result,
                    "attempts": attempts,
                    "total_attempts": attempt + 1
                }
                
            except Exception as e:
                last_error = e
                self.metrics["failure"] += 1
                
                # Check if retryable
                retryable_info = self.detector.is_retryable(e, context)
                
                attempt_info = {
                    "attempt": attempt + 1,
                    "success": False,
                    "error": str(e),
                    "error_type": type(e).__name__,
                    "retryable": retryable_info["retryable"],
                    "timestamp": datetime.now().isoformat()
                }
                attempts.append(attempt_info)
                
                if not retryable_info["retryable"]:
                    # Non-retryable error
                    cb.record_failure()
                    
                    return {
                        "success": False,
                        "error": str(e),
                        "attempts": attempts,
                        "reason": retryable_info["reason"],
                        "escalate": retryable_info.get("escalate", False)
                    }
                
                # Check if should escalate
                if self.detector.should_escalate(e):
                    return {
                        "success": False,
                        "error": str(e),
                        "attempts": attempts,
                        "reason": "Error requires escalation",
                        "escalate": True
                    }
                
                # Wait before retry
                if attempt < max_attempts - 1:
                    delay = backoff.get_delay(attempt, self.config)
                    time.sleep(delay)
                    attempt_info["delay"] = delay
        
        # All attempts failed
        cb.record_failure()
        
        return {
            "success": False,
            "error": str(last_error),
            "attempts": attempts,
            "reason": f"Max attempts ({max_attempts}) exceeded"
        }
    
    def get_circuit_breaker(self, service: str) -> CircuitBreaker:
        """Get or create circuit breaker for service."""
        
        if service not in self.circuit_breakers:
            self.circuit_breakers[service] = CircuitBreaker(
                failure_threshold=self.config.get("circuit_breaker_threshold", 5),
                recovery_timeout=self.config.get("circuit_breaker_timeout", 60)
            )
        
        return self.circuit_breakers[service]
    
    def get_default_config(self) -> dict:
        """Get default retry configuration."""
        
        return {
            "max_attempts": 3,
            "backoff_strategy": "exponential",
            "base_delay": 1.0,
            "max_delay": 60.0,
            "multiplier": 2.0,
            "circuit_breaker_threshold": 5,
            "circuit_breaker_timeout": 60
        }
    
    def get_metrics(self) -> dict:
        """Get retry metrics."""
        
        return {
            "total_calls": self.metrics["success"] + self.metrics["failure"],
            "successful": self.metrics["success"],
            "failed": self.metrics["failure"],
            "success_rate": self.metrics["success"] / max(1, self.metrics["success"] + self.metrics["failure"]),
            "circuit_breakers": {
                name: cb.get_stats()
                for name, cb in self.circuit_breakers.items()
            }
        }
```

## Usage Examples

### Example 1: Basic Retry

```python
retry = SmartRetrySystem({"max_attempts": 3, "backoff_strategy": "exponential"})

def unreliable_api_call():
    import random
    if random.random() < 0.7:  # 70% failure rate
        raise ConnectionError("Connection refused")
    return {"status": "success"}

result = retry.execute_with_retry(unreliable_api_call)
print(f"Success: {result['success']}, Attempts: {result['total_attempts']}")
```

### Example 2: Service-Specific Retry

```python
retry = SmartRetrySystem()

# Different config for different services
api_config = {"max_attempts": 5, "backoff_strategy": "exponential_with_jitter"}
db_config = {"max_attempts": 3, "backoff_strategy": "fixed", "delay": 2.0}

def call_api():
    return requests.get("https://api.example.com/data")

def query_db():
    return db.execute("SELECT * FROM users")

api_result = retry.execute_with_retry(call_api, {"service": "api", **api_config})
db_result = retry.execute_with_retry(query_db, {"service": "database", **db_config})
```

### Example 3: With Circuit Breaker

```python
retry = SmartRetrySystem({"circuit_breaker_threshold": 3})

def flaky_service():
    # Simulate service that fails sometimes
    import random
    if random.random() < 0.8:
        raise ConnectionError("Service down")
    return "ok"

# First few calls will retry
for i in range(10):
    result = retry.execute_with_retry(flaky_service, {"service": "flaky"})
    print(f"Call {i+1}: {result['success']}")
    
    # After 3 failures, circuit opens and calls fail fast
    if not result['success'] and 'Circuit breaker' in result.get('reason', ''):
        print("Circuit breaker opened - failing fast")
```

## Configuration Reference

```python
RETRY_CONFIGS = {
    # Conservative - few retries, long waits
    "conservative": {
        "max_attempts": 2,
        "backoff_strategy": "exponential",
        "base_delay": 5.0,
        "max_delay": 120.0,
        "circuit_breaker_threshold": 3
    },
    
    # Aggressive - many retries, short waits
    "aggressive": {
        "max_attempts": 5,
        "backoff_strategy": "exponential_with_jitter",
        "base_delay": 0.5,
        "max_delay": 30.0,
        "circuit_breaker_threshold": 10
    },
    
    # API-optimized - respect rate limits
    "api": {
        "max_attempts": 3,
        "backoff_strategy": "exponential",
        "base_delay": 1.0,
        "max_delay": 60.0,
        "circuit_breaker_threshold": 5,
        "circuit_breaker_timeout": 120
    },
    
    # Database - fast retries for transient issues
    "database": {
        "max_attempts": 3,
        "backoff_strategy": "fixed",
        "delay": 1.0,
        "circuit_breaker_threshold": 5
    }
}
```

## Best Practices

1. **Always use circuit breakers** — prevent cascade failures
2. **Differentiate error types** — not all errors are retryable
3. **Add jitter** — prevent thundering herd on recovery
4. **Set reasonable limits** — cap retries to prevent infinite loops
5. **Monitor metrics** — track success rates and circuit breaker states
6. **Log everything** — you need to debug retry behavior
7. **Test retry paths** — inject errors to verify retry works
8. **Consider idempotency** — ensure retries don't cause duplicate side effects

## Integration with Other Self-* Capabilities

| Capability | How it integrates |
|---|---|
| **Self-Healing** | Self-healing uses retry as a fix strategy |
| **Self-Monitoring** | Monitoring tracks retry metrics and circuit breaker states |
| **Self-Governing** | Governance limits retry attempts and backoff parameters |
| **Self-Improving** | Learning from retry patterns optimizes future retry behavior |
