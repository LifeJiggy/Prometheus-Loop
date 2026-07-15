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

---

## Architecture

```
Error → Classify → Check Patterns → Apply Fix → Verify → Learn
                         ↓
                    LLM Diagnosis (if unknown)
```

---

## Error Classification

### Error Types and Profiles

```python
ERROR_PROFILES = {
    # Transient errors - usually fixable with retry
    "ConnectionError": {
        "type": "transient",
        "severity": "medium",
        "retryable": True,
        "category": "network",
        "fix_strategy": "retry_with_backoff"
    },
    "TimeoutError": {
        "type": "transient",
        "severity": "medium",
        "retryable": True,
        "category": "network",
        "fix_strategy": "retry_with_backoff"
    },
    
    # Permanent errors - need different approach
    "PermissionError": {
        "type": "permanent",
        "severity": "high",
        "retryable": False,
        "category": "auth",
        "fix_strategy": "refresh_credentials"
    },
    "FileNotFoundError": {
        "type": "permanent",
        "severity": "low",
        "retryable": False,
        "category": "data",
        "fix_strategy": "find_alternative"
    },
    
    # Logic errors - need debugging
    "ValueError": {
        "type": "logic",
        "severity": "medium",
        "retryable": False,
        "category": "validation",
        "fix_strategy": "fix_parameters"
    },
    "TypeError": {
        "type": "logic",
        "severity": "medium",
        "retryable": False,
        "category": "type",
        "fix_strategy": "type_coercion"
    },
    
    # Resource errors - need management
    "MemoryError": {
        "type": "resource",
        "severity": "critical",
        "retryable": False,
        "category": "memory",
        "fix_strategy": "free_resources"
    },
    
    # Rate limiting - need backoff
    "429 Too Many Requests": {
        "type": "transient",
        "severity": "medium",
        "retryable": True,
        "category": "api",
        "fix_strategy": "exponential_backoff"
    }
}
```

### Error Classification Implementation

```python
class ErrorClassifier:
    """Classifies errors by type, severity, and retryability."""
    
    def __init__(self):
        self.profiles = ERROR_PROFILES
        self.custom_profiles = {}
    
    def classify(self, error: Exception, context: dict = None) -> dict:
        """Classify an error."""
        
        error_type = type(error).__name__
        error_msg = str(error)
        
        # Try exact match first
        profile = self.profiles.get(error_type)
        
        # Try message-based matching
        if not profile:
            for pattern, p in self.profiles.items():
                if pattern.lower() in error_msg.lower():
                    profile = p
                    break
        
        # Try custom profiles
        if not profile:
            profile = self.custom_profiles.get(error_type)
        
        # Default profile
        if not profile:
            profile = {
                "type": "unknown",
                "severity": "medium",
                "retryable": False,
                "category": "unknown",
                "fix_strategy": "escalate"
            }
        
        return {
            "error_type": error_type,
            "error_message": error_msg,
            "profile": profile,
            "context": context or {},
            "timestamp": datetime.now().isoformat(),
            "fingerprint": self.create_fingerprint(error_type, error_msg)
        }
    
    def create_fingerprint(self, error_type: str, error_msg: str) -> str:
        """Create a unique fingerprint for error deduplication."""
        import hashlib
        content = f"{error_type}:{error_msg[:200]}"
        return hashlib.md5(content.encode()).hexdigest()
    
    def add_custom_profile(self, error_type: str, profile: dict):
        """Add a custom error profile."""
        self.custom_profiles[error_type] = profile
```

---

## Pattern Database

