# Advanced Evaluation Framework

## Evaluation Dimensions

### 1. Task Completion

| Metric | Description | Target |
|---|---|---|
| Completion Rate | % tasks finished | > 90% |
| First-try Success | % correct on first attempt | > 70% |
| Time to Completion | Average time per task | < 30s simple |

### 2. Quality

| Metric | Description | Target |
|---|---|---|
| Accuracy | % correct results | > 85% |
| Completeness | % required output provided | > 90% |
| Relevance | % relevant information | > 80% |

### 3. Efficiency

| Metric | Description | Target |
|---|---|---|
| Token Usage | Tokens per task | Within budget |
| Cost per Task | Dollar cost | < $0.50 simple |
| Cycles per Task | Loops needed | < 8 simple |

### 4. Safety

| Metric | Description | Target |
|---|---|---|
| Security Violations | Safety breaches | 0 |
| Data Leaks | Sensitive data exposure | 0 |
| Policy Violations | Rule breaks | 0 |

## Evaluation Suite

```python
class EvaluationSuite:
    def __init__(self):
        self.tasks = []
        self.results = []
    
    def add_task(self, task: dict):
        """Add evaluation task."""
        self.tasks.append(task)
    
    def run(self, agent) -> dict:
        """Run evaluation suite."""
        
        results = []
        
        for task in self.tasks:
            start_time = time.time()
            
            try:
                result = agent.run(task["input"])
                success = self.evaluate(result, task["expected"])
                
                results.append({
                    "task": task,
                    "success": success,
                    "duration": time.time() - start_time
                })
            except Exception as e:
                results.append({
                    "task": task,
                    "success": False,
                    "error": str(e),
                    "duration": time.time() - start_time
                })
        
        return self.analyze_results(results)
    
    def evaluate(self, result: str, expected: str) -> bool:
        """Evaluate if result matches expected."""
        
        # Simple exact match
        if result.strip() == expected.strip():
            return True
        
        # Fuzzy match
        if self.fuzzy_match(result, expected):
            return True
        
        return False
    
    def fuzzy_match(self, result: str, expected: str) -> bool:
        """Fuzzy string matching."""
        
        # Simple similarity check
        result_words = set(result.lower().split())
        expected_words = set(expected.lower().split())
        
        overlap = len(result_words & expected_words)
        total = len(expected_words)
        
        return overlap / total > 0.8 if total > 0 else False
    
    def analyze_results(self, results: list) -> dict:
        """Analyze evaluation results."""
        
        total = len(results)
        successful = sum(1 for r in results if r["success"])
        avg_duration = sum(r["duration"] for r in results) / total if total > 0 else 0
        
        return {
            "total_tasks": total,
            "successful": successful,
            "success_rate": successful / total if total > 0 else 0,
            "avg_duration": avg_duration,
            "results": results
        }
```

## Red-Team Testing

```python
class RedTeamTester:
    def __init__(self):
        self.attack_suites = []
    
    def add_attack_suite(self, suite: list):
        """Add attack test suite."""
        self.attack_suites.append(suite)
    
    def run_attacks(self, agent) -> dict:
        """Run all attack tests."""
        
        results = []
        
        for suite in self.attack_suites:
            for attack in suite:
                try:
                    result = agent.run(attack["input"])
                    passed = not self.was_hijacked(result, attack)
                    
                    results.append({
                        "attack": attack["name"],
                        "passed": passed,
                        "result": result[:100]  # Truncate for safety
                    })
                except Exception as e:
                    results.append({
                        "attack": attack["name"],
                        "passed": True,  # Error = attack blocked
                        "error": str(e)
                    })
        
        return self.analyze_results(results)
    
    def was_hijacked(self, result: str, attack: dict) -> bool:
        """Check if agent was hijacked."""
        
        # Check if agent followed injected instructions
        if attack.get("expected_not"):
            return attack["expected_not"] in result
        
        return False
```

## Benchmarking

```python
class BenchmarkRunner:
    def __init__(self):
        self.benchmarks = {}
    
    def add_benchmark(self, name: str, tasks: list):
        """Add a benchmark."""
        self.benchmarks[name] = tasks
    
    def run_benchmark(self, name: str, agent) -> dict:
        """Run a benchmark."""
        
        tasks = self.benchmarks[name]
        
        results = []
        for task in tasks:
            start = time.time()
            result = agent.run(task["input"])
            duration = time.time() - start
            
            results.append({
                "task": task["input"][:50],
                "success": result.get("success", False),
                "duration": duration,
                "tokens": result.get("tokens", 0)
            })
        
        return self.analyze_benchmark(results)
    
    def analyze_benchmark(self, results: list) -> dict:
        """Analyze benchmark results."""
        
        total = len(results)
        successful = sum(1 for r in results if r["success"])
        avg_duration = sum(r["duration"] for r in results) / total if total > 0 else 0
        avg_tokens = sum(r["tokens"] for r in results) / total if total > 0 else 0
        
        return {
            "total": total,
            "success_rate": successful / total if total > 0 else 0,
            "avg_duration": avg_duration,
            "avg_tokens": avg_tokens
        }
```
