# Self-Refactoring Deep Dive

## Overview

Self-Refactoring is the agent's ability to improve its own code structure, reduce complexity, eliminate duplication, and maintain code quality over time — without changing external behavior.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SELF-REFACTORING SYSTEM                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐        │
│  │  Code    │──▶│  Issue   │──▶│  Fix     │──▶│ Verify   │        │
│  │ Analyzer │   │ Detector │   │ Generator│   │ Quality  │        │
│  └──────────┘   └──────────┘   └──────────┘   └──────────┘        │
│       │              │              │               │                │
│       ▼              ▼              ▼               ▼                │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐        │
│  │ Metrics  │   │ Code     │   │ Apply    │   │ Test     │        │
│  │ Collector│   │ Smells   │   │ Changes  │   │ Suite    │        │
│  └──────────┘   └──────────┘   └──────────┘   └──────────┘        │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    QUALITY GATE                              │   │
│  │  Complexity │ Duplication │ Coverage │ Style Compliance     │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

## Core Implementation

### Code Analyzer

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
        
        # Calculate overall quality score
        metrics["quality_score"] = self.calculate_quality_score(metrics)
        
        # Store metrics
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
        
        # Python functions
        for match in re.finditer(r'def\s+(\w+)\s*\(', code):
            func_name = match.group(1)
            start_line = code[:match.start()].count('\n') + 1
            
            # Find function body
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
        
        for line in lines[1:]:  # Skip def line
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
        
        # Count branching statements
        patterns = [
            r'\bif\b', r'\belif\b', r'\belse\b',
            r'\bfor\b', r'\bwhile\b',
            r'\bexcept\b', r'\bfinally\b',
            r'\band\b', r'\bor\b',
            r'\bcase\b'  # For switch statements
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
            if len(line) < 20:  # Skip short lines
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
        
        # Long functions
        functions = self.count_functions(code)
        for func in functions:
            if func["lines"] > 50:
                smells.append({
                    "type": "long_function",
                    "name": func["name"],
                    "lines": func["lines"],
                    "severity": "medium"
                })
        
        # High complexity
        if self.calculate_complexity(code) > 15:
            smells.append({
                "type": "high_complexity",
                "severity": "high"
            })
        
        # Too many parameters
        import re
        for match in re.finditer(r'def\s+\w+\s*\(([^)]+)\)', code):
            params = [p.strip() for p in match.group(1).split(',')]
            if len(params) > 5:
                smells.append({
                    "type": "too_many_parameters",
                    "count": len(params),
                    "severity": "medium"
                })
        
        # Deep nesting
        lines = code.split('\n')
        max_depth = 0
        current_depth = 0
        
        for line in lines:
            stripped = line.strip()
            if stripped.startswith(('if ', 'for ', 'while ', 'with ', 'try:')):
                current_depth += 1
                max_depth = max(max_depth, current_depth)
            elif stripped.startswith(('else:', 'elif ', 'except:', 'finally:')):
                pass  # Same level
            elif not stripped or stripped.startswith('#'):
                pass  # Empty or comment
            elif current_depth > 0 and not stripped.startswith(('return', 'pass', 'break', 'continue')):
                # Check if we're back to a shallower level
                indent = len(line) - len(line.lstrip())
                if indent < current_depth * 4:
                    current_depth = max(0, indent // 4)
        
        if max_depth > 4:
            smells.append({
                "type": "deep_nesting",
                "depth": max_depth,
                "severity": "medium"
            })
        
        return smells
    
    def calculate_quality_score(self, metrics: dict) -> float:
        """Calculate overall quality score (0-100)."""
        
        score = 100
        
        # Deduct for complexity
        complexity = metrics["complexity"]
        if complexity > 10:
            score -= (complexity - 10) * 2
        
        # Deduct for duplications
        duplications = len(metrics["duplications"])
        score -= duplications * 5
        
        # Deduct for code smells
        for smell in metrics["code_smells"]:
            if smell["severity"] == "high":
                score -= 15
            elif smell["severity"] == "medium":
                score -= 10
            else:
                score -= 5
        
        # Deduct for low comment ratio
        if metrics["lines"]["comment_ratio"] < 0.1:
            score -= 10
        
        return max(0, min(100, score))
```

### Refactoring Suggestions

```python
class RefactoringSuggester:
    """Suggests refactoring actions."""
    
    def __init__(self, llm=None):
        self.llm = llm
    
    def suggest(self, metrics: dict) -> list:
        """Generate refactoring suggestions."""
        
        suggestions = []
        
        # Check for long functions
        for func in metrics.get("functions", []):
            if func["lines"] > 30:
                suggestions.append({
                    "type": "extract_function",
                    "target": func["name"],
                    "description": f"Function '{func['name']}' is {func['lines']} lines long",
                    "priority": "high" if func["lines"] > 50 else "medium"
                })
        
        # Check for high complexity
        if metrics["complexity"] > 15:
            suggestions.append({
                "type": "reduce_complexity",
                "description": f"Code complexity is {metrics['complexity']}",
                "priority": "high"
            })
        
        # Check for duplications
        if len(metrics["duplications"]) > 3:
            suggestions.append({
                "type": "extract_common",
                "description": f"Found {len(metrics['duplications'])} code duplications",
                "priority": "medium"
            })
        
        # Check for code smells
        for smell in metrics.get("code_smells", []):
            suggestions.append({
                "type": f"fix_{smell['type']}",
                "description": f"Code smell: {smell['type']}",
                "priority": smell["severity"]
            })
        
        # Sort by priority
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
        
        Apply the refactoring while:
        1. Maintaining the same functionality
        2. Improving code structure
        3. Following best practices
        4. Keeping the same public interface
        
        Return JSON with:
        - refactored_code: the new code
        - changes_made: list of changes
        - confidence: 0-1
        """
        
        try:
            response = self.llm.call(prompt)
            import json
            return json.loads(response)
        except:
            return {"refactored_code": code, "changes_made": [], "confidence": 0}
    
    def generate_heuristic(self, code: str, suggestion: dict) -> dict:
        """Generate refactoring using heuristics."""
        
        # Simple heuristic refactorings
        refactored = code
        changes = []
        
        if suggestion["type"] == "extract_function":
            # This would require more sophisticated parsing
            return {"refactored_code": code, "changes_made": [], "confidence": 0.3}
        
        elif suggestion["type"] == "reduce_complexity":
            # Suggest breaking into smaller functions
            changes.append("Consider breaking complex logic into smaller functions")
            return {"refactored_code": code, "changes_made": changes, "confidence": 0.4}
        
        elif suggestion["type"] == "extract_common":
            # Suggest extracting common code
            changes.append("Extract duplicated code into shared utility functions")
            return {"refactored_code": code, "changes_made": changes, "confidence": 0.4}
        
        return {"refactored_code": code, "changes_made": [], "confidence": 0.3}
```

### Main Self-Refactoring System

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
            # Verify refactored code is valid
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

## Usage Examples

### Example 1: Analyze and Refactor

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

## Best Practices

1. **Validate before applying** — ensure refactored code compiles
2. **Run tests after refactoring** — verify behavior is preserved
3. **Refactor incrementally** — small changes are safer
4. **Keep public interfaces stable** — don't break external contracts
5. **Document changes** — track what was refactored and why
6. **Measure improvement** — compare metrics before and after
7. **Avoid over-refactoring** — not every smell needs fixing
8. **Human review for complex changes** — let humans verify major refactorings

## Integration

| Capability | Integration |
|---|---|
| **Self-Debugging** | Refactoring prevents bugs |
| **Self-Improving** | Code quality improves over time |
| **Self-Monitoring** | Metrics track code quality |
| **Self-Testing** | Tests verify refactoring correctness |
| **Self-Governing** | Quality standards enforced |
