# CLAUDE.md — frontend environment

Guidance for Claude Code (and humans) working in the frontend setup. The application lives in
`project/`; everything else here is the environment around it.

## Start of every task

1. Read `docs/README.md` and the rules that apply in `docs/rules/`.
2. Load context with the **second-brain** skill.
3. API work → **api-consumer** skill. UI work → **design-workflow** skill. New files → **folder-management**.

## Commands (run from `frontend/`)

| Command | Does |
|---|---|
| `pwsh scripts/setup.ps1` | Check tools, keys, plugins, hooks (`-Install`, `-ApplyEnv`) |
| `pwsh scripts/verify.ps1` | Lint + build + unit tests for whatever stack is in `project/` (`-Full` adds e2e, `-Format` the formatter check) |
| `pwsh scripts/security-scan.ps1` | gitleaks, Semgrep, osv-scanner, npm audit, Trivy vs `benchmarks/security-baseline.json` |
| `pwsh scripts/perf-bench.ps1 -Url <url>` | Lighthouse CI vs `benchmarks/lighthouserc.json` (app must be running) |
| `pwsh scripts/cleanup-scan.ps1` | Duplicates (jscpd) and unused code/deps (Knip); report only |
| `pwsh scripts/sync-docs.ps1` | Mirror `docs/` to `../backend/docs` (`-Check` to compare) |
| `docker compose -f docker/compose.yml up -d` | API mock of the shared contract on :4010 |

Exit codes for every script: `0` clean, `1` findings, `2` a tool is missing or failed. Logs: `reports/`.

## Rules

- **Coding style and method:** `docs/rules/CODING_STYLE.md`. Test first, small commits, verify before claiming.
- **Zero warnings.** Build, lint and tests must print no warnings. A change that adds one is not finished.
- **Never hide a failure:** no suppressed diagnostics, skipped tests, raised budgets or `--no-verify`.
- **Design:** tokens only (`docs/design/tokens.md`), no hard-coded colours; mobile first; WCAG AA; keyboard reachable.
- **Security:** never write data into raw HTML without sanitizing; no tokens in local storage; no secrets in code.
- **API:** types generated from `docs/api/openapi/`; handle every documented error code.
- **Docs are shared:** any change under `docs/` → `pwsh scripts/sync-docs.ps1`, commit both copies.
- **Done** means: verify passes, security scan at or under baseline, docs updated and in sync.

## MCP servers

`.mcp.json`: stitch (Google Stitch), inspo, boardui, playwright, context7, github. Details and keys: `mcp/README.md`.
