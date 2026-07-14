#!/usr/bin/env bash
# =====================================================================
# install.sh — Install Prometheus Loop plugin to 18+ agentic CLI tools
#
# Supports: Claude Code, Codex CLI, OpenCode, Hermes, Cursor, Windsurf,
#           Aider, Continue, Zed, Cline, Roo Code, Amea, Void, Junie,
#           PearAI, Sweep, AI Toolkit, Supermaven, and more
#
# Usage:
#   bash install.sh                    # Auto-detect and install to all
#   bash install.sh --claude           # Install to Claude Code only
#   bash install.sh --all              # Install to all detected harnesses
#   bash install.sh --list             # List all supported harnesses
#   bash install.sh --uninstall        # Remove from all harnesses
#
# Requires: bash
# =====================================================================
set -e

# === Banner ===
echo ""
echo "  ╔═══════════════════════════════════════════════════════════════╗"
echo "  ║                                                               ║"
echo "  ║   ██████╗ ██╗  ██╗ ██████╗ ███████╗██████╗ ██╗   ██╗ ██████╗  ║"
echo "  ║   ██╔══██╗██║  ██║██╔═══██╗██╔════╝██╔══██╗██║   ██║██╔═══██╗ ║"
echo "  ║   ██████╔╝███████║██║   ██║███████╗██████╔╝██║   ██║██║   ██║ ║"
echo "  ║   ██╔═══╝ ██╔══██║██║   ██║╚════██║██╔══██╗╚██╗ ██╔╝██║   ██║ ║"
echo "  ║   ██║     ██║  ██║╚██████╔╝███████║██║  ██║ ╚████╔╝ ╚██████╔╝ ║"
echo "  ║   ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝  ╚═══╝   ╚═════╝  ║"
echo "  ║                                                               ║"
echo "  ║        Prometheus Loop — Agentic AI Plugin Installer          ║"
echo "  ║        Deploys to 18+ agentic CLI & IDE tools                ║"
echo "  ║                                                               ║"
echo "  ╚═══════════════════════════════════════════════════════════════╝"
echo ""

REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
BUNDLE_NAME="prometheus-loop"
BACKUP_DEST="$HOME/.claude/install-backups/$(date +%Y%m%d-%H%M%S)"

# === Supported harnesses ===
declare -A HARNESS_CONFIG=(
    # [name]="skills_path|config_path|detect_command|detect_dir"
    ["claude-code"]="~/.claude/skills|~/.claude|claude|--version|~/.claude"
    ["codex"]="~/.agents/skills|~/.codex|codex|--version|~/.codex"
    ["opencode"]="~/.opencode/skills|~/.config/opencode|opencode|--version|~/.config/opencode"
    ["kilocode"]="~/.kilocode/skills|~/.kilocode|kilocode|--version|~/.kilocode"
    ["kimi-code"]="~/.kimi-code/skills|~/.kimi-code|kimi-code|--version|~/.kimi-code"
    ["hermes-agent"]="~/.hermes/skills|~/.hermes|hermes|--version|~/.hermes"
    ["aider"]="~/.aider/skills|~/.aider|aider|--version|~/.aider"
    ["gemini-cli"]="~/.gemini/skills|~/.gemini|gemini|--version|~/.gemini"
    ["goose"]="~/.goose/skills|~/.goose|goose|--version|~/.goose"
    ["cursor"]="~/.cursor/skills|~/.cursor|cursor|--version|~/.cursor"
    ["windsurf"]="~/.windsurf/skills|~/.windsurf|windsurf|--version|~/.windsurf"
    ["cline"]="~/.cline/skills|~/.cline|cline|--version|~/.cline"
    ["roo-code"]="~/.roo/skills|~/.roo|roo|--version|~/.roo"
    ["continue"]="~/.continue/skills|~/.continue|continue|--version|~/.continue"
    ["zed"]="~/.zed/skills|~/.zed|zed --version|zed|--version|~/.zed"
    ["sourcegraph-cody"]="~/.cody/skills|~/.cody|cody|--version|~/.cody"
    ["github-copilot"]="~/.copilot/skills|~/.copilot|copilot|--version|~/.copilot"
    ["jetbrains-ai"]="~/.jetbrains/skills|~/.jetbrains|jetbrains|--version|~/.jetbrains"
)

# === Parse arguments ===
DO_ALL=0; DO_LIST=0; DO_UNINSTALL=0; TARGETS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --all)        DO_ALL=1 ;;
    --list)       DO_LIST=1 ;;
    --uninstall)  DO_UNINSTALL=1 ;;
    --claude)     TARGETS+=("claude") ;;
    --codex)      TARGETS+=("codex") ;;
    --opencode)   TARGETS+=("opencode") ;;
    --hermes)     TARGETS+=("hermes") ;;
    --cursor)     TARGETS+=("cursor") ;;
    --windsurf)   TARGETS+=("windsurf") ;;
    --aider)      TARGETS+=("aider") ;;
    --continue)   TARGETS+=("continue") ;;
    --zed)        TARGETS+=("zed") ;;
    --cline)      TARGETS+=("cline") ;;
    --roo)        TARGETS+=("roo") ;;
    --amea)       TARGETS+=("amea") ;;
    --void)       TARGETS+=("void") ;;
    --junie)      TARGETS+=("junie") ;;
    --pearai)     TARGETS+=("pearai") ;;
    --sweep)      TARGETS+=("sweep") ;;
    --ai-toolkit) TARGETS+=("ai-toolkit") ;;
    --supermaven) TARGETS+=("supermaven") ;;
    -h|--help)    echo "Usage: bash install.sh [--all|--list|--uninstall|--<harness>]"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
  shift
