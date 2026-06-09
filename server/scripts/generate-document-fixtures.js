/**
 * 在 server/data/download/ 生成样例文件，并同步目录清单到 mock JSON。
 * 你也可以直接向 download/ 目录放入任意文件，无需改 JSON。
 */
import fs from 'node:fs/promises';
import path from 'node:path';
import zlib from 'node:zlib';
import { fileURLToPath } from 'node:url';

import { listDownloadFiles } from '../src/documentDownload.js';
import { config } from '../src/config.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const targetSize = 256 * 1024;

async function writeFile(name, buffer) {
  const filePath = path.join(config.downloadDir, name);
  await fs.writeFile(filePath, buffer);
  const stat = await fs.stat(filePath);
  return stat.size;
}

function padBuffer(seed, size) {
  const buf = Buffer.alloc(size);
  const seedBuf = Buffer.from(seed);
  for (let i = 0; i < size; i++) {
    buf[i] = seedBuf[i % seedBuf.length];
  }
  return buf;
}

async function syncCatalogJson() {
  const data = await listDownloadFiles();
  const catalog = { code: 0, message: 'ok', data };

  const mockPath = path.resolve(__dirname, '../data/mock/documents.json');
  const assetsPath = path.resolve(__dirname, '../../assets/mock/documents.json');
  const json = `${JSON.stringify(catalog, null, 2)}\n`;

  await fs.writeFile(mockPath, json, 'utf8');
  await fs.writeFile(assetsPath, json, 'utf8');

  return { mockPath, count: data.length };
}

async function main() {
  await fs.mkdir(config.downloadDir, { recursive: true });

  const pdfHeader = Buffer.from(
    '%PDF-1.4\n1 0 obj<< /Type /Catalog /Pages 2 0 R >>endobj\n' +
      '2 0 obj<< /Type /Pages /Kids [] /Count 0 >>endobj\n' +
      'trailer<< /Root 1 0 R >>\n%%EOF\n',
  );
  const pdfBody = Buffer.concat([pdfHeader, padBuffer('SHOO-PDF-DOWNLOAD-FIXTURE', targetSize)]);
  await writeFile('activity-guide.pdf', pdfBody);

  const docText = Buffer.from('SHOO Activity Guide (DOC fixture)\n'.repeat(8000), 'utf8');
  await writeFile('activity-guide.doc', docText);

  const csv = 'sku,name,price\nP001,Sample Tee,9900\nP002,Sample Bag,12900\n';
  await writeFile('price-list.xlsx', Buffer.from(csv, 'utf8'));

  const zipPayload = zlib.gzipSync(
    Buffer.from('SHOO zip bundle fixture content for download testing.', 'utf8'),
  );
  await writeFile('assets-bundle.zip', zipPayload);

  const mp4 = Buffer.concat([
    Buffer.from([0x00, 0x00, 0x00, 0x18, 0x66, 0x74, 0x79, 0x70, 0x69, 0x73, 0x6f, 0x6d]),
    padBuffer('SHOO-MP4-FIXTURE', targetSize),
  ]);
  await writeFile('promo.mp4', mp4);

  const { mockPath, count } = await syncCatalogJson();

  console.log(`Download dir: ${config.downloadDir}`);
  console.log(`Generated sample files (${count} total in catalog)`);
  console.log(`Catalog synced → ${mockPath}`);
  console.log('');
  console.log('Add your own files to download/, then:');
  console.log('  curl http://127.0.0.1:3847/api/v1/documents');
  console.log('  curl -O http://127.0.0.1:3847/api/v1/download/your-file.pdf');
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
