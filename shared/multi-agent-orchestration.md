# Multi-Agent Orchestration Deep Dive

## Communication Patterns

### 1. Request-Response (Synchronous)

```python
class RequestResponseProtocol:
    def __init__(self):
        self.agents = {}
        self.pending_requests = {}
    
    def register_agent(self, agent_id: str, agent):
        """Register an agent."""
        self.agents[agent_id] = agent
    
    def request(self, from_agent: str, to_agent: str, task: dict) -> dict:
        """Send request and wait for response."""
        
        request_id = str(uuid4())
        
        # Store pending request
        self.pending_requests[request_id] = {
            "from": from_agent,
            "to": to_agent,
            "task": task,
            "status": "pending",
            "response": None
        }
        
        # Send to target agent
        agent = self.agents[to_agent]
        response = agent.handle_request(task)
        
        # Update request
        self.pending_requests[request_id]["response"] = response
        self.pending_requests[request_id]["status"] = "completed"
        
        return response
```

### 2. Publish-Subscribe (Asynchronous)

```python
class PubSubProtocol:
    def __init__(self):
        self.subscribers = defaultdict(list)
        self.message_queue = asyncio.Queue()
    
    def subscribe(self, topic: str, agent_id: str, callback: callable):
        """Subscribe to a topic."""
        self.subscribers[topic].append({
            "agent_id": agent_id,
            "callback": callback
        })
    
    async def publish(self, topic: str, message: dict):
        """Publish message to topic."""
        
        # Add to queue
        await self.message_queue.put({
            "topic": topic,
            "message": message,
            "timestamp": datetime.now()
        })
    
    async def process_messages(self):
        """Process messages from queue."""
        
        while True:
            msg = await self.message_queue.get()
            topic = msg["topic"]
            
            # Notify subscribers
            for subscriber in self.subscribers.get(topic, []):
                try:
                    await subscriber["callback"](msg["message"])
                except Exception as e:
                    print(f"Error notifying {subscriber['agent_id']}: {e}")
```

### 3. Message Queue (Decoupled)

```python
class MessageQueueProtocol:
    def __init__(self):
        self.queues = defaultdict(asyncio.Queue)
        self.handlers = {}
    
    def register_handler(self, message_type: str, handler: callable):
        """Register handler for message type."""
        self.handlers[message_type] = handler
    
    async def send(self, queue_name: str, message: dict):
        """Send message to queue."""
        await self.queues[queue_name].put(message)
    
    async def consume(self, queue_name: str):
        """Consume messages from queue."""
        
        while True:
            message = await self.queues[queue_name].get()
            
            handler = self.handlers.get(message["type"])
            if handler:
                await handler(message)
```

### 4. Blackboard (Shared State)

```python
class BlackboardProtocol:
    def __init__(self):
        self.blackboard = {}
        self.lock = asyncio.Lock()
        self.observers = []
    
    async def write(self, agent_id: str, key: str, value: any):
        """Write to blackboard."""
        
        async with self.lock:
            self.blackboard[key] = {
                "value": value,
                "agent": agent_id,
                "timestamp": datetime.now()
            }
            
            # Notify observers
            for observer in self.observers:
                await observer(key, value, agent_id)
    
    async def read(self, key: str) -> any:
        """Read from blackboard."""
        return self.blackboard.get(key, {}).get("value")
    
    async def read_all(self) -> dict:
        """Read entire blackboard."""
        return {k: v["value"] for k, v in self.blackboard.items()}
```

## Consensus Algorithms

### Majority Vote

```python
class MajorityVote:
    def __init__(self, agents: list):
        self.agents = agents
    
    async def reach_consensus(self, proposal: dict) -> dict:
        """Reach consensus through majority vote."""
        
        votes = []
        
        # Collect votes
        for agent in self.agents:
            vote = await agent.vote(proposal)
            votes.append(vote)
        
        # Count votes
        vote_counts = Counter(votes)
        
        # Get majority
        majority = vote_counts.most_common(1)[0]
        
        return {
            "consensus": majority[0],
            "votes_for": majority[1],
            "total_votes": len(votes),
            "details": vote_counts
        }
```

