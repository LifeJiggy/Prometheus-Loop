---
name: self-refactoring
description: Improve code structure, reduce complexity, and maintain quality
---

# Self-Refactoring

The agent's ability to improve its own code structure automatically.

## Quick Start

When the user asks about code quality:

1. **Analyze** — measure code metrics
2. **Detect** — find code smells
3. **Suggest** — recommend refactorings
4. **Apply** — make changes
5. **Verify** — ensure tests pass

## Code Smells

| Smell | Threshold | Fix |
|---|---|---|
| **Long method** | > 50 lines | Extract method |
| **Large class** | > 500 lines | Extract class |
| **Deep nesting** | > 4 levels | Flatten logic |
| **Duplicate code** | > 20% duplication | Extract common |
| **Long parameter list** | > 7 params | Introduce parameter object |

## Usage

```python
refactorer = SelfRefactoringSystem(llm=my_llm)

code = open("my_module.py").read()
analysis = refactorer.analyze_and_suggest(code, "my_module.py")

for suggestion in analysis["suggestions"][:3]:
    result = refactorer.apply_refactoring(code, suggestion)
    if result["success"]:
        print(f"Applied: {suggestion['type']}")
```

## Further Reading

- [Full implementation](../shared/self/self-refactoring.md) — Code smells, refactoring strategies
