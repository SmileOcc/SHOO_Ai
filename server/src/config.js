import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export const config = {
  port: Number(process.env.PORT ?? 3847),
  mockDelayMs: Number(process.env.MOCK_DELAY_MS ?? 300),
  apiPrefix: process.env.API_PREFIX ?? '/api/v1',
  /// local 环境专用 Mock 数据（与 assets/mock 初始同步，可在 server 侧独立修改）
  mockDataDir:
    process.env.MOCK_DATA_DIR ??
    path.resolve(__dirname, '../data/mock'),
  downloadDir:
    process.env.DOWNLOAD_DIR ??
    path.resolve(__dirname, '../data/download'),
  host: process.env.HOST ?? '0.0.0.0',
};
