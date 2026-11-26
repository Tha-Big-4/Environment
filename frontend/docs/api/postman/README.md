# Postman

The shared API test suite. The backend owns it; the frontend can run it against the contract mock.

| File | What |
|---|---|
| `api.postman_collection.json` | Requests with tests, one folder per module. Collection-level tests check every response: under 800 ms, and errors in the ProblemDetails shape. |
| `local.postman_environment.json` | `baseUrl` = http://localhost:5000 (the running backend). `token` is empty on purpose. |
| `mock.postman_environment.json` | `baseUrl` = http://localhost:4010 (frontend `docker compose up api-mock`). |

## Run

```powershell
pwsh scripts/api-test.ps1                                           # local environment
pwsh scripts/api-test.ps1 -Environment docs/api/postman/mock.postman_environment.json
pwsh scripts/api-test.ps1 -BaseUrl http://localhost:8080 -EnvVar "token=$env:API_TOKEN"
```

It uses the Postman CLI (`npm install -g postman-cli`, installed by `setup.ps1 -Install`), runs locally,
uploads nothing, and writes a YAML run report to the setup's `reports/api-test-<time>/`.
Exit `0` all tests passed, `1` a test failed, `2` the CLI or collection is missing.

## Rules

- Every finished endpoint gets a request here, in its module folder, with tests for the success case and
  each documented error code (`docs/api/endpoints/<module>/<Endpoint>.md`).
- **No secrets in these files.** Tokens and passwords are passed at run time with `-EnvVar`, or kept as
  Postman "current values", which are never exported. gitleaks checks every commit.
- For every endpoint at once (no tests), import `../openapi/<file>.json` into Postman instead.
- Agents can build and run collections with the Postman MCP server (`backend/.mcp.json`).
