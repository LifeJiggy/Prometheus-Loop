---
name: self-debugging
description: Capture errors, analyze root causes, generate and apply fixes automatically
---

# Self-Debugging

The agent's ability to identify, diagnose, and fix its own bugs without human intervention.

## Quick Start

When the user asks about debugging agent issues:

1. **Capture** — record error details and stack trace
2. **Analyze** — classify error and gather code context
3. **Diagnose** — use patterns or LLM to find root cause
4. **Fix** — generate and apply fix
5. **Verify** — confirm fix works
6. **Store** — save solution for future reference

## Error Capture

```python
def capture_error(error: Exception, context: dict) -> dict:
    import traceback
    return {
        "error_type": type(error).__name__,
        "error_message": str(error),
        "traceback": traceback.format_exc(),
        "context": context,
        "timestamp": datetime.now().isoformat()
    }
```

## Fix Generation

| Error Type | Likely Cause | Fix Strategy |
|---|---|---|
| **NameError** | Variable not defined | Add variable definition |
| **ImportError** | Module not installed | Install missing module |
| **FileNotFoundError** | File doesn't exist | Check path or create file |
| **TypeError** | Wrong type used | Add type conversion |
| **KeyError** | Key doesn't exist | Use .get() with default |

## Usage

```python
debugger = SelfDebuggingSystem(llm=my_llm)

try:
    result = process_data()
except Exception as e:
    debug_result = debugger.debug_error(e, {"task": "process data"})
    
    if debug_result["verified"]:
        print(f"Fixed: {debug_result['fix'].get('fix_description')}")
```

## Further Reading

- [Full implementation](../shared/self/self-debugging.md) — Code context gathering, fix verification
- [Self-Healing](self-healing.md) — Complementary error recovery
