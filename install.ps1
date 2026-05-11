<#
.SYNOPSIS
    Unreal AngelScript skill installer (Windows / PowerShell).

.DESCRIPTION
    Downloads a released skill archive from GitHub and installs it into the
    AI agent directory of your choice (or every detected agent directory).

.EXAMPLE
    iwr -useb https://raw.githubusercontent.com/flashpoint493/unreal-angelscript-skills/main/install.ps1 | iex

.EXAMPLE
    & ([scriptblock]::Create((iwr -useb https://raw.githubusercontent.com/flashpoint493/unreal-angelscript-skills/main/install.ps1).Content)) -Agent codebuddy

.EXAMPLE
    .\install.ps1 -Agent all -Version 0.1.0

.NOTES
    Environment variable equivalents:
        UEAS_VERSION, UEAS_AGENT, UEAS_SCOPE, UEAS_REPO, UEAS_INSTALL_DIR
#>

[CmdletBinding()]
param(
    [string] $Version,
    [ValidateSet('codebuddy','claude','cursor','windsurf','cline','roo','trae','Claude','opencode','agents','spec','all','auto')]
    [string] $Agent = 'auto',
    [ValidateSet('project','user')]
    [string] $Scope = 'project',
    [string] $InstallDir,
    [string] $Repo = 'flashpoint493/unreal-angelscript-skills'
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# Honor environment variables when parameters are not supplied
if (-not $PSBoundParameters.ContainsKey('Version')    -and $env:UEAS_VERSION)     { $Version = $env:UEAS_VERSION }
if (-not $PSBoundParameters.ContainsKey('Agent')      -and $env:UEAS_AGENT)       { $Agent = $env:UEAS_AGENT }
if (-not $PSBoundParameters.ContainsKey('Scope')      -and $env:UEAS_SCOPE)       { $Scope = $env:UEAS_SCOPE }
if (-not $PSBoundParameters.ContainsKey('InstallDir') -and $env:UEAS_INSTALL_DIR) { $InstallDir = $env:UEAS_INSTALL_DIR }
if (-not $PSBoundParameters.ContainsKey('Repo')       -and $env:UEAS_REPO)        { $Repo = $env:UEAS_REPO }

$SkillName = 'unreal-angelscript'
$AllAgents = @('codebuddy','claude','cursor','windsurf','cline','roo','trae','Claude','opencode','agents')

function Write-Step { param($Msg) Write-Host ("  ● {0}" -f $Msg) -ForegroundColor Cyan }
function Write-Ok   { param($Msg) Write-Host ("  ✓ {0}" -f $Msg) -ForegroundColor Green }
function Write-Warn2{ param($Msg) Write-Host ("  ! {0}" -f $Msg) -ForegroundColor Yellow }
function Stop-Fail  { param($Msg) Write-Host ("  ✗ {0}" -f $Msg) -ForegroundColor Red; exit 1 }

# ── Resolve install root ──────────────────────────────────────────────────────
if ($InstallDir) {
    $Root = $InstallDir
} elseif ($Scope -eq 'user') {
    $Root = $HOME
} else {
    $Root = (Get-Location).Path
}
New-Item -ItemType Directory -Force -Path $Root | Out-Null
Write-Step ("Install root: {0}" -f $Root)

# ── Resolve version ───────────────────────────────────────────────────────────
if (-not $Version) {
    Write-Step ("Querying latest release from {0}" -f $Repo)
    $apiUrl = "https://api.github.com/repos/$Repo/releases/latest"
    try {
        $resp = Invoke-RestMethod -Uri $apiUrl -Headers @{ 'Accept' = 'application/vnd.github+json'; 'User-Agent' = 'ueas-installer' } -TimeoutSec 30
        $Version = $resp.tag_name
    } catch {
        Stop-Fail "Could not reach GitHub API. Pass -Version explicitly. ($($_.Exception.Message))"
    }
}
$Tag = "v$($Version -replace '^v','')"
$Ver = $Version -replace '^v',''
Write-Ok ("Target version: {0}" -f $Tag)

# ── Resolve agent list ────────────────────────────────────────────────────────
function Get-DetectedAgents {
    $found = @()
    foreach ($a in $AllAgents) {
        if (Test-Path -LiteralPath (Join-Path $Root ".$a")) { $found += $a }
    }
    return ,$found
}

$Targets = @()
switch ($Agent) {
    'all'  { $Targets = $AllAgents }
    'spec' { $Targets = @('__spec__') }
    'auto' {
        $detected = Get-DetectedAgents
        if ($detected.Count -gt 0) {
            $Targets = $detected
            Write-Ok ("Auto-detected agents: {0}" -f ($detected -join ', '))
        } else {
            Write-Warn2 ("No existing agent directories found under {0}." -f $Root)
            if ([Environment]::UserInteractive -and $Host.UI.RawUI) {
                $choice = Read-Host "  Choose target [codebuddy/claude/cursor/windsurf/cline/roo/trae/Claude/opencode/agents/spec/all]"
                if ([string]::IsNullOrWhiteSpace($choice)) { $choice = 'spec' }
                switch ($choice) {
                    'all'  { $Targets = $AllAgents }
                    'spec' { $Targets = @('__spec__') }
                    default { $Targets = @($choice) }
                }
            } else {
                $Targets = @('__spec__')
                Write-Warn2 "Non-interactive: defaulting to generic 'skills/' layout."
            }
        }
    }
    default { $Targets = @($Agent) }
}

# ── Download archive ──────────────────────────────────────────────────────────
$Asset = "unreal-angelscript-skill-$Ver.zip"
$Url   = "https://github.com/$Repo/releases/download/$Tag/$Asset"

$Tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("ueas-install-" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $Tmp | Out-Null
try {
    Write-Step ("Downloading {0}" -f $Asset)
    $zipPath = Join-Path $Tmp $Asset
    try {
        Invoke-WebRequest -Uri $Url -OutFile $zipPath -UseBasicParsing -TimeoutSec 60 -Headers @{ 'User-Agent' = 'ueas-installer' }
    } catch {
        Stop-Fail "Download failed: $Url ($($_.Exception.Message))"
    }
    $sizeKb = [Math]::Round((Get-Item $zipPath).Length / 1KB, 1)
    Write-Ok ("Downloaded {0} KB" -f $sizeKb)

    Write-Step "Extracting"
    $unpacked = Join-Path $Tmp 'unpacked'
    Expand-Archive -LiteralPath $zipPath -DestinationPath $unpacked -Force
    $src = Join-Path $unpacked $SkillName
    if (-not (Test-Path -LiteralPath $src)) {
        Stop-Fail "Archive layout unexpected: $SkillName/ not found inside zip."
    }

    # ── Install to each chosen target ─────────────────────────────────────────
    foreach ($a in $Targets) {
        if ($a -eq '__spec__') {
            $dest = Join-Path $Root (Join-Path 'skills' $SkillName)
        } else {
            $dest = Join-Path $Root (Join-Path ".$a" (Join-Path 'skills' $SkillName))
        }
        if (Test-Path -LiteralPath $dest) {
            Write-Warn2 ("Replacing existing {0}" -f $dest)
            Remove-Item -LiteralPath $dest -Recurse -Force
        }
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dest) | Out-Null
        Copy-Item -LiteralPath $src -Destination $dest -Recurse -Force
        Write-Ok ("Installed -> {0}" -f $dest)
    }

    Write-Ok ("Done. Skill '{0}' {1} is ready." -f $SkillName, $Tag)
}
finally {
    Remove-Item -LiteralPath $Tmp -Recurse -Force -ErrorAction SilentlyContinue
}
