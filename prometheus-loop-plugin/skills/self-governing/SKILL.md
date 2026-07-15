---
name: self-governing
description: Policy enforcement, ethical frameworks, and compliance checking
---

# Self-Governing

The agent's ability to enforce its own policies, rules, and ethical guidelines — ensuring it operates within defined boundaries without external oversight for every action.

## Quick Start

When the user asks about agent governance:

1. **Define policies** — set rules and constraints
2. **Check actions** — validate against policies
3. **Enforce** — allow, deny, or escalate
4. **Audit** — log all decisions

---

## Architecture

```
Action Requested → Check Policies → Policy Violation? → Deny Action
                                              ↓
                                    High Risk? → Require Approval → Approved? → Allow/Deny
                                              ↓
                                    Allow Action → Log Action → Verify Compliance
```

---

## Policy Engine

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
    
    def evaluate(self, action: dict) -> dict:
        """Evaluate an action against all policies."""
        
        results = []
        
        for policy in self.policies.values():
            if not policy["enabled"]:
                continue
            
            result = self.evaluate_policy(policy, action)
            results.append(result)
        
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
        
        return {"policy": policy["name"], "verdict": "deny", "reason": "Not in allow list"}
    
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

---

## Ethical Decision Framework

```python
class EthicalFramework:
    """Framework for ethical decision-making."""
    
    def __init__(self):
        self.principles = {
            "beneficence": {"weight": 0.3, "description": "Act in user's best interest"},
            "non_maleficence": {"weight": 0.3, "description": "Do no harm"},
            "autonomy": {"weight": 0.2, "description": "Respect user choices"},
            "justice": {"weight": 0.1, "description": "Fair treatment"},
            "transparency": {"weight": 0.1, "description": "Be explainable"}
        }
        self.decision_history = []
    
    def evaluate_action(self, action: dict, context: dict) -> dict:
        """Evaluate action against ethical principles."""
        
        scores = {}
        
        scores["beneficence"] = self.assess_beneficence(action, context)
        scores["non_maleficence"] = self.assess_harm(action, context)
        scores["autonomy"] = self.assess_autonomy(action, context)
        scores["justice"] = self.assess_fairness(action, context)
        scores["transparency"] = self.assess_explainability(action, context)
        
        total_score = sum(
            scores[principle] * self.principles[principle]["weight"]
            for principle in scores
        )
        
        if total_score >= 0.7:
            verdict = "ethical"
        elif total_score >= 0.5:
            verdict = "questionable"
        else:
            verdict = "unethical"
        
        decision = {
            "action": action,
            "scores": scores,
            "total_score": total_score,
            "verdict": verdict,
            "timestamp": datetime.now().isoformat()
        }
        
        self.decision_history.append(decision)
        
        return decision
    
    def assess_beneficence(self, action: dict, context: dict) -> float:
        """Assess if action benefits the user."""
        
        positive = 0.5
        
        if action.get("type") in ["help", "assist", "fix", "improve"]:
            positive += 0.3
        if context.get("user_requested"):
            positive += 0.2
        
        return min(positive, 1.0)
    
    def assess_harm(self, action: dict, context: dict) -> float:
        """Assess if action causes harm."""
        
        score = 1.0
        
        if action.get("type") in ["delete", "remove", "destroy"]:
            score -= 0.3
        if action.get("scope") == "all":
            score -= 0.2
        if action.get("irreversible"):
            score -= 0.3
        
        return max(score, 0.0)
    
    def assess_autonomy(self, action: dict, context: dict) -> float:
        """Assess if action respects user autonomy."""
        
        score = 0.5
        
        if context.get("user_choice"):
            score += 0.3
        if not action.get("overriding_user"):
            score += 0.2
        
        return min(score, 1.0)
    
    def assess_fairness(self, action: dict, context: dict) -> float:
        return 0.8
    
    def assess_explainability(self, action: dict, context: dict) -> float:
        score = 0.5
        
        if action.get("reasoning"):
            score += 0.3
        if action.get("documented"):
            score += 0.2
        
        return min(score, 1.0)
```

---

## Compliance Checker

