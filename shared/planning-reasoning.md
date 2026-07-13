# Planning & Reasoning Deep Dive

## Reasoning Techniques Overview

| Technique | Description | When to use |
|---|---|---|
| **Chain-of-Thought (CoT)** | Step-by-step reasoning | General problem solving |
| **Tree of Thoughts (ToT)** | Explore multiple reasoning paths | Complex problems with backtracking |
| **Graph of Thoughts (GoT)** | Graph-structured reasoning | Problems with interdependent sub-problems |
| **ReAct** | Reasoning + Acting interleaved | Tasks requiring tool use |
| **Reflexion** | Self-reflect on past actions | Learning from mistakes |
| **Hierarchical Planning** | Break into sub-plans | Large, complex tasks |
| **Meta-Reasoning** | Reason about reasoning | Choosing the right strategy |

## Chain-of-Thought (CoT)

```python
class ChainOfThought:
    def __init__(self, llm):
        self.llm = llm
    
    def reason(self, problem: str) -> dict:
        """Step-by-step reasoning."""
        
        prompt = f"""
        Problem: {problem}
        
        Think through this step by step:
        1. What are the key facts?
        2. What assumptions can I make?
        3. What intermediate conclusions can I draw?
        4. What is the final answer?
        
        Show your reasoning for each step.
        """
        
        response = self.llm.call(prompt)
        
        return {
            "steps": self.extract_steps(response),
            "conclusion": self.extract_conclusion(response),
            "confidence": self.assess_confidence(response)
        }
    
    def extract_steps(self, response: str) -> list:
        """Extract reasoning steps."""
        # Parse numbered steps
        steps = []
        for line in response.split("\n"):
            if line.strip() and line[0].isdigit():
                steps.append(line.strip())
        return steps
```

## Tree of Thoughts (ToT)

```python
class TreeOfThoughts:
    def __init__(self, llm, max_depth: int = 3, branch_factor: int = 3):
        self.llm = llm
        self.max_depth = max_depth
        self.branch_factor = branch_factor
    
    def solve(self, problem: str) -> dict:
        """Solve using tree of thoughts."""
        
        # Initialize root
        root = {"thought": problem, "children": [], "score": 0}
        
        # DFS with pruning
        self.expand(root, depth=0)
        
        # Find best path
        best_path = self.find_best_path(root)
        
        return {
            "solution": best_path[-1]["thought"],
            "path": [n["thought"] for n in best_path],
            "score": best_path[-1]["score"]
        }
    
    def expand(self, node: dict, depth: int):
        """Expand a node."""
        if depth >= self.max_depth:
            return
        
        # Generate thoughts
        thoughts = self.generate_thoughts(node["thought"])
        
        # Evaluate thoughts
        scored_thoughts = [
            {"thought": t, "score": self.evaluate(t), "children": []}
            for t in thoughts[:self.branch_factor]
        ]
        
        node["children"] = scored_thoughts
        
        # Recursively expand promising thoughts
        for child in scored_thoughts:
            if child["score"] > 0.5:  # Pruning threshold
                self.expand(child, depth + 1)
    
    def generate_thoughts(self, current: str) -> list:
        """Generate possible next thoughts."""
        response = self.llm.call(f"""
            Given the current reasoning: {current}
            
            Generate {self.branch_factor} possible next steps.
            Each should be a different approach or perspective.
        """)
        
        return self.parse_thoughts(response)
    
    def evaluate(self, thought: str) -> float:
        """Evaluate a thought's promise."""
        response = self.llm.call(f"""
            Rate how promising this reasoning step is (0-1):
            {thought}
            
            Consider:
            - Is it moving toward a solution?
            - Is it logically sound?
            - Is it making progress?
        """)
        
        return float(response)
    
    def find_best_path(self, root: dict) -> list:
        """Find the best path through the tree."""
        if not root["children"]:
            return [root]
        
        best_child = max(root["children"], key=lambda c: c["score"])
        return [root] + self.find_best_path(best_child)
```

## Graph of Thoughts (GoT)

