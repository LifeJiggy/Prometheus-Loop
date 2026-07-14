# Self-Remembering Deep Dive

## Overview

Self-Remembering is the agent's ability to manage its own memory lifecycle — storing relevant information, retrieving it when needed, consolidating knowledge, and forgetting what's no longer useful — all without human curation.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SELF-REMEMBERING SYSTEM                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐        │
│  │  Input   │──▶│ Relevance│──▶│ Storage  │──▶│ Retrieval│        │
│  │ Filter   │   │ Scorer   │   │ Manager  │   │ Engine   │        │
│  └──────────┘   └──────────┘   └──────────┘   └──────────┘        │
│       │              │              │               │                │
│       ▼              ▼              ▼               ▼                │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐        │
│  │  What to │   │ Importance│   │ Memory   │   │  When to │        │
│  │ Remember │   │ Assessment│   │ Types    │   │ Recall   │        │
│  └──────────┘   └──────────┘   └──────────┘   └──────────┘        │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    MEMORY LIFECYCLE                          │   │
│  │  Consolidation │ Forgetting │ Summarization │ Indexing       │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

## Core Implementation

### Input Filter

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
        
        # Check explicit rules
        for rule in self.filter_rules:
            result = rule(content)
            if not result.get("remember", True):
                return {"remember": False, "reason": result.get("reason", "Rule rejected")}
        
        # Check keyword relevance
        content_str = str(content).lower()
        keyword_matches = sum(1 for kw in self.memory_worthy_keywords if kw in content_str)
        
        if keyword_matches > 0:
            return {"remember": True, "relevance": min(keyword_matches / 5, 1.0)}
        
        # Check importance signals
        importance = content.get("importance", 0.5)
        if importance > 0.7:
            return {"remember": True, "relevance": importance}
        
        # Default: don't remember low-importance content
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

### Relevance Scorer

