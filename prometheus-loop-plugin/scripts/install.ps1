<#
.SYNOPSIS
    Install Prometheus Loop plugin to 18+ agentic CLI tools

.DESCRIPTION
    Deploys the Prometheus Loop plugin (skills + commands) to supported
    agentic CLI and IDE tools on Windows.

    Supports: Claude Code, Codex CLI, OpenCode, Hermes, Cursor, Windsurf,
              Aider, Continue, Zed, Cline, Roo Code, Amea, Void, Junie,
              PearAI, Sweep, AI Toolkit, Supermaven, and more

.PARAMETER All
    Auto-detect and install to all detected harnesses

.PARAMETER List
    List all supported harnesses

.PARAMETER Uninstall
    Remove plugin from harnesses

.PARAMETER Harness
    Install to specific harness (can be repeated)

.EXAMPLE
    .\install.ps1                    # Auto-detect and install to all
    .\install.ps1 -Harness claude   # Install to Claude Code only
    .\install.ps1 -All              # Install to all detected harnesses
    .\install.ps1 -List             # List all supported harnesses
    .\install.ps1 -Uninstall        # Remove from all harnesses

.NOTES
    Author: Prometheus Loop
    Version: 1.0.0
#>

param(
    [switch]$All,
    [switch]$List,
    [switch]$Uninstall,
    [string[]]$Harness
)

$ErrorActionPreference = "Stop"

# === Banner ===
Write-Host ""
Write-Host "  ╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║                                                               ║" -ForegroundColor Cyan
Write-Host "  ║   ██████╗ ██╗  ██╗ ██████╗ ███████╗██████╗ ██╗   ██╗ ██████╗  ║" -ForegroundColor Cyan
Write-Host "  ║   ██╔══██╗██║  ██║██╔═══██╗██╔════╝██╔══██╗██║   ██║██╔═══██╗ ║" -ForegroundColor Cyan
Write-Host "  ║   ██████╔╝███████║██║   ██║███████╗██████╔╝██║   ██║██║   ██║ ║" -ForegroundColor Cyan
Write-Host "  ║   ██╔═══╝ ██╔══██║██║   ██║╚════██║██╔══██╗╚██╗ ██╔╝██║   ██║ ║" -ForegroundColor Cyan
Write-Host "  ║   ██║     ██║  ██║╚██████╔╝███████║██║  ██║ ╚████╔╝ ╚██████╔╝ ║" -ForegroundColor Cyan
Write-Host "  ║   ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝  ╚═══╝   ╚═════╝  ║" -ForegroundColor Cyan
Write-Host "  ║                                                               ║" -ForegroundColor Cyan
Write-Host "  ║        Prometheus Loop — Agentic AI Plugin Installer          ║" -ForegroundColor Yellow
Write-Host "  ║        Deploys to 18+ agentic CLI & IDE tools                ║" -ForegroundColor Yellow
Write-Host "  ║                                                               ║" -ForegroundColor Cyan
Write-Host "  ╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# === Configuration ===
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoDir = Split-Path -Parent $ScriptDir
$BundleName = "prometheus-loop"

# Supported harnesses: name = skills_path
$HarnessConfig = @{
    "claude"      = "$env:USERPROFILE\.claude\skills"
    "codex"       = "$env:USERPROFILE\.agents\skills"
    "opencode"    = "$env:USERPROFILE\.claude\skills"
    "hermes"      = "$env:USERPROFILE\.hermes\skills"
    "cursor"      = "$env:USERPROFILE\.cursor\skills"
    "windsurf"    = "$env:USERPROFILE\.windsurf\skills"
    "aider"       = "$env:USERPROFILE\.aider\skills"
    "continue"    = "$env:USERPROFILE\.continue\skills"
    "zed"         = "$env:USERPROFILE\.zed\skills"
    "cline"       = "$env:USERPROFILE\.cline\skills"
    "roo"         = "$env:USERPROFILE\.roo\skills"
    "amea"        = "$env:USERPROFILE\.amea\skills"
    "void"        = "$env:USERPROFILE\.void\skills"
    "junie"       = "$env:USERPROFILE\.junie\skills"
    "pearai"      = "$env:USERPROFILE\.pearai\skills"
    "sweep"       = "$env:USERPROFILE\.sweep\skills"
    "ai-toolkit"  = "$env:USERPROFILE\.ai-toolkit\skills"
    "supermaven"  = "$env:USERPROFILE\.supermaven\skills"
}