### Weighted Voting

```python
class WeightedVoting:
    def __init__(self, agents: list, weights: dict):
        self.agents = agents
        self.weights = weights
    
    async def reach_consensus(self, proposal: dict) -> dict:
        """Reach consensus through weighted voting."""
        
        votes = {}
        
        for agent in self.agents:
            vote = await agent.vote(proposal)
            weight = self.weights.get(agent.id, 1.0)
            
            if vote not in votes:
                votes[vote] = 0
            votes[vote] += weight
        
        # Get weighted majority
        consensus = max(votes, key=votes.get)
        
        return {
            "consensus": consensus,
            "weighted_score": votes[consensus],
            "details": votes
        }
```

### Byzantine Fault Tolerance

```python
class ByzantineFaultTolerance:
    def __init__(self, agents: list, max_faulty: int):
        self.agents = agents
        self.max_faulty = max_faulty
    
    async def reach_consensus(self, proposal: dict) -> dict:
        """Reach consensus with Byzantine fault tolerance."""
        
        # Need 2f+1 votes where f is max faulty
        required_votes = 2 * self.max_faulty + 1
        
        if len(self.agents) < required_votes:
            raise ValueError("Not enough agents for BFT")
        
        # Collect votes
        votes = []
        for agent in self.agents:
            vote = await agent.vote(proposal)
            votes.append(vote)
        
        # Check for consensus
        vote_counts = Counter(votes)
        
        for vote, count in vote_counts.items():
            if count >= required_votes:
                return {
                    "consensus": vote,
                    "votes_for": count,
                    "required": required_votes,
                    "fault_tolerant": True
                }
        
        return {
            "consensus": None,
            "fault_tolerant": False
        }
```

## Conflict Resolution

### Operational Transformation

```python
class OperationalTransformation:
    def transform(self, op1: dict, op2: dict) -> dict:
        """Transform conflicting operations."""
        
        if op1["type"] == "insert" and op2["type"] == "insert":
            # Both inserting at same position
            if op1["position"] <= op2["position"]:
                return op2  # op2 goes after op1
            else:
                return op1  # op1 goes after op2
        
        elif op1["type"] == "delete" and op2["type"] == "insert":
            # Delete and insert at same position
            if op1["position"] < op2["position"]:
                return op2  # Insert after delete
            elif op1["position"] > op2["position"]:
                return op1  # Delete after insert
            else:
                return None  # Conflict - need resolution
        
        # Default: no transformation needed
        return op2
```

### Conflict-Free Replicated Data Types (CRDTs)

```python
class LWWRegister:
    """Last-Writer-Wins Register CRDT."""
    
    def __init__(self):
        self.value = None
        self.timestamp = 0
    
    def set(self, value: any, timestamp: int):
        """Set value if timestamp is newer."""
        if timestamp > self.timestamp:
            self.value = value
            self.timestamp = timestamp
    
    def get(self) -> any:
        """Get current value."""
        return self.value
    
    def merge(self, other: 'LWWRegister'):
        """Merge with another register."""
        if other.timestamp > self.timestamp:
            self.value = other.value
            self.timestamp = other.timestamp


class GCounter:
    """Grow-Only Counter CRDT."""
    
    def __init__(self, node_id: str):
        self.node_id = node_id
        self.counts = defaultdict(int)
    
    def increment(self):
        """Increment counter."""
        self.counts[self.node_id] += 1
    
    def get(self) -> int:
        """Get current count."""
        return sum(self.counts.values())
    
    def merge(self, other: 'GCounter'):
        """Merge with another counter."""
        for node_id, count in other.counts.items():
            self.counts[node_id] = max(self.counts[node_id], count)
```

### Merge Strategies

