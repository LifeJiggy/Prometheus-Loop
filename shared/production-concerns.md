# Production Concerns Deep Dive

## Observability Stack

### OpenTelemetry Integration

```python
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter

# Configure tracing
provider = TracerProvider()
processor = BatchSpanProcessor(OTLPSpanExporter())
provider.add_span_processor(processor)
trace.set_tracer_provider(provider)

tracer = trace.get_tracer("agent-service")


class ObservableAgent:
    def __init__(self, agent):
        self.agent = agent
    
    @tracer.start_as_current_span("agent.run")
    def run(self, task: str) -> dict:
        """Run agent with tracing."""
        
        span = trace.get_current_span()
        span.set_attribute("task", task)
        
        try:
            result = self.agent.run(task)
            span.set_attribute("success", True)
            span.set_attribute("result_length", len(str(result)))
            return result
        except Exception as e:
            span.set_attribute("success", False)
            span.set_attribute("error", str(e))
            raise
    
    @tracer.start_as_current_span("agent.think")
    def think(self, context: dict) -> str:
        """Reasoning step with tracing."""
        
        span = trace.get_current_span()
        span.set_attribute("context_size", len(str(context)))
        
        result = self.agent.think(context)
        
        span.set_attribute("thought_length", len(result))
        return result
    
    @tracer.start_as_current_span("agent.act")
    def act(self, decision: dict) -> dict:
        """Action step with tracing."""
        
        span = trace.get_current_span()
        span.set_attribute("action_type", decision.get("type"))
        span.set_attribute("tool", decision.get("tool"))
        
        result = self.agent.act(decision)
        
        span.set_attribute("success", result.get("success", False))
        return result
```

### Structured Logging

```python
import structlog

logger = structlog.get_logger()


class StructuredLogger:
    def __init__(self):
        self.logger = structlog.get_logger()
    
    def log_agent_start(self, task_id: str, task: str):
        """Log agent start."""
        self.logger.info(
            "agent_started",
            task_id=task_id,
            task=task,
            timestamp=datetime.now().isoformat()
        )
    
    def log_decision(self, task_id: str, cycle: int, decision: dict):
        """Log agent decision."""
        self.logger.info(
            "agent_decision",
            task_id=task_id,
            cycle=cycle,
            action=decision.get("action"),
            tool=decision.get("tool"),
            confidence=decision.get("confidence")
        )
    
    def log_action(self, task_id: str, action: dict, result: dict):
        """Log action execution."""
        self.logger.info(
            "agent_action",
            task_id=task_id,
            action_type=action.get("type"),
            tool=action.get("tool"),
            success=result.get("success"),
            duration_ms=result.get("duration_ms")
        )
    
    def log_error(self, task_id: str, error: Exception, context: dict):
        """Log error."""
        self.logger.error(
            "agent_error",
            task_id=task_id,
            error_type=type(error).__name__,
            error_message=str(error),
            context=context
        )
```

## Cost Control

### Token Budget Manager

```python
class TokenBudgetManager:
    def __init__(self, daily_budget: float, task_budget: float):
        self.daily_budget = daily_budget
        self.task_budget = task_budget
        self.daily_spent = 0.0
        self.task_spent = 0.0
        self.task_id = None
    
    def start_task(self, task_id: str):
        """Start tracking a new task."""
        self.task_id = task_id
        self.task_spent = 0.0
    
    def check_budget(self, estimated_tokens: int, model: str) -> bool:
        """Check if within budget."""
        
        estimated_cost = self.calculate_cost(estimated_tokens, model)
        
        # Check task budget
        if self.task_spent + estimated_cost > self.task_budget:
            logger.warning(
                "task_budget_exceeded",
                task_id=self.task_id,
                spent=self.task_spent,
                estimated=estimated_cost,
                budget=self.task_budget
            )
            return False
        
        # Check daily budget
        if self.daily_spent + estimated_cost > self.daily_budget:
            logger.warning(
                "daily_budget_exceeded",
                spent=self.daily_spent,
                estimated=estimated_cost,
                budget=self.daily_budget
            )
            return False
        
        return True
    
    def record_usage(self, tokens: int, model: str):
        """Record token usage."""
        
        cost = self.calculate_cost(tokens, model)
        
        self.task_spent += cost
        self.daily_spent += cost
        
        logger.info(
            "token_usage",
            task_id=self.task_id,
            tokens=tokens,
            model=model,
            cost=cost,
            task_total=self.task_spent,
            daily_total=self.daily_spent
        )
    
    def calculate_cost(self, tokens: int, model: str) -> float:
        """Calculate cost for tokens."""
        
        rates = {
            "gpt-4o-mini": {"input": 0.15, "output": 0.60},
            "gpt-4o": {"input": 2.50, "output": 10.00},
            "claude-3-haiku": {"input": 0.25, "output": 1.25},
            "claude-3-sonnet": {"input": 3.00, "output": 15.00}
        }
        
        rate = rates.get(model, {"input": 2.50, "output": 10.00})
        
        # Assume 50/50 input/output split
        return (tokens / 2 * rate["input"] + tokens / 2 * rate["output"]) / 1_000_000
```

