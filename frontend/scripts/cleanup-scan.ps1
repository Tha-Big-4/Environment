<#
.SYNOPSIS
  Report-only cleanup analysis: duplicated code (all stacks), unused code and dependencies (per stack).
  Never edits the project.
.EXAMPLE
  pwsh scripts/cleanup-scan.ps1
.NOTES
  Exit codes: 0 nothing found, 1 findings, 2 no project or a tool failed.
#>
param([string]$Path)
. "$PSScriptRoot/lib/common.ps1"

$project = Join-Path (Get-EnvRoot) 'project'
if ($Path) { $project = $Path }
$stacks = Get-ProjectStacks $project
if (-not $stacks) { Write-StepLine MISSING 'project' "no project found in $project"; exit 2 }
$project = (Resolve-Path $project).Path
$out = New-ReportDir 'cleanup'
$jscpdCfg = Join-Path (Get-EnvRoot) 'config/jscpd.json'
$codes = @()

$codes += Invoke-Step -Name 'dupes' -Tool 'npx' -WorkDir $project -LogDir $out `
    -Command "npx --yes jscpd@4.0.5 --config $(ConvertTo-PsLiteral $jscpdCfg) --output $(ConvertTo-PsLiteral "$out/jscpd") ."
foreach ($s in $stacks) {
    switch ($s.Name) {
        'node'   { $codes += Invoke-Step -Name 'knip' -Tool 'npx' -WorkDir $s.Dir -LogDir $out -Command 'npx --yes knip@5 --no-progress' }
        'dotnet' { $codes += Invoke-Step -Name 'roslyn-unused' -Tool 'dotnet' -WorkDir $s.Dir -LogDir $out -Command 'dotnet format analyzers --verify-no-changes --diagnostics IDE0005 IDE0051 IDE0052 IDE0060 CS0168 CS0219 --severity info' }
        'python' { $codes += Invoke-Step -Name 'ruff-unused' -Tool 'ruff' -WorkDir $s.Dir -LogDir $out -Command 'ruff check --select F401,F841,ERA001 .' }
        'go'     { $codes += Invoke-Step -Name 'staticcheck' -Tool 'staticcheck' -WorkDir $s.Dir -LogDir $out -Command 'staticcheck -checks U1000 ./...' }
        default  { Write-StepLine SKIP "$($s.Name) unused-code" 'no analyzer configured; add one in cleanup-scan.ps1' }
    }
}
Write-Host "Reports: $out"
if ($codes -contains 2) { exit 2 }
if ($codes | Where-Object { $_ -ne 0 }) { exit 1 }
exit 0
