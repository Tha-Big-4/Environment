// Smoke: 1 user, 30 s. Proves the service answers within budget. Run: pwsh scripts/perf-bench.ps1
import http from 'k6/http';
import { check, sleep } from 'k6';

const BASE = __ENV.BASE_URL || 'http://localhost:5000';
const PATH = __ENV.HEALTH_PATH || '/api/v1/health';

export const options = {
  vus: 1,
  duration: '30s',
  thresholds: {
    http_req_failed: ['rate<0.01'],
    http_req_duration: ['p(95)<300', 'p(99)<800'],
    checks: ['rate>0.99'],
  },
};

export default function () {
  const res = http.get(`${BASE}${PATH}`);
  check(res, { 'status is 200': (r) => r.status === 200 });
  sleep(1);
}
