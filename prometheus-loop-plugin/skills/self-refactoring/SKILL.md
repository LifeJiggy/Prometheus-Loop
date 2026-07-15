---
name: self-refactoring
description: Improve code structure, reduce complexity, and maintain quality
---

# Self-Refactoring

The agent's ability to improve its own code structure, reduce complexity, eliminate duplication, and maintain code quality over time — without changing external behavior.

## Quick Start

When the user asks about code quality:

1. **Analyze** — measure code metrics
2. **Detect** — find code smells
3. **Suggest** — recommend refactorings
4. **Apply** — make changes
5. **Verify** — ensure tests pass

---

## Architecture

```
Code → Analyze Metrics → Detect Smells → Generate Suggestions → Apply Refactoring
                                                                        ↓
                                                              Validate Code → Run Tests
                                                                        ↓
                                                              Update Metrics → Record History
```

---

## Code Analyzer

```python
class CodeAnalyzer:
    """Analyzes code for quality issues."""
    
    def __init__(self):
        self.metrics_history = []
    
    def analyze(self, code: str, file_path: str = None) -> dict:
        """Analyze code and return metrics."""
        
        metrics = {
            "file": file_path,
            "lines": self.count_lines(code),
            "functions": self.count_functions(code),
            "classes": self.count_classes(code),
            "complexity": self.calculate_complexity(code),
            "duplications": self.detect_duplications(code),
            "code_smells": self.detect_code_smells(code),
            "quality_score": 0
        }
        
        metrics["quality_score"] = self.calculate_quality_score(metrics)
        
        self.metrics_history.append(metrics)
        
        return metrics
    
    def count_lines(self, code: str) -> dict:
        """Count different types of lines."""
        
        lines = code.split('\n')
        total = len(lines)
        blank = sum(1 for l in lines if l.strip() == '')
        comment = sum(1 for l in lines if l.strip().startswith(('#', '//', '/*')))
        code = total - blank - comment
        
        return {
            "total": total,
            "code": code,
            "blank": blank,
            "comment": comment,
            "comment_ratio": comment / total if total > 0 else 0
        }
    
    def count_functions(self, code: str) -> list:
        """Count and analyze functions."""
        
        import re
        
        functions = []
        
        for match in re.finditer(r'def\s+(\w+)\s*\(', code):
            func_name = match.group(1)
            start_line = code[:match.start()].count('\n') + 1
            
            func_body = self.extract_function_body(code, match.start())
            
            functions.append({
                "name": func_name,
                "line": start_line,
                "lines": func_body.count('\n') + 1,
                "complexity": self.calculate_complexity(func_body)
            })
        
        return functions
    
    def extract_function_body(self, code: str, start: int) -> str:
        """Extract function body from code."""
        
        lines = code[start:].split('\n')
        body = []
        indent_level = None
        
        for line in lines[1:]:
            stripped = line.strip()
            
            if stripped == '':
                body.append(line)
                continue
            
            current_indent = len(line) - len(line.lstrip())
            
            if indent_level is None:
                if current_indent > 0:
                    indent_level = current_indent
                else:
                    break
            
            if current_indent >= indent_level or stripped.startswith(('return', 'pass')):
                body.append(line)
            else:
                break
        
        return '\n'.join(body)
    
    def count_classes(self, code: str) -> list:
        """Count and analyze classes."""
        
        import re
        
        classes = []
        
        for match in re.finditer(r'class\s+(\w+)\s*[:\(]', code):
            class_name = match.group(1)
            start_line = code[:match.start()].count('\n') + 1
            
            classes.append({
                "name": class_name,
                "line": start_line
            })
        
        return classes
    
    def calculate_complexity(self, code: str) -> int:
        """Calculate cyclomatic complexity."""
        
        import re
        
        complexity = 1
        
        patterns = [
            r'\bif\b', r'\belif\b', r'\belse\b',
            r'\bfor\b', r'\bwhile\b',
            r'\bexcept\b', r'\bfinally\b',
            r'\band\b', r'\bor\b'
        ]
        
        for pattern in patterns:
            complexity += len(re.findall(pattern, code))
        
        return complexity
    
    def detect_duplications(self, code: str) -> list:
        """Detect code duplications."""
        
        lines = [l.strip() for l in code.split('\n') if l.strip()]
        
        duplications = []
        seen = {}
        
        for i, line in enumerate(lines):
            if len(line) < 20:
                continue
            
            if line in seen:
                duplications.append({
                    "line": line,
                    "first_occurrence": seen[line],
                    "second_occurrence": i
                })
            else:
                seen[line] = i
        
        return duplications
    
    def detect_code_smells(self, code: str) -> list:
        """Detect code smells."""
        
        smells = []
        
        functions = self.count_functions(code)
        for func in functions:
            if func["lines"] > 50:
                smells.append({
                    "type": "long_function",
                    "name": func["name"],
                    "lines": func["lines"],
                    "severity": "high"
                })
        
        if self.calculate_complexity(code) > 15:
            smells.append({
                "type": "high_complexity",
                "severity": "high"
            })
        
        import re
        for match in re.finditer(r'def\s+\w+\s*\(([^)]+)\)', code):
            params = [p.strip() for p in match.group(1).split(',')]
            if len(params) > 7:
                smells.append({
                    "type": "too_many_parameters",
                    "count": len(params),
                    "severity": "medium"
                })
        
        return smells
    
    def calculate_quality_score(self, metrics: dict) -> float:
        """Calculate overall quality score (0-100)."""
        
        score = 100
        
        complexity = metrics["complexity"]
        if complexity > 10:
            score -= (complexity - 10) * 2
        
        duplications = len(metrics["duplications"])
        score -= duplications * 5
        
        for smell in metrics["code_smells"]:
            if smell["severity"] == "high":
                score -= 15
            elif smell["severity"] == "medium":
                score -= 10
            else:
                score -= 5
        
        if metrics["lines"]["comment_ratio"] < 0.1:
            score -= 10
        
        return max(0, min(100, score))
```

