# Frontend Docker

| Service | Start | What |
|---|---|---|
| `api-mock` | `docker compose -f docker/compose.yml up -d` | Prism mock of the shared API contract on http://localhost:4010. Set `OPENAPI_FILE` to your file in `docs/api/openapi/`. |
| `web` | `docker compose -f docker/compose.yml --profile app up -d --build` | Production build of `project/` served by unprivileged nginx on http://localhost:8080, with security headers. |

`Dockerfile` and `nginx.conf` are generic; tune `BUILD_CMD`, `DIST_DIR` and the CSP for your app.
`security-scan.ps1 -Only config` (Trivy) checks these files.
