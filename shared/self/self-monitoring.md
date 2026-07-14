# Self-Monitoring Deep Dive

## Overview

Self-Monitoring is the agent's ability to track its own performance, health, resource usage, and behavior in real-time. It detects anomalies, triggers alerts, and provides visibility into the agent's operational state.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SELF-MONITORING SYSTEM                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐        │
│  │ Metric   │──▶│ Threshold│──▶│  Alert   │──▶│ Notify   │        │
│  │ Collector│   │  Engine  │   │  Manager │   │ Handlers │        │
│  └──────────┘   └──────────┘   └──────────┘   └──────────┘        │
│       │              │              │               │                │
│       ▼              ▼              ▼               ▼                │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐        │
│  │ Health   │   │ Anomaly  │   │ Dashboard│   │ Log      │        │
│  │ Checks   │   │ Detection│   │ Data     │   │ Aggregator│       │
│  └──────────┘   └──────────┘   └──────────┘   └──────────┘        │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    METRICS STORE                             │   │
│  │  Time Series │ Aggregations │ Alerts │ Health Status         │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

## Core Implementation

### Metric Collector

```python
class MetricCollector:
    """Collects and stores metrics."""
    
    def __init__(self, retention_hours: int = 24):
        self.retention_hours = retention_hours
        self.metrics = defaultdict(list)
        self.counters = defaultdict(int)
        self.gauges = {}
        self.histograms = defaultdict(list)
    
    def record(self, name: str, value: float, tags: dict = None):
        """Record a metric value."""
        
        entry = {
            "value": value,
            "timestamp": datetime.now().isoformat(),
            "tags": tags or {}
        }
        
        self.metrics[name].append(entry)
        
        # Cleanup old entries
        self.cleanup_old_entries(name)
    
    def increment(self, name: str, amount: int = 1):
        """Increment a counter."""
        
        self.counters[name] += amount
    
    def set_gauge(self, name: str, value: float):
        """Set a gauge value."""
        
        self.gauges[name] = {
            "value": value,
            "timestamp": datetime.now().isoformat()
        }
    
    def observe_histogram(self, name: str, value: float):
        """Observe a value in a histogram."""
        
        self.histograms[name].append({
            "value": value,
            "timestamp": datetime.now().isoformat()
        })
        
        # Keep only recent observations
        if len(self.histograms[name]) > 1000:
            self.histograms[name] = self.histograms[name][-1000:]
    
    def cleanup_old_entries(self, name: str):
        """Remove old metric entries."""
        
        cutoff = datetime.now() - timedelta(hours=self.retention_hours)
        
        self.metrics[name] = [
            m for m in self.metrics[name]
            if datetime.fromisoformat(m["timestamp"]) > cutoff
        ]
    
    def get_summary(self, name: str, time_range: str = "1h") -> dict:
        """Get summary statistics for a metric."""
        
        cutoff = self.parse_time_range(time_range)
        
        entries = [
            m for m in self.metrics.get(name, [])
            if datetime.fromisoformat(m["timestamp"]) > cutoff
        ]
        
        if not entries:
            return {"count": 0}
        
        values = [e["value"] for e in entries]
        
        return {
            "count": len(values),
            "mean": sum(values) / len(values),
            "min": min(values),
            "max": max(values),
            "p50": sorted(values)[len(values) // 2],
            "p95": sorted(values)[int(len(values) * 0.95)],
            "p99": sorted(values)[int(len(values) * 0.99)]
        }
    
    def parse_time_range(self, time_range: str) -> datetime:
        """Parse time range string to datetime."""
        
        unit = time_range[-1]
        value = int(time_range[:-1])
        
        if unit == "m":
            return datetime.now() - timedelta(minutes=value)
        elif unit == "h":
            return datetime.now() - timedelta(hours=value)
        elif unit == "d":
            return datetime.now() - timedelta(days=value)
        
        return datetime.now() - timedelta(hours=1)
    
    def get_all_metrics(self) -> dict:
        """Get all current metrics."""
        
        return {
            "metrics": {name: self.get_summary(name, "1h") for name in self.metrics},
            "counters": dict(self.counters),
            "gauges": {k: v["value"] for k, v in self.gauges.items()},
            "histograms": {
                name: {
                    "count": len(values),
                    "mean": sum(v["value"] for v in values) / len(values) if values else 0
                }
                for name, values in self.histograms.items()
            }
        }
```

