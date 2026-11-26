# Backend environment

A complete, stack-agnostic setup for building a backend or API: coding rules, the shared API contract
and docs, Docker services, automated tests, security scans and load benchmarks.

## Quick start

```powershell
cd backend
pwsh scripts/setup.ps1 -Install                  # tools, .env
docker compose -f docker/compose.yml up -d       # postgres, redis, mailpit
cd project; git clone <your-backend-repo> .      # or create a new API here
cd ..; pwsh scripts/setup.ps1                    # installs git hooks into project/
pwsh scripts/verify.ps1 -Full                    # lint + build + unit + integration
claude                                           # start Claude Code here: loads CLAUDE.md, skills, MCP servers
```

## What's here

| Path | What |
|---|---|
| `project/` | Your API (own git repo, ignored by the environment repo) |
| `docs/` | **Shared** with `frontend/docs`: API contract (owned here), rules, design, templates, plans, second brain |
| `CLAUDE.md`, `AGENTS.md` | Instructions for AI agents (and humans) |
| `.mcp.json`, `mcp/` | MCP servers (context7, postman, github; optional DB, Docker) |
| `.claude/skills/` | api-endpoint, docs-management, folder-management, second-brain |
| `scripts/` | setup, verify, security-scan, perf-bench, cleanup-scan, sync-docs (+ `tests/`) |
| `benchmarks/` | k6 smoke and load scripts with thresholds, security baseline |
| `docker/` | Dev services and Dockerfile rules |
| `.githooks/` | pre-commit (docs in sync, no secrets), pre-push (verify) |
| `config/` | Tool configs (jscpd) |
| `environment.psd1` | Tool list, keys, perf settings for this setup |

## Adding a tool

1. Add an entry to `Tools` in `environment.psd1`.
2. If it runs as a check, add a step to the matching script in `scripts/`.
3. Document it in `CLAUDE.md` and `docs/rules/`, then `pwsh scripts/sync-docs.ps1`.
