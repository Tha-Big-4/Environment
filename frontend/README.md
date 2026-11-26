# Frontend environment

A complete, stack-agnostic setup for building a frontend: coding rules, shared docs and API contract,
design MCP servers (Google Stitch, Inspo, BoardUI, Playwright), automated tests, security and
performance benchmarks.

## Quick start

```powershell
cd frontend
pwsh scripts/setup.ps1 -Install                 # tools, stitch-skills, .env
notepad .env                                    # add STITCH_API_KEY (and GITHUB_TOKEN if wanted)
pwsh scripts/setup.ps1 -ApplyEnv                # makes the keys visible to MCP servers
cd project; git clone <your-frontend-repo> .    # or create a new app here
cd ..; pwsh scripts/setup.ps1                   # installs git hooks into project/
pwsh scripts/verify.ps1                         # lint + build + tests
claude                                          # start Claude Code here: loads CLAUDE.md, skills, MCP servers
```

## What's here

| Path | What |
|---|---|
| `project/` | Your app (own git repo, ignored by the environment repo) |
| `docs/` | **Shared** with `backend/docs`: API contract, rules, design, templates, plans, second brain |
| `CLAUDE.md`, `AGENTS.md` | Instructions for AI agents (and humans) |
| `.mcp.json`, `mcp/` | MCP servers and how to configure them |
| `.claude/skills/` | design-workflow, api-consumer, docs-management, folder-management, second-brain |
| `scripts/` | setup, verify, security-scan, perf-bench, cleanup-scan, sync-docs (+ `tests/`) |
| `benchmarks/` | Lighthouse budgets, bundle budgets, security baseline |
| `docker/` | API mock from the contract; production image (nginx, security headers) |
| `.githooks/` | pre-commit (docs in sync, no secrets), pre-push (verify) |
| `config/` | Tool configs (jscpd) |
| `environment.psd1` | Tool list, keys, plugins, perf settings for this setup |

## Adding a tool

1. Add an entry to `Tools` (or `Plugins`) in `environment.psd1`.
2. If it runs as a check, add a step to the matching script in `scripts/`.
3. Document it in `CLAUDE.md` and `docs/rules/`, then `pwsh scripts/sync-docs.ps1`.
