# Observability & Monitoring

## Observability Stack

| Layer | Tool | Purpose |
|---|---|---|
| **Tracing** | LangSmith, Phoenix, Langfuse | Track LLM calls, chain execution, latency |
| **Logging** | Structured logs (JSON) | Audit trail, debugging, compliance |
| **Metrics** | Prometheus + Grafana | Dashboards, alerts, trend analysis |
| **Alerting** | PagerDuty, OpsGenie | Incident response, anomaly detection |
| **Session replay** | Custom or LangSmith | Replay agent sessions for debugging |
| **Profiling** | Py-Spy, cProfile | CPU/memory profiling for performance |
| **Error tracking** | Sentry, Rollbar | Exception capture and grouping |

## Structured Log Format

### Standard Log Entry

```json
{
  "timestamp": "2025-01-15T10:32:01Z",
  "level": "info",
  "session_id": "ses_abc123",
  "task_id": "task_xyz789",
  "cycle": 3,
  "step": "permission_gate",
  "agent_id": "main",
  "action": "write src/auth.py",
  "input": {"file": "src/auth.py", "content_length": 2048},
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

### Log Levels

| Level | When to use | Example |
|---|---|---|
| **DEBUG** | Detailed diagnostic info | "Context loaded: 5 documents, 2400 tokens" |
| **INFO** | Normal operations | "Task completed successfully in 4 cycles" |
| **WARN** | Unexpected but recoverable | "Rate limit approaching: 45/50 requests used" |
| **ERROR** | Operation failed | "Tool call failed: connection timeout" |
| **CRITICAL** | System-level failure | "Memory store unavailable, falling back to session memory" |

### Structured Logging Implementation

```python
import structlog
from pythonjsonlogger import jsonlogger

# Configure structured logging
structlog.configure(
    processors=[
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.add_log_level,
        structlog.processors.StackInfoRenderer(),
        structlog.dev.ConsoleRenderer() if DEBUG else jsonlogger.JsonFormatter()
    ],
    context_class=dict,
    logger_factory=structlog.PrintLoggerFactory(),
    wrapper_class=structlog.BoundLogger,
    cache_logger_on_first_use=True,
)

logger = structlog.get_logger()


class AgentLogger:
    """Structured logger for agent operations."""
    
    def __init__(self, session_id: str, task_id: str):
        self.session_id = session_id
        self.task_id = task_id
        self.logger = logger.bind(session_id=session_id, task_id=task_id)
    
    def log_cycle_start(self, cycle: int):
        """Log cycle start."""
        self.logger.info(
            "cycle_started",
            cycle=cycle,
            event="cycle_start"
        )
    
    def log_decision(self, cycle: int, decision: dict):
        """Log agent decision."""
        self.logger.info(
            "decision_made",
            cycle=cycle,
            action=decision.get("action"),
            tool=decision.get("tool"),
            confidence=decision.get("confidence"),
            event="decision"
        )
    
    def log_action(self, cycle: int, action: dict, result: dict, duration_ms: float):
        """Log action execution."""
        self.logger.info(
            "action_executed",
            cycle=cycle,
            action_type=action.get("type"),
            tool=action.get("tool"),
            success=result.get("success"),
            duration_ms=duration_ms,
            tokens_used=result.get("tokens_used", 0),
            event="action"
        )
    
    def log_gate(self, cycle: int, decision: dict, evaluation: dict):
        """Log gate evaluation."""
        self.logger.info(
            "gate_evaluated",
            cycle=cycle,
            action=decision.get("action"),
            allowed=evaluation.get("allowed"),
            reason=evaluation.get("reason"),
            risk_level=evaluation.get("risk_level"),
            event="gate"
        )
    
    def log_error(self, cycle: int, error: Exception, context: dict):
        """Log error."""
        self.logger.error(
            "error_occurred",
            cycle=cycle,
            error_type=type(error).__name__,
            error_message=str(error),
            context=context,
            event="error"
        )
    
    def log_task_complete(self, result: dict, total_cycles: int, total_tokens: int):
        """Log task completion."""
        self.logger.info(
            "task_completed",
            success=result.get("success"),
            total_cycles=total_cycles,
            total_tokens=total_tokens,
            total_cost=result.get("cost", 0),
            event="task_complete"
        )
