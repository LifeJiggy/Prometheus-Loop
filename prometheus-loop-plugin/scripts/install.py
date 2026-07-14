#!/usr/bin/env python3
"""
install.py — Install Prometheus Loop plugin to 18+ agentic CLI tools (cross-platform)

Supports: Claude Code, Codex CLI, OpenCode, Hermes, Cursor, Windsurf,
          Aider, Continue, Zed, Cline, Roo Code, Amea, Void, Junie,
          PearAI, Sweep, AI Toolkit, Supermaven, and more

Usage:
    python install.py                    # Auto-detect and install to all
    python install.py --claude           # Install to Claude Code only
    python install.py --all              # Install to all detected harnesses
    python install.py --list             # List all supported harnesses
    python install.py --uninstall        # Remove from all harnesses

Requires: Python 3.7+
"""

import os
import sys
import shutil
import argparse
from pathlib import Path
from datetime import datetime

# === Banner ===
BANNER = """
  ╔═══════════════════════════════════════════════════════════════╗
  ║                                                               ║
  ║   ██████╗ ██╗  ██╗ ██████╗ ███████╗██████╗ ██╗   ██╗ ██████╗  ║
  ║   ██╔══██╗██║  ██║██╔═══██╗██╔════╝██╔══██╗██║   ██║██╔═══██╗ ║
  ║   ██████╔╝███████║██║   ██║███████╗██████╔╝██║   ██║██║   ██║ ║
  ║   ██╔═══╝ ██╔══██║██║   ██║╚════██║██╔══██╗╚██╗ ██╔╝██║   ██║ ║
  ║   ██║     ██║  ██║╚██████╔╝███████║██║  ██║ ╚████╔╝ ╚██████╔╝ ║
  ║   ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝  ╚═══╝   ╚═════╝  ║
  ║                                                               ║
  ║        Prometheus Loop — Agentic AI Plugin Installer          ║
  ║        Deploys to 18+ agentic CLI & IDE tools                 ║
  ║        Cross-platform: Windows, macOS, Linux                  ║
  ║                                                               ║
  ╚═══════════════════════════════════════════════════════════════╝
"""

# === Supported harnesses ===
# name -> skills_path (relative to home directory)
HARNESS_CONFIG = {
    "claude": ".claude/skills",
    "codex": ".agents/skills",
    "opencode": ".claude/skills",
    "hermes": ".hermes/skills",
    "cursor": ".cursor/skills",
    "windsurf": ".windsurf/skills",
    "aider": ".aider/skills",
    "continue": ".continue/skills",
    "zed": ".zed/skills",
    "cline": ".cline/skills",
    "roo": ".roo/skills",
    "amea": ".amea/skills",
    "void": ".void/skills",
    "junie": ".junie/skills",
    "pearai": ".pearai/skills",
    "sweep": ".sweep/skills",
    "ai-toolkit": ".ai-toolkit/skills",
    "supermaven": ".supermaven/skills",
}


def get_home_dir() -> Path:
    """Get home directory cross-platform."""
    return Path.home()


def detect_harnesses() -> list:
    """Detect installed harnesses."""
    home = get_home_dir()
    detected = []
    
    for name, skills_path in HARNESS_CONFIG.items():
        harness_dir = home / skills_path.parent
        if harness_dir.exists():
            detected.append(name)
    
    return detected


def install_skills(harness_name: str, repo_dir: Path) -> bool:
    """Install skills to a harness."""
    home = get_home_dir()
    skills_path = home / HARNESS_CONFIG[harness_name]
    source_skills = repo_dir / "prometheus-loop-plugin" / "skills"
    
    if not source_skills.exists():
        print(f"  ✗ Source skills not found: {source_skills}")
        return False
    
    # Create skills directory
    skills_path.mkdir(parents=True, exist_ok=True)
    
    # Copy skills
    count = 0
    for skill_dir in source_skills.iterdir():
        if skill_dir.is_dir():
            dest = skills_path / skill_dir.name
            if dest.exists():
                shutil.rmtree(dest)
            shutil.copytree(skill_dir, dest)
            count += 1
    
    print(f"  ✓ {count} skills installed to {skills_path}")
    return True


