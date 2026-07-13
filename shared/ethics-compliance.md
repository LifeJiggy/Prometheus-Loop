# Ethics & Compliance

## Ethical Principles

| Principle | What it means | How to enforce |
|---|---|---|
| **Transparency** | Users know when they're interacting with an agent | Label agent-generated content |
| **Accountability** | Someone is responsible for agent actions | Human-in-the-loop for high-stakes decisions |
| **Fairness** | Agent doesn't discriminate | Bias testing across demographics |
| **Privacy** | Agent doesn't leak personal data | Data minimization, access controls |
| **Safety** | Agent doesn't cause harm | Permission gates, verification, HITL |

## Bias Testing

```python
def test_bias(agent, tasks):
    """Test agent for bias across demographics."""
    
    results = {}
    
    # Test with different user demographics
    demographics = ["male", "female", "non-binary", "unknown"]
    
    for demo in demographics:
        demo_tasks = [inject_demographic(task, demo) for task in tasks]
        demo_results = [agent.run(task) for task in demo_tasks]
        results[demo] = analyze_results(demo_results)
    
    # Test with different phrasings
    phrasings = ["formal", "informal", "technical", "non-technical"]
    
    for phrasing in phrasings:
        phrased_tasks = [rephrase(task, phrasing) for task in tasks]
        phrased_results = [agent.run(task) for task in phrased_tasks]
        results[phrasing] = analyze_results(phrased_results)
    
    # Check for disparities
    disparities = find_disparities(results)
    
    return {
        "results": results,
        "disparities": disparities,
        "passed": len(disparities) == 0
    }
```

## Compliance Checklists

### GDPR

- [ ] Right to explanation: Decision traces for every user-facing action
- [ ] Right to erasure: Delete user data + memories on request
- [ ] Data minimization: Only collect data needed for the task
- [ ] Consent: User consents to agent processing their data
- [ ] Data portability: User can export their data
- [ ] Breach notification: Notify authorities within 72 hours of breach

### SOC 2

- [ ] Audit trail: Complete logging of all agent actions
- [ ] Access controls: Per-user memory isolation
- [ ] Encryption: Data encrypted at rest and in transit
- [ ] Monitoring: Real-time monitoring of agent behavior
- [ ] Incident response: Documented procedure for security incidents
- [ ] Risk assessment: Regular risk assessments of agent system

### HIPAA

- [ ] Access controls: Only authorized users access PHI
- [ ] Audit logs: Log every access to PHI with user and purpose
- [ ] Encryption: PHI encrypted at rest and in transit
- [ ] Business associate agreements: BAAs with all vendors
- [ ] Minimum necessary: Agent only accesses PHI needed for task
- [ ] Breach notification: Notify affected individuals within 60 days

### PCI DSS

- [ ] No card data in context: Never include card numbers in LLM context
- [ ] Encrypted storage: Card data encrypted if stored
- [ ] Access logging: Log all access to cardholder data
- [ ] Network segmentation: Agent runs in isolated network segment
- [ ] Regular testing: Penetration testing of agent system

### EU AI Act

- [ ] Risk assessment: Document agent capabilities and limitations
- [ ] Human oversight: HITL for high-risk applications
- [ ] Transparency: Users know they're interacting with an AI
- [ ] Accuracy: Agent meets accuracy requirements for use case
- [ ] Robustness: Agent handles edge cases gracefully
- [ ] Documentation: Complete technical documentation

## Impact Assessment Template

```markdown
# Agent Impact Assessment

## Agent Details
- Name: [Agent name]
- Purpose: [What the agent does]
- Data accessed: [What data the agent accesses]
- Actions taken: [What actions the agent can take]

## Risk Analysis
- Who is affected by the agent's decisions? [List stakeholders]
- What happens if the agent is wrong? [Failure scenarios]
- What are the failure modes? [List failure modes]
- What human oversight is in place? [HITL controls]

## Ethical Considerations
- Does the agent make decisions about people? [Yes/No]
- Does the agent access personal data? [Yes/No]
- Does the agent have financial impact? [Yes/No]
- Could the agent cause physical harm? [Yes/No]

## Mitigations
- [List mitigation measures]

## Rollback Plan
- How to disable the agent: [Procedure]
- How to undo agent actions: [Procedure]
- How to notify affected parties: [Procedure]

## Approval
- Approved by: [Name]
- Date: [Date]
- Next review: [Date]
```

## Accountability Framework

| Role | Responsibility |
|---|---|
| **Agent developer** | Implements safety controls, writes tests |
| **Agent operator** | Monitors agent, responds to incidents |
| **Data owner** | Approves data access, manages retention |
| **Compliance officer** | Ensures regulatory compliance |
| **Human reviewer** | Reviews high-stakes agent decisions |
| **Incident responder** | Handles security incidents |
