<#
.SYNOPSIS
  Security scan: secrets, SAST, vulnerable dependencies, misconfigurations. Compared to the baseline.
.EXAMPLE
  pwsh scripts/security-scan.ps1
  pwsh scripts/security-scan.ps1 -Only secrets,deps
  pwsh scripts/security-scan.ps1 -UpdateBaseline     # accept current counts (only ever lower them)
.NOTES
  Exit codes: 0 at or under the baseline, 1 a count went up, 2 a scanner failed or is missing.
  A scanner that fails is never reported as a pass.
#>
param(
    [string]$Path,
    [string[]]$Only = @('secrets', 'sast', 'deps', 'config'),
    [switch]$UpdateBaseline
)
. "$PSScriptRoot/lib/common.ps1"
$Only = @($Only -split ',' | ForEach-Object Trim | Where-Object { $_ })
$bad = @($Only | Where-Object { $_ -notin 'secrets', 'sast', 'deps', 'config' })
if ($bad) { Write-StepLine FAIL 'arguments' "unknown check(s): $($bad -join ', '). Use secrets, sast, deps, config"; exit 2 }

$project = Join-Path (Get-EnvRoot) 'project'
if ($Path) { $project = $Path }
$stacks = Get-ProjectStacks $project
if (-not $stacks) { Write-StepLine MISSING 'project' "no project found in $project"; exit 2 }
$project = (Resolve-Path $project).Path
$out = New-ReportDir 'security'
$baselineFile = Join-Path (Get-EnvRoot) 'benchmarks/security-baseline.json'
$baseline = if (Test-Path $baselineFile) { Get-Content $baselineFile -Raw | ConvertFrom-Json -AsHashtable } else { @{} }
$counts = [ordered]@{}
$failed = $false

function Invoke-Scanner([string]$Check, [string]$Tool, [string]$Command, [scriptblock]$Count, [string]$WorkDir = $project) {
    if (-not (Test-Tool $Tool)) { Write-StepLine MISSING "$Check/$Tool" 'run scripts/setup.ps1 -Install'; $script:failed = $true; return }
    $log = Join-Path $out "$Check-$Tool-$(Split-Path -Leaf $WorkDir).log"
    Push-Location $WorkDir
    try { & pwsh -NoProfile -NonInteractive -Command $Command *> $log } finally { Pop-Location }
    try { $n = [int](& $Count) } catch { Write-StepLine FAIL "$Check/$Tool" "could not read results, log: $log"; $script:failed = $true; return }
    $counts[$Check] = ($counts[$Check] ?? 0) + $n
    Write-StepLine $(if ($n) { 'FOUND' } else { 'PASS' }) "$Check/$Tool" "$n finding(s)"
}

if ($Only -contains 'secrets') {
    $f = Join-Path $out 'gitleaks.json'
    $mode = if (Test-Path (Join-Path $project '.git')) { 'git' } else { 'dir' }
    Invoke-Scanner 'secrets' 'gitleaks' "gitleaks $mode . --no-banner --report-format json --report-path '$f' --exit-code 0" { @(Get-Content $f -Raw | ConvertFrom-Json).Count }
}
if ($Only -contains 'sast') {
    $f = Join-Path $out 'semgrep.json'
    Invoke-Scanner 'sast' 'semgrep' "semgrep scan --config p/default --config p/owasp-top-ten --metrics=off --json -o '$f' ." { @((Get-Content $f -Raw | ConvertFrom-Json).results).Count }
}
if ($Only -contains 'deps') {
    $f = Join-Path $out 'osv.json'
    Invoke-Scanner 'deps' 'osv-scanner' "osv-scanner scan source -r . --format json --output-file '$f'" {
        if (-not (Test-Path $f)) {
            # osv-scanner writes no file when the project has no lockfile or manifest it understands.
            if (Select-String -Path $log -Pattern 'No package sources found' -Quiet) { return 0 }
            throw 'no output'
        }
        $r = Get-Content $f -Raw | ConvertFrom-Json
        @(@($r.PSObject.Properties['results'] ? $r.results : @()) | ForEach-Object { $_.packages } | ForEach-Object { $_.vulnerabilities }).Count }
    foreach ($s in $stacks) {
        switch ($s.Name) {
            'node' {
                if (-not (Get-ChildItem $s.Dir -File | Where-Object Name -in 'package-lock.json', 'npm-shrinkwrap.json')) {
                    Write-StepLine SKIP "deps/npm $(Split-Path -Leaf $s.Dir)" 'no package-lock.json; commit a lockfile so dependencies can be audited'; continue }
                $nf = Join-Path $out "npm-audit-$(Split-Path -Leaf $s.Dir).json"
                Invoke-Scanner 'deps' 'npm' "npm audit --omit=dev --json > '$nf'" { (Get-Content $nf -Raw | ConvertFrom-Json).metadata.vulnerabilities.total } $s.Dir
            }
            'dotnet' {
                $df = Join-Path $out 'dotnet-vulnerable.txt'
                Invoke-Scanner 'deps' 'dotnet' "dotnet list package --vulnerable --include-transitive > '$df'" { @(Select-String -Path $df -Pattern '^\s+>\s').Count } $s.Dir
            }
        }
    }
}
if ($Only -contains 'config') {
    $f = Join-Path $out 'trivy.json'
    Invoke-Scanner 'config' 'trivy' "trivy fs --scanners misconfig --skip-dirs node_modules --format json -o '$f' ." {
        $r = Get-Content $f -Raw | ConvertFrom-Json
        $results = if ($r.PSObject.Properties['Results']) { @($r.Results) } else { @() }
        @($results | Where-Object { $_.PSObject.Properties['Misconfigurations'] } | ForEach-Object { $_.Misconfigurations } | Where-Object Status -eq 'FAIL').Count }
}

$worst = 0
$summary = @("# Security scan $(Get-Date -Format 'yyyy-MM-dd HH:mm')", '', '| Check | Findings | Baseline |', '|---|---|---|')
foreach ($k in $counts.Keys) {
    $b = [int]($baseline[$k] ?? 0)
    $summary += "| $k | $($counts[$k]) | $b |"
    if ($counts[$k] -gt $b) { $worst = 1; Write-StepLine FAIL "baseline/$k" "$($counts[$k]) > $b" }
}
$summary | Set-Content (Join-Path $out 'summary.md')
if ($UpdateBaseline -and -not $failed) {
    $new = [ordered]@{}; foreach ($k in 'secrets', 'sast', 'deps', 'config') { $new[$k] = [int]($counts[$k] ?? $baseline[$k] ?? 0) }
    $new | ConvertTo-Json | Set-Content $baselineFile
    Write-StepLine INFO 'baseline updated' $baselineFile
    $worst = 0
}
Write-Host "Report: $out"
if ($failed) { exit 2 }
exit $worst
