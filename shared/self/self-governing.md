# Self-Governing Deep Dive

## Overview

Self-Governing is the agent's ability to enforce its own policies, rules, and ethical guidelines — ensuring it operates within defined boundaries without external oversight for every action.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SELF-GOVERNING SYSTEM                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐        │
│  │ Policy   │──▶│  Rule    │──▶│ Action   │──▶│ Verify   │        │
│  │ Engine   │   │ Checker  │   │ Enforcer │   │ Compliance│       │
│  └──────────┘   └──────────┘   └──────────┘   └──────────┘        │
│       │              │              │               │                │
│       ▼              ▼              ▼               ▼                │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐        │
│  │  Policy  │   │  Audit   │   │ Block/   │   │  Report  │        │
│  │  Store   │   │  Logger  │   │ Allow    │   │ Generator│        │
│  └──────────┘   └──────────┘   └──────────┘   └──────────┘        │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    GOVERNANCE DATA                           │   │
│  │  Policy Database │ Audit Logs │ Compliance Reports           │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

## Core Implementation

### Policy Engine

```python
class PolicyEngine:
    """Manages and enforces policies."""
    
    def __init__(self):
        self.policies = {}
        self.policy_groups = defaultdict(list)
    
    def add_policy(self, name: str, policy: dict):
        """Add a policy."""
        
        self.policies[name] = {
            **policy,
            "name": name,
            "enabled": True,
            "created_at": datetime.now().isoformat()
        }
    
    def remove_policy(self, name: str):
        """Remove a policy."""
        
        if name in self.policies:
            del self.policies[name]
    
    def enable_policy(self, name: str):
        """Enable a policy."""
        
        if name in self.policies:
            self.policies[name]["enabled"] = True
    
    def disable_policy(self, name: str):
        """Disable a policy."""
        
        if name in self.policies:
            self.policies[name]["enabled"] = False
    
    def get_policies(self, group: str = None) -> list:
        """Get policies, optionally filtered by group."""
        
        if group:
            policy_names = self.policy_groups.get(group, [])
            return [self.policies[name] for name in policy_names if name in self.policies]
        
        return list(self.policies.values())
    
    def add_to_group(self, policy_name: str, group: str):
        """Add policy to a group."""
        
        if policy_name in self.policies:
            self.policy_groups[group].append(policy_name)
    
    def evaluate(self, action: dict) -> dict:
        """Evaluate an action against all policies."""
        
        results = []
        
        for policy in self.policies.values():
            if not policy["enabled"]:
                continue
            
            result = self.evaluate_policy(policy, action)
            results.append(result)
        
        # Determine overall verdict
        verdicts = [r["verdict"] for r in results]
        
        if "deny" in verdicts:
            overall = "deny"
        elif "require_approval" in verdicts:
            overall = "require_approval"
        else:
            overall = "allow"
        
        return {
            "verdict": overall,
            "policy_results": results,
            "action": action
        }
    
    def evaluate_policy(self, policy: dict, action: dict) -> dict:
        """Evaluate a single policy against an action."""
        
        policy_type = policy.get("type", "deny_list")
        
        if policy_type == "deny_list":
            return self.evaluate_deny_list(policy, action)
        elif policy_type == "allow_list":
            return self.evaluate_allow_list(policy, action)
        elif policy_type == "rule_based":
            return self.evaluate_rules(policy, action)
        elif policy_type == "constraint":
            return self.evaluate_constraints(policy, action)
        
        return {"policy": policy["name"], "verdict": "allow", "reason": "Unknown policy type"}
    
    def evaluate_deny_list(self, policy: dict, action: dict) -> dict:
        """Evaluate deny list policy."""
        
        denied_patterns = policy.get("patterns", [])
        action_str = str(action).lower()
        
        for pattern in denied_patterns:
            if pattern.lower() in action_str:
                return {
                    "policy": policy["name"],
                    "verdict": "deny",
                    "reason": f"Matches denied pattern: {pattern}"
                }
        
        return {"policy": policy["name"], "verdict": "allow"}
    
    def evaluate_allow_list(self, policy: dict, action: dict) -> dict:
        """Evaluate allow list policy."""
        
        allowed_patterns = policy.get("patterns", [])
        action_str = str(action).lower()
        
        for pattern in allowed_patterns:
            if pattern.lower() in action_str:
                return {"policy": policy["name"], "verdict": "allow"}
        
        return {
            "policy": policy["name"],
            "verdict": "deny",
            "reason": "Not in allow list"
        }
    
    def evaluate_rules(self, policy: dict, action: dict) -> dict:
        """Evaluate rule-based policy."""
        
        rules = policy.get("rules", [])
        
        for rule in rules:
            if self.check_rule(rule, action):
                return {
                    "policy": policy["name"],
                    "verdict": rule.get("verdict", "allow"),
                    "reason": rule.get("reason", "Rule matched")
                }
        
        return {"policy": policy["name"], "verdict": "allow"}
    
    def check_rule(self, rule: dict, action: dict) -> bool:
        """Check if a rule matches an action."""
        
        conditions = rule.get("conditions", {})
        
        for key, expected in conditions.items():
            actual = action.get(key)
            
            if actual is None:
                return False
            
            if isinstance(expected, list):
                if actual not in expected:
                    return False
            elif actual != expected:
                return False
        
        return True
    
    def evaluate_constraints(self, policy: dict, action: dict) -> dict:
        """Evaluate constraint-based policy."""
        
        constraints = policy.get("constraints", {})
        
        for key, constraint in constraints.items():
            value = action.get(key)
            
            if value is None:
                continue
            
            if "max" in constraint and value > constraint["max"]:
                return {
                    "policy": policy["name"],
                    "verdict": "deny",
                    "reason": f"{key} exceeds maximum: {value} > {constraint['max']}"
                }
            
            if "min" in constraint and value < constraint["min"]:
                return {
                    "policy": policy["name"],
                    "verdict": "deny",
                    "reason": f"{key} below minimum: {value} < {constraint['min']}"
                }
        
        return {"policy": policy["name"], "verdict": "allow"}
```

