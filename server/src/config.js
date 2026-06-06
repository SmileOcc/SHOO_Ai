import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export const config = {
  port: Number(process.env.PORT ?? 3847),
  mockDelayMs: Number(process.env.MOCK_DELAY_MS ?? 300),
  apiPrefix: process.env.API_PREFIX ?? '/api/v1',
  mockDataDir:
    process.env.MOCK_DATA_DIR ??
    path.resolve(__dirname, '../../assets/mock'),
  host: process.env.HOST ?? '0.0.0.0',
};
