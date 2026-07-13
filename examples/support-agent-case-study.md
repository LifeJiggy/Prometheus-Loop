# Customer Support Agent Case Study

## Scenario

A customer support agent that handles inquiries, troubleshoots issues, and escalates when needed.

## Loop Application

### v1 (Concept)

```
Task: "Customer reports login issue with 2FA"

1. Prompt: "Help customer with 2FA login issue"
2. Context: Read customer history, check 2FA status, read knowledge base
3. Plan: [greet_customer, identify_issue, troubleshoot, resolve_or_escalate]
4. Reason: "Customer lost 2FA device, needs recovery code or reset"
5. Act: Provide recovery steps
6. Observe: Customer confirms issue resolved
7. Store: "2FA recovery procedure works for lost device"
```

### v2 (Production)

Same as v1, plus:
- **Permission Gate**: Validates agent can access customer data
- **HITL**: Escalates billing disputes to human agent
- **Retry**: If knowledge base search fails, retry with different query
- **Goal Check**: Stop when customer confirms resolution or max 5 cycles
- **Security**: Validates customer identity before account changes

### v3 (Autonomous)

Same as v2, plus:
- **Self-Healing**: Falls back to generic troubleshooting if KB is down
- **Adaptive Planning**: Learns "check 2FA status first" pattern
- **Cost Optimization**: Uses gpt-4o-mini for FAQs, gpt-4o for complex issues
- **Cross-Session Memory**: Remembers "customer had same issue last month"
- **Verification**: Confirms resolution before closing ticket

## Code Snippet

```python
class SupportAgent:
    def handle_inquiry(self, customer_id: str, message: str) -> dict:
        """Handle a customer support inquiry."""
        
        # Get customer context
        customer = self.tools.get_customer(customer_id)
        history = self.tools.get_history(customer_id)
        
        # Identify issue
        issue = self.llm.call(f"""
            Customer message: {message}
            Customer history: {history}
            
            Classify this issue:
            - type (login, billing, technical, general)
            - urgency (low, medium, high, critical)
            - requires_human (true/false)
        """)
        
        # Check if needs human
        if issue["requires_human"]:
            return self.escalate_to_human(customer, issue)
        
        # Troubleshoot
        solution = self.llm.call(f"""
            Issue: {issue}
            Customer: {customer}
            Knowledge base: {self.tools.search_kb(issue["type"])}
            
            Provide a solution.
        """)
        
        # Send response
        self.tools.send_message(customer_id, solution)
        
        # Follow up
        return {
            "status": "sent",
            "issue_type": issue["type"],
            "solution": solution
        }
    
    def escalate_to_human(self, customer: dict, issue: dict) -> dict:
        """Escalate to human agent."""
        ticket = self.tools.create_ticket({
            "customer": customer,
            "issue": issue,
            "priority": issue["urgency"],
            "reason": "Requires human intervention"
        })
        
        return {
            "status": "escalated",
            "ticket_id": ticket["id"],
            "message": "I've escalated your case to a human agent. They'll be with you shortly."
        }
```

## Metrics

| Metric | Without Loop | With Loop |
|---|---|---|
| Resolution rate | 50% | 85% |
| Avg cycles | 1 | 2.8 |
| Avg tokens | 1000 | 4000 |
| Avg cost | $0.02 | $0.10 |
| Customer satisfaction | 3.2/5 | 4.1/5 |
| Escalation rate | 50% | 15% |

## Lessons Learned

1. **Check history first** — customer may have had this issue before
2. **Classify before troubleshooting** — different issues need different approaches
3. **Escalate early** — don't waste time on issues beyond your capability
4. **Confirm resolution** — always ask "did that solve your issue?"
