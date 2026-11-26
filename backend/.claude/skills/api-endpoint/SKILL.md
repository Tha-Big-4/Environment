---
name: api-endpoint
description: Use when adding, changing or removing a backend endpoint, or changing a request, response or error code the frontend depends on.
---

# Building an endpoint

The backend owns the shared contract in `docs/api/`. An endpoint is not done until the contract says
what the code does (PROCESS_RULES rule 4).

1. **Contract first.** Breaking change? Add the `docs/api/changelog.md` entry with the frontend
   migration before writing code. New error codes go in `docs/api/errors.md` (`<module>_<what>`).
2. **Test first.** Write the failing tests: success, validation (400), unauthenticated (401),
   forbidden (403), not found **or not visible** (404, same body), conflict (409) where it applies.
3. **Build it.** Validate input at the boundary, declare auth explicitly (deny by default), parameterize
   queries, return ProblemDetails with a stable `code`. Paginate lists.
4. **Architecture tests** must still pass (every endpoint has auth; tenant data is isolated).
5. **Update the contract:** regenerate or edit `docs/api/openapi/`; write
   `docs/api/endpoints/<module>/<Endpoint Name>.md` from `_TEMPLATE.md`; add it to the module `SUMMARY.md`.
6. **Postman:** re-import the OpenAPI file or add the request to `docs/api/postman/` (Postman MCP can do it).
7. **Benchmark hot paths:** add or extend a k6 script in `benchmarks/k6/`; `pwsh scripts/perf-bench.ps1`.
8. **Gate and sync:** `pwsh scripts/verify.ps1 -Full`, `pwsh scripts/security-scan.ps1`,
   `pwsh scripts/sync-docs.ps1`. Commit code and both docs copies.
