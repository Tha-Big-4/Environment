# File creation rules

## 1. Layout

```
docs/superpowers/plans/            (specs/ is the same)
├── SUMMARY.md        master index: every plan, its status, its location
├── next/             approved, not built yet. Stays flat (no date folders).
│   └── SUMMARY.md
└── finished/         built and reviewed. One folder per completion date.
    ├── SUMMARY.md
    └── YYYY-MM-DD/
```

## 2. Naming

`YYYY-MM-DD-<topic>-design.md` for specs, `YYYY-MM-DD-<topic>-plan.md` for plans. The date is the
day it was written; it does not change when the file moves.

## 3. Moving to finished

When a plan is executed and reviewed clean: `git mv` the plan and its spec to `finished/<today>/`,
update both `SUMMARY.md` files, and fix links that pointed at the old path.

## 4. Size

A plan over ~600 lines becomes a folder: `YYYY-MM-DD-<topic>/` with `README.md` (overview and order)
and `part-N-<name>.md` files.

## 5. Reports

Reports go in `docs/reports/<area>/YYYY-MM-DD-<topic>.md` (template: `templates/report.md`). Areas are
lowercase kebab-case, one per module or concern (`auth`, `performance`, `security`, `code-quality`).

## 6. Never

- Docs at the repo root, apart from README.md, CLAUDE.md and AGENTS.md.
- Files loose in `plans/`, `specs/` or `finished/`.
- A doc on only one side (`frontend/docs` vs `backend/docs`).