```python
class PatternDatabase:
    """Stores known error patterns and their fixes."""
    
    def __init__(self):
        self.patterns = {}
        self.statistics = defaultdict(lambda: {"attempts": 0, "successes": 0})
    
    def add_pattern(self, fingerprint: str, error_type: str, fix_type: str, 
                    fix_params: dict, success_rate: float = 1.0):
        """Add a known pattern."""
        
        self.patterns[fingerprint] = {
            "error_type": error_type,
            "fix_type": fix_type,
            "fix_params": fix_params,
            "success_rate": success_rate,
            "occurrences": 1,
            "last_seen": datetime.now().isoformat(),
            "created": datetime.now().isoformat()
        }
    
    def find_fix(self, fingerprint: str) -> dict:
        """Find a known fix for an error fingerprint."""
        
        pattern = self.patterns.get(fingerprint)
        
        if pattern:
            if pattern["success_rate"] >= 0.5:
                return {
                    "found": True,
                    "fix_type": pattern["fix_type"],
                    "fix_params": pattern["fix_params"],
                    "confidence": pattern["success_rate"],
                    "occurrences": pattern["occurrences"]
                }
        
        return {"found": False}
    
    def update_statistics(self, fingerprint: str, success: bool):
        """Update statistics for a pattern."""
        
        self.statistics[fingerprint]["attempts"] += 1
        if success:
            self.statistics[fingerprint]["successes"] += 1
        
        if fingerprint in self.patterns:
            stats = self.statistics[fingerprint]
            self.patterns[fingerprint]["success_rate"] = (
                stats["successes"] / stats["attempts"]
            )
            self.patterns[fingerprint]["last_seen"] = datetime.now().isoformat()
    
    def get_recommended_fix(self, error_type: str, category: str) -> dict:
        """Get recommended fix based on error type and category."""
        
        matching = [
            p for p in self.patterns.values()
            if p["error_type"] == error_type or p.get("category") == category
        ]
        
        if not matching:
            return None
        
        best = max(matching, key=lambda p: p["success_rate"])
        
        return {
            "fix_type": best["fix_type"],
            "fix_params": best["fix_params"],
            "confidence": best["success_rate"]
        }
```

---

## Fix Execution Engine

