# Backend MCP servers

`../.mcp.json` is loaded when you start Claude Code in `backend/`. Keys come from environment
variables (`${NAME}`): put them in `backend/.env` and run `pwsh scripts/setup.ps1 -ApplyEnv`.

| Server | For | Key |
|---|---|---|
| **context7** | Current docs for the framework, ORM and libraries in use | none (sign in on first use) |
| **postman** | Build, run and document collections from the shared contract (`docs/api/`) | sign in on first use |
| **github** | Issues, PRs, code search | `GITHUB_TOKEN` (optional) |

## Optional servers (`optional/`)

| File | For | Note |
|---|---|---|
| `postgres-dbhub.json` | Query the **local** dev database (read-only) | `DATABASE_URL`; never point it at a shared or production DB |
| `docker.json` | Docker MCP gateway (containers, logs) | Needs Docker Desktop's MCP Toolkit |

Copy an entry into `../.mcp.json` when the project needs it.

## Adding a server

1. Add it to `../.mcp.json` (keys as `${NAME:-}`).
2. Add the key to `../.env.example` and `EnvKeys` in `../environment.psd1`.
3. Add a row to the table above.