---

## Refactoring Suggestions

```python
class RefactoringSuggester:
    """Suggests refactoring actions."""
    
    def __init__(self, llm=None):
        self.llm = llm
    
    def suggest(self, metrics: dict) -> list:
        """Generate refactoring suggestions."""
        
        suggestions = []
        
        for func in metrics.get("functions", []):
            if func["lines"] > 30:
                suggestions.append({
                    "type": "extract_function",
                    "target": func["name"],
                    "description": f"Function '{func['name']}' is {func['lines']} lines long",
                    "priority": "high" if func["lines"] > 50 else "medium"
                })
        
        if metrics["complexity"] > 15:
            suggestions.append({
                "type": "reduce_complexity",
                "description": f"Code complexity is {metrics['complexity']}",
                "priority": "high"
            })
        
        if len(metrics["duplications"]) > 3:
            suggestions.append({
                "type": "extract_common",
                "description": f"Found {len(metrics['duplications'])} code duplications",
                "priority": "medium"
            })
        
        for smell in metrics.get("code_smells", []):
            suggestions.append({
                "type": f"fix_{smell['type']}",
                "description": f"Code smell: {smell['type']}",
                "priority": smell["severity"]
            })
        
        priority_order = {"high": 0, "medium": 1, "low": 2}
        suggestions.sort(key=lambda s: priority_order.get(s["priority"], 3))
        
        return suggestions
    
    def generate_refactoring(self, code: str, suggestion: dict) -> dict:
        """Generate refactoring code."""
        
        if self.llm:
            return self.generate_with_llm(code, suggestion)
        
        return self.generate_heuristic(code, suggestion)
    
    def generate_with_llm(self, code: str, suggestion: dict) -> dict:
        """Generate refactoring using LLM."""
        
        prompt = f"""
        Refactor this code based on the suggestion:
        
        Original Code:
        {code}
        
        Suggestion: {suggestion['description']}
        
        Return JSON with: refactored_code, changes_made, confidence
        """
        
        try:
            response = self.llm.call(prompt)
            import json
            return json.loads(response)
        except:
            return {"refactored_code": code, "changes_made": [], "confidence": 0}
    
    def generate_heuristic(self, code: str, suggestion: dict) -> dict:
        """Generate refactoring using heuristics."""
        
        changes = []
        
        if suggestion["type"] == "reduce_complexity":
            changes.append("Consider breaking complex logic into smaller functions")
            return {"refactored_code": code, "changes_made": changes, "confidence": 0.4}
        
        elif suggestion["type"] == "extract_common":
            changes.append("Extract duplicated code into shared utility functions")
            return {"refactored_code": code, "changes_made": changes, "confidence": 0.4}
        
        return {"refactored_code": code, "changes_made": [], "confidence": 0.3}
```

---

## Main Self-Refactoring System

