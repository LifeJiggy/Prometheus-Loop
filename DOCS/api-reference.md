# API Reference

## Core API

### BasicAgent

```python
class BasicAgent:
    def __init__(self, llm, tools, memory):
        """Initialize agent.
        
        Args:
            llm: Language model instance
            tools: Dictionary of available tools
            memory: Memory storage instance
        """
    
    def run(self, task: str) -> dict:
        """Execute a task.
        
        Args:
            task: Task description
            
        Returns:
            dict: {
                "success": bool,
                "result": any,
                "cycles": int,
                "tokens_used": int
            }
        """
    
    def gather_context(self, task: str) -> dict:
        """Gather context for task.
        
        Args:
            task: Task description
            
        Returns:
            dict: Context information
        """
    
    def create_plan(self, task: str, context: dict) -> dict:
        """Create execution plan.
        
        Args:
            task: Task description
            context: Gathered context
            
        Returns:
            dict: Execution plan with steps
        """
    
    def reason(self, plan: dict, context: dict) -> dict:
        """Reason about next action.
        
        Args:
            plan: Execution plan
            context: Current context
            
        Returns:
            dict: Decision with action and parameters
        """
    
    def act(self, decision: dict) -> dict:
        """Execute an action.
        
        Args:
            decision: Decision with action details
            
        Returns:
            dict: Action result
        """
    
    def observe(self, result: dict) -> dict:
        """Observe action result.
        
        Args:
            result: Action result
            
        Returns:
            dict: Observation with status and metrics
        """
```

## Self-* Capabilities API

### SelfHealingSystem

```python
class SelfHealingSystem:
    def __init__(self, llm=None):
        """Initialize self-healing system.
        
        Args:
            llm: Optional LLM for diagnosis
        """
    
    def handle_error(self, error: Exception, context: dict) -> dict:
        """Handle an error with self-healing.
        
        Args:
            error: The exception that occurred
            context: Context including action to retry
            
        Returns:
            dict: {
                "healed": bool,
                "fix_applied": str,
                "result": dict,
                "confidence": float
            }
        """
```

### SelfRetrySystem

```python
class SmartRetrySystem:
    def __init__(self, config: dict = None):
        """Initialize retry system.
        
        Args:
            config: Retry configuration
        """
    
    def execute_with_retry(self, action: callable, context: dict = None) -> dict:
        """Execute with smart retry.
        
        Args:
            action: Function to execute
            context: Context including service name
            
        Returns:
            dict: {
                "success": bool,
                "result": any,
                "attempts": int,
                "total_attempts": int
            }
        """
```

### SelfMonitoringSystem

```python
class SelfMonitoringSystem:
    def __init__(self):
        """Initialize monitoring system."""
    
    def record_metric(self, name: str, value: float, tags: dict = None):
        """Record a metric.
        
        Args:
            name: Metric name
            value: Metric value
            tags: Optional tags
        """
    
    def get_health_status(self) -> dict:
        """Get health status.
        
        Returns:
            dict: {
                "status": "healthy" | "degraded" | "critical",
                "health_checks": dict,
                "active_alerts": int
            }
        """
```

### SelfDebuggingSystem

```python
class SelfDebuggingSystem:
    def __init__(self, llm=None):
        """Initialize debugging system.
        
        Args:
            llm: Optional LLM for diagnosis
        """
    
    def debug_error(self, error: Exception, context: dict = None) -> dict:
        """Debug an error.
        
        Args:
            error: The exception to debug
            context: Optional context
            
        Returns:
            dict: {
                "debugged": bool,
                "fix_applied": bool,
                "verified": bool,
                "fix": dict
            }
        """
```

### SelfImprovementSystem

```python
class SelfImprovementSystem:
    def __init__(self, llm=None):
        """Initialize improvement system.
        
        Args:
            llm: Optional LLM for analysis
        """
    
    def record_task(self, task: dict, result: dict, metrics: dict):
        """Record a completed task.
        
        Args:
            task: Task description
            result: Task result
            metrics: Performance metrics
        """
    
    def get_recommendation(self, task: dict) -> dict:
        """Get recommendation for new task.
        
        Args:
            task: New task description
            
        Returns:
            dict: {
                "recommendation": str,
                "strategy": dict,
                "confidence": float
            }
        """
```

## Plugin API

### Installing Plugins

```bash
# Bash
bash install.sh --all

# PowerShell
.\install.ps1 -All

# Python
python install.py --all
```

### Plugin Structure

```
plugin/
├── plugin.json           # Plugin manifest
├── skills/               # Skill implementations
│   └── skill-name/
│       └── SKILL.md      # Skill definition
├── commands/             # Command definitions
│   └── command.md        # Command definition
└── scripts/              # Install scripts
    ├── install.sh
    ├── install.ps1
    └── install.py
```

### Skill Definition

```markdown
---
name: skill-name
description: Skill description
---

# Skill Name

## Quick Start
...

## Implementation
...

## Usage
...
```