def uninstall_skills(harness_name: str, repo_dir: Path) -> bool:
    """Uninstall skills from a harness."""
    home = get_home_dir()
    skills_path = home / HARNESS_CONFIG[harness_name]
    source_skills = repo_dir / "prometheus-loop-plugin" / "skills"
    
    if not source_skills.exists():
        print(f"  ✗ Source skills not found")
        return False
    
    # Remove skills
    removed = 0
    for skill_dir in source_skills.iterdir():
        if skill_dir.is_dir():
            dest = skills_path / skill_dir.name
            if dest.exists():
                shutil.rmtree(dest)
                removed += 1
    
    print(f"  ✓ {removed} skills removed from {skills_path}")
    return True


def list_harnesses():
    """List all supported harnesses."""
    print("Supported agentic CLI harnesses:\n")
    
    for name in sorted(HARNESS_CONFIG.keys()):
        home = get_home_dir()
        harness_dir = home / HARNESS_CONFIG[name].parent
        
        if harness_dir.exists():
            print(f"  ✓ {name} (detected)")
        else:
            print(f"  ○ {name} (not detected)")
    
    print("\nInstall to all detected:  python install.py --all")
    print("Install to specific:      python install.py --claude --cursor")


def main():
    parser = argparse.ArgumentParser(
        description="Install Prometheus Loop plugin to 18+ agentic CLI tools"
    )
    parser.add_argument("--all", action="store_true", help="Install to all detected harnesses")
    parser.add_argument("--list", action="store_true", help="List all supported harnesses")
    parser.add_argument("--uninstall", action="store_true", help="Remove plugin from harnesses")
    parser.add_argument("--claude", action="store_true", help="Install to Claude Code")
    parser.add_argument("--codex", action="store_true", help="Install to Codex CLI")
    parser.add_argument("--opencode", action="store_true", help="Install to OpenCode")
    parser.add_argument("--hermes", action="store_true", help="Install to Hermes")
    parser.add_argument("--cursor", action="store_true", help="Install to Cursor")
    parser.add_argument("--windsurf", action="store_true", help="Install to Windsurf")
    parser.add_argument("--aider", action="store_true", help="Install to Aider")
    parser.add_argument("--continue", action="store_true", help="Install to Continue")
    parser.add_argument("--zed", action="store_true", help="Install to Zed")
    parser.add_argument("--cline", action="store_true", help="Install to Cline")
    parser.add_argument("--roo", action="store_true", help="Install to Roo Code")
    parser.add_argument("--amea", action="store_true", help="Install to Amea")
    parser.add_argument("--void", action="store_true", help="Install to Void")
    parser.add_argument("--junie", action="store_true", help="Install to Junie")
    parser.add_argument("--pearai", action="store_true", help="Install to PearAI")
    parser.add_argument("--sweep", action="store_true", help="Install to Sweep")
    parser.add_argument("--ai-toolkit", action="store_true", help="Install to AI Toolkit")
    parser.add_argument("--supermaven", action="store_true", help="Install to Supermaven")
    
    args = parser.parse_args()
    
    # Print banner
    print(BANNER)
    
    # Get repo directory
    repo_dir = Path(__file__).parent.parent
    
    # List harnesses
    if args.list:
        list_harnesses()
        return
    
    # Get target harnesses
    targets = []
    harness_flags = [
        "claude", "codex", "opencode", "hermes", "cursor", "windsurf",
        "aider", "continue", "zed", "cline", "roo", "amea", "void",
        "junie", "pearai", "sweep", "ai-toolkit", "supermaven"
    ]
    
    for flag in harness_flags:
        if getattr(args, flag.replace("-", "_"), False):
            targets.append(flag)
    
    # Auto-detect if no specific targets
    if not targets or args.all:
        targets = detect_harnesses()
        if not targets:
            print("No harnesses detected. Use --<harness> flags to install manually.")
            print("Run with --list to see all supported harnesses.")
            sys.exit(1)
    
    print(f"Target harnesses: {', '.join(targets)}\n")
    
    # Install or uninstall
    if args.uninstall:
        for name in targets:
            uninstall_skills(name, repo_dir)
        print("\n✓ Uninstall complete")
    else:
        for name in targets:
            install_skills(name, repo_dir)
        
        print("\n" + "=" * 50)
        print("✓ Install complete")
        print("=" * 50)
        print(f"\nInstalled to: {', '.join(targets)}")
        print("\nRestart your CLI/IDE to load the new skills.")
        print("Try: /loop")


if __name__ == "__main__":
    main()