```

## Dashboard Metrics

### Agent Health Dashboard

| Panel | Metric | Alert Threshold | Description |
|---|---|---|---|
| Task completion rate | % tasks finished successfully | < 80% | Core success metric |
| Average cycle count | Loops per task | > 50% above baseline | Efficiency indicator |
| Token consumption | Tokens per task | > 2x normal | Cost predictor |
| Error rate | Failed actions / total actions | > 5% | Reliability indicator |
| HITL queue depth | Pending approvals | > 10 | Human bottleneck |
| Self-heal success rate | Self-healed / total failures | < 40% | Resilience indicator |
| Cost per task | Dollar cost per task | > budget threshold | Budget tracking |
| Latency p95 | 95th percentile response time | > 30s | Performance indicator |

### Security Dashboard

| Panel | Metric | Alert Threshold | Description |
|---|---|---|---|
| Gate denials | Denied actions / total actions | Spike > 2x normal | Potential attack |
| Prompt injection attempts | Blocked injection attempts | Any spike | Active attack |
| Data exfiltration attempts | Blocked exfil attempts | Any occurrence | Data breach attempt |
| Memory anomalies | Flagged memory entries | > 0 | Memory poisoning |
| Adversarial inputs detected | Flagged user inputs | > 0 | Active attack |

### Cost Dashboard

| Panel | Metric | Alert Threshold | Description |
|---|---|---|---|
| Daily cost | Total spend per day | > 80% of budget | Budget tracking |
| Cost per task type | Cost breakdown by task | > 2x average | Efficiency by type |
| Model usage distribution | Tokens by model | Skewed distribution | Routing efficiency |
| Cache hit rate | Cache hits / total lookups | < 20% | Cache effectiveness |
| Cost trend | 7-day moving average | Increasing trend | Budget forecasting |

## Tracing with LangSmith

### Basic Tracing

```python
from langsmith import traceable
from langsmith.run_helpers import trace

@traceable(name="agentic-loop", run_type="chain")
def run_agent(task: str):
    """Run agent with full tracing."""
    
    # Trace prompt building
    with trace(name="prompt", run_type="llm") as t:
        prompt = build_prompt(task)
        t.on_inputs({"task": task})
        t.on_outputs({"prompt_length": len(prompt)})
    
    # Trace context gathering
    with trace(name="context", run_type="chain") as t:
        context = gather_context(prompt)
        t.on_outputs({"context_size": len(str(context))})
    
    # Trace planning
    with trace(name="plan", run_type="llm") as t:
        plan = create_plan(context)
        t.on_outputs({"plan_steps": len(plan.get("steps", []))})
    
    # Trace reasoning
    with trace(name="reason", run_type="llm") as t:
        decision = reason(plan, context)
        t.on_outputs({"action": decision.get("action")})
    
    # Trace gate evaluation
    with trace(name="gate", run_type="tool") as t:
        gate_result = permission_gate(decision)
        t.on_outputs({"allowed": gate_result.get("allowed")})
    
    # Trace action execution
    with trace(name="act", run_type="tool") as t:
        result = execute(decision)
        t.on_outputs({"success": result.get("success")})
    
    # Trace observation
    with trace(name="observe", run_type="chain") as t:
        observation = observe(result)
        t.on_outputs({"observation": observation})
    
    return observation
```

### Advanced Tracing

```python
from langsmith import traceable
from functools import wraps
import time


def trace_performance(func):
    """Decorator to trace function performance."""
    
    @wraps(func)
    @traceable(name=f"{func.__name__}", run_type="chain")
    def wrapper(*args, **kwargs):
        start_time = time.time()
        
        try:
            result = func(*args, **kwargs)
            duration = time.time() - start_time
            
            # Log success
            logger.info(
                f"{func.__name__}_completed",
                duration_ms=duration * 1000,
                success=True
            )
            
            return result
        except Exception as e:
            duration = time.time() - start_time
            
            # Log failure
            logger.error(
                f"{func.__name__}_failed",
                duration_ms=duration * 1000,
                error=str(e)
            )
            
            raise
    
    return wrapper