```python
class GraphOfThoughts:
    def __init__(self, llm):
        self.llm = llm
        self.graph = nx.DiGraph()
        self.node_id = 0
    
    def solve(self, problem: str) -> dict:
        """Solve using graph of thoughts."""
        
        # Initialize
        root_id = self.add_node(problem, thought_type="problem")
        
        # Iteratively build graph
        for iteration in range(5):
            # Generate new thoughts from existing ones
            new_thoughts = self.generate_from_graph()
            
            # Add to graph
            for thought in new_thoughts:
                new_id = self.add_node(thought["content"], thought["type"])
                
                # Connect to source
                self.graph.add_edge(thought["source_id"], new_id)
                
                # Check for merges
                for existing_id in self.graph.nodes():
                    if existing_id != new_id:
                        similarity = self.compute_similarity(
                            self.graph.nodes[new_id]["content"],
                            self.graph.nodes[existing_id]["content"]
                        )
                        if similarity > 0.8:
                            # Merge thoughts
                            merged = self.merge_thoughts(
                                self.graph.nodes[new_id]["content"],
                                self.graph.nodes[existing_id]["content"]
                            )
                            self.graph.nodes[new_id]["content"] = merged
        
        # Find best solution
        solution_nodes = [
            n for n in self.graph.nodes()
            if self.graph.nodes[n]["type"] == "solution"
        ]
        
        if solution_nodes:
            best = max(solution_nodes, key=lambda n: self.score_node(n))
            return {
                "solution": self.graph.nodes[best]["content"],
                "graph": self.graph_to_dict()
            }
        
        return {"solution": None, "graph": self.graph_to_dict()}
    
    def add_node(self, content: str, thought_type: str) -> int:
        """Add node to graph."""
        self.node_id += 1
        self.graph.add_node(self.node_id, content=content, type=thought_type)
        return self.node_id
    
    def merge_thoughts(self, thought_a: str, thought_b: str) -> str:
        """Merge two similar thoughts."""
        return self.llm.call(f"""
            Merge these two thoughts into one:
            A: {thought_a}
            B: {thought_b}
            
            Provide a single, improved thought.
        """)
```

## ReAct (Reasoning + Acting)

```python
class ReActAgent:
    def __init__(self, llm, tools: dict):
        self.llm = llm
        self.tools = tools
    
    def solve(self, problem: str, max_steps: int = 10) -> dict:
        """Solve using ReAct pattern."""
        
        history = []
        
        for step in range(max_steps):
            # Reason
            thought = self.think(problem, history)
            history.append({"type": "thought", "content": thought})
            
            # Decide action
            action = self.decide_action(thought, history)
            history.append({"type": "action", "content": action})
            
            # Execute action
            if action["type"] == "finish":
                return {
                    "solution": action["result"],
                    "history": history
                }
            
            observation = self.execute_action(action)
            history.append({"type": "observation", "content": observation})
        
        return {"solution": None, "history": history}
    
    def think(self, problem: str, history: list) -> str:
        """Generate thought."""
        return self.llm.call(f"""
            Problem: {problem}
            
            History:
            {self.format_history(history)}
            
            What should I think about next?
            Consider what you know, what you've learned, and what you need to find out.
        """)
    
    def decide_action(self, thought: str, history: list) -> dict:
        """Decide next action."""
        return self.llm.call(f"""
            Based on this thought: {thought}
            
            Available tools: {list(self.tools.keys())}
            
            What action should I take?
            Return JSON with:
            - type: "tool" or "finish"
            - tool: tool name (if type is tool)
            - params: parameters (if type is tool)
            - result: final answer (if type is finish)
        """)
    
    def execute_action(self, action: dict) -> str:
        """Execute an action."""
        tool = self.tools[action["tool"]]
        return tool(**action["params"])
```

## Hierarchical Planning

```python
class HierarchicalPlanner:
    def __init__(self, llm, max_levels: int = 3):
        self.llm = llm
        self.max_levels = max_levels
    
    def plan(self, goal: str) -> dict:
        """Create hierarchical plan."""
        
        # Level 0: High-level plan
        high_level = self.create_high_level_plan(goal)
        
        # Level 1: Decompose each high-level step
        level_1 = []
        for step in high_level["steps"]:
            sub_plan = self.decompose(step, level=1)
            level_1.append(sub_plan)
        
        # Level 2: Decompose further if needed
        level_2 = []
        for sub_plan in level_1:
            for step in sub_plan["steps"]:
                if self.needs_decomposition(step):
                    sub_sub_plan = self.decompose(step, level=2)
                    level_2.append(sub_sub_plan)
        
        return {
            "goal": goal,
            "levels": [high_level, level_1, level_2],
            "flat_plan": self.flatten(high_level, level_1, level_2)
        }
    
    def create_high_level_plan(self, goal: str) -> dict:
        """Create high-level plan."""
        return self.llm.call(f"""
            Create a high-level plan for: {goal}
            
            Return 3-5 major steps.
            Each step should be a high-level phase.
        """)
    
    def decompose(self, step: str, level: int) -> dict:
        """Decompose a step into sub-steps."""
        return self.llm.call(f"""
            Decompose this step into {3 + level} sub-steps:
            {step}
            
            Level: {level}
            Be more specific than the parent step.
        """)
    
    def needs_decomposition(self, step: str) -> bool:
        """Check if a step needs further decomposition."""
        return len(step.split()) > 20 or "and" in step.lower()
```