```python
class FixExecutionEngine:
    """Executes healing fixes."""
    
    def __init__(self, llm=None):
        self.llm = llm
        self.fix_history = []
    
    def execute_fix(self, fix_type: str, fix_params: dict, context: dict) -> dict:
        """Execute a healing fix."""
        
        start_time = time.time()
        
        try:
            fix_methods = {
                "retry_with_backoff": self.retry_with_backoff,
                "refresh_credentials": self.refresh_credentials,
                "find_alternative": self.find_alternative,
                "fix_parameters": self.fix_parameters,
                "type_coercion": self.type_coercion,
                "use_default": self.use_default,
                "free_resources": self.free_resources,
                "cleanup": self.cleanup,
                "escalate": self.escalate,
                "llm_diagnose": self.llm_diagnose
            }
            
            method = fix_methods.get(fix_type)
            if not method:
                return {"success": False, "reason": f"Unknown fix type: {fix_type}"}
            
            result = method(fix_params, context)
            
            duration = time.time() - start_time
            
            self.fix_history.append({
                "fix_type": fix_type,
                "success": result.get("success", False),
                "duration": duration,
                "timestamp": datetime.now().isoformat()
            })
            
            result["duration"] = duration
            return result
            
        except Exception as e:
            return {"success": False, "reason": f"Fix execution failed: {str(e)}"}
    
    def retry_with_backoff(self, params: dict, context: dict) -> dict:
        """Retry with exponential backoff."""
        
        import time
        
        max_retries = params.get("max_retries", 3)
        base_delay = params.get("base_delay", 1.0)
        max_delay = params.get("max_delay", 60.0)
        
        action = context.get("action")
        if not action:
            return {"success": False, "reason": "No action provided"}
        
        for attempt in range(max_retries):
            try:
                result = action()
                return {
                    "success": True,
                    "result": result,
                    "attempts": attempt + 1,
                    "total_delay": sum(min(base_delay * (2 ** i), max_delay) for i in range(attempt))
                }
            except Exception as e:
                if attempt < max_retries - 1:
                    delay = min(base_delay * (2 ** attempt), max_delay)
                    time.sleep(delay)
                else:
                    return {
                        "success": False,
                        "reason": str(e),
                        "attempts": attempt + 1
                    }
        
        return {"success": False, "reason": "Max retries exceeded"}
    
    def refresh_credentials(self, params: dict, context: dict) -> dict:
        """Refresh expired credentials."""
        
        auth_client = context.get("auth_client")
        if not auth_client:
            return {"success": False, "reason": "No auth client available"}
        
        try:
            new_credentials = auth_client.refresh()
            context["credentials"] = new_credentials
            
            action = context.get("action")
            if action:
                result = action()
                return {"success": True, "result": result}
            
            return {"success": True, "credentials_refreshed": True}
        except Exception as e:
            return {"success": False, "reason": f"Credential refresh failed: {e}"}
    
    def find_alternative(self, params: dict, context: dict) -> dict:
        """Find and use an alternative approach."""
        
        alternatives = params.get("alternatives", [])
        
        for alt in alternatives:
            try:
                if alt.get("type") == "path":
                    import os
                    if os.path.exists(alt["path"]):
                        context["file_path"] = alt["path"]
                        action = context.get("action")
                        if action:
                            result = action()
                            return {"success": True, "result": result, "alternative": alt["path"]}
                
                elif alt.get("type") == "endpoint":
                    context["endpoint"] = alt["url"]
                    action = context.get("action")
                    if action:
                        result = action()
                        return {"success": True, "result": result, "alternative": alt["url"]}
                        
            except Exception:
                continue
        
        return {"success": False, "reason": "All alternatives failed"}
    
    def fix_parameters(self, params: dict, context: dict) -> dict:
        """Fix invalid parameters."""
        
        action = context.get("action")
        if not action:
            return {"success": False, "reason": "No action provided"}
        
        current_params = context.get("params", {})
        fixed_params = current_params.copy()
        
        for param_name, fix in params.get("fixes", {}).items():
            if fix.get("type") == "default":
                fixed_params[param_name] = fix["value"]
            elif fix.get("type") == "transform":
                if param_name in fixed_params:
                    fixed_params[param_name] = fix["transform"](fixed_params[param_name])
        
        try:
            context["params"] = fixed_params
            result = action()
            return {"success": True, "result": result, "fixed_params": fixed_params}
        except Exception as e:
            return {"success": False, "reason": str(e)}
    
    def type_coercion(self, params: dict, context: dict) -> dict:
        """Fix type errors by coercing values."""
        
        action = context.get("action")
        if not action:
            return {"success": False, "reason": "No action provided"}
        
        current_params = context.get("params", {})
        fixed_params = current_params.copy()
        
        for param_name, expected_type in params.get("type_map", {}).items():
            if param_name in fixed_params:
                try:
                    fixed_params[param_name] = expected_type(fixed_params[param_name])
                except (ValueError, TypeError):
                    pass
        
        try:
            context["params"] = fixed_params
            result = action()
            return {"success": True, "result": result}
        except Exception as e:
            return {"success": False, "reason": str(e)}
    
    def use_default(self, params: dict, context: dict) -> dict:
        """Use default values for missing parameters."""
        
        action = context.get("action")
        if not action:
            return {"success": False, "reason": "No action provided"}
        
        current_params = context.get("params", {})
        defaults = params.get("defaults", {})
        
        for key, value in defaults.items():
            if key not in current_params:
                current_params[key] = value
        
        try:
            context["params"] = current_params
            result = action()
            return {"success": True, "result": result}
        except Exception as e:
            return {"success": False, "reason": str(e)}
    
    def free_resources(self, params: dict, context: dict) -> dict:
        """Free up system resources."""
        
        import gc
        
        gc.collect()
        
        if "cache" in context:
            context["cache"].clear()
        
        action = context.get("action")
        if action:
            try:
                result = action()
                return {"success": True, "result": result}
            except Exception as e:
                return {"success": False, "reason": str(e)}
        
        return {"success": True, "resources_freed": True}
    
    def cleanup(self, params: dict, context: dict) -> dict:
        """Clean up disk space or temp files."""
        
        import os
        import shutil
        import tempfile
        
        paths_to_clean = params.get("paths", [tempfile.gettempdir()])
        total_freed = 0
        
        for path in paths_to_clean:
            if os.path.exists(path):
                try:
                    if os.path.isfile(path):
                        size = os.path.getsize(path)
                        os.remove(path)
                        total_freed += size
                    elif os.path.isdir(path):
                        size = sum(os.path.getsize(os.path.join(path, f)) 
                                 for f in os.listdir(path) if os.path.isfile(os.path.join(path, f)))
                        shutil.rmtree(path)
                        total_freed += size
                except Exception:
                    continue
        
        return {"success": True, "bytes_freed": total_freed}
    
    def escalate(self, params: dict, context: dict) -> dict:
        """Escalate to human intervention."""
        
        return {
            "success": False,
            "escalated": True,
            "reason": params.get("reason", "Unable to self-heal"),
            "requires_human": True,
            "context": context
        }
    
    def llm_diagnose(self, params: dict, context: dict) -> dict:
        """Use LLM to diagnose and generate fix."""
        
        if not self.llm:
            return {"success": False, "reason": "No LLM available"}
        
        error_info = context.get("error_info", {})
        
        diagnosis_prompt = f"""
        An error occurred during agent execution:
        
        Error Type: {error_info.get('error_type', 'Unknown')}
        Error Message: {error_info.get('error_message', 'Unknown')}
        Context: {context.get('description', 'No context')}
        
        Previous attempts: {context.get('previous_attempts', [])}
        
        Please provide:
        1. Root cause diagnosis
        2. Recommended fix (as JSON with fix_type and fix_params)
        3. Confidence level (0-1)
        
        Return JSON: {{"diagnosis": "...", "fix_type": "...", "fix_params": {{}}, "confidence": 0.0-1.0}}
        """
        
        try:
            response = self.llm.call(diagnosis_prompt)
            import json
            diagnosis = json.loads(response)
            
            fix_type = diagnosis.get("fix_type")
            fix_params = diagnosis.get("fix_params", {})
            
            if fix_type:
                return self.execute_fix(fix_type, fix_params, context)
            
            return {"success": False, "reason": "No fix recommended"}
        except Exception as e:
            return {"success": False, "reason": f"LLM diagnosis failed: {e}"}
```

