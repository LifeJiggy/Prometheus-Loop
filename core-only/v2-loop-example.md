# v2 Loop Example: Code Review Assistant

A production-grade agent that reviews code for security, performance, and quality — demonstrating the safety layers added in v2.

## Scenario

User asks: "Review this pull request for security issues"

## Loop walkthrough

```mermaid
flowchart TD
    A["Prompt: Review PR for security"] --> B["Context: Read PR diff + security rules"]
    B --> C["Plan: Check OWASP, scan dependencies, review auth"]
    C --> D["Reason: Analyze each file for vulnerabilities"]
    D --> E{"Permission Gate"}
    E -->|allowed| F["Act: Flag issues in code"]
    E -->|high-stakes| HITL["Human approval"]
    HITL -->|approved| F
    F --> G["Observe: Check if analysis is complete"]
    G -->|incomplete| RETRY["Retry with more context"]
    RETRY --> F
    G -->|complete| H{"Done?"}
    H -->|more files| B
    H -->|all reviewed| I["Store: Save review results"]
```

## Implementation

```python
class CodeReviewAgent:
    """Code review agent using v2 loop with safety layers."""
    
    def __init__(self, llm=None):
        self.llm = llm
        self.security_rules = self.load_security_rules()
        self.review_history = []
    
    def review_pull_request(self, pr: dict) -> dict:
        """Review a pull request with safety checks."""
        
        # Step 1: Prompt (already received)
        
        # Step 2: Context (read PR diff + security rules)
        context = self.gather_context(pr)
        
        # Step 3: Plan (check OWASP, scan dependencies, review auth)
        plan = self.create_review_plan(context)
        
        # Step 4: Reason (analyze each file)
        findings = []
        for file in context["files"]:
            file_findings = self.analyze_file(file, context)
            findings.extend(file_findings)
        
        # Step 5: Permission Gate (check if review is safe)
        gate_result = self.permission_gate({
            "action": "review_code",
            "files": len(context["files"]),
            "findings": len(findings)
        })
        
        if not gate_result["allowed"]:
            return {"success": False, "reason": gate_result["reason"]}
        
        # Step 6: Act (flag issues)
        flagged = self.flag_issues(findings)
        
        # Step 7: Observe (check if analysis is complete)
        if self.validate_review(flagged, context):
            # Step 8: Done - store results
            self.store_review(flagged)
            
            return {
                "success": True,
                "findings": flagged,
                "summary": self.generate_summary(flagged)
            }
        else:
            # Retry with more context
            return self.review_with_more_context(pr, flagged)
    
    def gather_context(self, pr: dict) -> dict:
        """Gather context from PR."""
        
        return {
            "pr_id": pr.get("id"),
            "files": pr.get("files", []),
            "description": pr.get("description", ""),
            "security_rules": self.security_rules,
            "author": pr.get("author", "unknown")
        }
    
    def create_review_plan(self, context: dict) -> dict:
        """Create review plan."""
        
        return {
            "steps": [
                {"name": "owasp_check", "description": "Check OWASP Top 10"},
                {"name": "dependency_scan", "description": "Scan for vulnerable dependencies"},
                {"name": "auth_review", "description": "Review authentication logic"},
                {"name": "input_validation", "description": "Check input validation"}
            ],
            "files_to_review": len(context["files"]),
            "estimated_time": len(context["files"]) * 2  # minutes
        }
    
    def analyze_file(self, file: dict, context: dict) -> list:
        """Analyze a file for security issues."""
        
        findings = []
        content = file.get("content", "")
        
        # Check for SQL injection
        if self.check_sql_injection(content):
            findings.append({
                "file": file["path"],
                "line": self.find_line(content, "execute"),
                "severity": "high",
                "type": "sql_injection",
                "description": "Potential SQL injection vulnerability",
                "fix": "Use parameterized queries"
            })
        
        # Check for XSS
        if self.check_xss(content):
            findings.append({
                "file": file["path"],
                "line": self.find_line(content, "innerHTML"),
                "severity": "medium",
                "type": "xss",
                "description": "Potential XSS vulnerability",
                "fix": "Sanitize user input before rendering"
            })
        
        # Check for hardcoded secrets
        if self.check_secrets(content):
            findings.append({
                "file": file["path"],
                "line": self.find_line(content, "password"),
                "severity": "critical",
                "type": "hardcoded_secret",
                "description": "Hardcoded secret detected",
                "fix": "Move to environment variables"
            })
        
        return findings
    
    def check_sql_injection(self, content: str) -> bool:
        """Check for SQL injection vulnerabilities."""
        
        dangerous_patterns = [
            "execute(",
            "query(",
            "cursor.execute",
            "raw SQL",
            "string concatenation in SQL"
        ]
        
        return any(pattern in content.lower() for pattern in dangerous_patterns)
    
    def check_xss(self, content: str) -> bool:
        """Check for XSS vulnerabilities."""
        
        dangerous_patterns = [
            "innerHTML",
            "document.write",
            "eval(",
            "dangerouslySetInnerHTML"
        ]
        
        return any(pattern in content for pattern in dangerous_patterns)
    
    def check_secrets(self, content: str) -> bool:
        """Check for hardcoded secrets."""
        
        secret_patterns = [
            "password =",
            "api_key =",
            "secret =",
            "token =",
            "AWS_SECRET"
        ]
        
        return any(pattern in content for pattern in secret_patterns)
    
    def find_line(self, content: str, pattern: str) -> int:
        """Find line number of pattern."""
        
        lines = content.split('\n')
        for i, line in enumerate(lines, 1):
            if pattern in line:
                return i
        return 0
    
    def permission_gate(self, action: dict) -> dict:
        """Check if action is allowed."""
        
        # Check if review is within scope
        if action.get("files", 0) > 100:
            return {
                "allowed": False,
                "reason": "Too many files for automated review"
            }
        
        # Check if findings need escalation
        critical_findings = sum(1 for f in action.get("findings", []) if f.get("severity") == "critical")
        if critical_findings > 5:
            return {
                "allowed": False,
                "reason": "Too many critical findings - escalate to human"
            }
        
        return {"allowed": True}
    
    def flag_issues(self, findings: list) -> list:
        """Flag issues with recommended fixes."""
        
        flagged = []
        
        for finding in findings:
            flagged.append({
                **finding,
                "flagged": True,
                "recommended_action": self.get_recommended_action(finding),
                "confidence": self.calculate_confidence(finding)
            })
        
        return flagged
    
    def get_recommended_action(self, finding: dict) -> str:
        """Get recommended action for a finding."""
        
        actions = {
            "sql_injection": "Use parameterized queries or ORM",
            "xss": "Sanitize input and use Content Security Policy",
            "hardcoded_secret": "Move to environment variables or secret manager",
            "insecure_random": "Use cryptographically secure random functions",
            "path_traversal": "Validate and sanitize file paths"
        }
        
        return actions.get(finding.get("type"), "Review manually")
    
    def calculate_confidence(self, finding: dict) -> float:
        """Calculate confidence in finding."""
        
        # Simple confidence calculation
        severity_weights = {
            "critical": 0.95,
            "high": 0.85,
            "medium": 0.75,
            "low": 0.65
        }
        
        return severity_weights.get(finding.get("severity", "low"), 0.5)
    
    def validate_review(self, findings: list, context: dict) -> bool:
        """Validate review is complete."""
        
        # Check if all files were reviewed
        reviewed_files = set(f["file"] for f in findings)
        all_files = set(f["path"] for f in context["files"])
        
        # Allow if at least 80% of files reviewed
        return len(reviewed_files) / len(all_files) >= 0.8 if all_files else True
    
    def generate_summary(self, findings: list) -> dict:
        """Generate review summary."""
        
        summary = {
            "total_findings": len(findings),
            "by_severity": {},
            "by_type": {},
            "recommendations": []
        }
        
        for finding in findings:
            severity = finding.get("severity", "low")
            finding_type = finding.get("type", "unknown")
            
            summary["by_severity"][severity] = summary["by_severity"].get(severity, 0) + 1
            summary["by_type"][finding_type] = summary["by_type"].get(finding_type, 0) + 1
            
            summary["recommendations"].append({
                "file": finding["file"],
                "line": finding.get("line"),
                "action": finding.get("recommended_action")
            })
        
        return summary
    
    def store_review(self, findings: list):
        """Store review results."""
        
        self.review_history.append({
            "findings": findings,
            "timestamp": datetime.now().isoformat()
        })
    
    def load_security_rules(self) -> dict:
        """Load security rules."""
        
        return {
            "owasp_top_10": [
                "A01:2021 - Broken Access Control",
                "A02:2021 - Cryptographic Failures",
                "A03:2021 - Injection",
                "A04:2021 - Insecure Design",
                "A05:2021 - Security Misconfiguration",
                "A06:2021 - Vulnerable Components",
                "A07:2021 - Authentication Failures",
                "A08:2021 - Data Integrity Failures",
                "A09:2021 - Security Logging Failures",
                "A10:2021 - Server-Side Request Forgery"
            ]
        }
```

