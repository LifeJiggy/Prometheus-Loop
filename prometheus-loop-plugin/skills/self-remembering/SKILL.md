---
name: self-remembering
description: Memory lifecycle management - store, retrieve, consolidate, and forget intelligently
---

# Self-Remembering

The agent's ability to manage its own memory lifecycle — storing relevant information, retrieving it when needed, consolidating knowledge, and forgetting what's no longer useful.

## Quick Start

When the user asks about agent memory:

1. **Filter** — decide what to remember
2. **Score** — assess relevance
3. **Store** — save to memory
4. **Retrieve** — find relevant memories
5. **Consolidate** — merge related memories
6. **Forget** — remove stale memories

---

## Architecture

```
New Content → Filter → Score Relevance → Above Threshold? → Store Memory → Update Index
                                         ↓ No
                                    Discard                    ↓ Memory Full?
                                                          Consolidate → Evict Old
```

---

## Input Filter

```python
class InputFilter:
    """Filters what should be remembered."""
    
    def __init__(self):
        self.filter_rules = []
        self.memory_worthy_keywords = [
            "important", "remember", "note", "key", "critical",
            "decision", "preference", "pattern", "lesson", "insight"
        ]
    
    def add_rule(self, rule: callable):
        """Add a filter rule."""
        self.filter_rules.append(rule)
    
    def should_remember(self, content: dict) -> dict:
        """Determine if content should be remembered."""
        
        for rule in self.filter_rules:
            result = rule(content)
            if not result.get("remember", True):
                return {"remember": False, "reason": result.get("reason", "Rule rejected")}
        
        content_str = str(content).lower()
        keyword_matches = sum(1 for kw in self.memory_worthy_keywords if kw in content_str)
        
        if keyword_matches > 0:
            return {"remember": True, "relevance": min(keyword_matches / 5, 1.0)}
        
        importance = content.get("importance", 0.5)
        if importance > 0.7:
            return {"remember": True, "relevance": importance}
        
        return {"remember": importance > 0.3, "relevance": importance}
    
    def filter_batch(self, items: list) -> list:
        """Filter a batch of items."""
        
        filtered = []
        
        for item in items:
            result = self.should_remember(item)
            if result["remember"]:
                filtered.append({
                    "content": item,
                    "relevance": result.get("relevance", 0.5)
                })
        
        return filtered
```

---

## Relevance Scorer

```python
class RelevanceScorer:
    """Scores relevance of content for memory."""
    
    def __init__(self):
        self.scoring_history = []
    
    def score(self, content: dict, context: dict = None) -> float:
        """Score relevance of content."""
        
        score = 0.0
        
        explicit_importance = content.get("importance", 0.5)
        score += explicit_importance * 0.3
        
        recency = self.calculate_recency(content)
        score += recency * 0.2
        
        if context:
            context_match = self.calculate_context_match(content, context)
            score += context_match * 0.3
        
        uniqueness = self.calculate_uniqueness(content)
        score += uniqueness * 0.2
        
        self.scoring_history.append({
            "content": str(content)[:100],
            "score": score,
            "timestamp": datetime.now().isoformat()
        })
        
        return min(max(score, 0.0), 1.0)
    
    def calculate_recency(self, content: dict) -> float:
        """Calculate recency score."""
        
        timestamp = content.get("timestamp")
        if not timestamp:
            return 0.5
        
        try:
            content_time = datetime.fromisoformat(timestamp)
            age = datetime.now() - content_time
            
            decay_days = 30
            recency = max(0, 1 - age.days / decay_days)
            
            return recency
        except:
            return 0.5
    
    def calculate_context_match(self, content: dict, context: dict) -> float:
        """Calculate how well content matches context."""
        
        content_str = str(content).lower()
        context_str = str(context).lower()
        
        content_words = set(content_str.split())
        context_words = set(context_str.split())
        
        if not context_words:
            return 0.0
        
        overlap = len(content_words & context_words)
        return min(overlap / len(context_words), 1.0)
    
    def calculate_uniqueness(self, content: dict) -> float:
        """Calculate uniqueness of content."""
        
        content_str = str(content)
        
        recent_content = [s["content"] for s in self.scoring_history[-100:]]
        
        if not recent_content:
            return 1.0
        
        similar_count = sum(1 for c in recent_content if self.is_similar(content_str, c))
        
        uniqueness = 1 - (similar_count / len(recent_content))
        
        return max(uniqueness, 0.1)
    
    def is_similar(self, text1: str, text2: str) -> bool:
        """Check if two texts are similar."""
        
        words1 = set(text1.lower().split())
        words2 = set(text2.lower().split())
        
        if not words1 or not words2:
            return False
        
        overlap = len(words1 & words2) / max(len(words1), len(words2))
        return overlap > 0.7
```