```python
class ComplianceChecker:
    """Checks compliance with regulations."""
    
    def __init__(self):
        self.regulations = {
            "gdpr": {
                "data_minimization": True,
                "consent_required": True,
                "right_to_erasure": True,
                "data_portability": True
            },
            "hipaa": {
                "access_controls": True,
                "audit_logging": True,
                "encryption_required": True
            },
            "soc2": {
                "audit_trail": True,
                "access_controls": True,
                "monitoring": True
            }
        }
        self.compliance_log = []
    
    def check_compliance(self, action: dict, regulation: str) -> dict:
        """Check if action complies with regulation."""
        
        rules = self.regulations.get(regulation, {})
        
        violations = []
        
        for rule, required in rules.items():
            if required and not self.check_rule(action, rule):
                violations.append({
                    "rule": rule,
                    "regulation": regulation,
                    "severity": "high"
                })
        
        result = {
            "regulation": regulation,
            "compliant": len(violations) == 0,
            "violations": violations,
            "timestamp": datetime.now().isoformat()
        }
        
        self.compliance_log.append(result)
        
        return result
    
    def check_rule(self, action: dict, rule: str) -> bool:
        """Check if action satisfies a rule."""
        
        rule_checks = {
            "data_minimization": lambda a: len(str(a)) < 10000,
            "consent_required": lambda a: a.get("consent_obtained", False),
            "right_to_erasure": lambda a: True,
            "data_portability": lambda a: True,
            "access_controls": lambda a: a.get("access_controlled", True),
            "audit_logging": lambda a: a.get("logged", False),
            "encryption_required": lambda a: a.get("encrypted", True)
        }
        
        check_fn = rule_checks.get(rule)
        if check_fn:
            return check_fn(action)
        
        return True
    
    def get_compliance_report(self) -> dict:
        """Get compliance report."""
        
        return {
            "total_checks": len(self.compliance_log),
            "compliant": sum(1 for c in self.compliance_log if c["compliant"]),
            "violations": sum(len(c["violations"]) for c in self.compliance_log),
            "by_regulation": self.get_by_regulation()
        }
    
    def get_by_regulation(self) -> dict:
        """Get compliance by regulation."""
        
        by_reg = defaultdict(lambda: {"checks": 0, "compliant": 0})
        
        for check in self.compliance_log:
            reg = check["regulation"]
            by_reg[reg]["checks"] += 1
            if check["compliant"]:
                by_reg[reg]["compliant"] += 1
        
        return dict(by_reg)
```

---

## Audit Trail Manager

```python
class AuditTrailManager:
    """Manages comprehensive audit trails."""
    
    def __init__(self):
        self.trails = []
        self.current_trail = None
    
    def start_trail(self, session_id: str):
        """Start a new audit trail."""
        
        self.current_trail = {
            "session_id": session_id,
            "events": [],
            "start_time": datetime.now().isoformat()
        }
    
    def log_event(self, event_type: str, details: dict):
        """Log an event to the current trail."""
        
        if self.current_trail:
            self.current_trail["events"].append({
                "type": event_type,
                "details": details,
                "timestamp": datetime.now().isoformat()
            })
    
    def end_trail(self):
        """End the current audit trail."""
        
        if self.current_trail:
            self.current_trail["end_time"] = datetime.now().isoformat()
            self.current_trail["event_count"] = len(self.current_trail["events"])
            self.trails.append(self.current_trail)
            self.current_trail = None
    
    def get_trail(self, session_id: str) -> dict:
        """Get audit trail for a session."""
        
        for trail in self.trails:
            if trail["session_id"] == session_id:
                return trail
        
        return None
    
    def search_trails(self, query: dict) -> list:
        """Search audit trails."""
        
        results = []
        
        for trail in self.trails:
            if self.matches_query(trail, query):
                results.append(trail)
        
        return results
    
    def matches_query(self, trail: dict, query: dict) -> bool:
        """Check if trail matches search query."""
        
        for key, value in query.items():
            if key == "event_type":
                if not any(e["type"] == value for e in trail["events"]):
                    return False
            elif key == "after":
                if trail["start_time"] < value:
                    return False
            elif key == "before":
                if trail["start_time"] > value:
                    return False
        
        return True
```

---

## Main Self-Governing System

