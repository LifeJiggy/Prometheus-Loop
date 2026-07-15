# Knowledge Check Quiz

## Test Your Understanding

### Question 1: The Core Loop
What are the 7 steps of the agentic loop?

<details>
<summary>Answer</summary>

1. Prompt — The instruction that kicks off a cycle
2. Context — Everything pulled in before reasoning
3. Plan — Break the goal into ordered sub-tasks
4. Reason — Chain-of-thought, deciding what to do next
5. Act — Call an API, run code, write a file
6. Observe — Capture what happened
7. Store/Remember — Persist data and learn

</details>

### Question 2: Memory vs Storage
What's the difference between memory and storage?

<details>
<summary>Answer</summary>

- **Storage**: Raw persistence (logs, artifacts, whatever hits disk)
- **Memory**: The curated subset that gets pulled back into Context next cycle

Not everything stored is worth remembering. Memory is the filtered, relevant subset.

</details>

### Question 3: Self-Healing
When should an agent use self-healing vs. simple retry?

<details>
<summary>Answer</summary>

- **Simple retry**: Same action, same parameters, just try again
- **Self-healing**: Diagnose the error, apply a different fix, verify recovery

Use self-healing when the error is diagnosable and has a known fix pattern.

</details>

### Question 4: Permission Gate
What does the permission gate check?

<details>
<summary>Answer</summary>

The permission gate checks:
- Scope: Is this action within the agent's authority?
- Policy: Does this action violate any rules?
- Blast radius: How much does this action affect?
- Reversibility: Can this be undone?

</details>

### Question 5: Circuit Breaker
What is a circuit breaker and when should it be used?

<details>
<summary>Answer</summary>

A circuit breaker prevents repeated calls to a failing service. It has three states:
- **Closed**: Normal operation
- **Open**: Fail fast, don't retry
- **Half-Open**: Limited retries to test recovery

Use it when a service is failing to prevent cascade failures.

</details>

### Question 6: Context Window
Why is context management important?

<details>
<summary>Answer</summary>

Context windows are finite. Too much context:
- Dilutes attention on important information
- Increases token costs
- Can push out critical earlier turns

The art is retrieval and compression: pull in exactly what's relevant.

</details>

### Question 7: Adaptive Planning
What's the difference between static and adaptive planning?

<details>
<summary>Answer</summary>

- **Static plan**: Created once, followed exactly
- **Adaptive plan**: Created initially, then modified based on observations

Adaptive planning handles unexpected situations and new information.

</details>

### Question 8: Multi-Agent Coordination
When should you use multi-agent orchestration?

<details>
<summary>Answer</summary>

Use multi-agent when:
- Tasks require different specializations
- Work can be parallelized
- The problem exceeds a single agent's capabilities
- Different agents have different tools or knowledge

</details>

### Question 9: Cost Optimization
How can you reduce LLM costs?

<details>
<summary>Answer</summary>

Strategies include:
- Route simple tasks to cheaper models
- Cache frequent queries
- Compress context
- Batch operations
- Use semantic caching

</details>

### Question 10: Ethics
What are the key ethical considerations for agents?

<details>
<summary>Answer</summary>

Key considerations:
- **Transparency**: Users know they're interacting with an agent
- **Accountability**: Someone is responsible for agent actions
- **Fairness**: Agent doesn't discriminate
- **Privacy**: Agent doesn't leak personal data
- **Safety**: Agent doesn't cause harm

</details>

## Scoring

- 9-10 correct: Expert level
- 7-8 correct: Advanced
- 5-6 correct: Intermediate
- Below 5: Review the core guide