---

## Main Self-Healing System

```python
class SelfHealingSystem:
    """Main self-healing orchestrator."""
    
    def __init__(self, llm=None):
        self.classifier = ErrorClassifier()
        self.pattern_db = PatternDatabase()
        self.fix_engine = FixExecutionEngine(llm)
        self.healing_history = []
        self.max_fix_attempts = 3
    
    def handle_error(self, error: Exception, context: dict) -> dict:
        """Main entry point for self-healing."""
        
        # Step 1: Classify the error
        error_info = self.classifier.classify(error, context)
        
        # Step 2: Check if we've seen this before
        known_fix = self.pattern_db.find_fix(error_info["fingerprint"])
        
        # Step 3: Determine fix strategy
        if known_fix and known_fix["found"]:
            fix_type = known_fix["fix_type"]
            fix_params = known_fix["fix_params"]
            confidence = known_fix["confidence"]
        else:
            profile = error_info["profile"]
            fix_type = profile.get("fix_strategy", "escalate")
            fix_params = self.get_default_params(fix_type)
            confidence = 0.5
        
        # Step 4: Execute fix with retries
        result = None
        for attempt in range(self.max_fix_attempts):
            result = self.fix_engine.execute_fix(fix_type, fix_params, context)
            
            if result.get("success"):
                break
            
            if attempt < self.max_fix_attempts - 1:
                fix_type = self.get_alternative_fix(fix_type, error_info)
        
        # Step 5: Learn from this experience
        self.learn(error_info, result)
        
        # Step 6: Record in history
        self.healing_history.append({
            "error": error_info,
            "fix_type": fix_type,
            "result": result,
            "timestamp": datetime.now().isoformat()
        })
        
        return {
            "healed": result.get("success", False),
            "error_info": error_info,
            "fix_applied": fix_type,
            "result": result,
            "confidence": confidence
        }
    
    def get_default_params(self, fix_type: str) -> dict:
        """Get default parameters for a fix type."""
        
        defaults = {
            "retry_with_backoff": {"max_retries": 3, "base_delay": 1.0, "max_delay": 60.0},
            "refresh_credentials": {},
            "find_alternative": {"alternatives": []},
            "fix_parameters": {"fixes": {}},
            "type_coercion": {"type_map": {}},
            "use_default": {"defaults": {}},
            "free_resources": {},
            "cleanup": {},
            "escalate": {"reason": "Unable to self-heal"},
            "llm_diagnose": {}
        }
        
        return defaults.get(fix_type, {})
    
    def get_alternative_fix(self, current_fix: str, error_info: dict) -> str:
        """Get alternative fix if current one fails."""
        
        alternatives = {
            "retry_with_backoff": "exponential_backoff",
            "refresh_credentials": "escalate",
            "find_alternative": "escalate",
            "fix_parameters": "use_default",
            "type_coercion": "fix_parameters",
            "free_resources": "cleanup",
            "cleanup": "escalate"
        }
        
        return alternatives.get(current_fix, "escalate")
    
    def learn(self, error_info: dict, result: dict):
        """Learn from healing attempt."""
        
        success = result.get("success", False)
        fingerprint = error_info["fingerprint"]
        
        self.pattern_db.update_statistics(fingerprint, success)
        
        if success and not self.pattern_db.find_fix(fingerprint).get("found"):
            self.pattern_db.add_pattern(
                fingerprint=fingerprint,
                error_type=error_info["error_type"],
                fix_type=result.get("fix_type", "unknown"),
                fix_params=result.get("fix_params", {}),
                success_rate=1.0
            )
    
    def get_statistics(self) -> dict:
        """Get healing statistics."""
        
        if not self.healing_history:
            return {"total_attempts": 0, "success_rate": 0.0}
        
        total = len(self.healing_history)
        successful = sum(1 for h in self.healing_history if h["result"].get("success"))
        
        by_error_type = defaultdict(lambda: {"attempts": 0, "successes": 0})
        for h in self.healing_history:
            error_type = h["error"]["error_type"]
            by_error_type[error_type]["attempts"] += 1
            if h["result"].get("success"):
                by_error_type[error_type]["successes"] += 1
        
        return {
            "total_attempts": total,
            "successful": successful,
            "success_rate": successful / total,
            "by_error_type": dict(by_error_type),
            "patterns_stored": len(self.pattern_db.patterns)
        }
```

