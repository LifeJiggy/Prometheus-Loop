# Frequently Asked Questions

## General

### What is Prometheus Loop?
Prometheus Loop is a comprehensive framework for building, teaching, and reasoning about agentic AI systems. It provides three maturity levels (Concept, Production, Autonomous), 13 self-* capabilities, and implementations for 18+ CLI/IDE tools.

### Who is this for?
- **AI engineers** building agent systems
- **ML researchers** studying agentic AI
- **Engineering managers** deploying agents
- **Students** learning about AI
- **Security engineers** hardening agents

### Is it free?
Yes, Prometheus Loop is open source under the MIT License.

## Technical

### How do I install it?
```bash
# Linux/macOS
bash prometheus-loop-plugin/scripts/install.sh --all

# Windows
.\prometheus-loop-plugin\scripts\install.ps1 -All

# Python (cross-platform)
python prometheus-loop-plugin/scripts/install.py --all
```

### Which CLI/IDE tools are supported?
18+ tools including: Claude Code, Codex CLI, OpenCode, KiloCode, Kimi Code, Hermes Agent, Aider, Gemini CLI, Goose, Cursor, Windsurf, Cline, Roo Code, Continue, Zed, Sourcegraph Cody, GitHub Copilot, and JetBrains AI.

### What are the self-* capabilities?
13 autonomous capabilities: Self-Healing, Self-Retry, Self-Improving, Self-Monitoring, Self-Debugging, Self-Refactoring, Self-Evolution, Self-Observing, Self-Planning, Self-Adapting, Self-Governing, Self-Remembering, and Multi-Agent Orchestration.

### How do I contribute?
See [CONTRIBUTING.md](../CONTRIBUTING.md) for contribution guidelines.

## Troubleshooting

### The plugin isn't loading
1. Restart your CLI/IDE
2. Check installation logs for errors
3. Verify the skills directory exists
4. Try reinstalling with `--all` flag

### Mermaid diagrams aren't rendering
1. Ensure you're viewing on GitHub, Notion, or Obsidian
2. Check for syntax errors in the diagram
3. Try viewing at [mermaid.live](https://mermaid.live)

### Skills aren't being found
1. Check the skills directory path
2. Verify SKILL.md files exist
3. Restart your CLI/IDE
4. Try reinstalling the plugin

## Community

### How do I report a bug?
Open an issue on [GitHub Issues](https://github.com/LifeJiggy/Prometheus-Loop/issues) with:
- Description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Environment details

### How do I request a feature?
Open a feature request on [GitHub Issues](https://github.com/LifeJiggy/Prometheus-Loop/issues) with:
- Description of the feature
- Use case
- Expected behavior
