<#
.SYNOPSIS
  Performance benchmark against the budgets in benchmarks/. The app must be running.
  Frontend setup: Lighthouse CI (lighthouserc.json). Backend setup: k6 (benchmarks/k6/<Script>.js).
.EXAMPLE
  pwsh scripts/perf-bench.ps1 -Url http://localhost:4200
  pwsh scripts/perf-bench.ps1 -Url http://localhost:5000 -Script load
.NOTES
  Exit codes: 0 within budget, 1 a budget was broken, 2 the tool is missing or failed to run.
#>
param(
    [string]$Url,
    [string]$Script = 'smoke'
)
. "$PSScriptRoot/lib/common.ps1"
$cfg = Get-EnvConfig
$root = Get-EnvRoot
if (-not $Url) { $Url = $cfg.PerfUrl }
$out = New-ReportDir 'perf'

switch ($cfg.PerfTool) {
    'lighthouse' {
        if (-not (Test-Tool 'npx')) { Write-StepLine MISSING 'lighthouse' 'Node.js is required'; exit 2 }
        $rc = Join-Path $root 'benchmarks/lighthouserc.json'
        $code = Invoke-Step -Name 'lighthouse' -WorkDir $root -LogDir $out -Command "npx --yes @lhci/cli@0.15.1 autorun --config='$rc' --collect.url='$Url' --upload.target=filesystem --upload.outputDir='$out'"
    }
    'k6' {
        $js = Join-Path $root "benchmarks/k6/$Script.js"
        if (-not (Test-Path $js)) { Write-StepLine MISSING "k6/$Script" "$js not found"; exit 2 }
        $code = Invoke-Step -Name "k6-$Script" -Tool 'k6' -WorkDir $root -LogDir $out -Command "k6 run -e BASE_URL='$Url' --summary-export '$out/summary.json' '$js'"
        if ($code -eq 99) { $code = 1 }   # k6: thresholds crossed
    }
    default { Write-StepLine MISSING 'perf' "unknown PerfTool '$($cfg.PerfTool)' in environment.psd1"; exit 2 }
}
Write-Host "Results: $out"
if ($code -eq 0) { exit 0 } elseif ($code -eq 2) { exit 2 } else { exit 1 }
