<#
.SYNOPSIS
  Install (or update) Google Labs' Stitch skills into this setup's .claude/skills/ for Claude Code.
.DESCRIPTION
  github.com/google-labs-code/stitch-skills ships no Claude Code marketplace, and its `npx plugins`
  route does not support project scope. This script clones it, copies every skill to
  .claude/skills/stitch-<name>/, rewrites each skill's `name` to match its folder (Claude Code needs
  lowercase kebab-case; upstream uses `stitch::<name>`), keeps the Apache-2.0 license beside them and
  records the installed commit. The copies are git-ignored; re-run to update.
  Upstream says it is "not an officially supported Google product".
.EXAMPLE
  pwsh scripts/install-stitch-skills.ps1              # latest main
  pwsh scripts/install-stitch-skills.ps1 -Ref <sha>   # a pinned commit
  pwsh scripts/install-stitch-skills.ps1 -Remove
.NOTES
  Exit codes: 0 installed/removed, 2 git missing or the clone failed.
#>
param(
    [string]$Ref = 'main',
    [string]$Repo = 'https://github.com/google-labs-code/stitch-skills.git',
    [string]$Source,          # use a local checkout instead of cloning (tests)
    [switch]$Remove
)
. "$PSScriptRoot/lib/common.ps1"
$skillsDir = Join-Path (Get-EnvRoot) '.claude/skills'
$manifest = Join-Path $skillsDir '.stitch-skills.json'
New-Item -ItemType Directory -Force $skillsDir | Out-Null

# Remove what a previous run installed (only folders listed in its manifest).
if (Test-Path $manifest) {
    $old = Get-Content $manifest -Raw | ConvertFrom-Json
    foreach ($d in @($old.skills)) { $p = Join-Path $skillsDir $d; if (Test-Path $p) { Remove-Item -Recurse -Force $p } }
    Remove-Item (Join-Path $skillsDir 'STITCH_SKILLS_LICENSE') -ErrorAction SilentlyContinue
    Remove-Item $manifest
}
if ($Remove) { Write-StepLine PASS 'stitch-skills' 'removed'; exit 0 }

$tmp = $null
if (-not $Source) {
    if (-not (Test-Tool 'git')) { Write-StepLine MISSING 'stitch-skills' 'git is required'; exit 2 }
    $tmp = Join-Path ([IO.Path]::GetTempPath()) ('stitch-skills-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
    git clone --quiet --filter=blob:none $Repo $tmp 2>&1 | Out-Null
    if ($LASTEXITCODE) { Write-StepLine FAIL 'stitch-skills' "could not clone $Repo"; exit 2 }
    git -C $tmp checkout --quiet $Ref 2>&1 | Out-Null
    if ($LASTEXITCODE) { Write-StepLine FAIL 'stitch-skills' "ref '$Ref' not found"; Remove-Item -Recurse -Force $tmp; exit 2 }
    $Source = $tmp
}
try {
    $commit = if (Test-Path (Join-Path $Source '.git')) { (git -C $Source rev-parse HEAD).Trim() } else { 'local' }
    $installed = @()
    foreach ($skill in Get-ChildItem (Join-Path $Source 'plugins/*/skills/*') -Directory) {
        if (-not (Test-Path (Join-Path $skill.FullName 'SKILL.md'))) { continue }
        $name = $skill.Name.ToLowerInvariant() -replace '[^a-z0-9-]', '-'
        if ($name -notlike 'stitch-*') { $name = "stitch-$name" }
        $dest = Join-Path $skillsDir $name
        Copy-Item $skill.FullName $dest -Recurse -Force
        $md = Join-Path $dest 'SKILL.md'
        $text = Get-Content $md -Raw
        $text = [regex]::Replace($text, '(?m)^name:.*$', "name: $name", 1)
        Set-Content $md $text -NoNewline
        $installed += $name
    }
    if (-not $installed) { Write-StepLine FAIL 'stitch-skills' 'no skills found in the source (layout changed?)'; exit 2 }
    Copy-Item (Join-Path $Source 'LICENSE') (Join-Path $skillsDir 'STITCH_SKILLS_LICENSE') -ErrorAction SilentlyContinue
    [ordered]@{ repo = $Repo; ref = $Ref; commit = $commit; installed = (Get-Date -Format 'yyyy-MM-dd'); skills = $installed } |
        ConvertTo-Json | Set-Content $manifest
    Write-StepLine PASS 'stitch-skills' "$($installed.Count) skills at $($commit.Substring(0, [Math]::Min(12, $commit.Length))) -> .claude/skills/stitch-*"
    Write-Host 'Restart Claude Code to load them. They use the stitch MCP server (needs STITCH_API_KEY).'
} finally {
    if ($tmp) { Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue }
}
exit 0
