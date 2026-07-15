# Contributing to Prometheus Loop

Thank you for your interest in contributing! This document provides guidelines and information for contributors.

## Project Structure

```
Prometheus-Loop/
├── core/                    # Concept level (v1)
├── production/              # Production level (v2)
├── autonomous/              # Autonomous level (v3)
├── shared/                  # Deep dives & common resources
│   └── self/               # 13 self-* capabilities (700+ lines each)
├── examples/                # Code snippets & case studies
├── prometheus-loop-plugin/  # Plugin for 18+ CLI/IDE tools
├── DOCS/                    # Documentation
└── .github/                 # CI/CD, templates
```

## How to Contribute

### 1. Fork the Repository

```bash
# Fork on GitHub, then clone
git clone https://github.com/YOUR_USERNAME/Prometheus-Loop.git
cd Prometheus-Loop
git remote add upstream https://github.com/LifeJiggy/Prometheus-Loop.git
```

### 2. Create a Branch

```bash
git checkout -b feature/your-feature-name
```

### 3. Make Changes

- Follow the coding standards below
- Add tests for new functionality
- Update documentation as needed
- Ensure mermaid diagrams render correctly

### 4. Commit Changes

```bash
git commit -m "feat: add new feature description"
```

### 5. Push and Create PR

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

## What to Contribute

### Documentation
- Improve existing guides
- Add new tutorials or examples
- Fix typos or unclear explanations
- Add translations

### Code
- Fix bugs
- Add new features
- Improve performance
- Add tests

### Self-* Capabilities
- Enhance existing capabilities
- Add new capabilities
- Improve implementations

### Plugin System
- Add support for new CLI/IDE tools
- Improve existing integrations
- Add new skills

### Examples
- Add new case studies
- Create integration examples
- Improve existing examples

## Commit Messages

We follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` — New feature
- `fix:` — Bug fix
- `docs:` — Documentation changes
- `style:` — Code style changes (formatting, etc.)
- `refactor:` — Code refactoring
- `test:` — Adding tests
- `chore:` — Maintenance tasks

Examples:
- `feat: add self-healing capability`
- `fix: resolve mermaid rendering issue`
- `docs: update API reference`
- `test: add unit tests for retry system`
- `feat(plugin): add support for Windsurf`

## Coding Standards

### Python

- Follow PEP 8
- Use type hints
- Write docstrings for all public functions
- Keep functions under 50 lines
- Maximum line length: 88 characters

### Markdown

- Use proper heading hierarchy
- Include code examples where appropriate
- Keep paragraphs concise
- Use tables for structured data
- Ensure mermaid diagrams render correctly

### Skill Files

- Each skill should be 700+ lines
- Include: overview, architecture, implementation, examples, best practices
- Add mermaid diagram at the top
- Cross-reference related skills

## Pull Request Guidelines

### Before Submitting

- [ ] Code follows style guidelines
- [ ] Tests pass
- [ ] Documentation is updated
- [ ] Mermaid diagrams render correctly
- [ ] Commit messages follow conventions
- [ ] No merge conflicts

### PR Description

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation
- [ ] Refactoring
- [ ] Plugin enhancement

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Mermaid diagrams verified

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] Tests added
- [ ] No breaking changes
- [ ] Skill files are 700+ lines (if applicable)
```

## Reporting Issues

### Bug Reports

```markdown
## Bug Description
Clear description of the bug

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Expected Behavior
What should happen

## Actual Behavior
What actually happened

## Environment
- OS: [e.g., Windows 11]
- Python version: [e.g., 3.11]
- Prometheus Loop version: [e.g., 1.0.0]
```

### Feature Requests

```markdown
## Feature Description
Clear description of the feature

## Use Case
Why this feature is needed

## Proposed Solution
How it could be implemented

## Alternatives Considered
Other approaches considered
```

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow
- Follow the project's coding standards

## Questions?

- **Issues**: [GitHub Issues](https://github.com/LifeJiggy/Prometheus-Loop/issues)
- **Discussions**: [GitHub Discussions](https://github.com/LifeJiggy/Prometheus-Loop/discussions)
