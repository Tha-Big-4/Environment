<#
.SYNOPSIS
  API tests: run the shared Postman collection (docs/api/postman/) with the Postman CLI against a
  running API (backend) or the contract mock (frontend, docker api-mock on :4010).
.EXAMPLE
  pwsh scripts/api-test.ps1                                        # local environment, baseUrl from it
  pwsh scripts/api-test.ps1 -BaseUrl http://localhost:5000         # override baseUrl
  pwsh scripts/api-test.ps1 -Collection docs/api/postman/orders.postman_collection.json -Bail
.NOTES
  Exit codes: 0 all assertions passed, 1 a request or test failed, 2 Postman CLI / collection missing.
  Nothing is uploaded: runs are local files. Secrets go in -EnvVar at run time, never in the environment file.
#>
param(
    [string]$Collection,
    [string]$Environment,
    [string]$BaseUrl,
    [string[]]$EnvVar = @(),   # extra NAME=value pairs, e.g. -EnvVar token=$env:API_TOKEN
    [switch]$Bail
)
. "$PSScriptRoot/lib/common.ps1"
$root = Get-EnvRoot
$pm = Join-Path $root 'docs/api/postman'
if (-not $Collection) { $Collection = Join-Path $pm 'api.postman_collection.json' }
if (-not $Environment) { $Environment = Join-Path $pm 'local.postman_environment.json' }

if (-not (Test-Tool 'postman')) { Write-StepLine MISSING 'postman' 'Postman CLI not installed; run scripts/setup.ps1 -Install (npm install -g postman-cli)'; exit 2 }
if (-not (Test-Path $Collection -PathType Leaf)) { Write-StepLine MISSING 'collection' "$Collection not found"; exit 2 }

$out = New-ReportDir 'api-test'
$cmd = @('postman collection run', (ConvertTo-PsLiteral (Resolve-Path $Collection).Path), '--output', (ConvertTo-PsLiteral $out), '--working-dir', (ConvertTo-PsLiteral $pm))
if (Test-Path $Environment -PathType Leaf) { $cmd += @('-e', (ConvertTo-PsLiteral (Resolve-Path $Environment).Path)) }
if ($BaseUrl) { $EnvVar += "baseUrl=$BaseUrl" }
foreach ($v in $EnvVar) {
    if ($v -notmatch '^[A-Za-z_][\w.-]*=') { Write-StepLine FAIL 'arguments' "-EnvVar must be NAME=value, got '$($v -replace '=.*', '=...')'"; exit 2 }
    $cmd += @('--env-var', (ConvertTo-PsLiteral $v))
}
if ($Bail) { $cmd += '--bail' }

$code = Invoke-Step -Name "postman-$([IO.Path]::GetFileNameWithoutExtension($Collection))" -Command ($cmd -join ' ') -WorkDir $root -LogDir $out -Tool 'postman'
Write-Host "Report: $out"
if ($code -eq 0) { exit 0 } elseif ($code -eq 2) { exit 2 } else { exit 1 }