---

## Storage Manager

```python
class StorageManager:
    """Manages memory storage."""
    
    def __init__(self, max_size: int = 10000):
        self.max_size = max_size
        self.memories = []
        self.index = {}
    
    def store(self, memory: dict, relevance: float = 0.5):
        """Store a memory."""
        
        memory_entry = {
            **memory,
            "relevance": relevance,
            "stored_at": datetime.now().isoformat(),
            "access_count": 0,
            "last_accessed": None
        }
        
        if len(self.memories) >= self.max_size:
            self.evict()
        
        self.memories.append(memory_entry)
        
        memory_type = memory.get("type", "general")
        if memory_type not in self.index:
            self.index[memory_type] = []
        self.index[memory_type].append(len(self.memories) - 1)
    
    def retrieve(self, query: dict) -> list:
        """Retrieve relevant memories."""
        
        scored = []
        
        for i, memory in enumerate(self.memories):
            score = self.score_relevance(memory, query)
            if score > 0.3:
                scored.append((i, score, memory))
        
        scored.sort(key=lambda x: x[1], reverse=True)
        
        for idx, _, memory in scored:
            self.memories[idx]["access_count"] += 1
            self.memories[idx]["last_accessed"] = datetime.now().isoformat()
        
        return [memory for _, _, memory in scored[:10]]
    
    def score_relevance(self, memory: dict, query: dict) -> float:
        """Score relevance of memory to query."""
        
        score = 0.0
        
        memory_str = str(memory).lower()
        query_str = str(query).lower()
        
        memory_words = set(memory_str.split())
        query_words = set(query_str.split())
        
        if query_words:
            word_match = len(memory_words & query_words) / len(query_words)
            score += word_match * 0.5
        
        if memory.get("type") == query.get("type"):
            score += 0.2
        
        recency = self.calculate_recency(memory)
        score += recency * 0.2
        
        score += memory.get("relevance", 0.5) * 0.1
        
        return min(score, 1.0)
    
    def calculate_recency(self, memory: dict) -> float:
        """Calculate recency score."""
        
        try:
            stored_at = datetime.fromisoformat(memory["stored_at"])
            age = datetime.now() - stored_at
            return max(0, 1 - age.days / 30)
        except:
            return 0.5
    
    def evict(self):
        """Evict least relevant memories."""
        
        scored = []
        for i, memory in enumerate(self.memories):
            score = memory.get("relevance", 0.5) * 0.5 + \
                   min(memory.get("access_count", 0) / 10, 0.5)
            scored.append((i, score))
        
        scored.sort(key=lambda x: x[1])
        
        evict_count = max(1, len(self.memories) // 10)
        indices_to_evict = [idx for idx, _ in scored[:evict_count]]
        
        for idx in sorted(indices_to_evict, reverse=True):
            del self.memories[idx]
        
        self.rebuild_index()
    
    def rebuild_index(self):
        """Rebuild the memory index."""
        
        self.index = defaultdict(list)
        
        for i, memory in enumerate(self.memories):
            memory_type = memory.get("type", "general")
            self.index[memory_type].append(i)
    
    def get_stats(self) -> dict:
        """Get storage statistics."""
        
        return {
            "total_memories": len(self.memories),
            "max_size": self.max_size,
            "utilization": len(self.memories) / self.max_size,
            "types": {t: len(indices) for t, indices in self.index.items()},
            "avg_relevance": sum(m.get("relevance", 0) for m in self.memories) / len(self.memories) if self.memories else 0
        }
```

---

## Forgetting Mechanism