## Reflexion (Self-Reflection)

```python
class ReflexionAgent:
    def __init__(self, llm, max_reflections: int = 3):
        self.llm = llm
        self.max_reflections = max_reflections
    
    def solve(self, problem: str) -> dict:
        """Solve with self-reflection."""
        
        attempts = []
        
        for reflection in range(self.max_reflections):
            # Attempt
            solution = self.attempt(problem, attempts)
            
            # Evaluate
            evaluation = self.evaluate(problem, solution)
            
            attempts.append({
                "solution": solution,
                "evaluation": evaluation
            })
            
            if evaluation["success"]:
                return {
                    "solution": solution,
                    "attempts": len(attempts),
                    "reflections": reflection
                }
            
            # Reflect on failure
            reflection_notes = self.reflect(problem, attempts)
            attempts[-1]["reflection"] = reflection_notes
        
        return {
            "solution": attempts[-1]["solution"],
            "attempts": len(attempts),
            "success": False
        }
    
    def attempt(self, problem: str, past_attempts: list) -> str:
        """Make an attempt, learning from past failures."""
        
        context = ""
        if past_attempts:
            context = f"""
            Past attempts and their failures:
            {self.format_attempts(past_attempts)}
            
            Learn from these failures.
            """
        
        return self.llm.call(f"""
            Problem: {problem}
            {context}
            
            Provide your solution.
        """)
    
    def evaluate(self, problem: str, solution: str) -> dict:
        """Evaluate a solution."""
        return self.llm.call(f"""
            Evaluate this solution:
            Problem: {problem}
            Solution: {solution}
            
            Return JSON with:
            - success: true/false
            - score: 0-1
            - issues: list of problems
        """)
    
    def reflect(self, problem: str, attempts: list) -> str:
        """Reflect on what went wrong."""
        return self.llm.call(f"""
            Reflect on these failed attempts:
            {self.format_attempts(attempts)}
            
            What went wrong? What should be done differently?
            Provide specific, actionable insights.
        """)
```

## Meta-Reasoning

```python
class MetaReasoner:
    def __init__(self, llm):
        self.llm = llm
        self.strategies = {
            "cot": ChainOfThought(llm),
            "tot": TreeOfThoughts(llm),
            "react": ReActAgent(llm, {}),
            "reflexion": ReflexionAgent(llm)
        }
    
    def solve(self, problem: str) -> dict:
        """Solve with meta-reasoning."""
        
        # Analyze problem
        analysis = self.analyze_problem(problem)
        
        # Select strategy
        strategy = self.select_strategy(analysis)
        
        # Execute
        result = self.strategies[strategy].solve(problem)
        
        # Reflect on strategy choice
        meta_reflection = self.meta_reflect(analysis, strategy, result)
        
        return {
            **result,
            "strategy_used": strategy,
            "meta_analysis": analysis,
            "meta_reflection": meta_reflection
        }
    
    def analyze_problem(self, problem: str) -> dict:
        """Analyze problem characteristics."""
        return self.llm.call(f"""
            Analyze this problem:
            {problem}
            
            Return JSON with:
            - complexity: low/medium/high
            - requires_tool_use: true/false
            - requires_exploration: true/false
            - has_clear_solution: true/false
            - estimated_steps: number
        """)
    
    def select_strategy(self, analysis: dict) -> str:
        """Select best strategy for problem."""
        
        if analysis["requires_tool_use"]:
            return "react"
        elif analysis["complexity"] == "high" and analysis["requires_exploration"]:
            return "tot"
        elif not analysis["has_clear_solution"]:
            return "reflexion"
        else:
            return "cot"
    
    def meta_reflect(self, analysis: dict, strategy: str, result: dict) -> str:
        """Reflect on strategy choice."""
        return self.llm.call(f"""
            I chose strategy {strategy} for a problem with analysis:
            {analysis}
            
            The result was:
            {result}
            
            Was this the right strategy choice? What could be improved?
        """)
```
