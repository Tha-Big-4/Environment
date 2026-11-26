// Load: ramp to 50 users, hold, ramp down. Edit ENDPOINTS for the project's hot paths.
// Run: pwsh scripts/perf-bench.ps1 -Script load
import http from 'k6/http';
import { check, sleep } from 'k6';

const BASE = __ENV.BASE_URL || 'http://localhost:5000';
const ENDPOINTS = (__ENV.ENDPOINTS || '/api/v1/health').split(',');

export const options = {
  stages: [
    { duration: '1m', target: 50 },
    { duration: '3m', target: 50 },
    { duration: '30s', target: 0 },
  ],
  thresholds: {
    http_req_failed: ['rate<0.01'],
    http_req_duration: ['p(95)<300', 'p(99)<800'],
  },
};

export default function () {
  for (const path of ENDPOINTS) {
    const res = http.get(`${BASE}${path}`, { tags: { endpoint: path } });
    check(res, { [`${path} 2xx`]: (r) => r.status >= 200 && r.status < 300 });
  }
  sleep(1);
}