### Audit Logger

```python
class AuditLogger:
    """Logs all governance actions."""
    
    def __init__(self):
        self.logs = []
    
    def log(self, event: dict):
        """Log a governance event."""
        
        entry = {
            **event,
            "timestamp": datetime.now().isoformat(),
            "id": str(uuid4())
        }
        
        self.logs.append(entry)
    
    def log_action(self, action: dict, verdict: dict):
        """Log an action evaluation."""
        
        self.log({
            "type": "action_evaluated",
            "action": action,
            "verdict": verdict["verdict"],
            "policies_checked": len(verdict.get("policy_results", []))
        })
    
    def log_violation(self, action: dict, policy: str, reason: str):
        """Log a policy violation."""
        
        self.log({
            "type": "violation",
            "action": action,
            "policy": policy,
            "reason": reason,
            "severity": "high"
        })
    
    def log_approval(self, action: dict, approved: bool, approver: str = None):
        """Log an approval decision."""
        
        self.log({
            "type": "approval",
            "action": action,
            "approved": approved,
            "approver": approver
        })
    
    def get_logs(self, filter_type: str = None, limit: int = 100) -> list:
        """Get logs with optional filtering."""
        
        logs = self.logs
        
        if filter_type:
            logs = [l for l in logs if l.get("type") == filter_type]
        
        return logs[-limit:]
    
    def get_violations(self, limit: int = 100) -> list:
        """Get violation logs."""
        
        return self.get_logs(filter_type="violation", limit=limit)
    
    def get_statistics(self) -> dict:
        """Get logging statistics."""
        
        type_counts = defaultdict(int)
        for log in self.logs:
            type_counts[log.get("type", "unknown")] += 1
        
        return {
            "total_logs": len(self.logs),
            "by_type": dict(type_counts),
            "violations": type_counts.get("violation", 0),
            "approvals": type_counts.get("approval", 0)
        }
```

### Action Enforcer

