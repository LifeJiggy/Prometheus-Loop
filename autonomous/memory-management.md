# Memory Management Deep Dive

## Memory Types

### 1. Working Memory

**Purpose:** Current task context  
**Lifetime:** Session only  
**Size:** Limited by context window

```python
class WorkingMemory:
    def __init__(self, max_tokens=4000):
        self.max_tokens = max_tokens
        self.entries = []
    
    def add(self, entry: dict, tokens: int):
        """Add entry to working memory."""
        
        self.entries.append(entry)
        
        # Evict if over budget
        total_tokens = sum(e.get("tokens", 0) for e in self.entries)
        while total_tokens > self.max_tokens:
            removed = self.entries.pop(0)
            total_tokens -= removed.get("tokens", 0)
    
    def get_context(self) -> list:
        """Get current working memory."""
        return self.entries
```

### 2. Episodic Memory

**Purpose:** Past experiences  
**Lifetime:** Long-term  
**Size:** Large (persistent storage)

```python
class EpisodicMemory:
    def __init__(self):
        self.episodes = []
    
    def record(self, episode: dict):
        """Record an episode."""
        
        self.episodes.append({
            **episode,
            "timestamp": datetime.now().isoformat(),
            "importance": episode.get("importance", 0.5)
        })
    
    def recall(self, query: str, top_k: int = 5) -> list:
        """Recall relevant episodes."""
        
        scored = []
        for episode in self.episodes:
            score = self.score_relevance(episode, query)
            scored.append((score, episode))
        
        scored.sort(key=lambda x: x[0], reverse=True)
        return [episode for _, episode in scored[:top_k]]
    
    def score_relevance(self, episode: dict, query: str) -> float:
        """Score relevance of episode to query."""
        
        # Simple keyword matching
        query_words = set(query.lower().split())
        episode_words = set(str(episode).lower().split())
        
        overlap = len(query_words & episode_words)
        return overlap / max(len(query_words), 1)
```

### 3. Semantic Memory

**Purpose:** Facts and knowledge  
**Lifetime:** Persistent  
**Size:** Large (vector store)

```python
class SemanticMemory:
    def __init__(self):
        self.knowledge = {}
    
    def store(self, key: str, value: any, metadata: dict = None):
        """Store knowledge."""
        
        self.knowledge[key] = {
            "value": value,
            "metadata": metadata or {},
            "stored_at": datetime.now().isoformat(),
            "access_count": 0
        }
    
    def retrieve(self, query: str) -> any:
        """Retrieve knowledge."""
        
        # Simple keyword matching
        for key, entry in self.knowledge.items():
            if query.lower() in key.lower():
                entry["access_count"] += 1
                return entry["value"]
        
        return None
    
    def consolidate(self):
        """Consolidate old knowledge."""
        
        # Remove low-access knowledge
        to_remove = []
        for key, entry in self.knowledge.items():
            if entry["access_count"] == 0:
                age = datetime.now() - datetime.fromisoformat(entry["stored_at"])
                if age.days > 30:
                    to_remove.append(key)
        
        for key in to_remove:
            del self.knowledge[key]
```

## Memory Consolidation

```python
def consolidate_memories(working: WorkingMemory, episodic: EpisodicMemory, 
                        semantic: SemanticMemory):
    """Consolidate memories across types."""
    
    # Move important working memories to episodic
    for entry in working.get_context():
        if entry.get("importance", 0) > 0.7:
            episodic.record(entry)
    
    # Extract facts from episodic memory
    for episode in episodic.episodes:
        if episode.get("importance", 0) > 0.8:
            # Extract key facts
            facts = extract_facts(episode)
            for fact in facts:
                semantic.store(fact["key"], fact["value"])
    
    # Consolidate old memories
    episodic.consolidate()
    semantic.consolidate()
```

## Forgetting Mechanisms

```python
def forget_old_memories(episodic: EpisodicMemory, semantic: SemanticMemory):
    """Forget old, low-importance memories."""
    
    # Forget old episodic memories
    cutoff = datetime.now() - timedelta(days=90)
    episodic.episodes = [
        e for e in episodic.episodes
        if datetime.fromisoformat(e["timestamp"]) > cutoff
        or e.get("importance", 0) > 0.8
    ]
    
    # Forget low-access semantic knowledge
    to_remove = []
    for key, entry in semantic.knowledge.items():
        if entry["access_count"] < 3:
            to_remove.append(key)
    
    for key in to_remove:
        del semantic.knowledge[key]
```

## Memory Best Practices

1. **Separate concerns** — different memory types for different purposes
2. **Consolidate regularly** — merge related memories
3. **Forget strategically** — remove low-value, old memories
4. **Index for retrieval** — make memories findable
5. **Validate before storing** — ensure quality
6. **Encrypt sensitive data** — protect privacy
7. **Backup important memories** — prevent loss
8. **Monitor memory health** — track utilization and performance
