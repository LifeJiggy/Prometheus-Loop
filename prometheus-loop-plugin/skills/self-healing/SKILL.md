---
name: self-healing
description: Self-healing agent capability - diagnose errors, apply fixes, verify recovery automatically
---

# Self-Healing

The agent's ability to detect failures, diagnose root causes, apply fixes, and verify recovery — all without human intervention.

## Quick Start

When the user asks about handling failures automatically, use this guide:

1. **Detect** — classify the error type and severity
2. **Diagnose** — find root cause using patterns or LLM
3. **Fix** — apply the appropriate fix strategy
4. **Verify** — confirm the fix worked
5. **Learn** — store the pattern for future use

## Error Classification

```python
ERROR_PROFILES = {
    "ConnectionError": {"type": "transient", "retryable": True, "fix": "retry_with_backoff"},
    "TimeoutError": {"type": "transient", "retryable": True, "fix": "retry_with_backoff"},
    "PermissionError": {"type": "permanent", "retryable": False, "fix": "refresh_credentials"},
    "FileNotFoundError": {"type": "permanent", "retryable": False, "fix": "find_alternative"},
    "MemoryError": {"type": "resource", "retryable": False, "fix": "free_resources"},
}
```

## Fix Strategies

| Strategy | When to use | Example |
|---|---|---|
| **Retry with backoff** | Transient network errors | API timeout → wait 2s → retry |
| **Refresh credentials** | Auth token expired | 401 → refresh token → retry |
| **Find alternative** | Resource not found | File missing → search similar path |
| **Free resources** | Out of memory | MemoryError → gc.collect() → retry |
| **Escalate** | Unknown/unrecoverable | Log error → notify human |

## Implementation

```python
class SelfHealingSystem:
    def __init__(self, llm=None):
        self.pattern_db = PatternDatabase()
        self.fix_engine = FixExecutionEngine(llm)
    
    def handle_error(self, error: Exception, context: dict) -> dict:
        # 1. Classify
        error_info = self.classify_error(error)
        
        # 2. Check known patterns
        known_fix = self.pattern_db.find_fix(error_info["fingerprint"])
        
        # 3. Determine fix strategy
        if known_fix:
            fix_type = known_fix["fix_type"]
        else:
            fix_type = error_info["profile"]["fix_strategy"]
        
        # 4. Execute fix
        result = self.fix_engine.execute_fix(fix_type, {}, context)
        
        # 5. Learn
        self.learn(error_info, result)
        
        return {"healed": result.get("success", False), "fix": fix_type}
```

## Usage

```python
healer = SelfHealingSystem(llm=my_llm)

try:
    result = api_call()
except Exception as e:
    healing_result = healer.handle_error(e, {"action": api_call})
    
    if healing_result["healed"]:
        print(f"Fixed with: {healing_result['fix']}")
    else:
        print("Could not self-heal, escalating")
```

## Further Reading

- [Full implementation](../shared/self/self-healing.md) — 942 lines of detailed code
- [Self-Retry](self-retry.md) — Complementary retry strategies
- [Self-Monitoring](self-monitoring.md) — Detect when healing is needed
