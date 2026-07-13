# Cost Optimization Strategies

## Cost Landscape

### Model Pricing (as of 2025)

| Model | Input ($/1M tokens) | Output ($/1M tokens) | Best for |
|---|---|---|---|
| **gpt-4o-mini** | $0.15 | $0.60 | Simple tasks, classification, formatting |
| **gpt-4o** | $2.50 | $10.00 | Complex reasoning, code, analysis |
| **claude-3-haiku** | $0.25 | $1.25 | Quick responses, simple tasks |
| **claude-3-sonnet** | $3.00 | $15.00 | Balanced performance and cost |
| **claude-3-opus** | $15.00 | $75.00 | Most complex tasks, highest accuracy |
| **llama-3.1-8b** | $0.05 | $0.05 | Self-hosted, very cheap |
| **llama-3.1-70b** | $0.80 | $0.80 | Self-hosted, good performance |

### Cost Drivers

| Driver | Impact | Optimization |
|---|---|---|
| **Model selection** | 10-50x cost difference | Route to cheapest capable model |
| **Context length** | Linear cost increase | Compress, cache, truncate |
| **Retry loops** | 2-5x cost increase | Fix root cause, not symptoms |
| **Unnecessary calls** | 100% waste | Cache, batch, skip |
| **Output length** | Linear cost increase | Summarize, truncate |

## Model Routing

### Intelligent Model Router

```python
class IntelligentModelRouter:
    def __init__(self):
        self.models = {
            "simple": {"model": "gpt-4o-mini", "cost_per_1m": 0.15},
            "moderate": {"model": "gpt-4o", "cost_per_1m": 2.50},
            "complex": {"model": "gpt-4o", "cost_per_1m": 2.50},
            "critical": {"model": "gpt-4o", "cost_per_1m": 2.50}
        }
        
        # Learned routing patterns
        self.routing_history = []
    
    def select_model(self, task: str, context: dict, budget_remaining: float) -> str:
        """Select model based on task, context, and budget."""
        
        # Step 1: Classify task complexity
        complexity = self.classify_complexity(task, context)
        
        # Step 2: Check budget constraints
        if budget_remaining < 0.10:
            # Force cheap model when budget is low
            return "gpt-4o-mini"
        
        # Step 3: Task-specific routing
        task_type = self.classify_task_type(task)
        
        routing_rules = {
            "code_review": "gpt-4o-mini",      # Pattern matching
            "bug_fix": "gpt-4o",               # Needs reasoning
            "architecture": "gpt-4o",          # Complex design
            "documentation": "gpt-4o-mini",    # Formatting
            "security_audit": "gpt-4o",        # Careful analysis
            "data_analysis": "gpt-4o",         # Complex calculations
            "simple_qa": "gpt-4o-mini",        # Quick answers
            "complex_reasoning": "gpt-4o"      # Deep thinking
        }
        
        # Step 4: Select based on routing rules
        model = routing_rules.get(task_type, self.models[complexity]["model"])
        
        # Step 5: Verify budget
        estimated_cost = self.estimate_cost(task, model)
        if estimated_cost > budget_remaining * 0.5:
            # Downgrade if would consume too much budget
            model = "gpt-4o-mini"
        
        # Log routing decision
        self.log_routing(task, model, complexity, task_type)
        
        return model
    
    def classify_complexity(self, task: str, context: dict) -> str:
        """Classify task complexity."""
        
        indicators = {
            "simple": [
                len(task.split()) < 10,
                "read" in task.lower() or "list" in task.lower(),
                context.get("prior_success", False)
            ],
            "complex": [
                len(task.split()) > 30,
                "analyze" in task.lower() or "design" in task.lower(),
                "multiple" in task.lower() or "integrate" in task.lower(),
                context.get("prior_failures", 0) > 2
            ]
        }
        
        simple_score = sum(indicators["simple"])
        complex_score = sum(indicators["complex"])
        
        if simple_score >= 2:
            return "simple"
        elif complex_score >= 2:
            return "complex"
        else:
            return "moderate"
    
    def classify_task_type(self, task: str) -> str:
        """Classify task type for routing."""
        
        keywords = {
            "code_review": ["review", "check", "audit code"],
            "bug_fix": ["fix", "bug", "error", "broken"],
            "architecture": ["design", "architect", "plan system"],
            "documentation": ["document", "write docs", "explain"],
            "security_audit": ["security", "vulnerability", "attack"],
            "data_analysis": ["analyze", "data", "metrics", "statistics"],
            "simple_qa": ["what is", "how to", "explain"],
            "complex_reasoning": ["why", "compare", "evaluate", "tradeoff"]
        }
        
        task_lower = task.lower()
        
        for task_type, words in keywords.items():
            if any(word in task_lower for word in words):
                return task_type
        
        return "moderate"
    
    def estimate_cost(self, task: str, model: str) -> float:
        """Estimate cost for task."""
        
        # Rough token estimation
        estimated_input_tokens = len(task.split()) * 2  # ~2 tokens per word
        estimated_output_tokens = estimated_input_tokens * 2  # Output is usually longer
        
        # Get model pricing
        pricing = {
            "gpt-4o-mini": {"input": 0.15, "output": 0.60},
            "gpt-4o": {"input": 2.50, "output": 10.00}
        }
        
        model_pricing = pricing.get(model, {"input": 2.50, "output": 10.00})
        
        cost = (
            estimated_input_tokens * model_pricing["input"] / 1_000_000 +
            estimated_output_tokens * model_pricing["output"] / 1_000_000
        )
        
        return cost
    
    def log_routing(self, task: str, model: str, complexity: str, task_type: str):
        """Log routing decision for learning."""
        
        self.routing_history.append({
            "task": task[:100],  # Truncate for storage
            "model": model,
            "complexity": complexity,
            "task_type": task_type,
            "timestamp": datetime.now()
        })
```

