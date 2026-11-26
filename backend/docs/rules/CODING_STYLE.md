# Coding style and method

Applies to every stack. Stack tools (ESLint, Prettier, dotnet format, ruff, gofmt, rustfmt…) enforce
the mechanical parts; this file is the part tools cannot check.

## Method

1. **Understand first.** Read the code and docs the change touches before writing anything.
2. **Design, then plan, then build** for anything non-trivial (`PROCESS_RULES.md` rule 1).
3. **Test first.** Write the failing test, watch it fail, make it pass, refactor.
4. **Small steps, small commits.** One logical change per commit, message in the imperative
   (`Add task filter`, `Fix login redirect`). Conventional prefixes are welcome (`feat:`, `fix:`).
5. **Verify before you claim.** Run the gate and read its output before saying something works.

## Style

- **Names say what, not how.** `unpaidInvoices`, not `list2`. Booleans read as questions (`isActive`).
- **One responsibility per file and per function.** Split a file when it does two jobs.
- **No dead code.** Delete it; git remembers. `scripts/cleanup-scan.ps1` finds it.
- **No duplication** past the second copy. Extract on the third (`cleanup-scan` flags copy-paste).
- **Comments say why**, never what the next line does.
- **Errors are handled where they can be handled** and never swallowed silently.
- **No magic values.** Name constants; keep config in config, secrets in the environment.
- **Formatting is automatic.** Run the formatter; never hand-format or argue about it.
- **Zero warnings.** A build or test run that prints a warning is not finished.

## Frontend specifics

- Components are small and presentational where possible; data access lives in services or hooks.
- Colours, spacing and type come from design tokens (`docs/design/`), never hard-coded hex values.
- Accessibility: clickable things are buttons, every input has a label, everything works by keyboard.
- Never write raw HTML from data into the DOM without sanitizing it.
- API types are generated from `docs/api/openapi/`, not written by hand.

## Backend specifics

- Validate every input at the boundary; trust nothing from the client.
- Every endpoint declares its auth. Anything public says so explicitly.
- Errors use one shape (ProblemDetails-style) with a stable `code` listed in `docs/api/errors.md`.
- Database changes are migrations, reviewed and never applied to a shared database by hand.
- Multi-tenant data is isolated at the data layer, not only in queries.