```python
class SelfRefactoringSystem:
    """Main self-refactoring orchestrator."""
    
    def __init__(self, llm=None):
        self.analyzer = CodeAnalyzer()
        self.suggester = RefactoringSuggester(llm)
        self.refactoring_history = []
    
    def analyze_and_suggest(self, code: str, file_path: str = None) -> dict:
        """Analyze code and suggest refactorings."""
        
        metrics = self.analyzer.analyze(code, file_path)
        suggestions = self.suggester.suggest(metrics)
        
        return {
            "metrics": metrics,
            "suggestions": suggestions,
            "needs_refactoring": len(suggestions) > 0
        }
    
    def apply_refactoring(self, code: str, suggestion: dict) -> dict:
        """Apply a refactoring suggestion."""
        
        refactoring = self.suggester.generate_refactoring(code, suggestion)
        
        if refactoring.get("refactored_code") and refactoring.get("confidence", 0) > 0.5:
            if self.validate_code(refactoring["refactored_code"]):
                self.refactoring_history.append({
                    "original": code[:500],
                    "refactored": refactoring["refactored_code"][:500],
                    "suggestion": suggestion,
                    "timestamp": datetime.now().isoformat()
                })
                
                return {
                    "success": True,
                    "refactored_code": refactoring["refactored_code"],
                    "changes": refactoring.get("changes_made", [])
                }
        
        return {"success": False, "reason": "Refactoring failed validation"}
    
    def validate_code(self, code: str) -> bool:
        """Validate that code is syntactically correct."""
        
        try:
            compile(code, '<string>', 'exec')
            return True
        except SyntaxError:
            return False
    
    def get_refactoring_report(self) -> dict:
        """Get refactoring history report."""
        
        return {
            "total_refactorings": len(self.refactoring_history),
            "recent_refactorings": self.refactoring_history[-10:]
        }
```

---

## Usage Examples

### Analyze and Refactor

```python
refactorer = SelfRefactoringSystem(llm=my_llm)

code = open("my_module.py").read()
analysis = refactorer.analyze_and_suggest(code, "my_module.py")

print(f"Quality score: {analysis['metrics']['quality_score']}")
print(f"Suggestions: {len(analysis['suggestions'])}")

for suggestion in analysis["suggestions"][:3]:
    result = refactorer.apply_refactoring(code, suggestion)
    if result["success"]:
        print(f"Applied: {suggestion['type']}")
```

---

## Best Practices

1. **Validate before applying** — ensure refactored code compiles
2. **Run tests after refactoring** — verify behavior is preserved
3. **Refactor incrementally** — small changes are safer
4. **Keep public interfaces stable** — don't break external contracts
5. **Document changes** — track what was refactored and why
6. **Measure improvement** — compare metrics before and after
7. **Avoid over-refactoring** — not every smell needs fixing
8. **Human review for complex changes** — let humans verify major refactorings

---

## Integration

| Capability | How it integrates |
|---|---|
| **Self-Debugging** | Refactoring prevents bugs |
| **Self-Improving** | Code quality improves over time |
| **Self-Monitoring** | Metrics track code quality |
| **Self-Governing** | Quality standards enforced |
| **Self-Evolution** | Refactoring enables architectural changes |

---

## Advanced Refactoring Patterns

### Extract Method Pattern

**When to use:**
- Function does too many things
- Code block is repeated
- Function is too long (> 50 lines)

**How to apply:**
```python
# Before
def process_order(order):
    # Validate
    if not order.get("items"):
        return {"error": "No items"}
    if order.get("total", 0) <= 0:
        return {"error": "Invalid total"}
    
    # Calculate
    subtotal = sum(item["price"] * item["quantity"] for item in order["items"])
    tax = subtotal * 0.08
    total = subtotal + tax
    
    # Save
    db.save(order)
    
    # Notify
    email.send(order["email"], f"Order confirmed: ${total}")
    
    return {"success": True, "total": total}

# After
def validate_order(order):
    if not order.get("items"):
        return {"error": "No items"}
    if order.get("total", 0) <= 0:
        return {"error": "Invalid total"}
    return {"valid": True}

def calculate_total(order):
    subtotal = sum(item["price"] * item["quantity"] for item in order["items"])
    tax = subtotal * 0.08
    return subtotal + tax

def save_order(order):
    db.save(order)

def notify_customer(order, total):
    email.send(order["email"], f"Order confirmed: ${total}")

def process_order(order):
    validation = validate_order(order)
    if not validation["valid"]:
        return {"error": validation["error"]}
    
    total = calculate_total(order)
    save_order(order)
    notify_customer(order, total)
    
    return {"success": True, "total": total}
```

### Extract Class Pattern

**When to use:**
- Class does too many things
- Class has too many methods (> 20)
- Related methods can be grouped