```python
class RelevanceScorer:
    """Scores relevance of content for memory."""
    
    def __init__(self):
        self.scoring_history = []
    
    def score(self, content: dict, context: dict = None) -> float:
        """Score relevance of content."""
        
        score = 0.0
        
        # Factor 1: Explicit importance
        explicit_importance = content.get("importance", 0.5)
        score += explicit_importance * 0.3
        
        # Factor 2: Recency (more recent = more relevant)
        recency = self.calculate_recency(content)
        score += recency * 0.2
        
        # Factor 3: Context match
        if context:
            context_match = self.calculate_context_match(content, context)
            score += context_match * 0.3
        
        # Factor 4: Uniqueness
        uniqueness = self.calculate_uniqueness(content)
        score += uniqueness * 0.2
        
        # Record scoring
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
            
            # Decay over 30 days
            decay_days = 30
            recency = max(0, 1 - age.days / decay_days)
            
            return recency
        except:
            return 0.5
    
    def calculate_context_match(self, content: dict, context: dict) -> float:
        """Calculate how well content matches context."""
        
        content_str = str(content).lower()
        context_str = str(context).lower()
        
        # Simple word overlap
        content_words = set(content_str.split())
        context_words = set(context_str.split())
        
        if not context_words:
            return 0.0
        
        overlap = len(content_words & context_words)
        return min(overlap / len(context_words), 1.0)
    
    def calculate_uniqueness(self, content: dict) -> float:
        """Calculate uniqueness of content."""
        
        content_str = str(content)
        
        # Check against recent scores
        recent_content = [s["content"] for s in self.scoring_history[-100:]]
        
        if not recent_content:
            return 1.0
        
        # Count similar content
        similar_count = sum(1 for c in recent_content if self.is_similar(content_str, c))
        
        # More similar = less unique
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

### Storage Manager

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
        
        # Check capacity
        if len(self.memories) >= self.max_size:
            self.evict()
        
        self.memories.append(memory_entry)
        
        # Update index
        memory_type = memory.get("type", "general")
        if memory_type not in self.index:
            self.index[memory_type] = []
        self.index[memory_type].append(len(self.memories) - 1)
    
    def retrieve(self, query: dict) -> list:
        """Retrieve relevant memories."""
        
        scored = []
        
        for i, memory in enumerate(self.memories):
            score = self.score_relevance(memory, query)
            if score > 0.3:  # Relevance threshold
                scored.append((i, score, memory))
        
        # Sort by score
        scored.sort(key=lambda x: x[1], reverse=True)
        
        # Update access counts
        for idx, _, memory in scored:
            self.memories[idx]["access_count"] += 1
            self.memories[idx]["last_accessed"] = datetime.now().isoformat()
        
        return [memory for _, _, memory in scored[:10]]  # Return top 10
    
    def score_relevance(self, memory: dict, query: dict) -> float:
        """Score relevance of memory to query."""
        
        score = 0.0
        
        # Content match
        memory_str = str(memory).lower()
        query_str = str(query).lower()
        
        memory_words = set(memory_str.split())
        query_words = set(query_str.split())
        
        if query_words:
            word_match = len(memory_words & query_words) / len(query_words)
            score += word_match * 0.5
        
        # Type match
        if memory.get("type") == query.get("type"):
            score += 0.2
        
        # Recency
        recency = self.calculate_recency(memory)
        score += recency * 0.2
        
        # Stored relevance
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
        
        # Sort by relevance and access count
        scored = []
        for i, memory in enumerate(self.memories):
            score = memory.get("relevance", 0.5) * 0.5 + \
                   min(memory.get("access_count", 0) / 10, 0.5)
            scored.append((i, score))
        
        scored.sort(key=lambda x: x[1])
        
        # Remove bottom 10%
        evict_count = max(1, len(self.memories) // 10)
        indices_to_evict = [idx for idx, _ in scored[:evict_count]]
        
        # Remove in reverse order to maintain indices
        for idx in sorted(indices_to_evict, reverse=True):
            del self.memories[idx]
        
        # Rebuild index
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

### Consolidation Engine

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
        
        # Group related memories
        groups = self.group_related(memories)
        
        # Consolidate each group
        consolidated = []
        
        for group in groups:
            if len(group) > 1:
                summary = self.summarize_group(group)
                consolidated.append(summary)
            else:
                consolidated.append(group[0])
        
        # Record consolidation
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
        
        # Type match
        if mem1.get("type") == mem2.get("type"):
            return True
        
        # Content similarity
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
        """Summarize a group of related memories."""
        
        if self.llm:
            return self.summarize_with_llm(group)
        
        # Simple concatenation
        combined = {
            "type": group[0].get("type", "general"),
            "content": f"Summary of {len(group)} related memories",
            "memories": [str(m)[:100] for m in group],
            "consolidated_at": datetime.now().isoformat(),
            "relevance": max(m.get("relevance", 0.5) for m in group)
        }
        
        return combined
    
    def summarize_with_llm(self, group: list) -> dict:
        """Summarize using LLM."""
        
        if not self.llm:
            return self.summarize_group(group)
        
        prompt = f"""
        Summarize these related memories into one concise entry:
        
        {json.dumps(group, indent=2, default=str)}
        
        Return a JSON object with: type, content, key_points, relevance
        """
        
        try:
            response = self.llm.call(prompt)
            return json.loads(response)
        except:
            return self.summarize_group(group)
```

### Main Self-Remembering System

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
        
        # Filter
        filter_result = self.input_filter.should_remember(content)
        
        if not filter_result["remember"]:
            return {"remembered": False, "reason": filter_result.get("reason")}
        
        # Score relevance
        relevance = self.scorer.score(content, context)
        
        # Store
        self.storage.store(content, relevance)
        
        # Record
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
        
        # Replace memories with consolidated version
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

## Usage Examples

### Example 1: Remember and Recall

```python
rememberer = SelfRememberingSystem(llm=my_llm)

# Remember something
rememberer.remember({
    "type": "preference",
    "content": "User prefers dark mode",
    "importance": 0.8,
    "timestamp": datetime.now().isoformat()
})

# Recall relevant memories
memories = rememberer.recall({"type": "preference"})
print(f"Found {len(memories)} relevant memories")
```

### Example 2: Consolidate Memories

```python
# After storing many memories
rememberer.consolidate()

# Check stats
stats = rememberer.get_memory_stats()
print(f"Total memories: {stats['storage']['total_memories']}")
print(f"Utilization: {stats['storage']['utilization']:.1%}")
```

## Best Practices

