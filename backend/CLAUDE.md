# CLAUDE.md — backend environment

Guidance for Claude Code (and humans) working in the backend setup. The application lives in
`project/`; everything else here is the environment around it.

## Start of every task

1. Read `docs/README.md` and the rules that apply in `docs/rules/`.
2. Load context with the **second-brain** skill.
3. Endpoint work → **api-endpoint** skill (the backend owns `docs/api/`). New files → **folder-management**.

## Commands (run from `backend/`)

| Command | Does |
|---|---|
| `pwsh scripts/setup.ps1` | Check tools, keys, hooks (`-Install`, `-ApplyEnv`) |
| `pwsh scripts/verify.ps1` | Lint + build (warnings as errors) + unit tests for whatever stack is in `project/` |
| `pwsh scripts/verify.ps1 -Full` | + integration tests (Testcontainers; Docker must run) |
| `pwsh scripts/security-scan.ps1` | gitleaks, Semgrep, osv-scanner, stack audit, Trivy vs `benchmarks/security-baseline.json` |
| `pwsh scripts/perf-bench.ps1 -Url <url>` | k6 smoke (`-Script load` for load) vs thresholds (API must be running) |
| `pwsh scripts/cleanup-scan.ps1` | Duplicates (jscpd) and unused code (Roslyn / ruff / staticcheck / Knip); report only |
| `pwsh scripts/sync-docs.ps1` | Mirror `docs/` to `../frontend/docs` (`-Check` to compare) |
| `docker compose -f docker/compose.yml up -d` | Postgres, Redis, Mailpit (SQL Server with `--profile sqlserver`) |

Exit codes for every script: `0` clean, `1` findings, `2` a tool is missing or failed. Logs: `reports/`.

## Rules

- **Coding style and method:** `docs/rules/CODING_STYLE.md`. Test first, small commits, verify before claiming.
- **Zero warnings.** Build with warnings as errors. A change that adds a warning is not finished.
- **Never hide a failure:** no suppressed analyzers, skipped tests, raised budgets or `--no-verify`.
- **Security:** deny by default (every endpoint declares auth); validate all input; parameterized queries;
  tenant data isolated at the data layer; no secrets in code; never log secrets or personal data.
- **Database:** changes are migrations. Create and report them; never apply them to a shared database yourself.
- **API contract:** every endpoint change updates `docs/api/` (openapi, endpoint doc, errors, changelog).
- **Docs are shared:** any change under `docs/` → `pwsh scripts/sync-docs.ps1`, commit both copies.
- **Done** means: verify (`-Full`) passes, security scan at or under baseline, k6 within thresholds for
  hot paths, contract and docs updated and in sync.

## MCP servers

`.mcp.json`: context7, postman, github. Optional database and Docker servers: `mcp/README.md`.
