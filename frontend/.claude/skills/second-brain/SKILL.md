---
name: second-brain
description: Use when starting work on an unfamiliar part of the project (to load context), and after finishing a plan, making a design decision or hitting a trap that cost time (to record it).
---

# Second brain

The brain is `docs/second-brain/`. Read `RULES.md` there first.

## Loading context (start of work)

1. Read `SUMMARY.md`, then `INDEX.md`.
2. Open the module note in `06-modules/` and the gotchas in `04-gotchas/` for the area.
3. Follow `sources` to the full spec, plan or report only when you need detail.

## Recording (end of work)

| Event | Write |
|---|---|
| Plan finished | One line in `01-timeline/YYYY-Www.md`: date, what shipped, link to the plan |
| Real decision made | `02-decisions/YYYY-MM-DD-<decision>.md` from `docs/templates/decision.md` |
| Trap that cost > 15 min | `04-gotchas/<symptom>.md`: symptom, cause, fix |
| New cross-cutting pattern | `03-architecture/<pattern>.md` |
| New module | `06-modules/<module>.md` linking its specs, plans, endpoint docs, design exports |

Then update that folder's `SUMMARY.md`, `INDEX.md` and the top `SUMMARY.md` state line, and run
`pwsh scripts/sync-docs.ps1`. Distil and link; never paste whole docs in.
