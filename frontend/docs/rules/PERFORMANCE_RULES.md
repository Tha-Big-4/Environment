# Performance rules

## Benchmarks (`scripts/perf-bench.ps1`)

| Setup | Tool | Budget file | Default budget |
|---|---|---|---|
| Frontend | Lighthouse CI | `frontend/benchmarks/lighthouserc.json` | Performance ≥ 0.90, Accessibility ≥ 0.95, LCP ≤ 2.5 s, CLS ≤ 0.1, TBT ≤ 200 ms |
| Frontend | Bundle size | `frontend/benchmarks/budgets.json` | Initial JS ≤ 250 KB gzip, CSS ≤ 50 KB gzip |
| Backend | k6 | `backend/benchmarks/k6/*.js` | p95 ≤ 300 ms, p99 ≤ 800 ms, error rate < 1 % |

The tool's own thresholds fail the run, so `perf-bench.ps1` exits `1` when a budget is broken.
Each run's results go to `benchmarks/results/<timestamp>/` (git-ignored); record notable runs as a
report in `docs/reports/performance/`.

## Rules

- Never raise a budget to make a run pass. Reduce the cost instead, or write a report explaining
  why the budget is wrong and get it reviewed.
- Measure before optimizing; attach the before/after numbers to the change.
- Frontend: lazy-load routes, size images, avoid layout shift, keep the main thread free.
- Backend: no N+1 queries, index what you filter on, paginate lists, cache what is read often and changes rarely.
