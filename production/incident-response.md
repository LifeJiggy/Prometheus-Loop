# Incident Response Runbook

## Incident Severity Levels

| Level | Description | Response Time | Escalation |
|---|---|---|---|
| **P0 Critical** | System down, data loss | 15 minutes | Immediately |
| **P1 High** | Major feature broken | 1 hour | Within 4 hours |
| **P2 Medium** | Minor feature broken | 4 hours | Within 24 hours |
| **P3 Low** | Cosmetic issue | 24 hours | Within 1 week |

## Incident Response Steps

### 1. Detection

```python
# Monitor for incidents
def detect_incident(metrics: dict) -> dict:
    """Detect if an incident is occurring."""
    
    incidents = []
    
    # Check error rate
    if metrics.get("error_rate", 0) > 0.1:
        incidents.append({
            "type": "high_error_rate",
            "severity": "P1",
            "details": f"Error rate: {metrics['error_rate']:.1%}"
        })
    
    # Check latency
    if metrics.get("latency_p95", 0) > 30:
        incidents.append({
            "type": "high_latency",
            "severity": "P2",
            "details": f"p95 latency: {metrics['latency_p95']:.1f}s"
        })
    
    # Check availability
    if metrics.get("availability", 1) < 0.99:
        incidents.append({
            "type": "low_availability",
            "severity": "P0",
            "details": f"Availability: {metrics['availability']:.1%}"
        })
    
    return incidents
```

### 2. Triage

```python
def triage_incident(incident: dict) -> dict:
    """Triage an incident."""
    
    # Determine severity
    severity = incident.get("severity", "P3")
    
    # Determine impact
    impact = assess_impact(incident)
    
    # Determine urgency
    urgency = assess_urgency(incident)
    
    return {
        "severity": severity,
        "impact": impact,
        "urgency": urgency,
        "priority": calculate_priority(severity, impact, urgency)
    }
```

### 3. Containment

```python
def contain_incident(incident: dict) -> dict:
    """Contain an incident."""
    
    containment_actions = {
        "high_error_rate": ["reduce_traffic", "enable_circuit_breaker"],
        "high_latency": ["increase_timeout", "enable_caching"],
        "low_availability": ["failover", "enable_degraded_mode"],
        "data_loss": ["stop_writes", "enable_backup"]
    }
    
    actions = containment_actions.get(incident["type"], ["notify_team"])
    
    for action in actions:
        execute_action(action)
    
    return {"contained": True, "actions_taken": actions}
```

### 4. Resolution

```python
def resolve_incident(incident: dict) -> dict:
    """Resolve an incident."""
    
    # Identify root cause
    root_cause = identify_root_cause(incident)
    
    # Apply fix
    fix = apply_fix(root_cause)
    
    # Verify fix
    verified = verify_fix(fix)
    
    return {
        "resolved": verified,
        "root_cause": root_cause,
        "fix_applied": fix
    }
```

### 5. Recovery

```python
def recover_from_incident(incident: dict) -> dict:
    """Recover from an incident."""
    
    # Restore normal operations
    restore_normal_operations()
    
    # Verify recovery
    verified = verify_recovery()
    
    # Monitor for recurrence
    monitor_for_recurrence(incident)
    
    return {"recovered": verified}
```

### 6. Post-Mortem

```python
def conduct_post_mortem(incident: dict) -> dict:
    """Conduct post-mortem."""
    
    return {
        "timeline": incident["timeline"],
        "root_cause": incident["root_cause"],
        "impact": incident["impact"],
        "resolution": incident["resolution"],
        "lessons_learned": extract_lessons(incident),
        "action_items": generate_action_items(incident)
    }
```

## Communication Templates

### Initial Notification

```
Subject: [P{severity}] {incident_title}

Incident: {incident_title}
Severity: P{severity}
Status: Investigating
Impact: {impact_description}

We are currently investigating this issue and will provide updates as they become available.
```

### Resolution Notification

```
Subject: [RESOLVED] {incident_title}

Incident: {incident_title}
Status: Resolved
Duration: {duration}
Root Cause: {root_cause}
Resolution: {resolution}

We apologize for any inconvenience caused.
```
