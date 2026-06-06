import fs from 'node:fs/promises';
import path from 'node:path';
import { config } from './config.js';

const cache = new Map();

export async function loadMockJson(fileName) {
  const cacheKey = fileName;
  if (cache.has(cacheKey)) return cache.get(cacheKey);

  const filePath = path.join(config.mockDataDir, fileName);
  const raw = await fs.readFile(filePath, 'utf8');
  const json = JSON.parse(raw);
  cache.set(cacheKey, json);
  return json;
}

export function clearMockCache() {
  cache.clear();
}
