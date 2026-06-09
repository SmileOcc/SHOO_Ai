/**
 * 扫描 server/data/download/ 并同步清单到 mock JSON（不覆盖已有文件）。
 */
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { listDownloadFiles } from '../src/documentDownload.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

async function main() {
  const data = await listDownloadFiles();
  const catalog = { code: 0, message: 'ok', data };
  const json = `${JSON.stringify(catalog, null, 2)}\n`;

  const mockPath = path.resolve(__dirname, '../data/mock/documents.json');
  const assetsPath = path.resolve(__dirname, '../../assets/mock/documents.json');

  await fs.writeFile(mockPath, json, 'utf8');
  await fs.writeFile(assetsPath, json, 'utf8');

  console.log(`Synced ${data.length} file(s) → ${mockPath}`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
