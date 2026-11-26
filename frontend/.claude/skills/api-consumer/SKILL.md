---
name: api-consumer
description: Use when frontend code calls, adds or changes a call to a backend endpoint, or when the shared API contract in docs/api changed.
---

# Consuming the API

The contract is `docs/api/` (owned by the backend, shared through docs sync).

1. **Read the contract first:** the endpoint doc in `docs/api/endpoints/<module>/`, its error codes in
   `docs/api/errors.md`, recent entries in `docs/api/changelog.md`.
2. **Generate types, don't write them:**
   `npx openapi-typescript ../docs/api/openapi/<file>.json -o src/api/types.ts` (run in `project/`).
3. **Handle every documented error code** the endpoint can return; switch on `code`, show `detail`.
4. **Before the backend ships:** `docker compose -f docker/compose.yml up -d api-mock` serves the
   contract on http://localhost:4010.
5. **Missing or wrong in the contract?** Do not guess. Write the need in the spec, tell the backend,
   or propose the change in `docs/api/` and sync it; the backend owns the final shape.
6. **Tests mock HTTP** with responses that match the contract; no test reaches a real server.
