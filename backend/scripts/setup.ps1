<#
.SYNOPSIS
  Set up this environment: check (and optionally install) tools, create .env, apply MCP keys,
  install the agent plugins and the git hooks for project/.
.EXAMPLE
  pwsh scripts/setup.ps1              # check only: what is installed, what is missing, what to run
  pwsh scripts/setup.ps1 -Install     # install missing tools and plugins
  pwsh scripts/setup.ps1 -ApplyEnv    # copy keys from .env into user environment variables (for MCP servers)
.NOTES
  Exit codes: 0 everything ready, 2 something is missing.
  Tools and plugins are listed in environment.psd1; add a new tool there, not here.
#>
param([switch]$Install, [switch]$ApplyEnv)
. "$PSScriptRoot/lib/common.ps1"
$cfg = Get-EnvConfig
$root = Get-EnvRoot
$missing = 0
$os = if ($IsWindows) { 'Windows' } elseif ($IsMacOS) { 'MacOS' } else { 'Linux' }

Write-StepLine INFO "Tools ($($cfg.Side), $os)"
foreach ($t in $cfg.Tools) {
    $atPath = @($t['Paths'] | Where-Object { $_ } | ForEach-Object { [Environment]::ExpandEnvironmentVariables($_) } | Where-Object { Test-Path $_ })
    if ((Test-Tool $t.Check) -or $atPath) { Write-StepLine PASS $t.Name; continue }
    $cmd = $t[$os]
    if ($Install -and $cmd) {
        & pwsh -NoProfile -Command $cmd
        if (Test-Tool $t.Check) { Write-StepLine PASS $t.Name 'installed'; continue }
        Write-StepLine FAIL $t.Name 'install ran but the tool is still not on PATH; open a new terminal and re-run'
    } else {
        Write-StepLine MISSING $t.Name $(if ($cmd) { "install: $cmd" } else { $t['Url'] })
    }
    if (-not $t['Optional']) { $missing++ }
}

Write-StepLine INFO 'Environment keys'
$envFile = Join-Path $root '.env'
if (-not (Test-Path $envFile)) { Copy-Item (Join-Path $root '.env.example') $envFile; Write-StepLine INFO '.env created from .env.example; fill in the values' }
$values = @{}
Get-Content $envFile | Where-Object { $_ -match '^\s*([A-Z0-9_]+)\s*=\s*(.*)$' } | ForEach-Object { $values[$Matches[1]] = $Matches[2].Trim().Trim('"') }
foreach ($k in $cfg.EnvKeys) {
    $v = $values[$k.Name]
    $set = [bool]$v -or [bool][Environment]::GetEnvironmentVariable($k.Name)
    if (-not $set) { Write-StepLine MISSING $k.Name "$($k.For). Get it: $($k.Url)"; if (-not $k['Optional']) { $missing++ }; continue }
    if ($ApplyEnv -and $v) {
        if ($IsWindows) { [Environment]::SetEnvironmentVariable($k.Name, $v, 'User') }
        else { Write-StepLine INFO $k.Name "add to your shell profile: export $($k.Name)=..." }
    }
    Write-StepLine PASS $k.Name $(if ($ApplyEnv -and $IsWindows) { 'applied; restart Claude Code / your editor' } else { 'set' })
}

if ($cfg.Plugins) {
    Write-StepLine INFO 'Agent plugins'
    foreach ($p in $cfg.Plugins) {
        if ($p['Marker'] -and (Test-Path (Join-Path $root $p['Marker']))) { Write-StepLine PASS $p.Name; continue }
        if ($Install) {
            Push-Location $root; try { & pwsh -NoProfile -Command $p.Command } finally { Pop-Location }
            Write-StepLine INFO $p.Name 'install command ran; check its output above'
        } else { Write-StepLine MISSING $p.Name "install: $($p.Command)"; if (-not $p['Optional']) { $missing++ } }
    }
}

Write-StepLine INFO 'Git hooks'
$project = Join-Path $root 'project'
if (Test-Path (Join-Path $project '.git')) {
    git -C $project config core.hooksPath (Join-Path $root '.githooks')
    Write-StepLine PASS 'hooks' 'project/ uses this setup''s .githooks (pre-commit, pre-push)'
} else {
    Write-StepLine SKIP 'hooks' 'no git repo in project/ yet; re-run setup after creating or cloning it'
}

if ($missing) { Write-Host "$missing item(s) missing. Re-run with -Install, or install them by hand."; exit 2 }
Write-Host 'Ready.'
exit 0
