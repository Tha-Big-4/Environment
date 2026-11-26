# Backend Docker

| Service | Port | What |
|---|---|---|
| `postgres` | 127.0.0.1:5432 | PostgreSQL 17 (`dev` / `$POSTGRES_PASSWORD`, db `app`) |
| `redis` | 127.0.0.1:6379 | Cache / queues |
| `mailpit` | 127.0.0.1:8025 (UI), 1025 (SMTP) | Catches every email the app sends |
| `sqlserver` (profile) | 127.0.0.1:1433 | SQL Server 2022 for .NET projects that need it |
| `api` (profile `app`) | 127.0.0.1:5000 | The project, built from `project/Dockerfile` |

Ports bind to `127.0.0.1` only. Integration tests should use **Testcontainers** (their own throwaway
containers), not these long-lived services, so tests never share state. Trivy (`security-scan.ps1
-Only config`) checks this file and the project's Dockerfile.

## Dockerfile rules for the project

- Multi-stage: build with the SDK image, run on the smallest runtime image.
- Run as a non-root user; no secrets in layers (`--mount=type=secret` or runtime env).
- `HEALTHCHECK` on the health endpoint; pin base image versions.
