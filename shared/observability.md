# Observability & Monitoring

## Observability Stack

| Layer | Tool | Purpose |
|---|---|---|
| **Tracing** | LangSmith, Phoenix, Langfuse | Track LLM calls, chain execution, latency |
| **Logging** | Structured logs (JSON) | Audit trail, debugging, compliance |
| **Metrics** | Prometheus + Grafana | Dashboards, alerts, trend analysis |
| **Alerting** | PagerDuty, OpsGenie | Incident response, anomaly detection |
| **Session replay** | Custom or LangSmith | Replay agent sessions for debugging |

## Structured Log Format

```json
{
  "timestamp": "2025-01-15T10:32:01Z",
  "session_id": "ses_abc123",
  "task_id": "task_xyz789",
  "cycle": 3,
  "step": "permission_gate",
  "agent_id": "main",
  "action": "write src/auth.py",
  "input": {"file": "src/auth.py", "content": "..."},
  "output": {"status": "ALLOW", "rule": "write to src/**"},
  "decision_rationale": "File is within workspace scope, no policy violation",
  "tokens_used": 0,
  "duration_ms": 2,
  "gate_evaluation": {
    "scope": "ALLOW",
    "policy": "ALLOW",
    "blast_radius": "LOW",
    "reversibility": "REVERSIBLE"
  }
}
```

## Dashboard Metrics

### Agent Health Dashboard

| Panel | Metric | Alert Threshold |
|---|---|---|
| Task completion rate | % tasks finished successfully | < 80% |
| Average cycle count | Loops per task | > 50% above baseline |
| Token consumption | Tokens per task | > 2x normal |
| Error rate | Failed actions / total actions | > 5% |
| HITL queue depth | Pending approvals | > 10 |
| Self-heal success rate | Self-healed / total failures | < 40% |
| Cost per task | Dollar cost per task | > budget threshold |
| Latency p95 | 95th percentile response time | > 30s |

### Security Dashboard

| Panel | Metric | Alert Threshold |
|---|---|---|
| Gate denials | Denied actions / total actions | Spike > 2x normal |
| Prompt injection attempts | Blocked injection attempts | Any spike |
| Data exfiltration attempts | Blocked exfil attempts | Any occurrence |
| Memory anomalies | Flagged memory entries | > 0 |
| Adversarial inputs detected | Flagged user inputs | > 0 |

## Tracing with LangSmith

```python
from langsmith import traceable

@traceable(name="agentic-loop")
def run_agent(task: str):
    with traceable(name="prompt") as t:
        prompt = build_prompt(task)
    
    with traceable(name="context") as t:
        context = gather_context(prompt)
    
    with traceable(name="plan") as t:
        plan = create_plan(context)
    
    with traceable(name="reason") as t:
        decision = reason(plan, context)
    
    with traceable(name="gate") as t:
        gate_result = permission_gate(decision)
    
    with traceable(name="act") as t:
        result = execute(decision)
    
    with traceable(name="observe") as t:
        observation = observe(result)
    
    return observation
```

## Alert Rules

```yaml
alerts:
  - name: "Agent stuck in loop"
    condition: "cycle_count > 20 for same task"
    severity: warning
    action: "Notify on-call, suggest human intervention"

  - name: "Cost spike"
    condition: "cost_per_task > 2x baseline for 10+ tasks"
    severity: warning
    action: "Check for context bloat or infinite loops"

  - name: "Security violation"
    condition: "gate_denial_count > 5 in 1 minute"
    severity: critical
    action: "Pause agent, investigate"

  - name: "Human bottleneck"
    condition: "hitl_queue_depth > 20"
    severity: warning
    action: "Add reviewers or adjust gate sensitivity"
```
