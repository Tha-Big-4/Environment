# Error codes

Every error response is ProblemDetails with a stable `code`:

```json
{ "status": 409, "title": "Conflict", "detail": "Someone else changed this. Reload and try again.", "code": "task_changed" }
```

`detail` is safe to show to the user. `code` never changes once published; the frontend switches on it.
Name codes `<module>_<what>` in snake_case.

## Generic codes

| Status | Code | Meaning | Frontend should |
|---|---|---|---|
| 400 | `validation_failed` | Body or query failed validation; `errors` lists fields | Show field errors |
| 401 | `unauthenticated` | No or expired session | Send to sign-in |
| 403 | `forbidden` | Signed in, not allowed | Show "no access" |
| 404 | `not_found` | Missing or not visible | Show not found |
| 409 | `conflict` | State or concurrency conflict | Offer reload |
| 429 | `rate_limited` | Too many requests; `Retry-After` header | Wait and retry |
| 500 | `server_error` | Unexpected; has a `traceId` | Show generic error + trace id |
| 503 | `feature_disabled` | Feature flag off | Hide the feature |

## Module codes

| Module | Status | Code | Meaning |
|---|---|---|---|
| _(add as endpoints ship)_ | | | |
