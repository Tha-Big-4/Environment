# Docs — start here

This `docs/` folder is **shared**. `frontend/docs/` and `backend/docs/` are identical copies, and this
folder is the only connection between the two setups. Change it on one side, then run
`pwsh scripts/sync-docs.ps1` from that side ([rules/DOCS_SYNC_RULES.md](rules/DOCS_SYNC_RULES.md)).

## Where things are

| Folder | What's in it |
|---|---|
| [api/](api/) | **The contract between frontend and backend.** OpenAPI files, one Markdown doc per endpoint, error codes, breaking-change log, Postman collection. |
| [rules/](rules/) | How work and docs are done: process, file creation, docs sync, coding style, testing, security, performance. |
| [design/](design/) | Design system: tokens, components, Google Stitch exports, references. |
| [templates/](templates/) | Copy-and-fill templates: spec, plan, report, decision record, endpoint, second-brain note. |
| [superpowers/specs/](superpowers/specs/) | Designs. `next/` = approved, not built; `finished/<date>/` = built. Index: `SUMMARY.md`. |
| [superpowers/plans/](superpowers/plans/) | Implementation plans. Same `next/` / `finished/<date>/` split. |
| [reports/](reports/) | Point-in-time reports, one folder per area, `YYYY-MM-DD-` prefix. |
| [second-brain/](second-brain/) | Distilled, wiki-linked knowledge: timeline, decisions, architecture, gotchas, workflow. |

## Conventions

- File names: lowercase kebab-case. Dated docs start with `YYYY-MM-DD-`.
- Nothing loose at the docs root or directly in `plans/`, `specs/` or `finished/`.
- Move files with `git mv` and update the folder's `SUMMARY.md` in the same change.
- When code changes what a doc describes, update the doc in the same change.
