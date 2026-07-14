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

## Advanced Refactoring Patterns

### Code Smell Detection Engine

```python
class CodeSmellDetector:
    """Detects various code smells."""
    
    def __init__(self):
        self.smell_definitions = {
            "long_method": {"threshold": 50, "severity": "high"},
            "large_class": {"threshold": 500, "severity": "high"},
            "long_parameter_list": {"threshold": 7, "severity": "medium"},
            "deep_nesting": {"threshold": 4, "severity": "medium"},
            "duplicate_code": {"threshold": 0.2, "severity": "high"},
            "dead_code": {"severity": "low"},
            "magic_numbers": {"severity": "medium"},
            "complex_conditionals": {"threshold": 3, "severity": "medium"}
        }
    
    def detect(self, code: str) -> list:
        """Detect code smells in code."""
        
        smells = []
        
        # Check for long methods
        methods = self.extract_methods(code)
        for method in methods:
            if method["lines"] > self.smell_definitions["long_method"]["threshold"]:
                smells.append({
                    "type": "long_method",
                    "name": method["name"],
                    "lines": method["lines"],
                    "severity": "high"
                })
        
        # Check for large classes
        classes = self.extract_classes(code)
        for cls in classes:
            if cls["lines"] > self.smell_definitions["large_class"]["threshold"]:
                smells.append({
                    "type": "large_class",
                    "name": cls["name"],
                    "lines": cls["lines"],
                    "severity": "high"
                })
        
        # Check for deep nesting
        nesting = self.calculate_max_nesting(code)
        if nesting > self.smell_definitions["deep_nesting"]["threshold"]:
            smells.append({
                "type": "deep_nesting",
                "depth": nesting,
                "severity": "medium"
            })
        
        # Check for duplicate code
        duplicates = self.find_duplicates(code)
        if duplicates:
            smells.append({
                "type": "duplicate_code",
                "count": len(duplicates),
                "severity": "high"
            })
        
        return smells
    
    def extract_methods(self, code: str) -> list:
        """Extract methods from code."""
        
        import re
        
        methods = []
        
        for match in re.finditer(r'def\s+(\w+)\s*\([^)]*\):', code):
            name = match.group(1)
            start = match.end()
            
            # Find method body
            lines = code[start:].split('\n')
            body_lines = 0
            for line in lines[1:]:
                if line.strip() and not line.strip().startswith(('def ', 'class ')):
                    body_lines += 1
                elif line.strip().startswith(('def ', 'class ')):
                    break
            
            methods.append({"name": name, "lines": body_lines})
        
        return methods
    
    def extract_classes(self, code: str) -> list:
        """Extract classes from code."""
        
        import re
        
        classes = []
        
        for match in re.finditer(r'class\s+(\w+):', code):
            name = match.group(1)
            start = match.end()
            
            # Find class body
            lines = code[start:].split('\n')
            body_lines = 0
            for line in lines:
                if line.strip().startswith(('def ', 'class ')):
                    break
                body_lines += 1
            
            classes.append({"name": name, "lines": body_lines})
        
        return classes
    
    def calculate_max_nesting(self, code: str) -> int:
        """Calculate maximum nesting depth."""
        
        max_depth = 0
        current_depth = 0
        
        for line in code.split('\n'):
            stripped = line.strip()
            if stripped.startswith(('if ', 'for ', 'while ', 'with ')):
                current_depth += 1
                max_depth = max(max_depth, current_depth)
            elif stripped.startswith(('else:', 'elif ')):
                pass
            elif current_depth > 0 and not stripped.startswith((' ', '\t')):
                current_depth = max(0, current_depth - 1)
        
        return max_depth
    
    def find_duplicates(self, code: str) -> list:
        """Find duplicate code blocks."""
        
        lines = [l.strip() for l in code.split('\n') if l.strip()]
        
        seen = {}
        duplicates = []
        
        for i, line in enumerate(lines):
            if len(line) < 20:
                continue
            if line in seen:
                duplicates.append({"line": line, "first": seen[line], "second": i})
            else:
                seen[line] = i
        
        return duplicates
```

### Refactoring Strategies

