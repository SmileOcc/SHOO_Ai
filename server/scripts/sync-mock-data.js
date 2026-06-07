/**
 * 将 Flutter assets/mock 同步到 server/data/mock（local 环境数据源）。
 * 修改 assets/mock 后请执行: npm run sync-mock
 * 商品数据可由 npm run generate-products 生成后再 sync。
 */
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const sourceDir = path.resolve(__dirname, '../../assets/mock');
const targetDir = path.resolve(__dirname, '../data/mock');

async function collectJsonFiles(dir, base = dir) {
  const entries = await fs.readdir(dir, { withFileTypes: true });
  const files = [];
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      files.push(...(await collectJsonFiles(fullPath, base)));
      continue;
    }
    if (entry.isFile() && entry.name.endsWith('.json')) {
      files.push(path.relative(base, fullPath));
    }
  }
  return files;
}

const jsonFiles = await collectJsonFiles(sourceDir);
await fs.mkdir(targetDir, { recursive: true });

for (const relativePath of jsonFiles) {
  const targetPath = path.join(targetDir, relativePath);
  await fs.mkdir(path.dirname(targetPath), { recursive: true });
  await fs.copyFile(path.join(sourceDir, relativePath), targetPath);
}

console.log(`Synced ${jsonFiles.length} mock JSON files → ${targetDir}`);
