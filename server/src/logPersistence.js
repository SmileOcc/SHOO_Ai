import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const logsDir = path.resolve(__dirname, '../logs');

const files = {
  analytics: 'analytics.jsonl',
  network: 'network-logs.jsonl',
  api: 'api-requests.jsonl',
};

let ready = false;

async function ensureLogsDir() {
  if (ready) return;
  await fs.mkdir(logsDir, { recursive: true });
  ready = true;
}

async function appendJsonl(filename, record) {
  await ensureLogsDir();
  const line = `${JSON.stringify({ ts: new Date().toISOString(), ...record })}\n`;
  await fs.appendFile(path.join(logsDir, filename), line, 'utf8');
}

export async function persistAnalytics(body) {
  await appendJsonl(files.analytics, { type: 'analytics', body });
}

export async function persistNetworkLog(body) {
  await appendJsonl(files.network, { type: 'network-log', body });
}

export async function persistApiRequest(record) {
  await appendJsonl(files.api, { type: 'api', ...record });
}

export function getLogsDir() {
  return logsDir;
}

export function getLogFiles() {
  return { ...files, dir: logsDir };
}
