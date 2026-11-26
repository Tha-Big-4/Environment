# Environment

A generic coding environment for **any stack**. Clone it, put your project in `frontend/project/` or
`backend/project/`, and you get the coding style, documentation system, second brain, design and MCP
tools, automated tests, and security and performance benchmarks without setting them up again.

```
Environment/
├── frontend/          full frontend setup (design MCPs: Google Stitch, Inspo, BoardUI, Playwright)
│   ├── project/       ← your frontend app goes here
│   └── docs/          ◄─┐
├── backend/           full backend setup (Docker services, k6 load tests, Postman)
│   ├── project/       ← your backend/API goes here
│   └── docs/          ◄─┘ identical copies: the shared link between the two setups
└── .github/           CI: docs in sync, scripts identical, self-tests, no secrets
```

## Start a project

```powershell
git clone https://github.com/Tha-Big-4/Environment.git my-product
cd my-product/frontend               # or backend
pwsh scripts/setup.ps1 -Install      # tools, plugins, .env, hooks
cd project; <clone or create your app here>; cd ..
pwsh scripts/setup.ps1               # hooks the project repo into the gates
pwsh scripts/verify.ps1              # lint + build + tests, whatever the stack
claude                               # Claude Code with this setup's CLAUDE.md, skills and MCP servers
```

Needs PowerShell 7 (`winget install Microsoft.PowerShell`, `brew install powershell`), Git and Docker.

## What each setup gives you

| Area | How |
|---|---|
| Coding style and method | `docs/rules/CODING_STYLE.md`, `CLAUDE.md`, `AGENTS.md` |
| Documentation | `docs/` layout, rules and templates; specs and plans move `next/` → `finished/<date>/` |
| API contract | `docs/api/`: OpenAPI, endpoint docs, error codes, changelog, Postman |
| Second brain | `docs/second-brain/`: wiki-linked timeline, decisions, architecture, gotchas (opens in Obsidian) |
| Design | `docs/design/` + frontend MCP servers + the design-workflow skill |
| Tests | `scripts/verify.ps1` detects Node, .NET, Python, Go, Java, Rust, PHP and runs lint, build, tests |
| Security | `scripts/security-scan.ps1`: gitleaks, Semgrep, osv-scanner, stack audit, Trivy vs a baseline |
| Performance | `scripts/perf-bench.ps1`: Lighthouse CI (frontend) or k6 (backend) vs budgets |
| Code cleanup | `scripts/cleanup-scan.ps1`: jscpd, Knip, Roslyn, ruff, staticcheck (report only) |
| Agent tooling | `.mcp.json`, `.claude/skills/` (folder-management, docs-management, second-brain, …) |
| Automation | git hooks (pre-commit, pre-push), Docker Compose, GitHub Actions |

## Rules that keep it working

- `docs/` is identical in both setups: edit one, run `pwsh scripts/sync-docs.ps1`, commit both.
- `scripts/` and the shared skills are identical in both setups; CI checks it.
- No secrets anywhere: keys are `${ENV_VAR}` placeholders, values live in git-ignored `.env` files.
- Adding a tool: an entry in `<setup>/environment.psd1`, a step in the matching script, a line in the docs.