**How to apply:**
```python
# Before
class UserManager:
    def authenticate(self, credentials):
        pass
    def authorize(self, user, resource):
        pass
    def send_email(self, user, message):
        pass
    def generate_report(self, user):
        pass
    def audit_action(self, user, action):
        pass

# After
class AuthManager:
    def authenticate(self, credentials):
        pass
    def authorize(self, user, resource):
        pass

class NotificationManager:
    def send_email(self, user, message):
        pass

class ReportGenerator:
    def generate_report(self, user):
        pass

class AuditLogger:
    def audit_action(self, user, action):
        pass

class UserManager:
    def __init__(self):
        self.auth = AuthManager()
        self.notifications = NotificationManager()
        self.reports = ReportGenerator()
        self.audit = AuditLogger()
```

### Replace Conditional with Polymorphism

**When to use:**
- Long if/elif chains
- Different behavior based on type
- Adding new types requires modifying existing code

**How to apply:**
```python
# Before
def get_discount(customer_type, amount):
    if customer_type == "premium":
        return amount * 0.2
    elif customer_type == "regular":
        return amount * 0.1
    elif customer_type == "new":
        return amount * 0.05
    return 0

# After
class DiscountStrategy:
    def get_discount(self, amount):
        raise NotImplementedError

class PremiumDiscount(DiscountStrategy):
    def get_discount(self, amount):
        return amount * 0.2

class RegularDiscount(DiscountStrategy):
    def get_discount(self, amount):
        return amount * 0.1

class NewCustomerDiscount(DiscountStrategy):
    def get_discount(self, amount):
        return amount * 0.05

DISCOUNT_STRATEGIES = {
    "premium": PremiumDiscount(),
    "regular": RegularDiscount(),
    "new": NewCustomerDiscount()
}

def get_discount(customer_type, amount):
    strategy = DISCOUNT_STRATEGIES.get(customer_type)
    return strategy.get_discount(amount) if strategy else 0
```

### Introduce Parameter Object

**When to use:**
- Function has many parameters (> 5)
- Parameters are related
- Same parameters passed to multiple functions

**How to apply:**
```python
# Before
def create_order(customer_id, product_id, quantity, discount_code, 
                 shipping_address, billing_address, gift_message=None):
    pass

# After
class OrderParams:
    def __init__(self, customer_id, product_id, quantity, discount_code,
                 shipping_address, billing_address, gift_message=None):
        self.customer_id = customer_id
        self.product_id = product_id
        self.quantity = quantity
        self.discount_code = discount_code
        self.shipping_address = shipping_address
        self.billing_address = billing_address
        self.gift_message = gift_message

def create_order(params: OrderParams):
    pass
```

### Code Smell Detection Rules

| Smell | Detection Rule | Severity |
|---|---|---|
| Long method | > 50 lines | High |
| Large class | > 500 lines | High |
| Long parameter list | > 7 parameters | Medium |
| Deep nesting | > 4 levels | Medium |
| Duplicate code | > 20% similarity | High |
| Dead code | Unused functions/variables | Low |
| Magic numbers | Hardcoded numeric literals | Medium |
| Complex conditionals | > 3 conditions | Medium |
| God class | Does too many things | High |
| Feature envy | Uses another class's data more than its own | Medium |

### Refactoring Safety Rules

1. **Never refactor and add features at the same time**
2. **Always have tests before refactoring**
3. **Refactor in small steps**
4. **Commit after each successful refactoring**
5. **Run tests after every change**
6. **Keep public interfaces stable**
7. **Document what was refactored and why**
8. **Review with a colleague for complex changes**

### Refactoring Metrics

| Metric | Description | Target |
|---|---|---|
| Code quality score | Overall quality (0-100) | > 80 |
| Cyclomatic complexity | Decision points in code | < 10 per function |
| Duplication rate | Duplicated code percentage | < 5% |
| Test coverage | Code covered by tests | > 80% |
| Technical debt | Estimated effort to fix issues | Decreasing trend |
| Refactoring frequency | Refactorings per sprint | 2-5 |

### Common Refactoring Mistakes

| Mistake | Consequence | Prevention |
|---|---|---|
| Refactoring without tests | Introduces bugs | Write tests first |
| Too large changes | Hard to review, easy to break | Small, incremental changes |
| Not committing | Lose progress | Commit after each change |
| Skipping verification | Breaks existing functionality | Run tests after every change |
| Ignoring dependencies | Breaks other parts of system | Check impact before refactoring |
| Over-engineering | Adds unnecessary complexity | Refactor only when needed |

---

## Further Reading

- **Self-Debugging** — Finding bugs to fix
- **Self-Improving** — Learning from refactoring outcomes
- **Production Concerns** — Code quality in production
- **Safety & Guardrails** — Ensuring refactoring stays safe
- **Testing Strategies** — How to test refactored code