### Model Router

```python
class ModelRouter:
    def __init__(self):
        self.models = {
            "simple": "gpt-4o-mini",
            "moderate": "gpt-4o",
            "complex": "gpt-4o",
            "critical": "gpt-4o"
        }
    
    def select_model(self, task: str, complexity: str, 
                    budget_remaining: float) -> str:
        """Select model based on task and budget."""
        
        # Default selection
        model = self.models.get(complexity, "gpt-4o")
        
        # Budget constraint
        if budget_remaining < 0.10:
            model = "gpt-4o-mini"
        
        # Task-specific overrides
        if "code" in task.lower():
            model = "gpt-4o"  # Better at code
        elif "quick" in task.lower():
            model = "gpt-4o-mini"
        
        return model
```

## Streaming

### Server-Sent Events (SSE)

```python
from fastapi import FastAPI
from fastapi.responses import StreamingResponse
import json

app = FastAPI()


class StreamingAgent:
    def __init__(self, agent):
        self.agent = agent
    
    async def stream_run(self, task: str):
        """Stream agent execution."""
        
        # Send start event
        yield self.format_event("start", {"task": task})
        
        # Stream reasoning
        async for thought in self.agent.stream_think(task):
            yield self.format_event("thought", {"content": thought})
        
        # Stream actions
        async for action in self.agent.stream_act():
            yield self.format_event("action", {
                "type": action["type"],
                "tool": action.get("tool")
            })
            
            # Stream action result
            async for result in self.agent.stream_execute(action):
                yield self.format_event("result", result)
        
        # Send completion
        yield self.format_event("complete", {"status": "success"})
    
    def format_event(self, event_type: str, data: dict) -> str:
        """Format SSE event."""
        return f"data: {json.dumps({'type': event_type, 'data': data})}\n\n"


@app.post("/agent/run")
async def run_agent(task: str):
    """Stream agent execution."""
    
    agent = StreamingAgent(get_agent())
    
    return StreamingResponse(
        agent.stream_run(task),
        media_type="text/event-stream"
    )
```

### WebSocket Streaming

```python
from fastapi import WebSocket, WebSocketDisconnect


class WebSocketAgent:
    def __init__(self, agent):
        self.agent = agent
        self.connections = []
    
    async def connect(self, websocket: WebSocket):
        """Accept WebSocket connection."""
        await websocket.accept()
        self.connections.append(websocket)
    
    async def disconnect(self, websocket: WebSocket):
        """Remove WebSocket connection."""
        self.connections.remove(websocket)
    
    async def broadcast(self, message: dict):
        """Broadcast message to all connections."""
        
        for connection in self.connections:
            try:
                await connection.send_json(message)
            except:
                await self.disconnect(connection)
    
    async def handle_task(self, websocket: WebSocket, task: str):
        """Handle task with WebSocket streaming."""
        
        try:
            # Stream execution
            async for event in self.agent.stream_run(task):
                await websocket.send_json(event)
            
            await websocket.send_json({
                "type": "complete",
                "status": "success"
            })
        except Exception as e:
            await websocket.send_json({
                "type": "error",
                "message": str(e)
            })
```

## Deployment Patterns

### Blue-Green Deployment

```python
class BlueGreenDeployment:
    def __init__(self):
        self.blue_url = None
        self.green_url = None
        self.active = "blue"
    
    def deploy(self, version: str, url: str):
        """Deploy new version."""
        
        if self.active == "blue":
            self.green_url = url
            self.switch_to_green()
        else:
            self.blue_url = url
            self.switch_to_blue()
    
    def switch_to_green(self):
        """Switch traffic to green."""
        self.active = "green"
        self.update_load_balancer(self.green_url)
    
    def switch_to_blue(self):
        """Switch traffic to blue."""
        self.active = "blue"
        self.update_load_balancer(self.blue_url)
    
    def rollback(self):
        """Rollback to previous version."""
        
        if self.active == "green":
            self.switch_to_blue()
        else:
            self.switch_to_green()
    
    def update_load_balancer(self, url: str):
        """Update load balancer configuration."""
        # Implementation depends on load balancer
        pass
```

