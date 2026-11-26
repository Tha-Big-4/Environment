# Security rules

## Scanners (`scripts/security-scan.ps1`)

| Check | Tool | Finds |
|---|---|---|
| `secrets` | gitleaks | Secrets in files and git history |
| `sast` | Semgrep (`p/default`, `p/owasp-top-ten`) | Injection, XSS, unsafe crypto, auth mistakes |
| `deps` | osv-scanner + the stack's own audit (`npm audit`, `dotnet list package --vulnerable`, `pip-audit`, `govulncheck`, `cargo audit`) | Vulnerable dependencies |
| `config` | Trivy (`fs` misconfig) | Dockerfile, compose, IaC and CI misconfigurations |

Exit codes: `0` clean, `1` findings above the baseline, `2` a scanner failed or is missing. A scanner that
fails is never reported as a pass.

## Security benchmark

`benchmarks/security-baseline.json` holds the accepted finding count per check. A run fails when any
count goes **up**. Lower the baseline when you fix findings (`security-scan.ps1 -UpdateBaseline`);
never raise it without a written reason in `docs/reports/security/`.

## Rules for code

- No secrets in code, config or docs. Use environment variables; `.env` is git-ignored, `.env.example` lists names only.
- Every endpoint declares authentication and authorization. Deny by default.
- Validate and size-limit all input. Parameterize every query.
- Never put user data into raw HTML. Sanitize rich text on write and on render.
- Sessions in HttpOnly, Secure, SameSite cookies; CSRF protection on unsafe methods.
- Security headers (CSP, HSTS, X-Content-Type-Options, frame-ancestors) on every response.
- Rate-limit authentication and expensive endpoints.
- Log security events without logging secrets or personal data.
- Dependencies: update promptly (Dependabot), remove unused ones (`cleanup-scan.ps1`).