```python
class RefactoringStrategies:
    """Collection of refactoring strategies."""
    
    def __init__(self):
        self.strategies = {
            "extract_method": self.extract_method,
            "extract_class": self.extract_class,
            "rename": self.rename,
            "move_method": self.move_method,
            "inline": self.inline,
            "replace_temp_with_query": self.replace_temp_with_query,
            "introduce_parameter_object": self.introduce_parameter_object,
            "replace_conditional_with_polymorphism": self.replace_conditional_with_polymorphism
        }
    
    def extract_method(self, code: str, start_line: int, end_line: int, 
                       method_name: str) -> str:
        """Extract a method from code."""
        
        lines = code.split('\n')
        method_body = lines[start_line:end_line]
        
        # Create method
        method = f"\ndef {method_name}():\n"
        for line in method_body:
            method += f"    {line}\n"
        
        # Replace original with method call
        lines[start_line:end_line] = [f"{method_name}()"]
        
        return method + '\n'.join(lines)
    
    def extract_class(self, code: str, methods: list, class_name: str) -> str:
        """Extract a class from code."""
        
        class_def = f"\nclass {class_name}:\n"
        for method in methods:
            class_def += f"    {method}\n"
        
        return class_def
    
    def rename(self, code: str, old_name: str, new_name: str) -> str:
        """Rename a variable or method."""
        
        import re
        return re.sub(r'\b' + old_name + r'\b', new_name, code)
    
    def move_method(self, code: str, method_name: str, from_class: str, 
                    to_class: str) -> str:
        """Move a method from one class to another."""
        
        # Simplified - in reality would need AST manipulation
        return code
    
    def inline(self, code: str, method_name: str) -> str:
        """Inline a method."""
        
        # Find method definition
        import re
        pattern = rf'def {method_name}\([^)]*\):(.*?)(?=\ndef |\nclass |\Z)'
        match = re.search(pattern, code, re.DOTALL)
        
        if match:
            method_body = match.group(1).strip()
            # Replace method calls with body
            code = re.sub(rf'{method_name}\(\)', method_body, code)
            # Remove method definition
            code = re.sub(pattern, '', code, flags=re.DOTALL)
        
        return code
    
    def replace_temp_with_query(self, code: str, temp_name: str, 
                                query: str) -> str:
        """Replace temporary variable with query."""
        
        return code.replace(temp_name, query)
    
    def introduce_parameter_object(self, code: str, params: list, 
                                   class_name: str) -> str:
        """Introduce parameter object for long parameter lists."""
        
        param_obj = f"\nclass {class_name}:\n"
        param_obj += f"    def __init__(self, {', '.join(params)}):\n"
        for param in params:
            param_obj += f"        self.{param} = {param}\n"
        
        return param_obj + code
    
    def replace_conditional_with_polymorphism(self, code: str, 
                                              conditionals: dict) -> str:
        """Replace conditional logic with polymorphism."""
        
        # Simplified - would need full class hierarchy in reality
        base_class = "\nclass Base:\n    def execute(self):\n        pass\n\n"
        
        for condition, implementation in conditionals.items():
            class_name = f"Handler_{condition}"
            base_class += f"class {class_name}(Base):\n"
            base_class += f"    def execute(self):\n"
            base_class += f"        {implementation}\n\n"
        
        return base_class + code
```

### Quality Metrics Tracker

```python
class QualityMetricsTracker:
    """Tracks code quality metrics over time."""
    
    def __init__(self):
        self.metrics_history = []
        self.thresholds = {
            "complexity": {"max": 15, "target": 10},
            "duplication": {"max": 0.3, "target": 0.1},
            "coverage": {"min": 0.7, "target": 0.9},
            "maintainability": {"min": 60, "target": 80}
        }
    
    def record_metrics(self, file_path: str, metrics: dict):
        """Record quality metrics for a file."""
        
        self.metrics_history.append({
            "file": file_path,
            "metrics": metrics,
            "timestamp": datetime.now().isoformat(),
            "quality_score": self.calculate_quality_score(metrics)
        })
    
    def calculate_quality_score(self, metrics: dict) -> float:
        """Calculate overall quality score."""
        
        score = 100.0
        
        # Complexity penalty
        complexity = metrics.get("complexity", 0)
        if complexity > self.thresholds["complexity"]["target"]:
            score -= (complexity - self.thresholds["complexity"]["target"]) * 2
        
        # Duplication penalty
        duplication = metrics.get("duplication", 0)
        if duplication > self.thresholds["duplication"]["target"]:
            score -= (duplication - self.thresholds["duplication"]["target"]) * 50
        
        return max(0, min(100, score))
    
    def check_thresholds(self, metrics: dict) -> list:
        """Check if metrics exceed thresholds."""
        
        violations = []
        
        if metrics.get("complexity", 0) > self.thresholds["complexity"]["max"]:
            violations.append({
                "metric": "complexity",
                "value": metrics["complexity"],
                "threshold": self.thresholds["complexity"]["max"],
                "severity": "high"
            })
        
        if metrics.get("duplication", 0) > self.thresholds["duplication"]["max"]:
            violations.append({
                "metric": "duplication",
                "value": metrics["duplication"],
                "threshold": self.thresholds["duplication"]["max"],
                "severity": "high"
            })
        
        return violations
    
    def get_trend(self, file_path: str, metric: str) -> dict:
        """Get trend for a metric."""
        
        file_metrics = [h for h in self.metrics_history if h["file"] == file_path]
        
        if len(file_metrics) < 2:
            return {"trend": "insufficient_data"}
        
        values = [h["metrics"].get(metric, 0) for h in file_metrics]
        
        recent = values[-1]
        older = values[0]
        
        if recent > older * 1.1:
            trend = "degrading"
        elif recent < older * 0.9:
            trend = "improving"
        else:
            trend = "stable"
        
        return {"trend": "trend", "values": values}
```

## Integration

| Capability | Integration |
|---|---|
| **Self-Debugging** | Refactoring prevents bugs |
| **Self-Improving** | Code quality improves over time |
| **Self-Monitoring** | Metrics track code quality |
| **Self-Testing** | Tests verify refactoring correctness |
| **Self-Governing** | Quality standards enforced |