## Caching Strategies

### Multi-Level Cache

```python
class MultiLevelCache:
    def __init__(self):
        # L1: In-memory cache (fast, small)
        self.l1_cache = {}
        self.l1_max_size = 100
        
        # L2: Redis cache (fast, large)
        self.redis = Redis()
        
        # L3: Database cache (slow, persistent)
        self.db = Database()
    
    def get(self, key: str) -> dict:
        """Get from cache, checking all levels."""
        
        # Check L1
        if key in self.l1_cache:
            return self.l1_cache[key]
        
        # Check L2
        l2_result = self.redis.get(key)
        if l2_result:
            # Promote to L1
            self.l1_cache[key] = l2_result
            return l2_result
        
        # Check L3
        l3_result = self.db.get(key)
        if l3_result:
            # Promote to L2 and L1
            self.redis.set(key, l3_result, ex=3600)
            self.l1_cache[key] = l3_result
            return l3_result
        
        return None
    
    def set(self, key: str, value: dict, ttl: int = 3600):
        """Set in all cache levels."""
        
        # Set in L1
        if len(self.l1_cache) >= self.l1_max_size:
            # Evict oldest
            oldest_key = next(iter(self.l1_cache))
            del self.l1_cache[oldest_key]
        
        self.l1_cache[key] = value
        
        # Set in L2
        self.redis.set(key, value, ex=ttl)
        
        # Set in L3
        self.db.set(key, value, expires_at=datetime.now() + timedelta(seconds=ttl))
```

### Semantic Cache

```python
import numpy as np
from sentence_transformers import SentenceTransformer


class SemanticCache:
    def __init__(self, similarity_threshold: float = 0.92):
        self.model = SentenceTransformer('all-MiniLM-L6-v2')
        self.threshold = similarity_threshold
        self.cache = []
    
    def get(self, query: str) -> dict:
        """Get semantically similar result."""
        
        query_embedding = self.model.encode(query)
        
        best_match = None
        best_score = 0
        
        for entry in self.cache:
            similarity = self.cosine_similarity(query_embedding, entry["embedding"])
            
            if similarity > best_score:
                best_score = similarity
                best_match = entry
        
        if best_score >= self.threshold:
            return best_match["result"]
        
        return None
    
    def set(self, query: str, result: dict):
        """Add to semantic cache."""
        
        embedding = self.model.encode(query)
        
        self.cache.append({
            "query": query,
            "embedding": embedding,
            "result": result,
            "timestamp": datetime.now()
        })
    
    def cosine_similarity(self, a, b) -> float:
        """Compute cosine similarity."""
        return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))
```

## Context Compression

### Smart Context Compressor

