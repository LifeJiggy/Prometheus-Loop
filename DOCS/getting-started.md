# Getting Started with Prometheus Loop

## What is Prometheus Loop?

Prometheus Loop is a comprehensive framework for building, teaching, and reasoning about **agentic AI systems** — AI agents that can plan, act, observe, learn, and iterate autonomously.

## Installation

### From Source (Recommended)

```bash
# Clone the repository
git clone https://github.com/LifeJiggy/Prometheus-Loop.git
cd Prometheus-Loop

# Install as plugin (Linux/macOS)
bash prometheus-loop-plugin/scripts/install.sh --all

# Install as plugin (Windows PowerShell)
.\prometheus-loop-plugin\scripts\install.ps1 -All

# Install as plugin (Python cross-platform)
python prometheus-loop-plugin/scripts/install.py --all
```

### Using the Plugin

After installation, restart your CLI/IDE and use:

```
/loop                    # Show the loop overview
/loop self-healing       # Show specific capability
/loop guide              # Show implementation guide
```

## Your First Agent

### Step 1: Understand the Loop

The core loop has 7 steps:

```
Prompt → Context → Plan → Reason → Act → Observe → Store/Remember → (loop)
```

### Step 2: Implement Basic Agent

```python
class BasicAgent:
    def __init__(self, llm, tools, memory):
        self.llm = llm
        self.tools = tools
        self.memory = memory
    
    def run(self, task: str) -> dict:
        # 1. Context
        context = self.gather_context(task)
        
        # 2. Plan
        plan = self.create_plan(task, context)
        
        # 3-6. Execute loop
        for cycle in range(plan.max_cycles):
            decision = self.reason(plan, context)
            result = self.act(decision)
            observation = self.observe(result)
            
            if observation.status == "success":
                break
            
            context.update(observation)
        
        # 7. Store
        self.store(task, plan, result)
        
        return result
```

### Step 3: Add Safety (v2)

```python
class SafeAgent(BasicAgent):
    def run(self, task: str) -> dict:
        # Add permission gate
        gate_result = self.permission_gate.evaluate(action)
        if not gate_result.allowed:
            return self.handle_denied(action, gate_result)
        
        # Add HITL for high-risk actions
        if gate_result.requires_approval:
            approval = self.hitl.request(action)
            if not approval.approved:
                return self.handle_rejected(action)
        
        # Continue with basic loop
        return super().run(task)
```

## Next Steps

1. Read the [Architecture Guide](architecture.md) to understand the system design
2. Explore the [API Reference](api-reference.md) for implementation details
3. Check out the [Examples](../examples/) for real-world use cases
4. Join the community for support and contributions

## Support

- **Issues**: [GitHub Issues](https://github.com/LifeJiggy/Prometheus-Loop/issues)
- **Discussions**: [GitHub Discussions](https://github.com/LifeJiggy/Prometheus-Loop/discussions)
- **Documentation**: This folder