```python
class ActionEnforcer:
    """Enforces governance decisions."""
    
    def __init__(self):
        self.enforcement_history = []
    
    def enforce(self, action: dict, verdict: dict, approval_fn: callable = None) -> dict:
        """Enforce a governance decision."""
        
        decision = verdict["verdict"]
        
        if decision == "allow":
            return {"enforced": True, "action": action, "result": "allowed"}
        
        elif decision == "deny":
            self.enforcement_history.append({
                "action": action,
                "decision": "denied",
                "reason": verdict.get("reason"),
                "timestamp": datetime.now().isoformat()
            })
            return {"enforced": True, "action": action, "result": "denied"}
        
        elif decision == "require_approval":
            if approval_fn:
                approved = approval_fn(action, verdict)
                
                self.enforcement_history.append({
                    "action": action,
                    "decision": "approved" if approved else "rejected",
                    "timestamp": datetime.now().isoformat()
                })
                
                return {
                    "enforced": True,
                    "action": action,
                    "result": "approved" if approved else "rejected"
                }
            else:
                return {
                    "enforced": False,
                    "action": action,
                    "result": "pending_approval",
                    "reason": "No approval function provided"
                }
        
        return {"enforced": False, "action": action, "result": "unknown_decision"}
    
    def get_enforcement_stats(self) -> dict:
        """Get enforcement statistics."""
        
        if not self.enforcement_history:
            return {"total": 0}
        
        decisions = defaultdict(int)
        for entry in self.enforcement_history:
            decisions[entry["decision"]] += 1
        
        return {
            "total": len(self.enforcement_history),
            "decisions": dict(decisions)
        }
```

### Main Self-Governing System

```python
class SelfGoverningSystem:
    """Main self-governing orchestrator."""
    
    def __init__(self):
        self.policy_engine = PolicyEngine()
        self.audit_logger = AuditLogger()
        self.enforcer = ActionEnforcer()
        self.compliance_rules = {}
    
    def add_policy(self, name: str, policy: dict):
        """Add a governance policy."""
        
        self.policy_engine.add_policy(name, policy)
    
    def check_action(self, action: dict, approval_fn: callable = None) -> dict:
        """Check and enforce an action."""
        
        # Evaluate against policies
        verdict = self.policy_engine.evaluate(action)
        
        # Log the evaluation
        self.audit_logger.log_action(action, verdict)
        
        # Enforce the decision
        result = self.enforcer.enforce(action, verdict, approval_fn)
        
        # Log violations
        if verdict["verdict"] == "deny":
            for policy_result in verdict.get("policy_results", []):
                if policy_result["verdict"] == "deny":
                    self.audit_logger.log_violation(
                        action,
                        policy_result["policy"],
                        policy_result.get("reason", "Policy violation")
                    )
        
        return {
            "allowed": result["result"] in ["allowed", "approved"],
            "verdict": verdict["verdict"],
            "result": result["result"],
            "enforcement": result
        }
    
    def get_compliance_report(self) -> dict:
        """Get compliance report."""
        
        return {
            "policies": len(self.policy_engine.policies),
            "audit_stats": self.audit_logger.get_statistics(),
            "enforcement_stats": self.enforcer.get_enforcement_stats(),
            "violations": self.audit_logger.get_violations(limit=10)
        }
    
    def setup_default_policies(self):
        """Set up default governance policies."""
        
        # Safety policy
        self.add_policy("safety", {
            "type": "deny_list",
            "patterns": ["rm -rf", "drop table", "delete all", "format disk"],
            "description": "Prevent destructive actions"
        })
        
        # Scope policy
        self.add_policy("scope", {
            "type": "allow_list",
            "patterns": ["read", "write", "analyze", "test"],
            "description": "Only allow scoped actions"
        })
        
        # Rate limit policy
        self.add_policy("rate_limit", {
            "type": "constraint",
            "constraints": {
                "calls_per_minute": {"max": 60},
                "tokens_per_request": {"max": 10000}
            },
            "description": "Enforce rate limits"
        })
```

## Usage Examples

### Example 1: Enforce Policies

```python
governor = SelfGoverningSystem()
governor.setup_default_policies()

# Check an action
result = governor.check_action({
    "type": "file_delete",
    "path": "/important/file.txt"
})

if result["allowed"]:
    print("Action allowed")
else:
    print(f"Action denied: {result['verdict']}")
```

## Best Practices

1. **Define policies clearly** — ambiguous policies cause confusion
2. **Log everything** — audit trail is essential
3. **Review violations** — learn from policy breaches
4. **Update policies regularly** — adapt to new requirements
5. **Test enforcement** — verify policies work as expected
6. **Separate concerns** — different policies for different aspects
7. **Human override for edge cases** — some situations need flexibility
8. **Monitor compliance** — track adherence to policies

## Integration

| Capability | Integration |
|---|---|
| **Self-Healing** | Governance constrains healing actions |
| **Self-Improving** | Policies evolve based on outcomes |
| **Self-Monitoring** | Monitoring detects policy violations |
| **Self-Governing** | Meta-governance of governance itself |
| **Self-Adapting** | Adaptation respects policy boundaries |