### Canary Deployment

```python
class CanaryDeployment:
    def __init__(self):
        self.stable_url = None
        self.canary_url = None
        self.canary_weight = 0
    
    def deploy_canary(self, version: str, url: str, 
                      initial_weight: float = 0.05):
        """Deploy canary version."""
        
        self.canary_url = url
        self.canary_weight = initial_weight
        
        self.update_routing()
    
    def increase_weight(self, increment: float = 0.05):
        """Increase canary traffic weight."""
        
        self.canary_weight = min(1.0, self.canary_weight + increment)
        self.update_routing()
    
    def promote_canary(self):
        """Promote canary to stable."""
        
        self.stable_url = self.canary_url
        self.canary_url = None
        self.canary_weight = 0
        
        self.update_routing()
    
    def rollback(self):
        """Rollback canary."""
        
        self.canary_url = None
        self.canary_weight = 0
        
        self.update_routing()
    
    def update_routing(self):
        """Update traffic routing."""
        # Implementation depends on service mesh
        pass
```

## Agent-as-a-Service

### REST API

```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()


class TaskRequest(BaseModel):
    task: str
    context: dict = {}
    priority: str = "normal"


class TaskResponse(BaseModel):
    task_id: str
    status: str
    result: dict = None


@app.post("/v1/tasks", response_model=TaskResponse)
async def create_task(request: TaskRequest):
    """Create a new task."""
    
    task_id = str(uuid4())
    
    # Validate request
    if not validate_request(request):
        raise HTTPException(status_code=400, detail="Invalid request")
    
    # Check rate limit
    if not check_rate_limit():
        raise HTTPException(status_code=429, detail="Rate limit exceeded")
    
    # Queue task
    await queue_task(task_id, request)
    
    return TaskResponse(task_id=task_id, status="queued")


@app.get("/v1/tasks/{task_id}", response_model=TaskResponse)
async def get_task(task_id: str):
    """Get task status."""
    
    task = await get_task_status(task_id)
    
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    return TaskResponse(
        task_id=task_id,
        status=task["status"],
        result=task.get("result")
    )


@app.delete("/v1/tasks/{task_id}")
async def cancel_task(task_id: str):
    """Cancel a task."""
    
    success = await cancel_task(task_id)
    
    if not success:
        raise HTTPException(status_code=404, detail="Task not found")
    
    return {"status": "cancelled"}
```

### Authentication & Rate Limiting

```python
from fastapi import Security
from fastapi.security import APIKeyHeader

api_key_header = APIKeyHeader(name="X-API-Key")


class RateLimiter:
    def __init__(self):
        self.limits = {
            "free": {"requests": 10, "window": 3600},
            "pro": {"requests": 100, "window": 3600},
            "enterprise": {"requests": 1000, "window": 3600}
        }
        self.usage = defaultdict(list)
    
    def check_rate_limit(self, api_key: str, tier: str) -> bool:
        """Check if rate limit is exceeded."""
        
        limit = self.limits.get(tier, self.limits["free"])
        
        # Clean old entries
        cutoff = datetime.now() - timedelta(seconds=limit["window"])
        self.usage[api_key] = [
            t for t in self.usage[api_key] if t > cutoff
        ]
        
        # Check limit
        if len(self.usage[api_key]) >= limit["requests"]:
            return False
        
        # Record request
        self.usage[api_key].append(datetime.now())
        
        return True


def authenticate(api_key: str = Security(api_key_header)):
    """Authenticate API request."""
    
    # Validate API key
    user = validate_api_key(api_key)
    
    if not user:
        raise HTTPException(status_code=401, detail="Invalid API key")
    
    return user
```

### SLA Monitoring

```python
class SLAMonitor:
    def __init__(self):
        self.sla_targets = {
            "uptime": 0.999,
            "latency_p95": 5.0,
            "error_rate": 0.01
        }
        self.metrics = defaultdict(list)
    
    def record_metric(self, metric: str, value: float):
        """Record SLA metric."""
        self.metrics[metric].append({
            "value": value,
            "timestamp": datetime.now()
        })
    
    def check_sla(self) -> dict:
        """Check SLA compliance."""
        
        results = {}
        
        for metric, target in self.sla_targets.items():
            values = [m["value"] for m in self.metrics[metric]]
            
            if not values:
                results[metric] = {"compliant": True, "current": None}
                continue
            
            if metric in ["uptime", "success_rate"]:
                current = sum(values) / len(values)
                compliant = current >= target
            else:
                current = sum(values) / len(values)
                compliant = current <= target
            
            results[metric] = {
                "compliant": compliant,
                "current": current,
                "target": target
            }
        
        return results
```