```python
class SmartContextCompressor:
    def __init__(self, llm, max_tokens: int = 4000):
        self.llm = llm
        self.max_tokens = max_tokens
    
    def compress(self, context: list, task: str) -> list:
        """Compress context intelligently."""
        
        current_tokens = self.estimate_tokens(context)
        
        if current_tokens <= self.max_tokens:
            return context
        
        # Strategy 1: Remove redundant information
        deduplicated = self.deduplicate(context)
        if self.estimate_tokens(deduplicated) <= self.max_tokens:
            return deduplicated
        
        # Strategy 2: Summarize old context
        summarized = self.summarize_old(deduplicated)
        if self.estimate_tokens(summarized) <= self.max_tokens:
            return summarized
        
        # Strategy 3: Extract relevant chunks only
        relevant = self.extract_relevant(summarized, task)
        if self.estimate_tokens(relevant) <= self.max_tokens:
            return relevant
        
        # Strategy 4: Aggressive summarization
        return self.aggressive_summarize(relevant)
    
    def deduplicate(self, context: list) -> list:
        """Remove duplicate information."""
        
        seen = set()
        deduplicated = []
        
        for item in context:
            # Create a signature for the item
            signature = self.create_signature(item)
            
            if signature not in seen:
                seen.add(signature)
                deduplicated.append(item)
        
        return deduplicated
    
    def summarize_old(self, context: list) -> list:
        """Summarize older context entries."""
        
        if len(context) <= 3:
            return context
        
        # Keep recent context
        recent = context[-3:]
        old = context[:-3]
        
        # Summarize old context
        summary = self.llm.call(f"""
            Summarize this conversation history concisely:
            {old}
            
            Focus on:
            - Key decisions made
            - Important findings
            - User preferences
            - Action items
        """)
        
        return [{"role": "system", "content": summary}] + recent
    
    def extract_relevant(self, context: list, task: str) -> list:
        """Extract only relevant context."""
        
        relevant = []
        
        for item in context:
            relevance = self.calculate_relevance(item, task)
            if relevance > 0.3:  # Relevance threshold
                relevant.append(item)
        
        return relevant
    
    def aggressive_summarize(self, context: list) -> list:
        """Aggressively summarize to fit budget."""
        
        summary = self.llm.call(f"""
            Provide a very brief summary of:
            {context}
            
            Maximum 500 characters.
        """)
        
        return [{"role": "system", "content": summary}]
```

## Batching and Parallelization

### Intelligent Batching

```python
class IntelligentBatcher:
    def __init__(self, max_batch_size: int = 10, max_concurrent: int = 5):
        self.max_batch_size = max_batch_size
        self.max_concurrent = max_concurrent
    
    async def process_batch(self, tasks: list, processor: callable) -> list:
        """Process tasks in intelligent batches."""
        
        # Group similar tasks
        grouped = self.group_similar_tasks(tasks)
        
        results = []
        
        for group in grouped:
            # Process group in parallel
            batch_results = await asyncio.gather(*[
                processor(task) for task in group[:self.max_batch_size]
            ])
            
            results.extend(batch_results)
        
        return results
    
    def group_similar_tasks(self, tasks: list) -> list:
        """Group similar tasks for efficient batching."""
        
        groups = defaultdict(list)
        
        for task in tasks:
            # Classify task
            task_type = self.classify_task(task)
            groups[task_type].append(task)
        
        return list(groups.values())
    
    def classify_task(self, task: str) -> str:
        """Classify task for grouping."""
        
        if "read" in task.lower() or "list" in task.lower():
            return "read_operations"
        elif "write" in task.lower() or "create" in task.lower():
            return "write_operations"
        elif "analyze" in task.lower() or "compare" in task.lower():
            return "analysis_operations"
        else:
            return "other_operations"
```

## Cost Tracking and Budgeting

### Comprehensive Cost Tracker