---

## Usage Examples

### Basic Usage

```python
healer = SelfHealingSystem()

try:
    result = api_call()
except Exception as e:
    healing_result = healer.handle_error(e, {
        "action": api_call,
        "description": "Fetching data from API"
    })
    
    if healing_result["healed"]:
        print(f"Successfully healed after {healing_result['result'].get('attempts', 1)} attempts")
    else:
        print(f"Could not heal: {healing_result['result'].get('reason')}")
```

### With LLM Diagnosis

```python
healer = SelfHealingSystem(llm=my_llm)

try:
    result = complex_operation()
except Exception as e:
    healing_result = healer.handle_error(e, {
        "action": complex_operation,
        "description": "Complex data processing",
        "previous_attempts": ["retry", "alternative"]
    })
    
    if healing_result["healed"]:
        print(f"Healed with: {healing_result['fix_applied']}")
        print(f"Confidence: {healing_result['confidence']:.1%}")
```

### Custom Healing Rules

```python
healer = SelfHealingSystem()

# Add custom error profile
healer.classifier.add_custom_profile("DatabaseError", {
    "type": "transient",
    "severity": "high",
    "retryable": True,
    "category": "database",
    "fix_strategy": "retry_with_backoff"
})

# Add custom fix
def rebuild_cache(params, context):
    cache = context.get("cache")
    if cache:
        cache.rebuild()
    return {"success": True, "cache_rebuilt": True}

healer.fix_engine.fix_methods["rebuild_cache"] = rebuild_cache
```

---

## Best Practices

1. **Start simple** — begin with basic retry/backoff before adding LLM diagnosis
2. **Track everything** — log all healing attempts for analysis
3. **Set limits** — cap retry attempts to prevent infinite loops
4. **Verify fixes** — always confirm the fix actually worked
5. **Learn from failures** — update patterns when fixes don't work
6. **Escalate appropriately** — some errors need human intervention
7. **Monitor metrics** — track success rates to identify systemic issues
8. **Test healing paths** — inject errors to verify healing works

---

## Integration with Other Self-* Capabilities

| Capability | How it integrates |
|---|---|
| **Self-Retry** | Self-healing uses retry as one fix strategy |
| **Self-Monitoring** | Monitoring detects when healing is needed |
| **Self-Debugging** | Debugging provides root cause analysis |
| **Self-Improving** | Learning from healing attempts improves future healing |
| **Self-Governing** | Governance ensures healing stays within policy |

---

## Common Failure Modes

| Failure | Description | Mitigation |
|---|---|---|
| Misdiagnosis | Healing rule matches wrong pattern | Improve pattern matching, add LLM fallback |
| Healing loop | Fix triggers new failure | Set max attempts, detect cycles |
| Stale rules | Pattern database outdated | Regular auditing, success rate decay |
| Over-confidence | Agent "heals" something needing human attention | Confidence thresholds, escalation |
| Resource exhaustion | Healing attempts consume resources | Budget limits, circuit breakers |

---

## Monitoring and Metrics

```python
# Monitor healing effectiveness
stats = healer.get_statistics()

print(f"Total healing attempts: {stats['total_attempts']}")
print(f"Success rate: {stats['success_rate']:.1%}")
print(f"Patterns stored: {stats['patterns_stored']}")

# Alert if success rate drops
if stats['success_rate'] < 0.5 and stats['total_attempts'] > 10:
    print("WARNING: Healing success rate below 50%")
```

---

## Further Reading

- **Self-Retry** — Complementary retry strategies
- **Self-Monitoring** — Detect when healing is needed
- **Self-Debugging** — Root cause analysis for complex issues
- **Safety & Guardrails** — Ensure healing stays within policy