### Health Check System

```python
class HealthChecker:
    """Performs health checks on the agent."""
    
    def __init__(self):
        self.checks = {}
        self.results = {}
    
    def register_check(self, name: str, check_fn: callable, 
                       interval_seconds: int = 60):
        """Register a health check."""
        
        self.checks[name] = {
            "check": check_fn,
            "interval": interval_seconds,
            "last_run": None,
            "last_result": None
        }
    
    def run_check(self, name: str) -> dict:
        """Run a specific health check."""
        
        if name not in self.checks:
            return {"status": "unknown", "error": f"Check not found: {name}"}
        
        check = self.checks[name]
        
        try:
            result = check["check"]()
            check["last_run"] = datetime.now()
            check["last_result"] = {
                "status": "healthy" if result.get("healthy", True) else "unhealthy",
                "details": result,
                "timestamp": datetime.now().isoformat()
            }
        except Exception as e:
            check["last_run"] = datetime.now()
            check["last_result"] = {
                "status": "error",
                "error": str(e),
                "timestamp": datetime.now().isoformat()
            }
        
        return check["last_result"]
    
    def run_all_checks(self) -> dict:
        """Run all health checks."""
        
        results = {}
        
        for name in self.checks:
            results[name] = self.run_check(name)
        
        self.results = results
        
        return results
    
    def get_health_status(self) -> dict:
        """Get overall health status."""
        
        if not self.results:
            self.run_all_checks()
        
        healthy = sum(1 for r in self.results.values() if r.get("status") == "healthy")
        total = len(self.results)
        
        return {
            "status": "healthy" if healthy == total else "degraded",
            "healthy_checks": healthy,
            "total_checks": total,
            "checks": self.results
        }
    
    def get_unhealthy_checks(self) -> list:
        """Get list of unhealthy checks."""
        
        return [
            {"name": name, "result": result}
            for name, result in self.results.items()
            if result.get("status") != "healthy"
        ]
```

### Alert Manager

```python
class AlertManager:
    """Manages alerts and notifications."""
    
    def __init__(self):
        self.alert_rules = []
        self.active_alerts = {}
        self.alert_history = []
        self.notification_handlers = []
    
    def add_rule(self, name: str, condition: callable, 
                 severity: str = "warning", message: str = ""):
        """Add an alert rule."""
        
        self.alert_rules.append({
            "name": name,
            "condition": condition,
            "severity": severity,
            "message": message,
            "enabled": True
        })
    
    def add_notification_handler(self, handler: callable):
        """Add a notification handler."""
        
        self.notification_handlers.append(handler)
    
    def evaluate_rules(self, metrics: dict):
        """Evaluate all alert rules."""
        
        for rule in self.alert_rules:
            if not rule["enabled"]:
                continue
            
            try:
                triggered = rule["condition"](metrics)
                
                if triggered:
                    self.trigger_alert(rule, metrics)
                else:
                    self.resolve_alert(rule["name"])
            except Exception as e:
                print(f"Error evaluating rule {rule['name']}: {e}")
    
    def trigger_alert(self, rule: dict, metrics: dict):
        """Trigger an alert."""
        
        alert_id = rule["name"]
        
        # Don't re-trigger if already active
        if alert_id in self.active_alerts:
            return
        
        alert = {
            "id": alert_id,
            "rule": rule["name"],
            "severity": rule["severity"],
            "message": rule["message"],
            "metrics": metrics,
            "timestamp": datetime.now().isoformat(),
            "status": "active"
        }
        
        self.active_alerts[alert_id] = alert
        self.alert_history.append(alert)
        
        # Notify handlers
        for handler in self.notification_handlers:
            try:
                handler(alert)
            except Exception as e:
                print(f"Notification handler error: {e}")
    
    def resolve_alert(self, alert_id: str):
        """Resolve an active alert."""
        
        if alert_id in self.active_alerts:
            alert = self.active_alerts[alert_id]
            alert["status"] = "resolved"
            alert["resolved_at"] = datetime.now().isoformat()
            
            del self.active_alerts[alert_id]
    
    def get_active_alerts(self) -> list:
        """Get all active alerts."""
        
        return list(self.active_alerts.values())
    
    def get_alert_history(self, limit: int = 100) -> list:
        """Get alert history."""
        
        return self.alert_history[-limit:]
```