1. **Filter aggressively** — don't remember everything
2. **Score relevance** — prioritize important information
3. **Consolidate regularly** — merge related memories
4. **Evict stale memories** — keep memory fresh
5. **Index for retrieval** — make memories findable
6. **Export/import** — persist memories across sessions
7. **Monitor memory health** — track utilization and relevance
8. **Privacy-aware** — don't remember sensitive data

## Advanced Memory Patterns

### Memory Consolidation

```python
class MemoryConsolidator:
    """Consolidates related memories for efficiency."""
    
    def __init__(self, llm=None):
        self.llm = llm
        self.consolidation_history = []
    
    def consolidate(self, memories: list) -> list:
        """Consolidate related memories."""
        
        if len(memories) < 3:
            return memories
        
        # Group related memories
        groups = self.group_related(memories)
        
        # Consolidate each group
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

### Memory Search Engine

```python
class MemorySearchEngine:
    """Searches through memories efficiently."""
    
    def __init__(self):
        self.index = {}
        self.search_history = []
    
    def index_memory(self, memory: dict, memory_id: str):
        """Index a memory for search."""
        
        # Extract keywords
        content = str(memory).lower()
        words = set(content.split())
        
        for word in words:
            if len(word) > 3:  # Skip short words
                if word not in self.index:
                    self.index[word] = []
                self.index[word].append(memory_id)
    
    def search(self, query: str, memories: dict) -> list:
        """Search memories by query."""
        
        query_words = set(query.lower().split())
        
        # Find matching memories
        scores = defaultdict(float)
        
        for word in query_words:
            if word in self.index:
                for memory_id in self.index[word]:
                    scores[memory_id] += 1.0
        
        # Sort by score
        sorted_results = sorted(scores.items(), key=lambda x: x[1], reverse=True)
        
        # Return top results
        results = []
        for memory_id, score in sorted_results[:10]:
            if memory_id in memories:
                results.append({
                    "memory": memories[memory_id],
                    "score": score
                })
        
        self.search_history.append({
            "query": query,
            "results_count": len(results),
            "timestamp": datetime.now().isoformat()
        })
        
        return results
    
    def get_search_stats(self) -> dict:
        """Get search statistics."""
        
        return {
            "index_size": len(self.index),
            "total_searches": len(self.search_history)
        }
```

### Forgetting Mechanism

```python
class ForgettingMechanism:
    """Implements forgetting for memory management."""
    
    def __init__(self, decay_rate: float = 0.1):
        self.decay_rate = decay_rate
        self.forgetting_history = []
    
    def should_forget(self, memory: dict) -> bool:
        """Determine if memory should be forgotten."""
        
        # Check age
        stored_at = memory.get("stored_at")
        if stored_at:
            try:
                age = datetime.now() - datetime.fromisoformat(stored_at)
                if age.days > 30:  # Older than 30 days
                    return True
            except:
                pass
        
        # Check access count
        if memory.get("access_count", 0) == 0:
            return True
        
        # Check relevance decay
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

### Memory Validation

```python
class MemoryValidator:
    """Validates memory integrity."""
    
    def __init__(self):
        self.validation_rules = []
        self.validation_history = []
    
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
        
        is_valid = len(violations) == 0
        
        validation = {
            "memory_id": memory.get("id"),
            "valid": is_valid,
            "violations": violations,
            "timestamp": datetime.now().isoformat()
        }
        
        self.validation_history.append(validation)
        
        return validation
    
    def add_default_rules(self):
        """Add default validation rules."""
        
        # Rule: Memory must have content
        self.add_rule(
            lambda m: {"valid": bool(m.get("content")), 
                       "reason": "Memory must have content"}
        )
        
        # Rule: Memory must have type
        self.add_rule(
            lambda m: {"valid": bool(m.get("type")), 
                       "reason": "Memory must have type"}
        )
        
        # Rule: Relevance must be between 0 and 1
        self.add_rule(
            lambda m: {"valid": 0 <= m.get("relevance", 0.5) <= 1, 
                       "reason": "Relevance must be between 0 and 1"}
        )
```

## Integration

| Capability | Integration |
|---|---|
| **Self-Improving** | Learned patterns are remembered |
| **Self-Planning** | Plans are stored for reuse |
| **Self-Adapting** | Adaptation history is remembered |
| **Self-Governing** | Policy violations are recorded |
| **Self-Debugging** | Known fixes are remembered |
