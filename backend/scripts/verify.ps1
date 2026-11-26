<#
.SYNOPSIS
  Lint, format check, build and test the project, whatever its stack.
.EXAMPLE
  pwsh scripts/verify.ps1                 # project/ : lint + build + unit tests
  pwsh scripts/verify.ps1 -Full           # + integration and e2e
  pwsh scripts/verify.ps1 -Format         # + formatter check
  pwsh scripts/verify.ps1 -Path ../other  # another folder
.NOTES
  Exit codes: 0 clean, 1 a step failed, 2 no project found or a tool is missing.
#>
param(
    [string]$Path,
    [switch]$Full,
    [switch]$Format
)
. "$PSScriptRoot/lib/common.ps1"

$project = Join-Path (Get-EnvRoot) 'project'
if ($Path) { $project = $Path }
$stacks = Get-ProjectStacks $project
if (-not $stacks) {
    Write-StepLine MISSING 'project' "no project found in $project. Create or clone it there first"
    exit 2
}

$logDir = New-ReportDir 'verify'
$worst = 0
foreach ($s in $stacks) {
    Write-StepLine INFO "$($s.Name) in $($s.Dir)"
    $order = @('lint') + $(if ($Format) { 'format' }) + @('build', 'test') + $(if ($Full) { 'full' })
    foreach ($step in $order) {
        $cmd = $s.Steps[$step]
        if (-not $cmd) { Write-StepLine SKIP "$($s.Name) $step" 'not configured for this project'; continue }
        $code = Invoke-Step -Name "$($s.Name)-$step" -Command $cmd -WorkDir $s.Dir -LogDir $logDir -Tool $s.Tool
        if ($code -eq 2 -and $worst -lt 2) { $worst = 2 } elseif ($code -ne 0 -and $worst -eq 0) { $worst = 1 }
        if ($code -ne 0 -and $step -eq 'build') { break }
    }
}
Write-Host "Logs: $logDir"
exit $worst
