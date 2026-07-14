---
name: self-governing
description: Policy enforcement, ethical frameworks, and compliance checking
---

# Self-Governing

The agent's ability to enforce its own policies, rules, and ethical guidelines.

## Quick Start

When the user asks about agent governance:

1. **Define policies** — set rules and constraints
2. **Check actions** — validate against policies
3. **Enforce** — allow, deny, or escalate
4. **Audit** — log all decisions

## Policy Types

| Type | Description | Example |
|---|---|---|
| **Deny list** | Block specific actions | "Never delete production data" |
| **Allow list** | Only permit specific actions | "Only read from database" |
| **Rule-based** | Conditional rules | "If risk > high, require approval" |
| **Constraint** | Value limits | "Max 60 API calls per minute" |

## Usage

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

## Further Reading

- [Full implementation](../shared/self/self-governing.md) — Ethical frameworks, compliance checking
- [Ethics & Compliance](../shared/ethics-compliance.md) — GDPR, SOC 2, HIPAA
