# Research Agent Case Study

## Scenario

A research agent that gathers information, synthesizes findings, and produces reports.

## Loop Application

### v1 (Concept)

```
Task: "Research the latest advances in RLHF"

1. Prompt: "Research the latest advances in RLHF"
2. Context: Search arxiv, read papers, check blog posts
3. Plan: [search_papers, read_abstracts, read_top_5, synthesize, write_report]
4. Reason: "15 papers found, 5 highly relevant, 3 have novel contributions"
5. Act: Write summary with citations
6. Observe: Report covers key advances, has 12 citations
7. Store: "RLHF improvements focus on reward model alignment"
```

### v2 (Production)

Same as v1, plus:
- **Permission Gate**: Validates search queries are within scope
- **HITL**: N/A (read-only research)
- **Retry**: If arxiv API times out, retry with backoff
- **Goal Check**: Stop when report has 10+ citations or max 8 cycles
- **Security**: Validates URLs before fetching

### v3 (Autonomous)

Same as v2, plus:
- **Self-Healing**: Falls back to Google Scholar if arxiv is down
- **Adaptive Planning**: Learns "read abstracts first" pattern
- **Cost Optimization**: Uses gpt-4o-mini for summarization, gpt-4o for synthesis
- **Cross-Session Memory**: Remembers "user prefers papers from 2023-2025"
- **Verification**: Validates citations exist before including

## Code Snippet

```python
class ResearchAgent:
    def research(self, topic: str) -> dict:
        """Research a topic and produce a report."""
        
        # Search
        papers = self.tools.search_arxiv(topic, max_results=20)
        
        # Read abstracts
        abstracts = [self.tools.read_abstract(p) for p in papers]
        
        # Select top papers
        top_papers = self.select_top_papers(abstracts, top_k=5)
        
        # Read full papers
        full_papers = [self.tools.read_paper(p) for p in top_papers]
        
        # Synthesize
        synthesis = self.llm.call(f"""
            Synthesize these papers on {topic}:
            {full_papers}
            
            Focus on:
            1. Key contributions
            2. Novel approaches
            3. Results and limitations
        """)
        
        # Write report
        report = self.llm.call(f"""
            Write a research report based on:
            {synthesis}
            
            Include:
            - Executive summary
            - Key findings
            - Detailed analysis
            - Citations
        """)
        
        return {
            "report": report,
            "citations": self.extract_citations(report),
            "paper_count": len(full_papers)
        }
    
    def select_top_papers(self, abstracts: list, top_k: int) -> list:
        """Select most relevant papers."""
        scored = [
            (abstract, self.relevance_score(abstract))
            for abstract in abstracts
        ]
        scored.sort(key=lambda x: x[1], reverse=True)
        return [a for a, s in scored[:top_k]]
```

## Metrics

| Metric | Without Loop | With Loop |
|---|---|---|
| Success rate | 70% | 95% |
| Avg cycles | 1 | 4.1 |
| Avg tokens | 3000 | 12000 |
| Avg cost | $0.08 | $0.35 |
| Citations | 3-5 | 10-15 |

## Lessons Learned

1. **Read abstracts first** — quickly filter relevance before full reads
2. **Cite everything** — credibility requires sources
3. **Check recency** — prefer papers from last 2 years
4. **Balance depth and breadth** — 5 deep reads > 20 shallow reads
