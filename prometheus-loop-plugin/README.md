# Prometheus Loop Plugin

A plugin for agentic CLI and IDE tools that provides the Agentic AI Loop framework and 13 self-* capabilities.

## Supported Harnesses (18+)

| Harness | Install command |
|---|---|
| **Claude Code** | `bash install.sh --claude` |
| **Codex CLI** | `bash install.sh --codex` |
| **OpenCode** | `bash install.sh --opencode` |
| **Hermes** | `bash install.sh --hermes` |
| **Cursor** | `bash install.sh --cursor` |
| **Windsurf** | `bash install.sh --windsurf` |
| **Aider** | `bash install.sh --aider` |
| **Continue** | `bash install.sh --continue` |
| **Zed** | `bash install.sh --zed` |
| **Cline** | `bash install.sh --cline` |
| **Roo Code** | `bash install.sh --roo` |
| **Amea** | `bash install.sh --amea` |
| **Void** | `bash install.sh --void` |
| **Junie** | `bash install.sh --junie` |
| **PearAI** | `bash install.sh --pearai` |
| **Sweep** | `bash install.sh --sweep` |
| **AI Toolkit** | `bash install.sh --ai-toolkit` |
| **Supermaven** | `bash install.sh --supermaven` |

## Installers

Three installer options for different platforms:

### Bash (Linux/macOS/WSL)

```bash
bash install.sh --all        # Auto-detect and install
bash install.sh --claude     # Install to specific harness
bash install.sh --list       # List supported harnesses
bash install.sh --uninstall  # Remove plugin
```

### PowerShell (Windows)

```powershell
.\install.ps1 -All           # Auto-detect and install
.\install.ps1 -Harness claude  # Install to specific harness
.\install.ps1 -List          # List supported harnesses
.\install.ps1 -Uninstall     # Remove plugin
```

### Python (Cross-platform)

```bash
python install.py --all      # Auto-detect and install
python install.py --claude   # Install to specific harness
python install.py --list     # List supported harnesses
python install.py --uninstall  # Remove plugin
```

## What's Included

### Skills (14)

| Skill | Description |
|---|---|
| `prometheus-loop-guide` | Core 7-step loop framework |
| `self-healing` | Error diagnosis and recovery |
| `self-retry` | Smart backoff and circuit breakers |
| `self-improving` | Learning from successes/failures |
| `self-monitoring` | Metrics, health checks, alerts |
| `self-debugging` | Root cause analysis, fix generation |
| `self-refactoring` | Code quality improvement |
| `self-evolution` | Capability acquisition |
| `self-observing` | Meta-cognition, decision tracing |
| `self-planning` | Goal decomposition, adaptive plans |
| `self-adapting` | Context-aware configuration |
| `self-governing` | Policy enforcement, compliance |
| `self-remembering` | Memory lifecycle management |
| `multi-agent-orchestration` | Multi-agent coordination |

### Commands (1)

| Command | Description |
|---|---|
| `/loop` | Interactive loop guide and capability reference |

## Usage After Install

1. Restart your CLI/IDE
2. Type `/loop` to see the overview
3. Type `/loop self-healing` for specific capability
4. Reference skills in your prompts

## File Structure

```
prometheus-loop-plugin/
├── plugin.json           # Plugin manifest
├── README.md             # This file
├── scripts/
│   └── install.sh        # Multi-harness installer
├── skills/
│   ├── prometheus-loop-guide/
│   │   └── SKILL.md
│   ├── self-healing/
│   │   └── SKILL.md
│   ├── self-retry/
│   │   └── SKILL.md
│   ├── self-improving/
│   │   └── SKILL.md
│   ├── self-monitoring/
│   │   └── SKILL.md
│   ├── self-debugging/
│   │   └── SKILL.md
│   ├── self-refactoring/
│   │   └── SKILL.md
│   ├── self-evolution/
│   │   └── SKILL.md
│   ├── self-observing/
│   │   └── SKILL.md
│   ├── self-planning/
│   │   └── SKILL.md
│   ├── self-adapting/
│   │   └── SKILL.md
│   ├── self-governing/
│   │   └── SKILL.md
│   ├── self-remembering/
│   │   └── SKILL.md
│   └── multi-agent-orchestration/
│       └── SKILL.md
└── commands/
    └── loop.md           # /loop command
```

## Full Documentation

For complete implementations (700+ lines each), see the main repository:
- **Guides**: `core/`, `production/`, `autonomous/`
- **Deep dives**: `shared/self/` (13 capabilities)
- **Examples**: `examples/` (8 case studies)
- **Summaries**: `core-only/` (quick reference)
