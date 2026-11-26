# API — the contract between frontend and backend

This is the most important folder in the environment. The **backend publishes** the contract here;
the **frontend builds against it**. Both setups have the same copy (`docs/` is shared).

| Path | What | Who writes it |
|---|---|---|
| [openapi/](openapi/) | OpenAPI 3.1 files, the machine-readable contract. Frontend types and the mock server come from here. | Backend (generated at build time where the stack allows) |
| [endpoints/](endpoints/) | One Markdown doc per endpoint, grouped by module, readable on GitHub. | Backend, when the endpoint ships |
| [errors.md](errors.md) | Every stable error `code` and what the UI should do with it. | Backend |
| [changelog.md](changelog.md) | Breaking and notable changes, newest first, with the frontend migration. | Backend; frontend acknowledges |
| [postman/](postman/) | Postman collection and environments (no secrets). | Either side |

## Conventions (defaults; record changes in `changelog.md`)

- Base path `/api/v1/...`. A breaking change gets a new version, never a silent change.
- JSON in camelCase. Times are ISO-8601; the server returns UTC.
- Errors: ProblemDetails `{ status, title, detail, code }`, `code` from `errors.md`.
- 404 for "not found **or not allowed to see**", with the same body, so existence does not leak.
- Lists are paginated: `?page=&pageSize=` → `{ items, page, pageSize, total }`.
- Auth is declared per endpoint in the OpenAPI security schemes and in the endpoint doc.

## Workflow

1. Backend designs the endpoint, writes the endpoint doc from [`endpoints/_TEMPLATE.md`](endpoints/_TEMPLATE.md) and updates `openapi/`.
2. Run `pwsh scripts/sync-docs.ps1` so the frontend copy matches.
3. Frontend regenerates types from `openapi/` and can work against the mock (`frontend/docker`, `api-mock` service) before the backend ships.
4. Breaking change → `changelog.md` entry first, then the code.