class TracedAgent:
    """Agent with comprehensive tracing."""
    
    @trace_performance
    def run(self, task: str) -> dict:
        """Run agent with tracing."""
        
        with trace(name="agent.run", run_type="chain") as t:
            t.on_inputs({"task": task})
            
            result = self._execute(task)
            
            t.on_outputs({
                "success": result.get("success"),
                "cycles": result.get("cycles"),
                "tokens": result.get("tokens")
            })
            
            return result
    
    @trace_performance
    def _execute(self, task: str) -> dict:
        """Execute with sub-tracing."""
        
        cycles = 0
        tokens_used = 0
        
        while cycles < self.max_cycles:
            with trace(name=f"cycle_{cycles}", run_type="chain"):
                # Reason
                with trace(name="reason", run_type="llm"):
                    decision = self.reason(task)
                    tokens_used += decision.get("tokens", 0)
                
                # Gate
                with trace(name="gate", run_type="tool"):
                    gate_result = self.gate(decision)
                
                if not gate_result.get("allowed"):
                    break
                
                # Act
                with trace(name="act", run_type="tool"):
                    result = self.act(decision)
                    tokens_used += result.get("tokens", 0)
                
                # Observe
                with trace(name="observe", run_type="chain"):
                    observation = self.observe(result)
                
                if observation.get("status") == "success":
                    break
                
                cycles += 1
        
        return {
            "success": observation.get("status") == "success",
            "cycles": cycles,
            "tokens": tokens_used
        }
```

## Alert Rules

### Prometheus Alert Rules

```yaml
groups:
  - name: agent_alerts
    rules:
      # Agent stuck in loop
      - alert: AgentStuckInLoop
        expr: agent_cycle_count > 20
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Agent stuck in loop"
          description: "Task {{ $labels.task_id }} has exceeded 20 cycles"
      
      # Cost spike
      - alert: CostSpike
        expr: rate(agent_cost_total[5m]) > 2 * rate(agent_cost_total[1h] offset 1d)
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Cost spike detected"
          description: "Agent cost is 2x higher than baseline"
      
      # Security violation
      - alert: SecurityViolation
        expr: increase(agent_gate_denials_total[1m]) > 5
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Security violation detected"
          description: "Multiple gate denials in 1 minute"
      
      # Human bottleneck
      - alert: HumanBottleneck
        expr: agent_hitl_queue_depth > 20
        for: 15m
        labels:
          severity: warning
        annotations:
          summary: "Human approval bottleneck"
          description: "HITL queue has {{ $value }} pending items"
      
      # Error rate
      - alert: HighErrorRate
        expr: rate(agent_errors_total[5m]) / rate(agent_actions_total[5m]) > 0.05
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High error rate"
          description: "Agent error rate is {{ $value | humanizePercentage }}"
      
      # Latency
      - alert: HighLatency
        expr: histogram_quantile(0.95, agent_latency_bucket) > 30
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High latency"
          description: "p95 latency is {{ $value }}s"
```

## Session Replay

### Session Replay Implementation

```python
class SessionReplay:
    def __init__(self):
        self.events = []
    
    def record_event(self, event: dict):
        """Record an event for replay."""
        
        self.events.append({
            **event,
            "timestamp": datetime.now().isoformat(),
            "sequence": len(self.events)
        })
    
    def replay(self, session_id: str) -> list:
        """Replay a session."""
        
        # Load events from storage
        events = self.load_events(session_id)
        
        # Reconstruct timeline
        timeline = []
        for event in events:
            timeline.append({
                "time": event["timestamp"],
                "type": event.get("type"),
                "summary": self.summarize_event(event),
                "details": event
            })
        
        return timeline
    
    def summarize_event(self, event: dict) -> str:
        """Create human-readable summary of event."""
        
        event_type = event.get("type")
        
        if event_type == "task_start":
            return f"Task started: {event.get('task', 'unknown')[:50]}..."
        elif event_type == "decision":
            return f"Agent decided to: {event.get('action', 'unknown')}"
        elif event_type == "action":
            return f"Executed: {event.get('tool', 'unknown')} - {'success' if event.get('success') else 'failed'}"
        elif event_type == "gate":
            return f"Gate: {'ALLOWED' if event.get('allowed') else 'DENIED'} - {event.get('reason', '')}"
        elif event_type == "error":
            return f"Error: {event.get('error_type', 'unknown')}"
        elif event_type == "task_complete":
            return f"Task {'completed' if event.get('success') else 'failed'}"
        
        return f"Event: {event_type}"
    
    def export_session(self, session_id: str, format: str = "json") -> str:
        """Export session for analysis."""
        
        events = self.load_events(session_id)
        
        if format == "json":
            return json.dumps(events, indent=2)
        elif format == "markdown":
            return self.to_markdown(events)
        elif format == "csv":
            return self.to_csv(events)
        
        return json.dumps(events)
    
    def to_markdown(self, events: list) -> str:
        """Convert events to markdown."""
        
        lines = ["# Session Replay\n"]
        
        for event in events:
            lines.append(f"## {event.get('timestamp', 'unknown')}")
            lines.append(f"**Type:** {event.get('type', 'unknown')}")
            lines.append(f"**Summary:** {self.summarize_event(event)}")
            lines.append("")
        
        return "\n".join(lines)