```python
class ForgettingMechanism:
    """Implements forgetting for memory management."""
    
    def __init__(self, decay_rate: float = 0.1):
        self.decay_rate = decay_rate
        self.forgetting_history = []
    
    def should_forget(self, memory: dict) -> bool:
        """Determine if memory should be forgotten."""
        
        stored_at = memory.get("stored_at")
        if stored_at:
            try:
                age = datetime.now() - datetime.fromisoformat(stored_at)
                if age.days > 30:
                    return True
            except:
                pass
        
        if memory.get("access_count", 0) == 0:
            return True
        
        relevance = memory.get("relevance", 0.5)
        if relevance < 0.2:
            return True
        
        return False
    
    def apply_decay(self, memory: dict) -> dict:
        """Apply relevance decay to a memory."""
        
        current_relevance = memory.get("relevance", 0.5)
        new_relevance = current_relevance * (1 - self.decay_rate)
        
        memory["relevance"] = max(0, new_relevance)
        memory["last_decayed"] = datetime.now().isoformat()
        
        return memory
    
    def batch_decay(self, memories: list) -> list:
        """Apply decay to a batch of memories."""
        
        decayed = []
        forgotten = []
        
        for memory in memories:
            if self.should_forget(memory):
                forgotten.append(memory)
            else:
                decayed.append(self.apply_decay(memory))
        
        self.forgetting_history.append({
            "input_count": len(memories),
            "kept_count": len(decayed),
            "forgotten_count": len(forgotten),
            "timestamp": datetime.now().isoformat()
        })
        
        return decayed
```

---

## Consolidation Engine

```python
class ConsolidationEngine:
    """Consolidates related memories."""
    
    def __init__(self, llm=None):
        self.llm = llm
        self.consolidation_history = []
    
    def consolidate(self, memories: list) -> list:
        """Consolidate related memories."""
        
        if len(memories) < 3:
            return memories
        
        groups = self.group_related(memories)
        
        consolidated = []
        for group in groups:
            if len(group) > 1:
                summary = self.summarize_group(group)
                consolidated.append(summary)
            else:
                consolidated.append(group[0])
        
        self.consolidation_history.append({
            "input_count": len(memories),
            "output_count": len(consolidated),
            "timestamp": datetime.now().isoformat()
        })
        
        return consolidated
    
    def group_related(self, memories: list) -> list:
        """Group related memories."""
        
        groups = []
        used = set()
        
        for i, mem1 in enumerate(memories):
            if i in used:
                continue
            
            group = [mem1]
            used.add(i)
            
            for j, mem2 in enumerate(memories):
                if j in used:
                    continue
                
                if self.are_related(mem1, mem2):
                    group.append(mem2)
                    used.add(j)
            
            groups.append(group)
        
        return groups
    
    def are_related(self, mem1: dict, mem2: dict) -> bool:
        """Check if two memories are related."""
        
        if mem1.get("type") == mem2.get("type"):
            return True
        
        str1 = str(mem1).lower()
        str2 = str(mem2).lower()
        
        words1 = set(str1.split())
        words2 = set(str2.split())
        
        if words1 and words2:
            overlap = len(words1 & words2) / max(len(words1), len(words2))
            if overlap > 0.5:
                return True
        
        return False
    
    def summarize_group(self, group: list) -> dict:
        """Summarize a group of memories."""
        
        if self.llm:
            return self.summarize_with_llm(group)
        
        return {
            "type": group[0].get("type", "general"),
            "content": f"Summary of {len(group)} related memories",
            "memories": [str(m)[:100] for m in group],
            "consolidated_at": datetime.now().isoformat()
        }
    
    def summarize_with_llm(self, group: list) -> dict:
        """Summarize using LLM."""
        
        if not self.llm:
            return self.summarize_group(group)
        
        prompt = f"""
        Summarize these related memories:
        {json.dumps(group, indent=2, default=str)}
        
        Return JSON with: type, content, key_points
        """
        
        try:
            response = self.llm.call(prompt)
            return json.loads(response)
        except:
            return self.summarize_group(group)
```

---

## Main Self-Remembering System