```python
class ComprehensiveCostTracker:
    def __init__(self, daily_budget: float, task_budget: float):
        self.daily_budget = daily_budget
        self.task_budget = task_budget
        self.daily_spent = 0.0
        self.task_spent = 0.0
        self.calls = []
        self.alerts = []
    
    def log_call(self, model: str, input_tokens: int, output_tokens: int, 
                 task_id: str = None):
        """Log an LLM call."""
        
        cost = self.calculate_cost(model, input_tokens, output_tokens)
        
        self.daily_spent += cost
        self.task_spent += cost
        
        self.calls.append({
            "model": model,
            "input_tokens": input_tokens,
            "output_tokens": output_tokens,
            "cost": cost,
            "task_id": task_id,
            "timestamp": datetime.now()
        })
        
        # Check budget limits
        self.check_budgets()
    
    def calculate_cost(self, model: str, input_tokens: int, output_tokens: int) -> float:
        """Calculate cost for a call."""
        
        pricing = {
            "gpt-4o-mini": {"input": 0.15, "output": 0.60},
            "gpt-4o": {"input": 2.50, "output": 10.00},
            "claude-3-haiku": {"input": 0.25, "output": 1.25},
            "claude-3-sonnet": {"input": 3.00, "output": 15.00}
        }
        
        model_pricing = pricing.get(model, {"input": 2.50, "output": 10.00})
        
        cost = (
            input_tokens * model_pricing["input"] / 1_000_000 +
            output_tokens * model_pricing["output"] / 1_000_000
        )
        
        return cost
    
    def check_budgets(self):
        """Check if budget limits are exceeded."""
        
        # Check task budget
        if self.task_spent > self.task_budget * 0.8:
            self.alerts.append({
                "type": "task_budget_warning",
                "spent": self.task_spent,
                "budget": self.task_budget,
                "timestamp": datetime.now()
            })
        
        if self.task_spent > self.task_budget:
            self.alerts.append({
                "type": "task_budget_exceeded",
                "spent": self.task_spent,
                "budget": self.task_budget,
                "timestamp": datetime.now()
            })
        
        # Check daily budget
        if self.daily_spent > self.daily_budget * 0.8:
            self.alerts.append({
                "type": "daily_budget_warning",
                "spent": self.daily_spent,
                "budget": self.daily_budget,
                "timestamp": datetime.now()
            })
    
    def get_summary(self) -> dict:
        """Get cost summary."""
        
        if not self.calls:
            return {
                "total_spent": 0,
                "daily_spent": self.daily_spent,
                "task_spent": self.task_spent,
                "calls": 0
            }
        
        return {
            "total_spent": sum(c["cost"] for c in self.calls),
            "daily_spent": self.daily_spent,
            "task_spent": self.task_spent,
            "daily_budget_remaining": self.daily_budget - self.daily_spent,
            "task_budget_remaining": self.task_budget - self.task_spent,
            "calls": len(self.calls),
            "avg_cost_per_call": sum(c["cost"] for c in self.calls) / len(self.calls),
            "calls_by_model": self._calls_by_model(),
            "cost_by_model": self._cost_by_model()
        }
    
    def _calls_by_model(self) -> dict:
        """Count calls by model."""
        
        counts = defaultdict(int)
        for call in self.calls:
            counts[call["model"]] += 1
        return dict(counts)
    
    def _cost_by_model(self) -> dict:
        """Calculate cost by model."""
        
        costs = defaultdict(float)
        for call in self.calls:
            costs[call["model"]] += call["cost"]
        return dict(costs)
```

## Cost Optimization Report

### Sample Report

```
Cost Optimization Report
Period: 2025-01-01 to 2025-01-15

=== Summary ===

Total Cost: $125.43
Total Calls: 1,247
Avg Cost per Call: $0.10
Avg Tokens per Call: 2,340

=== Cost Breakdown by Model ===

Model           Calls    Cost       % of Total
─────────────────────────────────────────────
gpt-4o-mini     892      $23.45     18.7%
gpt-4o          355      $101.98    81.3%

=== Optimization Opportunities ===

1. Model Routing
   - Current: 28.5% of calls use gpt-4o
   - Potential: Route 15% more to gpt-4o-mini
   - Estimated Savings: $18.50/month

2. Caching
   - Cache Hit Rate: 32%
   - Potential: Increase to 50% with semantic caching
   - Estimated Savings: $12.00/month

3. Context Compression
   - Avg Context Length: 4,500 tokens
   - Potential: Compress to 2,500 tokens
   - Estimated Savings: $8.50/month

4. Batching
   - Current Batch Size: 1
   - Potential: Batch similar tasks (avg batch size: 5)
   - Estimated Savings: $5.00/month

=== Total Estimated Savings: $44.00/month (35% reduction) ===

=== Recommendations ===

1. Implement intelligent model routing
2. Add semantic caching for repeated queries
3. Enable context compression for long conversations
4. Batch similar tasks when possible
5. Monitor and alert on cost anomalies
```
