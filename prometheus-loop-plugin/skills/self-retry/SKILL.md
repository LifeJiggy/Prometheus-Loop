---
name: self-retry
description: Smart retry with backoff, circuit breakers, and adaptive strategies
---

# Self-Retry

Intelligent retry that adapts based on error type, history, and context.

## Quick Start

When the user asks about retrying failed operations:

1. **Check circuit breaker** — is the service healthy?
2. **Check retryability** — is this error retryable?
3. **Calculate delay** — exponential backoff with jitter
4. **Retry** — execute with smart backoff
5. **Record** — track outcomes for learning

## Circuit Breaker States

| State | Behavior | Transition |
|---|---|---|
| **Closed** | Normal operation, count failures | Failure threshold → Open |
| **Open** | Fail fast, don't retry | Timeout → Half-Open |
| **Half-Open** | Limited retries to test recovery | Success → Closed |

## Backoff Strategies

| Strategy | Formula | Best for |
|---|---|---|
| **Fixed** | delay = constant | Predictable services |
| **Linear** | delay = base × attempt | Gradual backoff |
| **Exponential** | delay = base × 2^attempt | Most scenarios |
| **Jitter** | delay = random(base, max) | Prevent thundering herd |

## Usage

```python
retry = SmartRetrySystem({
    "max_attempts": 3,
    "backoff_strategy": "exponential",
    "base_delay": 1.0,
    "max_delay": 60.0
})

result = retry.execute_with_retry(api_call, {"service": "payment-api"})
```

## Further Reading

- [Full implementation](../shared/self/self-retry.md) — Circuit breakers, adaptive strategies
- [Self-Healing](self-healing.md) — Complementary error diagnosis