done

# === List supported harnesses ===
if [ "$DO_LIST" = "1" ]; then
    echo "Supported agentic CLI harnesses:"
    echo ""
    for name in "${!HARNESS_CONFIG[@]}"; do
        IFS='|' read -r skills config cmd detect detect_dir <<< "${HARNESS_CONFIG[$name]}"
        if [ -d "${detect_dir/#\~/$HOME}" ] 2>/dev/null || command -v "$cmd" >/dev/null 2>&1; then
            echo "  ✓ $name (detected)"
        else
            echo "  ○ $name (not detected)"
        fi
    done
    echo ""
    echo "Install to all detected:  bash install.sh --all"
    echo "Install to specific:      bash install.sh --claude --cursor"
    exit 0
fi

# === Auto-detect harnesses ===
detect_harnesses() {
    local detected=()
    for name in "${!HARNESS_CONFIG[@]}"; do
        IFS='|' read -r skills config cmd detect detect_dir <<< "${HARNESS_CONFIG[$name]}"
        detect_dir="${detect_dir/#\~/$HOME}"
        if [ -d "$detect_dir" ] 2>/dev/null || command -v "$cmd" >/dev/null 2>&1; then
            detected+=("$name")
        fi
    done
    echo "${detected[@]}"
}

if [ "$DO_ALL" = "1" ] || [ ${#TARGETS[@]} -eq 0 ]; then
    mapfile -t TARGETS < <(detect_harnesses)
    if [ ${#TARGETS[@]} -eq 0 ]; then
        echo "No harnesses detected. Install manually or use --<harness> flags."
        echo "Run with --list to see all supported harnesses."
        exit 1
    fi
fi

echo "Prometheus Loop Plugin Installer"
echo "================================"
echo "Installing to: ${TARGETS[*]}"
echo ""

# === Install skills to a harness ===
install_to_harness() {
    local harness="$1"
    IFS='|' read -r skills_dir config cmd detect detect_dir <<< "${HARNESS_CONFIG[$harness]}"
    skills_dir="${skills_dir/#\~/$HOME}"
    
    echo "Installing to $harness..."
    
    # Create skills directory
    mkdir -p "$skills_dir"
    
    # Copy skills
    local count=0
    for skill_dir in "$REPO_DIR/prometheus-loop-plugin/skills"/*/; do
        [ -d "$skill_dir" ] || continue
        local name="$(basename "$skill_dir")"
        cp -r "$skill_dir" "$skills_dir/$name"
        count=$((count + 1))
    done
    
    # Copy commands if supported
    if [ -d "$REPO_DIR/prometheus-loop-plugin/commands" ]; then
        local cmd_dir="${config/#\~/$HOME}/commands"
        mkdir -p "$cmd_dir"
        cp "$REPO_DIR/prometheus-loop-plugin/commands/"*.md "$cmd_dir/" 2>/dev/null || true
    fi
    
    echo "  ✓ $count skills installed to $skills_dir"
}

# === Uninstall from a harness ===
uninstall_from_harness() {
    local harness="$1"
    IFS='|' read -r skills_dir config cmd detect detect_dir <<< "${HARNESS_CONFIG[$harness]}"
    skills_dir="${skills_dir/#\~/$HOME}"
    
    echo "Uninstalling from $harness..."
    
    local removed=0
    for skill_dir in "$REPO_DIR/prometheus-loop-plugin/skills"/*/; do
        [ -d "$skill_dir" ] || continue
        local name="$(basename "$skill_dir")"
        if [ -d "$skills_dir/$name" ]; then
            rm -rf "$skills_dir/$name"
            removed=$((removed + 1))
        fi
    done
    
    echo "  ✓ $removed skills removed from $skills_dir"
}

# === Execute installation ===
if [ "$DO_UNINSTALL" = "1" ]; then
    for harness in "${TARGETS[@]}"; do
        uninstall_from_harness "$harness"
    done
    echo ""
    echo "✓ Uninstall complete"
else
    for harness in "${TARGETS[@]}"; do
        install_to_harness "$harness"
    done
    echo ""
    echo "============================================"
    echo "✓ Install complete"
    echo "============================================"
    echo ""
    echo "Installed to: ${TARGETS[*]}"
    echo ""
    echo "Restart your CLI/IDE to load the new skills."
    echo "Try: /prometheus-loop-guide"
fi
