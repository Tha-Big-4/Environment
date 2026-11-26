# Benchmarks

| File | Used by | Budget |
|---|---|---|
| `lighthouserc.json` | `scripts/perf-bench.ps1` (Lighthouse CI) | Performance ≥ 0.90, accessibility ≥ 0.95, LCP ≤ 2.5 s, CLS ≤ 0.1, TBT ≤ 200 ms, JS ≤ 250 KB, CSS ≤ 50 KB |
| `budgets.json` | Lighthouse budgets / bundler budget config | Resource sizes (KB) and timings (ms) |
| `security-baseline.json` | `scripts/security-scan.ps1` | Accepted finding count per check; a run fails when a count goes up |

Rules: `docs/rules/PERFORMANCE_RULES.md`, `docs/rules/SECURITY_RULES.md`. Lower a number when you
improve; never raise one without a report in `docs/reports/`.
