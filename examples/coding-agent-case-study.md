# Coding Agent Case Study

## Scenario

A coding agent that fixes bugs, implements features, and refactors code.

## Loop Application

### v1 (Concept)

```
Task: "Fix the failing test in test_auth.py"

1. Prompt: "Fix the failing test in test_auth.py"
2. Context: Read test_auth.py, read auth.py, check CI logs
3. Plan: [read_test, read_source, diagnose, fix, test, commit]
4. Reason: "Test expects status=200 but handler returns 404"
5. Act: Edit auth.py line 47
6. Observe: Run tests, 5/5 passing
7. Store: "Bug was null pointer in auth handler"
```

### v2 (Production)

Same as v1, plus:
- **Permission Gate**: Validates write is within src/** scope
- **HITL**: N/A (writing to src is allowed)
- **Retry**: If test runner times out, retry with backoff
- **Goal Check**: Stop when tests pass or max 10 cycles reached
- **Security**: Injection detection on user input

### v3 (Autonomous)

Same as v2, plus:
- **Self-Healing**: Token refresh if auth expires mid-session
- **Adaptive Planning**: Learns "read test first" pattern from history
- **Cost Optimization**: Uses gpt-4o-mini for simple fixes, gpt-4o for complex
- **Cross-Session Memory**: Remembers "this project uses TypeScript strict mode"
- **Verification**: Pre-checks that file exists before writing

## Code Snippet

```python
class CodingAgent:
    def fix_bug(self, test_file: str) -> dict:
        """Fix a failing test."""
        
        # Read test
        test_content = self.tools.read_file(test_file)
        
        # Find source file
        source_file = self.extract_source(test_content)
        source_content = self.tools.read_file(source_file)
        
        # Diagnose
        diagnosis = self.llm.call(f"""
            Test: {test_content}
            Source: {source_content}
            Why is the test failing?
        """)
        
        # Fix
        fix = self.llm.call(f"""
            Fix this bug: {diagnosis}
            Source: {source_content}
        """)
        
        # Apply fix
        self.tools.write_file(source_file, fix)
        
        # Test
        test_result = self.tools.run_tests()
        
        return {
            "fixed": test_result.passed,
            "diagnosis": diagnosis,
            "fix_applied": fix
        }
```

## Metrics

| Metric | Without Loop | With Loop |
|---|---|---|
| Success rate | 60% | 92% |
| Avg cycles | 1 (no recovery) | 3.2 |
| Avg tokens | 2000 | 8000 |
| Avg cost | $0.05 | $0.20 |
| Human intervention | 40% | 8% |

## Lessons Learned

1. **Read test first** — the test file always reveals expected behavior
2. **Check null pointers** — 60% of bugs are null-related
3. **Run tests after every change** — catch regressions immediately
4. **Commit often** — small commits are easier to revert
