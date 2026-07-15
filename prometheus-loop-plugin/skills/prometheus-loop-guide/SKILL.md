---
name: prometheus-loop-guide
description: Core agentic AI loop guide with 7-step framework, self-* capabilities, and implementation patterns
---

# Prometheus Loop Guide

The foundational agentic AI loop with 7 steps: Prompt, Context, Plan, Reason, Act, Observe, Store/Memory.

## Quick Start

When the user asks about building an agent, use this guide:

1. **Understand the loop** — 7 steps that form the core of any agent
2. **Add safety layers** — Permission Gate, HITL, Retry (v2)
3. **Add autonomy** — Self-Healing, Self-Planning, Self-Improvement (v3)

## The 7-Step Loop

```
Prompt → Context → Plan → Reason → Act → Observe → Store/Remember → (loop)
```

### Step 1: Prompt

The instruction that kicks off a cycle. More than just the user's ask — it's the system prompt, the tool definitions, and any few-shot examples that shape how the agent behaves.

**What's in a prompt:**
- User message (the immediate task)
- System prompt (behavioral constraints, persona, safety rules)
- Tool definitions (schemas for every action the agent can take)
- Few-shot examples (input/output pairs that calibrate behavior)

**Why it matters:**
The prompt is the seed crystal. Every downstream decision cascades from this step. A vague prompt produces a vague plan. A precise prompt produces a focused agent.

