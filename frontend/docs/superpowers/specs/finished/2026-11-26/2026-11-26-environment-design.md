# Environment — design

**Status:** Approved 2026-11-26. **Plan:** [../../../plans/finished/2026-11-26/2026-11-26-environment-plan.md](../../../plans/finished/2026-11-26/2026-11-26-environment-plan.md)

## Intent

A public, stack-agnostic coding environment. Clone it, put a project inside `frontend/project/` or
`backend/project/`, and you get the coding style, documentation method, second brain, design tools,
MCP servers, automated tests, security and performance checks and benchmarks without setting them up again.

## Goals

- Two self-contained setups, `frontend/` and `backend/`, each with its own CLAUDE.md, scripts, MCP config, skills, Docker, hooks and benchmarks.
- One shared `docs/` folder, identical in both setups. It is the only connection between them.
- `docs/api/` is the main shared piece: the contract the backend publishes and the frontend consumes.
- Scripts detect the stack (Node, .NET, Python, Go, Java, Rust, PHP) and run the right tools.
- Frontend ships the design MCP servers (Google Stitch, Inspo, BoardUI, Playwright, Context7) and Stitch skills.
- New tools are added later, one at a time, as a script step plus a `setup.ps1` entry.

## Non-goals and anti-goals

- No stack-specific starter code. The environment never creates the project for you.
- Nothing from a private project (names, paths, hosts) and no secrets. Keys are `${ENV_VAR}` placeholders.
- A scanner that fails to run is never reported as a pass.

## Approaches

| Approach | Trade-off | Picked |
|---|---|---|
| Common core + stack auto-detect | One set of scripts for every stack; detection must be kept honest | **Yes** |
| Docs and checklists only | Nothing runs automatically | No |
| One starter per stack | Stack-specific again | No |

## Decisions

- `docs/` is copied, not symlinked (Windows symlinks break in git). `sync-docs.ps1` copies, CI and the pre-commit hook check.
- Scripts are PowerShell 7 (`pwsh`), which runs on Windows, macOS and Linux.
- Exit codes: `0` clean, `1` findings, `2` a tool failed or is missing.
- `project/*` is git-ignored by the template; the project keeps its own git history.
- MCP keys live in `<setup>/.env` (git-ignored). `setup.ps1 -ApplyEnv` copies them into user environment variables so MCP servers see them.

## Left to the builder

Exact tool flags, default thresholds and the wording of rules, within the constraints above.
