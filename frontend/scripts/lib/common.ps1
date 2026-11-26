# Shared helpers for every environment script. Dot-source it: . "$PSScriptRoot/lib/common.ps1"
# Identical in frontend/ and backend/; per-setup differences live in <setup>/environment.psd1.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:EnvRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
if ((Split-Path -Leaf $script:EnvRoot) -eq 'scripts') { $script:EnvRoot = Split-Path -Parent $script:EnvRoot }

function Get-EnvRoot { $script:EnvRoot }

function Get-EnvConfig {
    $file = Join-Path $script:EnvRoot 'environment.psd1'
    if (-not (Test-Path $file)) { throw "environment.psd1 not found in $script:EnvRoot" }
    Import-PowerShellDataFile $file
}

# A tool is "present" when it is on PATH and not hidden by ENV_TEST_HIDE_TOOLS (used by the tests).
function Test-Tool([string]$Name) {
    $hidden = @(($env:ENV_TEST_HIDE_TOOLS ?? '') -split ',' | Where-Object { $_ })
    if ($hidden -contains $Name) { return $false }
    [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Write-StepLine([string]$Status, [string]$Name, [string]$Detail = '') {
    $color = @{ PASS = 'Green'; FAIL = 'Red'; MISSING = 'Yellow'; SKIP = 'DarkGray'; INFO = 'Cyan'; FOUND = 'Yellow' }[$Status] ?? 'White'
    $line = '{0,-8} {1}' -f $Status, $Name
    if ($Detail) { $line += "  ($Detail)" }
    Write-Host $line -ForegroundColor $color
}

function New-ReportDir([string]$Kind) {
    $dir = Join-Path $script:EnvRoot ("reports/{0}-{1}" -f $Kind, (Get-Date -Format 'yyyyMMdd-HHmmss'))
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    $dir
}

# Runs one command line in WorkDir, logs everything to LogDir/<name>.log, prints one line.
# Returns the process exit code.
function Invoke-Step {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Command,
        [Parameter(Mandatory)][string]$WorkDir,
        [Parameter(Mandatory)][string]$LogDir,
        [string]$Tool
    )
    if ($Tool -and -not (Test-Tool $Tool)) { Write-StepLine MISSING $Name "$Tool not installed; run scripts/setup.ps1"; return 2 }
    $log = Join-Path $LogDir (($Name -replace '[^\w.-]', '_') + '.log')
    $sw = [Diagnostics.Stopwatch]::StartNew()
    Push-Location $WorkDir
    try {
        $global:LASTEXITCODE = 0
        & pwsh -NoProfile -NonInteractive -Command $Command *> $log
        $code = $LASTEXITCODE
    } finally { Pop-Location }
    $secs = '{0:N1}s' -f $sw.Elapsed.TotalSeconds
    if ($code -eq 0) { Write-StepLine PASS $Name $secs } else { Write-StepLine FAIL $Name "exit $code, $secs, log: $log" }
    $code
}

function Get-NodeRunner([string]$Dir) {
    if (Test-Path (Join-Path $Dir 'pnpm-lock.yaml')) { return 'pnpm' }
    if (Test-Path (Join-Path $Dir 'yarn.lock')) { return 'yarn' }
    if (Test-Path (Join-Path $Dir 'bun.lockb')) { return 'bun' }
    'npm'
}

# Detects every stack in Path and in its direct subfolders (project/ or project/<name>/).
# Returns objects: @{ Name; Dir; Tool; Steps = ordered @{ lint; format; build; test; full } } (missing steps are $null).
function Get-ProjectStacks([string]$Path) {
    if (-not (Test-Path $Path)) { return @() }
    $skip = 'node_modules', '.git', 'bin', 'obj', 'dist', 'build', 'target', '.venv', 'vendor'
    $dirs = @(Get-Item $Path) + @(Get-ChildItem $Path -Directory -ErrorAction SilentlyContinue | Where-Object { $skip -notcontains $_.Name })
    $found = foreach ($d in $dirs) {
        $p = $d.FullName
        $has = { param($pattern) [bool](Get-ChildItem $p -Filter $pattern -File -ErrorAction SilentlyContinue | Select-Object -First 1) }

        if (& $has 'package.json') {
            $pm = Get-NodeRunner $p
            $scripts = @{}
            try { $json = Get-Content (Join-Path $p 'package.json') -Raw | ConvertFrom-Json -AsHashtable; if ($json.ContainsKey('scripts')) { $scripts = $json.scripts } } catch { }
            $run = { param($s) if ($scripts.ContainsKey($s)) { "$pm run $s" } else { $null } }
            $e2e = (& $run 'e2e') ?? (& $run 'test:e2e')
            [pscustomobject]@{ Name = 'node'; Dir = $p; Tool = $pm; Steps = [ordered]@{
                lint = & $run 'lint'; format = (& $run 'format:check'); build = & $run 'build'
                test = if ($scripts.ContainsKey('test')) { "`$env:CI='true'; $pm test" } else { $null }; full = $e2e } }
        }
        if ((& $has '*.sln') -or (& $has '*.slnx') -or (& $has '*.csproj') -or (& $has '*.fsproj')) {
            [pscustomobject]@{ Name = 'dotnet'; Dir = $p; Tool = 'dotnet'; Steps = [ordered]@{
                lint = $null; format = 'dotnet format --verify-no-changes'; build = 'dotnet build -c Release -warnaserror'
                test = 'dotnet test -c Release --filter "Category!=Integration"'; full = 'dotnet test -c Release' } }
        }
        if ((& $has 'pyproject.toml') -or (& $has 'requirements.txt')) {
            [pscustomobject]@{ Name = 'python'; Dir = $p; Tool = 'python'; Steps = [ordered]@{
                lint = 'ruff check .'; format = 'ruff format --check .'; build = $null; test = 'python -m pytest -q -m "not integration"'; full = 'python -m pytest -q' } }
        }
        if (& $has 'go.mod') {
            [pscustomobject]@{ Name = 'go'; Dir = $p; Tool = 'go'; Steps = [ordered]@{
                lint = 'go vet ./...'; format = 'if (gofmt -l .) { exit 1 }'; build = 'go build ./...'; test = 'go test -short ./...'; full = 'go test ./...' } }
        }
        if (& $has 'pom.xml') {
            [pscustomobject]@{ Name = 'maven'; Dir = $p; Tool = 'mvn'; Steps = [ordered]@{
                lint = $null; format = $null; build = 'mvn -B -q -DskipTests package'; test = 'mvn -B -q test'; full = 'mvn -B -q verify' } }
        }
        if ((& $has 'build.gradle') -or (& $has 'build.gradle.kts')) {
            $g = if ($IsWindows) { '.\gradlew.bat' } else { './gradlew' }
            [pscustomobject]@{ Name = 'gradle'; Dir = $p; Tool = $null; Steps = [ordered]@{
                lint = $null; format = $null; build = "$g assemble"; test = "$g test"; full = "$g check" } }
        }
        if (& $has 'Cargo.toml') {
            [pscustomobject]@{ Name = 'rust'; Dir = $p; Tool = 'cargo'; Steps = [ordered]@{
                lint = 'cargo clippy --all-targets -- -D warnings'; format = 'cargo fmt --check'; build = 'cargo build'; test = 'cargo test'; full = 'cargo test -- --include-ignored' } }
        }
        if (& $has 'composer.json') {
            [pscustomobject]@{ Name = 'php'; Dir = $p; Tool = 'composer'; Steps = [ordered]@{
                lint = 'composer validate --strict'; format = $null; build = $null; test = 'vendor/bin/phpunit'; full = 'vendor/bin/phpunit' } }
        }
    }
    # A stack found at the project root wins over the same stack in a subfolder (monorepo tooling).
    $rootNames = @($found | Where-Object { $_.Dir -eq (Get-Item $Path).FullName } | ForEach-Object Name)
    @($found | Where-Object { $_.Dir -eq (Get-Item $Path).FullName -or $rootNames -notcontains $_.Name })
}

# Quotes a value as a PowerShell single-quoted literal so a path can never break out of a command string.
function ConvertTo-PsLiteral([string]$Value) { "'" + ($Value -replace "'", "''") + "'" }

# Safe file-name part from any folder or project name.
function ConvertTo-SafeName([string]$Value) { $Value -replace '[^\w.-]', '_' }

function Resolve-ProjectPath([string]$Path) {
    if (-not $Path) { $Path = Join-Path $script:EnvRoot 'project' }
    (Resolve-Path $Path).Path
}
