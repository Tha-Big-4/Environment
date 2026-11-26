<#
.SYNOPSIS
  Keep frontend/docs and backend/docs identical (docs/rules/DOCS_SYNC_RULES.md).
.EXAMPLE
  pwsh scripts/sync-docs.ps1          # mirror THIS setup's docs/ onto the other setup's docs/
  pwsh scripts/sync-docs.ps1 -Check   # list differences; exit 1 if any
.NOTES
  Exit codes: 0 in sync (or synced), 1 differences found (-Check), 2 the other setup is missing.
#>
param([switch]$Check)
. "$PSScriptRoot/lib/common.ps1"
$cfg = Get-EnvConfig
$src = Join-Path (Get-EnvRoot) 'docs'
$dst = Join-Path (Split-Path -Parent (Get-EnvRoot)) "$($cfg.Sibling)/docs"
if (-not (Test-Path (Split-Path -Parent $dst))) { Write-StepLine MISSING 'docs-sync' "other setup not found at $(Split-Path -Parent $dst)"; exit 2 }

function Get-FileMap([string]$Root) {
    $map = @{}
    if (Test-Path $Root) {
        Get-ChildItem $Root -Recurse -File -Force | ForEach-Object {
            $map[[IO.Path]::GetRelativePath($Root, $_.FullName) -replace '\\', '/'] = (Get-FileHash $_.FullName -Algorithm SHA256).Hash
        }
    }
    $map
}
$a = Get-FileMap $src
$b = Get-FileMap $dst
$changed = @($a.Keys | Where-Object { $b[$_] -ne $a[$_] } | Sort-Object)
$extra = @($b.Keys | Where-Object { -not $a.ContainsKey($_) } | Sort-Object)

if ($Check) {
    if (-not ($changed + $extra)) { Write-StepLine PASS 'docs-sync' "$($a.Count) files identical"; exit 0 }
    $changed | ForEach-Object { Write-StepLine FAIL "docs/$_" $(if ($b.ContainsKey($_)) { 'differs' } else { "only in $($cfg.Side)" }) }
    $extra | ForEach-Object { Write-StepLine FAIL "docs/$_" "only in $($cfg.Sibling)" }
    Write-Host "Run: pwsh $($cfg.Side)/scripts/sync-docs.ps1  (or from $($cfg.Sibling)/ if that side is newer)"
    exit 1
}
foreach ($rel in $changed) {
    $target = Join-Path $dst $rel
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
    Copy-Item (Join-Path $src $rel) $target -Force
}
foreach ($rel in $extra) { Remove-Item (Join-Path $dst $rel) -Force }
Get-ChildItem $dst -Recurse -Directory | Sort-Object { $_.FullName.Length } -Descending |
    Where-Object { -not (Get-ChildItem $_.FullName -Force) } | Remove-Item
Write-StepLine PASS 'docs-sync' "$($cfg.Side) -> $($cfg.Sibling): $($changed.Count) copied, $($extra.Count) removed"
exit 0
