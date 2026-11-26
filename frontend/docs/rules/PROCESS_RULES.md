# Process rules

## 1. Plan before non-trivial work

Anything bigger than a one-file fix gets a design in `superpowers/specs/next/` (template: `templates/spec.md`)
and a plan in `superpowers/plans/next/` (template: `templates/plan.md`) before code is written.

## 2. Definition of done

A change is done only when all of these hold:

1. `pwsh scripts/verify.ps1` exits `0` (lint, build, tests; zero warnings).
2. `pwsh scripts/security-scan.ps1` reports no finding above the security baseline.
3. Performance-sensitive changes: `pwsh scripts/perf-bench.ps1` stays inside the budgets.
4. Docs that describe the change are updated in the same commit, on both sides (rule 5).
5. API changes are in `docs/api/` (rule 4).

## 3. Never hide a failure

Do not suppress a warning, disable a test, lower a budget or use `--no-verify` to make a check pass.
Fix the code. A truly unavoidable suppression needs the lead's sign-off and a comment saying why.

## 4. Every endpoint change updates `docs/api/`

Adding, changing or removing an endpoint is not finished until:

- the OpenAPI file in `docs/api/openapi/` is regenerated or edited,
- the endpoint's Markdown doc exists in `docs/api/endpoints/<module>/` (template: `docs/api/endpoints/_TEMPLATE.md`),
- new error codes are in `docs/api/errors.md`,
- breaking changes are in `docs/api/changelog.md` with the date and the migration for the frontend.

## 5. Docs are shared

`docs/` exists in both setups and must stay identical. See [DOCS_SYNC_RULES.md](DOCS_SYNC_RULES.md).

## 6. Each folder keeps its own `SUMMARY.md`

When you add, move or finish a file, update the `SUMMARY.md` of every folder it touched.

## 7. Specs and plans follow `FILE_CREATION_RULES.md`

## 8. Record what you learn

A decision that shaped the design goes in `second-brain/02-decisions/`. A trap that cost time goes in
`second-brain/04-gotchas/` with its fix.
