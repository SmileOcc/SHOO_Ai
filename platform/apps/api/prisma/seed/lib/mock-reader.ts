import * as fs from 'fs';
import * as path from 'path';

type Envelope<T> = { code: number; message: string; data: T };

function mockDirs(): string[] {
  return [
    process.env.MOCK_DATA_DIR,
    path.resolve(__dirname, '../../../../../assets/mock'),
    path.resolve(process.cwd(), '../../../assets/mock'),
    path.resolve(process.cwd(), '../../../../assets/mock'),
  ].filter(Boolean) as string[];
}

export function readMock<T>(file: string): T {
  for (const dir of mockDirs()) {
    const full = path.join(dir, file);
    if (fs.existsSync(full)) {
      const raw = JSON.parse(fs.readFileSync(full, 'utf8')) as Envelope<T>;
      return raw.data;
    }
  }
  throw new Error(`Mock file not found: ${file}`);
}

export function tryReadMock<T>(file: string): T | null {
  try {
    return readMock<T>(file);
  } catch {
    return null;
  }
}

export function tryReadRawJson<T>(file: string): T | null {
  for (const dir of mockDirs()) {
    const full = path.join(dir, file);
    if (!fs.existsSync(full)) continue;
    try {
      return JSON.parse(fs.readFileSync(full, 'utf8')) as T;
    } catch {
      return null;
    }
  }
  return null;
}
