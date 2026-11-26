# Testing rules

## Layers

| Layer | What it proves | Runs | Where |
|---|---|---|---|
| Unit | One function or component in isolation | Every commit (pre-push), CI | Next to the code or `tests/unit` |
| Architecture | Layering, naming and security rules hold (e.g. every endpoint has auth) | Pre-push, CI | `tests/architecture` |
| Integration | Real database, queue or HTTP pipeline (Testcontainers / Docker) | `verify.ps1 -Full`, CI | `tests/integration` |
| Contract | Frontend and backend agree with `docs/api/openapi/` | CI | Both sides |
| API | Every endpoint's success and documented error cases over real HTTP (Postman CLI) | `api-test.ps1`, CI | `docs/api/postman/` |
| End-to-end | A user journey through the real UI (Playwright) | `verify.ps1 -Full`, nightly | `e2e/` |
| Performance | Budgets and load thresholds (`PERFORMANCE_RULES.md`) | `perf-bench.ps1`, before release | `benchmarks/` |
| Security | Scanners against the baseline (`SECURITY_RULES.md`) | `security-scan.ps1`, CI | `benchmarks/` |

## Automation

- `scripts/api-test.ps1` runs the Postman collection against the running API (backend) or the mock (frontend).
- `scripts/verify.ps1` detects the stack and runs lint → build → unit tests. `-Full` adds integration and e2e.
- The `pre-push` hook runs `verify.ps1`; CI runs the same script, so local and CI agree.
- Logs go to `reports/`; the console shows one line per step.

## Rules

- A bug fix starts with a test that reproduces the bug.
- Tests do not depend on the current date, the network or the order they run in. Use a fixed clock.
- Unit tests mock HTTP; nothing reaches a real server.
- Never skip, delete or weaken a failing test to go green. Fix the code or the test's wrong assumption.
- Test names describe behaviour: `rejects_expired_token`, `shows_empty_state_when_no_tasks`.
