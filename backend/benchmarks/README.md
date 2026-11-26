# Benchmarks

| File | Used by | Budget |
|---|---|---|
| `k6/smoke.js` | `pwsh scripts/perf-bench.ps1` | 1 user, 30 s; p95 ≤ 300 ms, p99 ≤ 800 ms, errors < 1 % |
| `k6/load.js` | `pwsh scripts/perf-bench.ps1 -Script load` | Ramp to 50 users; same thresholds. Set `ENDPOINTS=/a,/b` for hot paths |
| `security-baseline.json` | `pwsh scripts/security-scan.ps1` | Accepted finding count per check; a run fails when a count goes up |

k6 exits non-zero when a threshold is crossed, and `perf-bench.ps1` reports that as exit `1`.
Rules: `docs/rules/PERFORMANCE_RULES.md`, `docs/rules/SECURITY_RULES.md`. Lower numbers as you
improve; never raise one without a report in `docs/reports/`.
