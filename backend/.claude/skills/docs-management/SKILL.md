---
name: docs-management
description: Use when writing, updating, moving or finishing any document under docs/ — specs, plans, reports, API docs, design docs — or after a code change that makes a doc out of date.
---

# Docs management

Rules live in `docs/rules/` (PROCESS_RULES, FILE_CREATION_RULES, DOCS_SYNC_RULES). This is the checklist.

## Writing a new doc

1. Pick the template from `docs/templates/` (endpoint docs: `docs/api/endpoints/_TEMPLATE.md`).
2. Put it where FILE_CREATION_RULES says; name it `YYYY-MM-DD-<topic>-<kind>.md`.
3. Add a row to the folder's `SUMMARY.md`.

## After a code change

- Endpoint added/changed/removed → `docs/api/` (openapi, endpoint doc, errors.md, changelog.md).
- Architecture or a pattern changed → the matching `docs/second-brain/03-architecture/` note.
- UI changed → `docs/design/` (Stitch export, tokens).

## Finishing a plan

1. `git mv` the plan and its spec to `finished/<today>/`; update `SUMMARY.md` in `next/`, `finished/` and the top index.
2. Add the timeline line, decisions and gotchas to `docs/second-brain/` (second-brain skill).

## Always, before committing

```powershell
pwsh scripts/sync-docs.ps1          # mirror to the other setup
pwsh scripts/sync-docs.ps1 -Check   # must print PASS
```

Writing style: plain words, short sentences, lead with what matters, tables for lists of facts,
no secrets or personal data (public template).
