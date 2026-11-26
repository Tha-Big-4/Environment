# Self-tests for the environment scripts. No Pester needed: pwsh scripts/tests/run-tests.ps1
# Exit 0 when every test passes, 1 otherwise.
$ErrorActionPreference = 'Stop'
$scripts = Split-Path -Parent $PSScriptRoot
$envRoot = Split-Path -Parent $scripts
$fails = 0
function Assert([string]$Name, [bool]$Condition, [string]$Detail = '') {
    if ($Condition) { Write-Host "PASS  $Name" -ForegroundColor Green }
    else { Write-Host "FAIL  $Name $Detail" -ForegroundColor Red; $script:fails++ }
}
function New-TempDir { $d = Join-Path ([IO.Path]::GetTempPath()) ("envtest-" + [guid]::NewGuid().ToString('N').Substring(0, 8)); New-Item -ItemType Directory $d | Out-Null; $d }

# Builds a throwaway two-setup environment so sync tests never touch the real docs.
function New-FakeEnv {
    $t = New-TempDir
    foreach ($side in 'frontend', 'backend') {
        $other = if ($side -eq 'frontend') { 'backend' } else { 'frontend' }
        New-Item -ItemType Directory "$t/$side/docs", "$t/$side/project" -Force | Out-Null
        Copy-Item $scripts "$t/$side/scripts" -Recurse
        "@{ Side = '$side'; Sibling = '$other'; PerfTool = 'k6'; PerfUrl = 'http://localhost'; Tools = @(); EnvKeys = @(); Plugins = @() }" | Set-Content "$t/$side/environment.psd1"
    }
    $t
}

. "$scripts/lib/common.ps1"

# --- stack detection ---
$empty = New-TempDir
Assert 'empty project: no stacks' (@(Get-ProjectStacks $empty).Count -eq 0)

$nested = New-TempDir; New-Item -ItemType Directory "$nested/my-app" | Out-Null
'{ "scripts": { "build": "x", "test": "y" } }' | Set-Content "$nested/my-app/package.json"
$s = @(Get-ProjectStacks $nested)
Assert 'nested project/my-app: node detected' ($s.Count -eq 1 -and $s[0].Name -eq 'node')
Assert 'node: lint missing -> null step' ($null -eq $s[0].Steps.lint)
Assert 'node: build uses npm run build' ($s[0].Steps.build -eq 'npm run build')

$multi = New-TempDir
'{}' | Set-Content "$multi/package.json"; 'pnpm' | Set-Content "$multi/pnpm-lock.yaml"
'<Project />' | Set-Content "$multi/api.csproj"
$names = @(Get-ProjectStacks $multi | ForEach-Object Name)
Assert 'package.json + csproj: node and dotnet' (($names -contains 'node') -and ($names -contains 'dotnet'))
Assert 'pnpm lockfile -> pnpm runner' ((Get-ProjectStacks $multi | Where-Object Name -eq 'node').Tool -eq 'pnpm')

$py = New-TempDir; '' | Set-Content "$py/pyproject.toml"; New-Item -ItemType Directory "$py/node_modules/x" -Force | Out-Null; '{}' | Set-Content "$py/node_modules/package.json"
$names = @(Get-ProjectStacks $py | ForEach-Object Name)
Assert 'python detected, node_modules ignored' ($names.Count -eq 1 -and $names[0] -eq 'python')

# --- tools ---
$env:ENV_TEST_HIDE_TOOLS = 'git'
Assert 'hidden tool reported missing' (-not (Test-Tool 'git'))
$env:ENV_TEST_HIDE_TOOLS = ''
Assert 'nonexistent tool missing' (-not (Test-Tool 'definitely-not-a-tool-xyz'))

