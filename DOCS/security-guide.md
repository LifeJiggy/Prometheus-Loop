# Security Guide

## Threat Model

### Attack Vectors

| Vector | Description | Severity | Mitigation |
|---|---|---|---|
| **Prompt Injection** | Malicious input hijacks agent | Critical | Input sanitization, instruction hierarchy |
| **Data Exfiltration** | Agent leaks sensitive data | Critical | Network allowlist, output scanning |
| **Privilege Escalation** | Agent gains unauthorized access | Critical | Permission gates, least privilege |
| **Memory Poisoning** | Corrupted memories affect decisions | High | Memory validation, signing |
| **Supply Chain** | Compromised dependencies | High | Dependency scanning, version pinning |
| **Denial of Service** | Resource exhaustion | Medium | Rate limiting, budget enforcement |

## Security Best Practices

### 1. Input Validation

```python
def validate_input(user_input: str) -> str:
    """Validate and sanitize user input."""
    
    # Remove potentially dangerous patterns
    dangerous_patterns = [
        "ignore previous instructions",
        "you are now",
        "disregard all rules",
        "system prompt:"
    ]
    
    sanitized = user_input
    for pattern in dangerous_patterns:
        if pattern.lower() in sanitized.lower():
            sanitized = sanitized.replace(pattern, "[FILTERED]")
    
    return sanitized
```

### 2. Output Validation

```python
def validate_output(output: str) -> dict:
    """Validate agent output for safety."""
    
    issues = []
    
    # Check for secrets
    secret_patterns = [
        r"sk-[a-zA-Z0-9]{48}",  # OpenAI key
        r"ghp_[a-zA-Z0-9]{36}",  # GitHub token
        r"AKIA[0-9A-Z]{16}",     # AWS key
    ]
    
    for pattern in secret_patterns:
        if re.search(pattern, output):
            issues.append(f"Contains secret: {pattern}")
    
    # Check for PII
    pii_patterns = [
        r"\b\d{3}-\d{2}-\d{4}\b",  # SSN
        r"\b\d{16}\b",              # Credit card
    ]
    
    for pattern in pii_patterns:
        if re.search(pattern, output):
            issues.append(f"Contains PII: {pattern}")
    
    return {"valid": len(issues) == 0, "issues": issues}
```

### 3. Network Security

```python
ALLOWED_DOMAINS = [
    "api.openai.com",
    "api.anthropic.com",
    "*.github.com",
    "*.amazonaws.com"
]

def validate_url(url: str) -> bool:
    """Validate URL against allowlist."""
    
    from urllib.parse import urlparse
    
    parsed = urlparse(url)
    hostname = parsed.hostname
    
    return any(
        hostname.endswith(domain) or hostname == domain
        for domain in ALLOWED_DOMAINS
    )
```

## Compliance Checklists

### GDPR
- [ ] Data minimization
- [ ] Right to explanation
- [ ] Right to erasure
- [ ] Consent management
- [ ] Data portability

### SOC 2
- [ ] Audit trail
- [ ] Access controls
- [ ] Encryption
- [ ] Monitoring
- [ ] Incident response

### HIPAA
- [ ] Access controls
- [ ] Audit logging
- [ ] Encryption
- [ ] BAAs with vendors
- [ ] Breach notification

## Security Testing

```bash
# Run security scan
python -m safety check

# Check for vulnerabilities
pip audit

# Run SAST
bandit -r src/

# Run dependency check
safety check --full-report
```