## Example usage

```python
agent = CodeReviewAgent()

# Simulate a PR with security issues
pr = {
    "id": "PR-123",
    "description": "Add user authentication",
    "author": "developer1",
    "files": [
        {
            "path": "src/auth.py",
            "content": """
import sqlite3

def login(username, password):
    query = f"SELECT * FROM users WHERE username='{username}' AND password='{password}'"
    cursor.execute(query)
    return cursor.fetchone()
"""
        },
        {
            "path": "src/config.py",
            "content": """
DATABASE_URL = "postgresql://user:password@localhost/mydb"
API_KEY = "sk-1234567890abcdef"
"""
        }
    ]
}

# Review the PR
result = agent.review_pull_request(pr)

print(f"Found {result['summary']['total_findings']} issues:")
for finding in result['findings']:
    print(f"  [{finding['severity'].upper()}] {finding['file']}:{finding.get('line', '?')} - {finding['description']}")
```

## What this demonstrates

| v2 Step | What happens |
|---|---|
| **Prompt** | User asks to review PR for security |
| **Context** | Agent reads PR diff and loads security rules |
| **Plan** | Agent creates review plan (OWASP, deps, auth) |
| **Reason** | Agent analyzes each file for vulnerabilities |
| **Permission Gate** | Agent checks if review is within scope |
| **HITL** | Escalates if too many critical findings |
| **Act** | Agent flags issues with recommended fixes |
| **Observe** | Agent validates review is complete (80%+ files) |
| **Retry** | Retries with more context if review incomplete |
| **Done** | Stores review results and generates summary |

## Key takeaway

v2 adds the safety layer between reasoning and action. The permission gate prevents the agent from doing something dangerous, and the HITL checkpoint catches high-stakes decisions. This is what makes an agent production-ready.