# --- quoting: a path with a quote cannot break out of a command string ---
$evil = "x'; Write-Output pwned; '"
$out = pwsh -NoProfile -Command "Write-Output $(ConvertTo-PsLiteral $evil)"
Assert 'ConvertTo-PsLiteral keeps a hostile path literal' ($out -eq $evil) "got $out"
Assert 'ConvertTo-SafeName strips quotes and separators' ((ConvertTo-SafeName "a'b/c d") -eq 'a_b_c_d')

# --- verify on an empty project exits 2 ---
$fake = New-FakeEnv
pwsh -NoProfile -File "$fake/frontend/scripts/verify.ps1" *> $null
Assert 'verify: empty project exits 2' ($LASTEXITCODE -eq 2) "got $LASTEXITCODE"

# --- security-scan with a missing scanner exits 2 ---
'{}' | Set-Content "$fake/frontend/project/package.json"
$env:ENV_TEST_HIDE_TOOLS = 'gitleaks'
pwsh -NoProfile -File "$fake/frontend/scripts/security-scan.ps1" -Only secrets *> $null
Assert 'security-scan: missing gitleaks exits 2' ($LASTEXITCODE -eq 2) "got $LASTEXITCODE"
$env:ENV_TEST_HIDE_TOOLS = ''

# --- raising the security baseline needs a report file ---
pwsh -NoProfile -File "$fake/frontend/scripts/security-scan.ps1" -UpdateBaseline -Allow *> $null
Assert 'security-scan: abbreviated -Allow without reason exits 2' ($LASTEXITCODE -eq 2) "got $LASTEXITCODE"
$outside = Join-Path $fake 'reason.md'; 'why' | Set-Content $outside
pwsh -NoProfile -File "$fake/frontend/scripts/security-scan.ps1" -UpdateBaseline -allowincrease -ReasonFile $outside *> $null
Assert 'security-scan: reason file outside docs/reports/security exits 2' ($LASTEXITCODE -eq 2) "got $LASTEXITCODE"

# --- docs sync ---
'a' | Set-Content "$fake/frontend/docs/one.md"
New-Item -ItemType Directory "$fake/frontend/docs/api" | Out-Null; 'b' | Set-Content "$fake/frontend/docs/api/two.md"
'old' | Set-Content "$fake/backend/docs/stale.md"
pwsh -NoProfile -File "$fake/frontend/scripts/sync-docs.ps1" -Check *> $null
Assert 'sync -Check: one-sided edit exits 1' ($LASTEXITCODE -eq 1) "got $LASTEXITCODE"
pwsh -NoProfile -File "$fake/frontend/scripts/sync-docs.ps1" *> $null
Assert 'sync: copies new files' ((Test-Path "$fake/backend/docs/api/two.md") -and (Test-Path "$fake/backend/docs/one.md"))
Assert 'sync: removes files the source no longer has' (-not (Test-Path "$fake/backend/docs/stale.md"))
pwsh -NoProfile -File "$fake/backend/scripts/sync-docs.ps1" -Check *> $null
Assert 'sync -Check from the other side: in sync exits 0' ($LASTEXITCODE -eq 0) "got $LASTEXITCODE"
Remove-Item -Recurse -Force "$fake/backend"
pwsh -NoProfile -File "$fake/frontend/scripts/sync-docs.ps1" -Check *> $null
Assert 'sync: missing other setup exits 2' ($LASTEXITCODE -eq 2) "got $LASTEXITCODE"

# --- this setup's config parses and names its sibling ---
$cfg = Import-PowerShellDataFile "$envRoot/environment.psd1"
Assert 'environment.psd1 parses' ($cfg.Side -in 'frontend', 'backend' -and $cfg.Sibling -in 'frontend', 'backend' -and $cfg.Side -ne $cfg.Sibling)

foreach ($d in $empty, $nested, $multi, $py, $fake) { Remove-Item -Recurse -Force $d -ErrorAction SilentlyContinue }
if ($fails) { Write-Host "$fails test(s) failed" -ForegroundColor Red; exit 1 }
Write-Host 'All tests passed' -ForegroundColor Green
exit 0
