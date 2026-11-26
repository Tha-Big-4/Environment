# Environment — implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:executing-plans. Steps use `- [ ]` checkboxes.

**Goal:** Build the two-setup environment described in the spec and publish it as the public repo `Tha-Big-4/Environment`.
**Architecture:** `frontend/` and `backend/` are full setups. `docs/` is mirrored between them. Scripts share `scripts/lib/common.ps1`, which detects stacks.
**Tech stack:** PowerShell 7, Docker Compose, GitHub Actions, gitleaks, Semgrep, osv-scanner, Trivy, jscpd, Knip, Lighthouse CI, k6.
**Spec:** [../../../specs/finished/2026-11-26/2026-11-26-environment-design.md](../../../specs/finished/2026-11-26/2026-11-26-environment-design.md)

## Global constraints

- No secrets and no private-project names anywhere in the repo.
- `frontend/docs` and `backend/docs` are byte-identical.
- Every script prints one line per step and writes full logs to `<setup>/reports/` (git-ignored).
- Exit codes `0` / `1` / `2` as in the spec.

## Review focus

- An empty `project/` folder: scripts say "no project found" and exit 2, not 0.
- A project nested one level down (`project/my-app/`): detected.
- A missing tool (`gitleaks` not installed): reported as `MISSING`, exit 2.
- Docs edited on one side only: `sync-docs.ps1 -Check` exits 1 and names the files.
- `STITCH_API_KEY` unset: `setup.ps1` names the missing key; the MCP config still parses.

## Tasks

- [x] **1. Shared docs** — `docs/` index, rules (process, file creation, docs sync, coding style, testing, security, performance), `api/` (openapi, endpoints + template, errors, changelog, postman), `design/`, `templates/`, `superpowers/`, `reports/`, `second-brain/`.
- [x] **2. Scripts** — `lib/common.ps1` (`Get-ProjectStacks`, `Invoke-Step`, `Write-StepLine`), `verify.ps1`, `security-scan.ps1`, `perf-bench.ps1`, `cleanup-scan.ps1`, `sync-docs.ps1`, `setup.ps1`; tests in `scripts/tests/run-tests.ps1` cover the review-focus cases.
- [x] **3. Frontend setup** — CLAUDE.md, `.mcp.json` (stitch, inspo, boardui, playwright, context7, github), skills (design-workflow, api-consumer + shared), Lighthouse budgets, Docker (static build + API mock from OpenAPI).
- [x] **4. Backend setup** — CLAUDE.md, `.mcp.json` (context7, postman, github), skills (api-endpoint + shared), k6 benchmarks, Docker (Postgres, Redis, Mailpit profiles).
- [x] **5. Root** — README, `.gitignore`, CI (docs sync, gitleaks, script tests), PR template, Dependabot.
- [x] **6. Publish** — create the public repo and push.