**Common failure modes:**
- Overloaded system prompts (50+ rules create conflict)
- Missing tool schemas (agent invents tools that don't exist)
- No success criteria (agent loops indefinitely)

**Example:**
```python
# Bad prompt
prompt = "Help me with my code"

# Good prompt
prompt = """
Task: Fix the failing test in test_auth.py
Context: The test expects status=200 but the handler returns 404
Constraints: 
- Only modify src/auth.py
- Don't change the test
- Run tests after fixing
Success: All tests pass
"""
```

---

### Step 2: Context

Everything pulled in before reasoning starts: retrieved documents (RAG), conversation history, live data, tool outputs from earlier steps.

**Context sources:**
| Source | What it provides | When to use |
|---|---|---|
| Conversation history | Prior turns, user preferences | Always |
| RAG retrieval | External documents, codebase | When task references external info |
| Tool outputs | Results from prior steps | Multi-step cycles |
| Live data | Real-time state | When task depends on current state |
| Memory | Curated facts, learned patterns | Every subsequent cycle |

**Why it matters:**
Context is the bottleneck. Models have finite windows, and most real tasks need more information than fits. The art is retrieval and compression: pull in exactly what's relevant, summarize what's too long, discard what's noise.

**Cost note:**
Every token of context costs inference time and money. More context is not always better — *relevant* context is.

**Common failure modes:**
- Context poisoning (stale/incorrect info leads to wrong actions)
- Context overflow (too much pushes out critical earlier turns)
- Missing context (agent acts without needed information)

---

### Step 3: Plan

Break the goal into ordered sub-tasks, or delegate across sub-agents if it's a multi-agent system.

**Planning patterns:**
| Pattern | When to use | Example |
|---|---|---|
| Sequential | Tasks with clear ordering | "Read file → find bug → fix → test" |
| Parallel | Independent sub-tasks | "Search 3 codebases for same pattern" |
| Hierarchical | Large tasks with sub-sub-tasks | "Refactor auth module" → extract, test, migrate |
| Delegated | Tasks needing specialization | "Agent A researches, B implements, C reviews" |

**Why it matters:**
Planning is the difference between "I'll try things until something works" and "here's the path, now execute it." Without planning, the agent burns tokens on dead ends.

**Common failure modes:**
- Over-planning (20-step plan for a 2-step task)
- Under-planning (diving straight into complex tasks)
- Rigid plans (not updating when observations reveal new info)

---

### Step 4: Reason

The actual inference step — chain-of-thought, weighing options, deciding what to do next.

**What reasoning does:**
1. Evaluate the plan — is this still the right approach?
2. Select the next action — which tool, with what parameters?
3. Assess confidence — am I sure about this?
4. Handle ambiguity — ask user, try exploratory action, or proceed?

**Why it matters:**
Reasoning is where the model earns its keep. It's not just "think about the next step" — it's evaluating tradeoffs: speed vs. accuracy, exploration vs. exploitation, autonomy vs. caution.

**Common failure modes:**
- Confident wrong reasoning (picks plausible but incorrect path)
- Analysis paralysis (reasons endlessly without committing)
- Sunk cost fallacy (continues down failing path)

---

### Step 5: Act

Where thinking becomes doing: call an API, run code, hit an endpoint, write a file, send a request.

**Action categories:**
| Category | Examples | Risk level |
|---|---|---|
| Read-only | Search, query, fetch, list | Low |
| Constructive | Create file, write code, generate output | Medium |
| Mutating | Edit file, update database, modify config | High |
| Irreversible | Delete, send, deploy, publish | Critical |

**Why it matters:**
Actions are where the agent's work becomes real. The gap between "I think I should do X" and "X is done" is where most failures happen.

**Common failure modes:**
- Action without observation (doing and not checking)
- Blast radius blindness (affecting more than intended)
- Retry loops (hitting same failing action repeatedly)

---

### Step 6: Observe

Capture what actually happened — success, failure, returned data, side effects — and feed it back in.

**What to observe:**
| Signal | Why it matters |
|---|---|
| Return value | Did the action produce expected output? |
| Error messages | What went wrong? Is it retryable? |
| Side effects | Did it change state beyond intended? |
| Timing | Was it fast enough? Did it timeout? |
| Resource usage | Did it exhaust quotas, hit rate limits? |

**Why it matters:**
Observation closes the gap between intention and reality. Without it, the agent operates on assumptions. The quality of observation directly determines the quality of recovery.

**Common failure modes:**
- Partial observation (checking only happy path)
- Ignoring warnings (success code with warning messages)
- No observation at all (calling tool and not reading result)

---

### Step 7: Storage & Memory

Two different jobs:
- **Storage** — raw persistence (logs, artifacts, whatever hits disk)
- **Memory** — the curated subset that gets pulled back into Context next cycle

**Storage vs. Memory:**
| | Storage | Memory |
|---|---|---|
| What | Everything that happened | What's worth remembering |
| Format | Raw logs, full outputs | Summaries, key facts |
| Access | On-demand (search when needed) | Injected into every cycle |
| Volume | Unbounded | Bounded (curate ruthlessly) |

**Why it matters:**
Storage is cheap; memory is expensive (in context tokens). Not everything stored is worth remembering. A good memory system curates — surfaces what's relevant, discards what's noise.

---

## The loop, not the line

The real unlock is that **Memory feeds back into Context**, and a failed **Observe** can kick the agent back to **Plan** instead of dead-ending.

**Compressed version:**
> Prompt → Context → Plan → Reason → Act → Observe → Store/Remember → (loop)

**Feedback edges:**
1. Memory → Context (learning across cycles)
2. Observe(failure) → Plan (recovery within a cycle)
3. Observe → Act (retry same action)

---

## Maturity Levels

| Level | Adds | Use when |
|---|---|---|
| **v1 (Core)** | Basic 7-step loop | Teaching, prototyping |
| **v2 (Production)** | Safety, HITL, retry, goal check | Real deployments |
| **v3 (Autonomous)** | Self-healing, learning, adaptation | Minimal oversight |

---

## Self-* Capabilities

### Detection Layer
- **Self-Monitoring** — tracks metrics, health, alerts
- **Self-Observing** — traces decisions, reflects on reasoning

### Diagnosis Layer
- **Self-Debugging** — captures errors, analyzes root causes
- **Self-Healing** — classifies errors, applies fixes, verifies recovery

### Adaptation Layer
- **Self-Adapting** — detects context changes, adjusts configuration
- **Self-Retry** — smart backoff, circuit breakers, adaptive strategies
- **Self-Planning** — decomposes goals, creates and adapts plans

### Evolution Layer
- **Self-Improving** — learns from successes and failures
- **Self-Evolution** — acquires new capabilities, adapts architecture
- **Self-Refactoring** — improves code structure, reduces complexity

### Governance Layer
- **Self-Governing** — enforces policies, ethical guidelines
- **Multi-Agent Orchestration** — coordinates multiple agents
- **Self-Remembering** — manages memory lifecycle

---

## Implementation Patterns

### Basic Agent Loop

```python
class BasicAgent:
    def __init__(self, llm, tools, memory):
        self.llm = llm
        self.tools = tools
        self.memory = memory
    
    def run(self, task: str) -> dict:
        # 1. Prompt (already received)
        
        # 2. Context
        context = self.gather_context(task)
        
        # 3. Plan
        plan = self.create_plan(task, context)
        
        # 4-6. Execute loop
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

### Agent with Safety (v2)

```python
class SafeAgent(BasicAgent):
    def __init__(self, llm, tools, memory, gate, hitl):
        super().__init__(llm, tools, memory)
        self.gate = gate
        self.hitl = hitl
    
    def run(self, task: str) -> dict:
        context = self.gather_context(task)
        plan = self.create_plan(task, context)
        
        for cycle in range(plan.max_cycles):
            decision = self.reason(plan, context)
            
            # Permission Gate
            gate_result = self.gate.evaluate(decision)
            if not gate_result.allowed:
                if gate_result.requires_approval:
                    approval = self.hitl.request(decision)
                    if not approval.approved:
                        continue
                else:
                    continue
            
            result = self.act(decision)
            observation = self.observe(result)
            
            if observation.status == "success":
                break
            
            # Retry vs Replan
            if observation.retryable:
                continue  # Retry same action
            else:
                plan = self.replan(plan, observation)  # New plan
        
        self.store(task, plan, result)
        return result
```

### Agent with Autonomy (v3)

```python
class AutonomousAgent(SafeAgent):
    def __init__(self, llm, tools, memory, gate, hitl, healer, improver):
        super().__init__(llm, tools, memory, gate, hitl)
        self.healer = healer
        self.improver = improver
    
    def run(self, task: str) -> dict:
        # Get recommendation from learning
        recommendation = self.improver.get_recommendation(task)
        
        context = self.gather_context(task)
        plan = self.create_plan(task, context, recommendation)
        
        for cycle in range(plan.max_cycles):
            decision = self.reason(plan, context)
            
            gate_result = self.gate.evaluate(decision)
            if not gate_result.allowed:
                continue
            
            result = self.act(decision)
            observation = self.observe(result)
            
            if observation.status == "success":
                break
            
            # Self-healing
            if observation.error:
                heal_result = self.healer.handle_error(observation.error, context)
                if heal_result.healed:
                    continue
            
            # Retry vs Replan
            if observation.retryable:
                continue
            else:
                plan = self.replan(plan, observation)
        
        # Learn from this task
        self.improver.record_task(task, result, self.get_metrics())
        
        self.store(task, plan, result)
        return result
```

---

## Real-World Examples

### Coding Agent
```python
# Task: Fix the failing test
agent.run("Fix the failing test in test_auth.py")
# Loop: read test → read source → diagnose → fix → run tests → commit
```

### Research Agent
```python
# Task: Summarize papers on RLHF
agent.run("Summarize the latest 5 papers on RLHF")
# Loop: search papers → read abstracts → synthesize → write report
```

### Customer Support Agent
```python
# Task: Handle login issue
agent.run("Customer reports 2FA login issue")
# Loop: check account → diagnose → provide solution → follow up
```

### Data Pipeline Agent
```python
# Task: Process daily sales data
agent.run("Process today's sales data from CSV to database")
# Loop: read CSV → validate schema → transform → load → verify
```

### Security Agent
```python
# Task: Review PR for vulnerabilities
agent.run("Review PR #123 for security issues")
# Loop: read diff → scan patterns → flag issues → generate report
```

---

## Common Pitfalls

1. **No observation** — calling tools and not reading results
2. **No memory** — re-learning same lessons every cycle
3. **No planning** — diving straight into execution on complex tasks
4. **No error handling** — assuming everything will succeed
5. **Too much context** — diluting attention with irrelevant information
6. **Too little context** — acting on assumptions instead of facts

---

## When to use each step

| Task type | Prompt | Context | Plan | Reason | Act | Observe | Memory |
|---|---|---|---|---|---|---|---|
| Simple Q&A | Essential | Minimal | Skip | Core | Skip | Skip | Optional |
| Code generation | Essential | Codebase | Optional | Core | Write file | Run tests | Learn |
| Multi-step task | Essential | Full | Essential | Core | Multiple | After each | Critical |
| Long-running | Essential | Context+Memory | Essential | Core | Continuous | Continuous | Critical |
| Multi-agent | Essential | Shared | Delegated | Per-agent | Parallel | Coordinated | Shared |

---

## Advanced Patterns

### Prompt Engineering for Agents

**System prompt structure:**
```
1. Identity — who the agent is
2. Constraints — what it can/cannot do
3. Tools — available actions
4. Examples — few-shot demonstrations
5. Output format — expected response structure
```

**Common prompt patterns:**

| Pattern | When to use | Example |
|---|---|---|
| **Role-playing** | Domain-specific tasks | "You are a senior security engineer..." |
| **Chain-of-thought** | Complex reasoning | "Think step by step..." |
| **Reflection** | Self-correction | "Review your answer before finalizing..." |
| **Tool selection** | Multi-tool scenarios | "Choose the best tool for this task..." |

### Context Management Strategies

**Context window optimization:**
1. **Prioritize recent context** — recent turns are more relevant
2. **Summarize old context** — compress history into summaries
3. **Extract key facts** — pull out only relevant information
4. **Use RAG** — retrieve external knowledge on demand
5. **Cache frequently accessed data** — avoid re-fetching

**Context poisoning detection:**
- Validate all retrieved content
- Check for instruction-like patterns in documents
- Verify source trustworthiness
- Monitor for sudden context changes

### Planning Best Practices

**When to plan:**
- Task has 3+ steps
- Requires tool calls in sequence
- Involves multiple files
- Has failure modes needing contingencies
- User expects structured output

**When to skip planning:**
- Single tool call
- Direct lookup
- Trivial transformation
- Time-sensitive response needed

**Plan validation:**
- Verify all dependencies are met
- Check resource availability
- Validate step ordering
- Confirm success criteria

### Reasoning Optimization

**Reduce reasoning errors:**
1. **Ground in context** — always reference source material
2. **Consider alternatives** — don't commit to first idea
3. **Assess confidence** — know when you're uncertain
4. **Seek clarification** — ask when ambiguous
5. **Validate assumptions** — check prerequisites

**Common reasoning traps:**
- **Anchoring** — over-relying on first piece of information
- **Confirmation bias** — seeking evidence that supports existing belief
- **Overconfidence** — being certain when uncertain
- **Sunk cost** — continuing because of past investment

### Action Safety

**Pre-action checklist:**
- Is this action within scope?
- Does it have side effects?
- Can it be undone?
- Does it require approval?
- Are there dependencies?

**Post-action verification:**
- Did it produce expected output?
- Were side effects contained?
- Is the system in a valid state?
- Should this be logged?

### Observation Quality

**Good observations include:**
- Exact return values (not summaries)
- Error messages (full text)
- Timing information
- Resource usage
- Side effects detected

**Bad observations:**
- "It worked" (no details)
- "Error occurred" (no message)
- "Took some time" (no metrics)

### Memory Management

**What to remember:**
- Successful approaches for similar tasks
- User preferences and corrections
- System quirks and workarounds
- Cost patterns and optimizations
- Failure patterns and fixes

**What to forget:**
- Stale information (> 30 days)
- Low-relevance data
- Superseded knowledge
- Sensitive information

**Memory consolidation schedule:**
- After every 10 tasks — merge related memories
- Weekly — prune old memories
- Monthly — rebuild memory index

---

## Troubleshooting Guide

### Problem: Agent loops indefinitely

**Diagnosis:**
- Check if goal check is implemented
- Verify termination conditions
- Look for infinite retry loops

**Fix:**
```python
# Add cycle limit
for cycle in range(max_cycles):
    # ... agent logic
    pass

# Add goal check
if goal_met(state):
    break
```

### Problem: Agent uses wrong tools

**Diagnosis:**
- Check tool definitions in prompt
- Verify tool schemas are correct
- Look for tool selection reasoning

**Fix:**
```python
# Improve tool selection reasoning
prompt = f"""
Available tools: {tool_schemas}
Task: {task}

Which tool is best for this task and why?
"""
```

### Problem: Agent ignores context

**Diagnosis:**
- Check context window size
- Verify relevant context is included
- Look for context poisoning

**Fix:**
```python
# Improve context retrieval
context = retrieve_relevant(task, all_documents, top_k=5)
```

### Problem: Agent forgets previous decisions

**Diagnosis:**
- Check if memory is implemented
- Verify memory is being populated
- Look for memory retrieval issues

**Fix:**
```python
# Ensure memory is stored and retrieved
memory.store(decision)
relevant_memories = memory.retrieve(task)
```

### Problem: High token usage

**Diagnosis:**
- Check context window utilization
- Look for redundant information
- Verify caching is working

**Fix:**
```python
# Compress context
context = compress_context(full_context, max_tokens=4000)
```

---

## Performance Optimization

### Token Efficiency

| Strategy | Savings | Implementation |
|---|---|---|
| Context compression | 30-50% | Summarize old context |
| Caching | 20-40% | Cache tool results |
| Model routing | 40-60% | Use cheap model for simple tasks |
| Deduplication | 10-20% | Remove redundant information |

### Latency Optimization

| Strategy | Impact | Implementation |
|---|---|---|
| Parallel execution | 50-70% faster | Run independent tasks simultaneously |
| Caching | 80-90% faster | Cache frequent queries |
| Pre-computation | 30-50% faster | Compute common results ahead |
| Lazy loading | 20-40% faster | Load data only when needed |

### Reliability Patterns

| Pattern | Purpose | Implementation |
|---|---|---|
| Circuit breaker | Prevent cascade failure | Stop calling failing service |
| Retry with backoff | Handle transient errors | Exponential backoff with jitter |
| Fallback | Provide alternative path | Use backup service/method |
| Timeout | Prevent hanging | Set max execution time |
| Checkpoint | Enable recovery | Save state periodically |

---

## Security Considerations

### Threat Model

| Threat | Vector | Mitigation |
|---|---|---|
| Prompt injection | Malicious user input | Input sanitization, instruction hierarchy |
| Data exfiltration | Agent sends data externally | Network allowlist, output scanning |
| Privilege escalation | Agent gains unauthorized access | Permission gates, least privilege |
| Memory poisoning | Corrupted memories | Memory validation, signing |
| Supply chain | Compromised dependencies | Dependency scanning, version pinning |

### Security Checklist

- [ ] Input validation on all user-provided data
- [ ] Output scanning for sensitive information
- [ ] Network restrictions for external calls
- [ ] File system permissions properly scoped
- [ ] Memory encrypted at rest
- [ ] Audit logging enabled
- [ ] Rate limiting enforced
- [ ] Error messages don't leak internals

---

## Testing Strategies

### Unit Testing

```python
def test_prompt_construction():
    agent = BasicAgent(llm, tools, memory)
    prompt = agent.build_prompt("Fix the bug")
    assert "Fix the bug" in prompt
    assert len(prompt) > 0

def test_context_gathering():
    agent = BasicAgent(llm, tools, memory)
    context = agent.gather_context("Fix the bug")
    assert "task" in context
    assert len(context) > 0
```

### Integration Testing

```python
def test_full_loop():
    agent = BasicAgent(llm, tools, memory)
    result = agent.run("Read main.py")
    assert result["success"] == True
    assert "content" in result
```

### Chaos Testing

```python
def test_error_recovery():
    agent = BasicAgent(llm, tools, memory)
    
    # Inject failure
    tools.fail_next_call()
    
    # Agent should handle gracefully
    result = agent.run("Read file")
    assert result["handled_error"] == True
```

---

## Monitoring Metrics

| Metric | Description | Target |
|---|---|---|
| Task completion rate | % tasks finished | > 90% |
| Average cycles | Loops per task | < 8 for simple |
| Token usage | Tokens per task | Within budget |
| Error rate | Failed actions / total | < 5% |
| Response time | Time to complete | < 30s simple |
| Cost per task | Dollar cost | < $0.50 simple |

---

## Deployment Checklist

- [ ] Prompt tested with edge cases
- [ ] Context retrieval verified
- [ ] Planning logic validated
- [ ] Reasoning quality checked
- [ ] Actions scoped correctly
- [ ] Observations comprehensive
- [ ] Memory persistence tested
- [ ] Error handling verified
- [ ] Monitoring configured
- [ ] Security reviewed

---

## See also

- **v2 guide** — adds permission gates, HITL, retry vs. replan, goal checks
- **v3 guide** — adds self-healing, adaptive planning, cost optimization
- **Self-* capabilities** — 13 autonomous capabilities deep dives
- **Shared resources** — memory, planning, safety, evaluation deep dives