```

## Debugging Workflows

### Debugging Agent Failures

```python
class AgentDebugger:
    def __init__(self, agent):
        self.agent = agent
        self.debug_log = []
    
    def debug_task(self, task: str) -> dict:
        """Debug a failing task."""
        
        self.debug_log = []
        
        # Run with debug logging
        try:
            result = self.agent.run(task)
            self.debug_log.append({
                "step": "completion",
                "result": result
            })
        except Exception as e:
            self.debug_log.append({
                "step": "error",
                "error": str(e),
                "traceback": traceback.format_exc()
            })
        
        # Analyze debug log
        analysis = self.analyze_log()
        
        return {
            "task": task,
            "debug_log": self.debug_log,
            "analysis": analysis,
            "recommendations": self.generate_recommendations(analysis)
        }
    
    def analyze_log(self) -> dict:
        """Analyze debug log for issues."""
        
        issues = []
        
        for entry in self.debug_log:
            # Check for errors
            if entry.get("step") == "error":
                issues.append({
                    "type": "error",
                    "message": entry.get("error"),
                    "severity": "high"
                })
            
            # Check for slow steps
            if entry.get("duration_ms", 0) > 5000:
                issues.append({
                    "type": "performance",
                    "message": f"Slow step: {entry.get('step')} took {entry.get('duration_ms')}ms",
                    "severity": "medium"
                })
            
            # Check for high token usage
            if entry.get("tokens_used", 0) > 10000:
                issues.append({
                    "type": "efficiency",
                    "message": f"High token usage: {entry.get('tokens_used')} tokens",
                    "severity": "low"
                })
        
        return {
            "issues": issues,
            "total_issues": len(issues),
            "high_severity": sum(1 for i in issues if i["severity"] == "high")
        }
    
    def generate_recommendations(self, analysis: dict) -> list:
        """Generate recommendations based on analysis."""
        
        recommendations = []
        
        for issue in analysis.get("issues", []):
            if issue["type"] == "error":
                recommendations.append(
                    "Check error message and stack trace for root cause"
                )
            elif issue["type"] == "performance":
                recommendations.append(
                    "Consider caching or parallelizing slow operations"
                )
            elif issue["type"] == "efficiency":
                recommendations.append(
                    "Consider context compression or model optimization"
                )
        
        return recommendations
```

## Monitoring Best Practices

### The Four Golden Signals

| Signal | What it measures | Target |
|---|---|---|
| **Latency** | Time to complete a task | < 30s for simple, < 5min for complex |
| **Traffic** | Number of concurrent tasks | Within capacity limits |
| **Errors** | Failed tasks / total tasks | < 5% |
| **Saturation** | Resource utilization | < 80% of capacity |

### RED Method

| Metric | Definition | How to measure |
|---|---|---|
| **Rate** | Requests per second | count(requests) / time |
| **Errors** | Errors per second | count(errors) / time |
| **Duration** | Latency distribution | histogram(duration) |

### USE Method

| Metric | Definition | How to measure |
|---|---|---|
| **Utilization** | % time resource is busy | cpu_time / total_time |
| **Saturation** | Queue depth | queue_length |
| **Errors** | Error count | count(errors) |