```python
class SelfGoverningSystem:
    """Main self-governing orchestrator."""
    
    def __init__(self):
        self.policy_engine = PolicyEngine()
        self.audit_logger = AuditTrailManager()
        self.enforcer = ActionEnforcer()
    
    def add_policy(self, name: str, policy: dict):
        """Add a governance policy."""
        self.policy_engine.add_policy(name, policy)
    
    def check_action(self, action: dict, approval_fn: callable = None) -> dict:
        """Check and enforce an action."""
        
        verdict = self.policy_engine.evaluate(action)
        
        self.audit_logger.log_event("action_evaluated", {
            "action": action,
            "verdict": verdict["verdict"]
        })
        
        result = self.enforcer.enforce(action, verdict, approval_fn)
        
        if verdict["verdict"] == "deny":
            for policy_result in verdict.get("policy_results", []):
                if policy_result["verdict"] == "deny":
                    self.audit_logger.log_event("violation", {
                        "action": action,
                        "policy": policy_result["policy"],
                        "reason": policy_result.get("reason")
                    })
        
        return {
            "allowed": result["result"] in ["allowed", "approved"],
            "verdict": verdict["verdict"],
            "result": result["result"],
            "enforcement": result
        }
    
    def get_compliance_report(self) -> dict:
        return {
            "policies": len(self.policy_engine.policies),
            "audit_stats": {"total_events": sum(len(t["events"]) for t in self.audit_logger.trails)},
            "enforcement_stats": self.enforcer.get_enforcement_stats()
        }
    
    def setup_default_policies(self):
        """Set up default governance policies."""
        
        self.add_policy("safety", {
            "type": "deny_list",
            "patterns": ["rm -rf", "drop table", "delete all", "format disk"],
            "description": "Prevent destructive actions"
        })
        
        self.add_policy("scope", {
            "type": "allow_list",
            "patterns": ["read", "write", "analyze", "test"],
            "description": "Only allow scoped actions"
        })
        
        self.add_policy("rate_limit", {
            "type": "constraint",
            "constraints": {
                "calls_per_minute": {"max": 60},
                "tokens_per_request": {"max": 10000}
            },
            "description": "Enforce rate limits"
        })


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
        if not self.enforcement_history:
            return {"total": 0}
        
        decisions = defaultdict(int)
        for entry in self.enforcement_history:
            decisions[entry["decision"]] += 1
        
        return {"total": len(self.enforcement_history), "decisions": dict(decisions)}
```

---

## Usage Examples

### Basic Governance

```python
governor = SelfGoverningSystem()
governor.setup_default_policies()

result = governor.check_action({
    "type": "file_delete",
    "path": "/important/file.txt"
})

if result["allowed"]:
    print("Action allowed")
else:
    print(f"Action denied: {result['verdict']}")
```

---

## Best Practices

1. **Define policies clearly** — ambiguous policies cause confusion
2. **Log everything** — audit trail is essential
3. **Review violations** — learn from policy breaches
4. **Update policies regularly** — adapt to new requirements
5. **Test enforcement** — verify policies work as expected
6. **Separate concerns** — different policies for different aspects
7. **Human override for edge cases** — some situations need flexibility
8. **Monitor compliance** — track adherence to policies

---

## Integration

| Capability | How it integrates |
|---|---|
| **Self-Healing** | Governance constrains healing actions |
| **Self-Improving** | Policies evolve based on outcomes |
| **Self-Monitoring** | Monitoring detects policy violations |
| **Self-Adapting** | Adaptation respects policy boundaries |
| **Self-Remembering** | Policy violations are recorded |

---

## Further Reading

- **Ethics & Compliance** — GDPR, SOC 2, HIPAA frameworks
- **Safety & Guardrails** — Security-focused governance
- **Observability** — Audit logging and compliance tracking

---

## Quick Reference

| Concept | Description |
|---|---|
| **Policy Engine** | Manages and enforces policies |
| **Ethical Framework** | Evaluates actions against principles |
| **Compliance Checker** | Checks regulatory compliance |
| **Audit Trail** | Logs all decisions and actions |
| **Action Enforcer** | Enforces governance decisions |
| **Deny List** | Blocks specific actions |
| **Allow List** | Only permits specific actions |
| **Rule-Based** | Conditional policy rules |
| **Constraint** | Value limits and boundaries |

---

## Summary

Self-Governing ensures agents operate within ethical and policy boundaries. By enforcing rules, checking compliance, and maintaining audit trails, agents can be trusted to make responsible decisions.

### Key Takeaways

- Clear policies prevent unauthorized actions
- Ethical frameworks guide decision-making
- Compliance checking ensures regulatory adherence
- Audit trails enable accountability and debugging
