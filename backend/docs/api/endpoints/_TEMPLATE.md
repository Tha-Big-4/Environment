# <Endpoint name>

**<METHOD>** `/api/v1/<route>/{id}`

**Auth:** <session cookie + CSRF header | bearer token | public (say why)>
**Permission:** `<permission:code>` <or the relationship rule, e.g. "owner of the project">
**Idempotent:** <Yes | No — what happens on a repeat call>

## Description

<What it does and when the frontend calls it. One short paragraph.>

## Request

Path / query parameters:

| Name | Type | Required | Notes |
|---|---|---|---|
| `id` | uuid | yes | |

Body:

```json
{
  "name": "string (1-200)"
}
```

## Response

`200 OK`

```json
{
  "id": "uuid",
  "name": "string",
  "createdAt": "2026-01-01T00:00:00Z"
}
```

## Errors

| Status | Code | Cause |
|---|---|---|
| `400` | `<module>_name_invalid` | Name empty or over 200 characters |
| `403` | `<module>_forbidden` | Signed in but not allowed |
| `404` | `<module>_not_found` | Does not exist, or you may not see it |
| `409` | `<module>_changed` | Someone else changed it; reload |

## Source

Controller / route: `<path>`
Handler: `<path>`
Spec: `docs/superpowers/specs/<...>`