```python
class SelfRememberingSystem:
    """Main self-remembering orchestrator."""
    
    def __init__(self, llm=None):
        self.input_filter = InputFilter()
        self.scorer = RelevanceScorer()
        self.storage = StorageManager()
        self.consolidator = ConsolidationEngine(llm)
        self.remembering_history = []
    
    def remember(self, content: dict, context: dict = None) -> dict:
        """Decide whether to remember content and store it."""
        
        filter_result = self.input_filter.should_remember(content)
        
        if not filter_result["remember"]:
            return {"remembered": False, "reason": filter_result.get("reason")}
        
        relevance = self.scorer.score(content, context)
        
        self.storage.store(content, relevance)
        
        record = {
            "content": str(content)[:100],
            "relevance": relevance,
            "remembered": True,
            "timestamp": datetime.now().isoformat()
        }
        
        self.remembering_history.append(record)
        
        return {
            "remembered": True,
            "relevance": relevance,
            "storage_stats": self.storage.get_stats()
        }
    
    def recall(self, query: dict) -> list:
        """Recall relevant memories."""
        return self.storage.retrieve(query)
    
    def consolidate(self):
        """Consolidate stored memories."""
        
        consolidated = self.consolidator.consolidate(self.storage.memories)
        
        self.storage.memories = consolidated
        self.storage.rebuild_index()
    
    def get_memory_stats(self) -> dict:
        """Get memory statistics."""
        
        return {
            "storage": self.storage.get_stats(),
            "total_remembered": len(self.remembering_history),
            "consolidations": len(self.consolidator.consolidation_history)
        }
    
    def export_memories(self) -> dict:
        """Export memories for persistence."""
        
        return {
            "memories": self.storage.memories,
            "stats": self.storage.get_stats(),
            "consolidation_history": self.consolidator.consolidation_history
        }
    
    def import_memories(self, data: dict):
        """Import memories from persistence."""
        
        self.storage.memories = data.get("memories", [])
        self.storage.rebuild_index()
```

---

## Usage Examples

### Remember and Recall

```python
rememberer = SelfRememberingSystem(llm=my_llm)

rememberer.remember({
    "type": "preference",
    "content": "User prefers dark mode",
    "importance": 0.8,
    "timestamp": datetime.now().isoformat()
})

memories = rememberer.recall({"type": "preference"})
print(f"Found {len(memories)} relevant memories")
```

### Consolidate Memories

```python
rememberer.consolidate()

stats = rememberer.get_memory_stats()
print(f"Total memories: {stats['storage']['total_memories']}")
print(f"Utilization: {stats['storage']['utilization']:.1%}")
```

### Export and Import

```python
# Export
data = rememberer.export_memories()

# Import in new session
new_rememberer = SelfRememberingSystem()
new_rememberer.import_memories(data)
```

---

## Best Practices

1. **Filter aggressively** — don't remember everything
2. **Score relevance** — prioritize important information
3. **Consolidate regularly** — merge related memories
4. **Evict stale memories** — keep memory fresh
5. **Index for retrieval** — make memories findable
6. **Export/import** — persist memories across sessions
7. **Monitor memory health** — track utilization and relevance
8. **Privacy-aware** — don't remember sensitive data

---

## Integration

| Capability | How it integrates |
|---|---|
| **Self-Improving** | Learned patterns are remembered |
| **Self-Planning** | Plans are stored for reuse |
| **Self-Adapting** | Adaptation history is remembered |
| **Self-Governing** | Policy violations are recorded |
| **Self-Debugging** | Known fixes are remembered |

---

## Advanced Memory Patterns

### Memory Consolidation Strategies

**Strategy 1: Time-based consolidation**
- Consolidate memories older than 7 days
- Keep recent memories separate
- Merge related old memories

**Strategy 2: Access-based consolidation**
- Consolidate rarely accessed memories
- Keep frequently accessed memories separate
- Priority based on access count

**Strategy 3: Relevance-based consolidation**
- Consolidate low-relevance memories
- Keep high-relevance memories separate
- Priority based on relevance score

### Memory Validation