# === List harnesses ===
if ($List) {
    Write-Host "Supported agentic CLI harnesses:" -ForegroundColor Green
    Write-Host ""
    
    foreach ($name in $HarnessConfig.Keys | Sort-Object) {
        $skillsPath = $HarnessConfig[$name] -replace '~', $env:USERPROFILE
        if (Test-Path $skillsPath -ErrorAction SilentlyContinue) {
            Write-Host "  ✓ $name (detected)" -ForegroundColor Green
        } else {
            Write-Host "  ○ $name (not detected)" -ForegroundColor DarkGray
        }
    }
    
    Write-Host ""
    Write-Host "Install to all detected:  .\install.ps1 -All" -ForegroundColor Yellow
    Write-Host "Install to specific:      .\install.ps1 -Harness claude -Harness cursor" -ForegroundColor Yellow
    exit 0
}

# === Auto-detect harnesses ===
function Get-DetectedHarnesses {
    $detected = @()
    foreach ($name in $HarnessConfig.Keys) {
        $skillsPath = $HarnessConfig[$name] -replace '~', $env:USERPROFILE
        if (Test-Path (Split-Path $skillsPath -Parent) -ErrorAction SilentlyContinue) {
            $detected += $name
        }
    }
    return $detected
}

# === Install skills to harness ===
function Install-ToHarness {
    param([string]$HarnessName)
    
    $skillsPath = $HarnessConfig[$HarnessName] -replace '~', $env:USERPROFILE
    
    Write-Host "Installing to $HarnessName..." -ForegroundColor Cyan
    
    # Create skills directory
    if (-not (Test-Path $skillsPath)) {
        New-Item -ItemType Directory -Path $skillsPath -Force | Out-Null
    }
    
    # Copy skills
    $sourceSkills = Join-Path $RepoDir "prometheus-loop-plugin\skills"
    $count = 0
    
    Get-ChildItem -Path $sourceSkills -Directory | ForEach-Object {
        $destPath = Join-Path $skillsPath $_.Name
        Copy-Item -Path $_.FullName -Destination $destPath -Recurse -Force
        $count++
    }
    
    Write-Host "  ✓ $count skills installed to $skillsPath" -ForegroundColor Green
}

# === Uninstall from harness ===
function Uninstall-FromHarness {
    param([string]$HarnessName)
    
    $skillsPath = $HarnessConfig[$HarnessName] -replace '~', $env:USERPROFILE
    
    Write-Host "Uninstalling from $HarnessName..." -ForegroundColor Yellow
    
    $sourceSkills = Join-Path $RepoDir "prometheus-loop-plugin\skills"
    $removed = 0
    
    Get-ChildItem -Path $sourceSkills -Directory | ForEach-Object {
        $destPath = Join-Path $skillsPath $_.Name
        if (Test-Path $destPath) {
            Remove-Item -Path $destPath -Recurse -Force
            $removed++
        }
    }
    
    Write-Host "  ✓ $removed skills removed from $skillsPath" -ForegroundColor Green
}

# === Main execution ===
if ($Uninstall) {
    $targets = if ($Harness.Count -gt 0) { $Harness } else { Get-DetectedHarnesses }
    
    foreach ($name in $targets) {
        Uninstall-FromHarness -HarnessName $name
    }
    
    Write-Host ""
    Write-Host "✓ Uninstall complete" -ForegroundColor Green
} else {
    $targets = if ($All -or $Harness.Count -eq 0) { Get-DetectedHarnesses } else { $Harness }
    
    if ($targets.Count -eq 0) {
        Write-Host "No harnesses detected. Use -Harness <name> to install manually." -ForegroundColor Red
        Write-Host "Run with -List to see all supported harnesses." -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "Installing to: $($targets -join ', ')" -ForegroundColor Green
    Write-Host ""
    
    foreach ($name in $targets) {
        Install-ToHarness -HarnessName $name
    }
    
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "✓ Install complete" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Installed to: $($targets -join ', ')" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Restart your CLI/IDE to load the new skills." -ForegroundColor Yellow
    Write-Host "Try: /loop" -ForegroundColor Yellow
}
