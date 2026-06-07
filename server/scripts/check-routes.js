#!/usr/bin/env node
/**
 * Smoke-test all registered routes against a running server.
 * Usage: npm run check
 *        API_BASE=http://127.0.0.1:3847 npm run check
 */
import { routes } from '../src/routeRegistry.js';

const base = process.env.API_BASE ?? 'http://127.0.0.1:3847';
const prefix = '/api/v1';

const samples = {
  '/products/{id}': '/products/c1-p1',
  '/products/{id}/reviews': '/products/c1-p1/reviews',
  '/orders/{id}': '/orders/o1',
  '/orders/{id}/logistics': '/orders/o1/logistics',
};

let failed = 0;

for (const route of routes) {
  const samplePath = samples[route.path] ?? route.path;
  const url = `${base}${prefix}${samplePath}`;
  try {
    const init = route.method === 'POST' ? { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: '{}' } : {};
    const res = await fetch(url, init);
    const json = await res.json();
    if (!res.ok || json.code !== 0) {
      console.error(`FAIL ${route.method} ${samplePath} → ${res.status} code=${json.code}`);
      failed++;
    } else {
      console.log(`OK   ${route.method} ${samplePath}`);
    }
  } catch (error) {
    console.error(`FAIL ${route.method} ${samplePath} → ${error.message}`);
    failed++;
  }
}

if (failed > 0) {
  console.error(`\n${failed} route(s) failed. Is the server running? (npm run dev)`);
  process.exit(1);
}

console.log(`\nAll ${routes.length} routes OK.`);
