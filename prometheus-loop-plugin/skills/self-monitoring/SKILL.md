---
name: self-monitoring
description: Track metrics, health checks, alerts, and anomaly detection
---

# Self-Monitoring

The agent's ability to track its own performance, health, and resource usage in real-time.

## Quick Start

When the user asks about monitoring agent health:

1. **Collect metrics** — record performance data
2. **Check thresholds** — detect when limits are exceeded
3. **Run health checks** — verify system components
4. **Trigger alerts** — notify when issues detected
5. **Update dashboards** — visualize status

## Key Metrics

| Metric | What it measures | Alert threshold |
|---|---|---|
| **Response time** | How fast the agent responds | > 30 seconds |
| **Error rate** | Failed actions / total actions | > 5% |
| **Token usage** | Tokens consumed per task | > budget limit |
| **Memory usage** | RAM consumption | > 80% |
| **Queue depth** | Pending tasks | > 100 |

## Usage

```python
monitor = SelfMonitoringSystem()

# Register health checks
monitor.register_health_check("database", lambda: {"healthy": db.ping()})

# Add alert rules
monitor.add_alert_rule(
    "high_error_rate",
    lambda m: m.get("error_rate", 0) > 0.05,
    severity="critical"
)

# Record metrics
monitor.record_metric("response_time", 0.5)
monitor.increment_counter("requests")
```

## Further Reading

- [Full implementation](../shared/self/self-monitoring.md) — Anomaly detection, SLA monitoring
- [Observability](../shared/observability.md) — Tracing, logging, dashboards