### Anomaly Detector

```python
class AnomalyDetector:
    """Detects anomalies in metrics."""
    
    def __init__(self, sensitivity: float = 2.0):
        self.sensitivity = sensitivity
        self.baselines = {}
    
    def update_baseline(self, metric_name: str, values: list):
        """Update baseline for a metric."""
        
        if not values:
            return
        
        mean = sum(values) / len(values)
        std = (sum((x - mean) ** 2 for x in values) / len(values)) ** 0.5
        
        self.baselines[metric_name] = {
            "mean": mean,
            "std": std,
            "sample_size": len(values),
            "updated": datetime.now().isoformat()
        }
    
    def is_anomaly(self, metric_name: str, value: float) -> dict:
        """Check if a value is anomalous."""
        
        if metric_name not in self.baselines:
            return {"is_anomaly": False, "reason": "No baseline established"}
        
        baseline = self.baselines[metric_name]
        mean = baseline["mean"]
        std = baseline["std"]
        
        if std == 0:
            return {"is_anomaly": False, "reason": "No variance in baseline"}
        
        # Calculate z-score
        z_score = abs(value - mean) / std
        
        is_anomaly = z_score > self.sensitivity
        
        return {
            "is_anomaly": is_anomaly,
            "z_score": z_score,
            "value": value,
            "baseline_mean": mean,
            "baseline_std": std,
            "deviation": value - mean,
            "deviation_percent": ((value - mean) / mean * 100) if mean != 0 else 0
        }
    
    def detect_anomalies(self, metric_name: str, values: list) -> list:
        """Detect anomalies in a series of values."""
        
        anomalies = []
        
        for i, value in enumerate(values):
            result = self.is_anomaly(metric_name, value)
            if result["is_anomaly"]:
                anomalies.append({
                    "index": i,
                    "value": value,
                    "details": result
                })
        
        return anomalies
```

### Main Self-Monitoring System

