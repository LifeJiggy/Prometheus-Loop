# Monitoring Setup Guide

## Monitoring Stack

### Components

| Component | Purpose | Tool |
|---|---|---|
| **Metrics** | Collect numerical data | Prometheus |
| **Logs** | Collect text data | ELK Stack |
| **Traces** | Track requests | Jaeger |
| **Dashboards** | Visualize data | Grafana |
| **Alerts** | Notify on issues | PagerDuty |

## Setup Steps

### 1. Install Prometheus

```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'agent'
    static_configs:
      - targets: ['localhost:8080']
    metrics_path: '/metrics'
```

### 2. Configure Grafana

```json
{
  "dashboard": {
    "title": "Agent Metrics",
    "panels": [
      {
        "title": "Task Completion Rate",
        "type": "stat",
        "targets": [{"expr": "agent_tasks_completed / agent_tasks_total"}]
      },
      {
        "title": "Error Rate",
        "type": "graph",
        "targets": [{"expr": "rate(agent_errors_total[5m])"}]
      },
      {
        "title": "Latency",
        "type": "heatmap",
        "targets": [{"expr": "histogram_quantile(0.95, agent_latency_bucket)"}]
      }
    ]
  }
}
```

### 3. Set Up Alerts

```yaml
# alerts.yml
groups:
  - name: agent
    rules:
      - alert: HighErrorRate
        expr: rate(agent_errors_total[5m]) > 0.05
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High error rate detected"
      
      - alert: HighLatency
        expr: histogram_quantile(0.95, agent_latency_bucket) > 30
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High latency detected"
```

## Key Metrics

| Metric | Description | Alert Threshold |
|---|---|---|
| `agent_tasks_total` | Total tasks processed | - |
| `agent_tasks_completed` | Successfully completed tasks | - |
| `agent_errors_total` | Total errors | - |
| `agent_latency_seconds` | Request latency | > 30s |
| `agent_tokens_used` | Tokens consumed | > budget |
| `agent_cost_dollars` | Cost incurred | > budget |

## Dashboard Panels

### Task Overview
- Task completion rate
- Tasks per minute
- Error rate

### Performance
- Latency distribution
- Token usage
- Cost per task

### Health
- Uptime
- Memory usage
- CPU usage

### Errors
- Error rate by type
- Error trend over time
- Top error messages
