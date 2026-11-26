# OpenAPI documents

Put the OpenAPI 3.1 files here, one per audience, for example `public-v1.json`, `admin-v1.json`.
`api-v1.example.json` shows the expected shape; delete it once the project has a real file.

## Keeping them current

- Generate them from code at build time where the stack can (ASP.NET `Microsoft.AspNetCore.OpenApi`,
  FastAPI, NestJS Swagger, springdoc, etc.), and commit the result here.
- Add a test that fails when the committed file differs from what the build produces, so the docs
  cannot drift from the code.
- Never commit server URLs that are private, or example data that is real.

## Uses

- **Frontend types:** `npx openapi-typescript docs/api/openapi/<file>.json -o <project>/src/api/types.ts`.
- **Mock server:** the `api-mock` service in `frontend/docker/compose.yml` serves these files (Prism).
- **Postman:** Import → File → pick a file → import as a collection.
- **Contract tests:** validate real responses against these files in CI.
