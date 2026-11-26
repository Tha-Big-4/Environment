---
name: folder-management
description: Use when creating, moving, renaming or deleting files or folders in this environment or its project, or when unsure where a new file belongs.
---

# Folder management

## Where things go

| Thing | Place |
|---|---|
| Application code | `project/` (its own git repo) |
| Any document | `docs/` (shared with the other setup) — never the project root, never loose |
| Design / plan | `docs/superpowers/specs/next/` · `docs/superpowers/plans/next/` |
| Report | `docs/reports/<area>/YYYY-MM-DD-<topic>.md` |
| API contract | `docs/api/` |
| Knowledge | `docs/second-brain/<NN-folder>/` |
| Tool config | `config/`, budgets in `benchmarks/`, MCP in `.mcp.json` + `mcp/` |
| Scratch output | `reports/` (git-ignored; delete freely) |

## Rules

1. Look before you create: search for an existing file that already covers it, and extend it.
2. Names: lowercase kebab-case; dated docs `YYYY-MM-DD-`; one responsibility per file.
3. Move with `git mv` so history follows; fix every link to the old path (`rg -l '<old-name>'`).
4. Every docs folder you touch: update its `SUMMARY.md` in the same change.
5. A change under `docs/` → run `pwsh scripts/sync-docs.ps1` and commit both setups' docs.
6. Never delete a doc that another doc links to without fixing the link.
7. Empty folders are not committed; add a `SUMMARY.md` or `README.md` saying what belongs there.