```python
class MemoryValidator:
    """Validates memory integrity."""
    
    def __init__(self):
        self.validation_rules = []
    
    def add_rule(self, rule: callable):
        """Add a validation rule."""
        self.validation_rules.append(rule)
    
    def validate(self, memory: dict) -> dict:
        """Validate a memory."""
        
        violations = []
        
        for rule in self.validation_rules:
            result = rule(memory)
            if not result.get("valid", True):
                violations.append(result)
        
        return {
            "valid": len(violations) == 0,
            "violations": violations
        }
    
    def add_default_rules(self):
        """Add default validation rules."""
        
        self.validation_rules.append(
            lambda m: {"valid": bool(m.get("content")), "reason": "Memory must have content"}
        )
        self.validation_rules.append(
            lambda m: {"valid": bool(m.get("type")), "reason": "Memory must have type"}
        )
        self.validation_rules.append(
            lambda m: {"valid": 0 <= m.get("relevance", 0.5) <= 1, 
                       "reason": "Relevance must be between 0 and 1"}
        )
```

### Memory Search Optimization

```python
class MemorySearchOptimizer:
    """Optimizes memory search performance."""
    
    def __init__(self):
        self.search_cache = {}
        self.search_stats = defaultdict(int)
    
    def optimize_search(self, query: dict, memories: list) -> list:
        """Optimize memory search."""
        
        # Check cache first
        cache_key = str(sorted(query.items()))
        if cache_key in self.search_cache:
            self.search_stats["cache_hit"] += 1
            return self.search_cache[cache_key]
        
        # Perform search
        results = self.search(query, memories)
        
        # Cache results
        self.search_cache[cache_key] = results
        self.search_stats["cache_miss"] += 1
        
        return results
    
    def search(self, query: dict, memories: list) -> list:
        """Search memories."""
        
        results = []
        
        for memory in memories:
            score = self.calculate_relevance(query, memory)
            if score > 0.3:
                results.append({"memory": memory, "score": score})
        
        results.sort(key=lambda x: x["score"], reverse=True)
        
        return results[:10]
    
    def calculate_relevance(self, query: dict, memory: dict) -> float:
        """Calculate relevance score."""
        
        score = 0.0
        
        # Type match
        if query.get("type") == memory.get("type"):
            score += 0.3
        
        # Content similarity
        query_words = set(str(query).lower().split())
        memory_words = set(str(memory).lower().split())
        if query_words:
            overlap = len(query_words & memory_words) / len(query_words)
            score += overlap * 0.5
        
        # Recency
        if memory.get("stored_at"):
            try:
                age = (datetime.now() - datetime.fromisoformat(memory["stored_at"])).days
                recency = max(0, 1 - age / 30)
                score += recency * 0.2
            except:
                pass
        
        return min(score, 1.0)
```

### Memory Safety Rules

1. **Don't store sensitive data** — passwords, keys, tokens
2. **Validate before storing** — check format and content
3. **Encrypt sensitive memories** — if must store sensitive data
4. **Implement access controls** — who can read/write memories
5. **Audit memory access** — log who accessed what
6. **Regular cleanup** — remove stale and invalid memories
7. **Backup important memories** — prevent data loss
8. **Test memory operations** — verify store/retrieve works

### Memory Metrics

| Metric | Description | Target |
|---|---|---|
| Memory utilization | % of capacity used | 50-80% |
| Retrieval accuracy | % relevant memories retrieved | > 80% |
| Consolidation rate | Memories consolidated per session | > 20% |
| Forgetting rate | Memories forgotten per session | 5-15% |
| Search latency | Time to retrieve memories | < 100ms |

### Common Memory Pitfalls

| Pitfall | Description | Prevention |
|---|---|---|
| Memory bloat | Too many memories stored | Regular consolidation and pruning |
| Stale memories | Outdated information | Time-based decay |
| Privacy leakage | Sensitive data stored | Data classification and filtering |
| Search inefficiency | Slow memory retrieval | Indexing and caching |
| Consolidation loss | Important information lost | Priority-based consolidation |

---

## Further Reading

- **Memory Systems** — Vector stores, graph memory, summarization
- **Self-Improving** — Learning from remembered patterns
- **Production Concerns** — Memory persistence in production
- **Self-Governing** — Memory access controls
- **Self-Debugging** — Using memory for debugging
