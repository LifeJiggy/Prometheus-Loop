# Deployment Guide

## Deployment Options

### 1. Local Development

```bash
# Clone and install
git clone https://github.com/LifeJiggy/Prometheus-Loop.git
cd Prometheus-Loop
bash prometheus-loop-plugin/scripts/install.sh --all
```

### 2. Docker Deployment

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Copy plugin files
COPY prometheus-loop-plugin/ ./prometheus-loop-plugin/

# Install dependencies
RUN pip install -r requirements.txt

# Install plugin
RUN python prometheus-loop-plugin/scripts/install.py --all

# Run agent
CMD ["python", "main.py"]
```

### 3. Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus-agent
spec:
  replicas: 3
  selector:
    matchLabels:
      app: prometheus-agent
  template:
    metadata:
      labels:
        app: prometheus-agent
    spec:
      containers:
      - name: agent
        image: prometheus-loop:latest
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
```

## Environment Variables

| Variable | Description | Default |
|---|---|---|
| `PROMETHEUS_LOG_LEVEL` | Logging level | `INFO` |
| `PROMETHEUS_MAX_RETRIES` | Maximum retry attempts | `3` |
| `PROMETHEUS_TIMEOUT` | Operation timeout (seconds) | `30` |
| `PROMETHEUS_BUDGET` | Daily token budget | `1000000` |

## Monitoring Setup

```yaml
# prometheus.yml
scrape_configs:
  - job_name: 'prometheus-agent'
    static_configs:
      - targets: ['localhost:8080']
    metrics_path: '/metrics'
    scrape_interval: 15s
```

## Health Checks

```python
# Health check endpoint
@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "version": "1.0.0",
        "uptime": get_uptime(),
        "metrics": get_metrics_summary()
    }
```