```python
class MergeStrategy:
    def merge(self, local: dict, remote: dict) -> dict:
        """Merge local and remote states."""
        raise NotImplementedError


class ThreeWayMerge(MergeStrategy):
    def merge(self, local: dict, remote: dict, base: dict) -> dict:
        """Three-way merge."""
        
        merged = {}
        
        all_keys = set(list(local.keys()) + list(remote.keys()) + list(base.keys()))
        
        for key in all_keys:
            local_val = local.get(key)
            remote_val = remote.get(key)
            base_val = base.get(key)
            
            if local_val == remote_val:
                # Both same - no conflict
                merged[key] = local_val
            elif local_val == base_val:
                # Local unchanged - use remote
                merged[key] = remote_val
            elif remote_val == base_val:
                # Remote unchanged - use local
                merged[key] = local_val
            else:
                # Both changed - conflict
                merged[key] = self.resolve_conflict(local_val, remote_val)
        
        return merged
    
    def resolve_conflict(self, local: any, remote: any) -> any:
        """Resolve conflict between local and remote."""
        # Default: use local value
        # Override with custom logic
        return local
```

## Coordination Protocols

### Leader Election

```python
class LeaderElection:
    def __init__(self, agents: list):
        self.agents = agents
        self.leader = None
    
    async def elect_leader(self) -> str:
        """Elect a leader using Bully algorithm."""
        
        # Each agent announces its ID
        announcements = []
        for agent in self.agents:
            announcements.append({
                "id": agent.id,
                "timestamp": datetime.now()
            })
        
        # Highest ID wins
        leader = max(announcements, key=lambda x: x["id"])
        
        self.leader = leader["id"]
        
        # Notify all agents
        for agent in self.agents:
            await agent.notify_leader(self.leader)
        
        return self.leader
    
    async def handle_leader_failure(self, failed_leader: str):
        """Handle leader failure."""
        
        if self.leader == failed_leader:
            # Re-elect
            await self.elect_leader()
```

### Distributed Lock

```python
class DistributedLock:
    def __init__(self, redis_client):
        self.redis = redis_client
    
    async def acquire(self, resource: str, timeout: int = 10) -> bool:
        """Acquire distributed lock."""
        
        lock_key = f"lock:{resource}"
        
        # Try to set lock
        acquired = await self.redis.set(
            lock_key,
            str(uuid4()),
            nx=True,  # Only if not exists
            ex=timeout
        )
        
        return acquired
    
    async def release(self, resource: str):
        """Release distributed lock."""
        
        lock_key = f"lock:{resource}"
        await self.redis.delete(lock_key)
    
    async def with_lock(self, resource: str, func: callable):
        """Execute function with lock."""
        
        acquired = await self.acquire(resource)
        
        if not acquired:
            raise TimeoutError("Could not acquire lock")
        
        try:
            return await func()
        finally:
            await self.release(resource)
```

### Consensus (Raft-like)

```python
class RaftConsensus:
    def __init__(self, node_id: str, peers: list):
        self.node_id = node_id
        self.peers = peers
        self.state = "follower"
        self.current_term = 0
        self.voted_for = None
        self.log = []
    
    async def start_election(self):
        """Start leader election."""
        
        self.state = "candidate"
        self.current_term += 1
        self.voted_for = self.node_id
        
        votes = 1  # Vote for self
        
        # Request votes from peers
        for peer in self.peers:
            vote = await self.request_vote(peer)
            if vote:
                votes += 1
        
        # Check if won election
        if votes > len(self.peers) / 2:
            self.state = "leader"
            await self.announce_leader()
        else:
            self.state = "follower"
    
    async def request_vote(self, peer: str) -> bool:
        """Request vote from peer."""
        
        # Send vote request
        response = await self.send_to_peer(peer, {
            "type": "vote_request",
            "term": self.current_term,
            "candidate_id": self.node_id
        })
        
        return response.get("vote_granted", False)
    
    async def append_entries(self, entries: list):
        """Append entries to log (leader only)."""
        
        if self.state != "leader":
            raise RuntimeError("Only leader can append entries")
        
        # Add to local log
        for entry in entries:
            self.log.append({
                "term": self.current_term,
                "entry": entry
            })
        
        # Replicate to peers
        for peer in self.peers:
            await self.replicate_to_peer(peer)
```