```python
class SelfMonitoringSystem:
    """Main self-monitoring orchestrator."""
    
    def __init__(self):
        self.collector = MetricCollector()
        self.health_checker = HealthChecker()
        self.alert_manager = AlertManager()
        self.anomaly_detector = AnomalyDetector()
        self.monitoring_start = datetime.now()
    
    def record_metric(self, name: str, value: float, tags: dict = None):
        """Record a metric."""
        
        self.collector.record(name, value, tags)
        
        # Check for anomalies
        anomaly_check = self.anomaly_detector.is_anomaly(name, value)
        if anomaly_check["is_anomaly"]:
            self.alert_manager.trigger_alert(
                {"name": f"anomaly_{name}", "severity": "warning",
                 "message": f"Anomaly detected in {name}"},
                {"metric": name, "value": value, "details": anomaly_check}
            )
    
    def increment_counter(self, name: str, amount: int = 1):
        """Increment a counter."""
        
        self.collector.increment(name, amount)
    
    def set_gauge(self, name: str, value: float):
        """Set a gauge value."""
        
        self.collector.set_gauge(name, value)
    
    def register_health_check(self, name: str, check_fn: callable):
        """Register a health check."""
        
        self.health_checker.register_check(name, check_fn)
    
    def add_alert_rule(self, name: str, condition: callable, 
                       severity: str = "warning"):
        """Add an alert rule."""
        
        self.alert_manager.add_rule(name, condition, severity)
    
    def add_notification_handler(self, handler: callable):
        """Add a notification handler."""
        
        self.alert_manager.add_notification_handler(handler)
    
    def evaluate(self):
        """Evaluate all monitoring systems."""
        
        # Run health checks
        health_status = self.health_checker.get_health_status()
        
        # Evaluate alert rules
        metrics = self.collector.get_all_metrics()
        self.alert_manager.evaluate_rules(metrics)
        
        # Update baselines for anomaly detection
        for name in self.collector.metrics:
            values = [m["value"] for m in self.collector.metrics[name][-100:]]
            self.anomaly_detector.update_baseline(name, values)
    
    def get_dashboard_data(self) -> dict:
        """Get data for monitoring dashboard."""
        
        uptime = (datetime.now() - self.monitoring_start).total_seconds()
        
        return {
            "uptime_seconds": uptime,
            "health_status": self.health_checker.get_health_status(),
            "active_alerts": self.alert_manager.get_active_alerts(),
            "metrics_summary": self.collector.get_all_metrics(),
            "alert_history": self.alert_manager.get_alert_history(limit=20)
        }
    
    def get_health_status(self) -> dict:
        """Get overall health status."""
        
        health = self.health_checker.get_health_status()
        alerts = self.alert_manager.get_active_alerts()
        
        critical_alerts = [a for a in alerts if a["severity"] == "critical"]
        
        if critical_alerts:
            overall_status = "critical"
        elif health["status"] == "degraded":
            overall_status = "degraded"
        else:
            overall_status = "healthy"
        
        return {
            "status": overall_status,
            "health_checks": health,
            "active_alerts": len(alerts),
            "critical_alerts": len(critical_alerts)
        }
```

## Usage Examples

### Example 1: Basic Monitoring

```python
monitor = SelfMonitoringSystem()

# Record metrics
monitor.record_metric("response_time", 0.5)
monitor.record_metric("error_rate", 0.02)
monitor.increment_counter("requests")
monitor.set_gauge("queue_size", 15)

# Add health checks
monitor.register_health_check("database", lambda: {"healthy": db.ping()})
monitor.register_health_check("cache", lambda: {"healthy": cache.is_connected()})

# Add alert rules
monitor.add_alert_rule(
    "high_error_rate",
    lambda m: m.get("metrics", {}).get("error_rate", {}).get("mean", 0) > 0.05,
    severity="critical"
)

# Evaluate
monitor.evaluate()

# Get status
status = monitor.get_health_status()
print(f"Status: {status['status']}")
```

### Example 2: Custom Dashboard

```python
monitor = SelfMonitoringSystem()

# Simulate metrics
for i in range(100):
    monitor.record_metric("response_time", random.uniform(0.1, 1.0))
    monitor.record_metric("error_rate", random.uniform(0, 0.1))

# Get dashboard data
dashboard = monitor.get_dashboard_data()
print(json.dumps(dashboard, indent=2))
```

## Best Practices

1. **Set meaningful thresholds** — avoid alert fatigue
2. **Use multiple alert severities** — critical vs warning vs info
3. **Track baselines** — anomalies need reference points
4. **Monitor health proactively** — don't wait for failures
5. **Log everything** — you need data for debugging
6. **Dashboard regularly** — make monitoring visible
7. **Test alerting** — ensure alerts actually fire
8. **Review and tune** — adjust thresholds based on reality

## Integration

| Capability | Integration |
|---|---|
| **Self-Healing** | Monitoring triggers healing when issues detected |
| **Self-Retry** | Metrics inform retry decisions |
| **Self-Improving** | Metrics drive optimization |
| **Self-Debugging** | Health checks help diagnose issues |
| **Self-Governing** | Alerts enforce policy compliance |
