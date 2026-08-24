import { Injectable, NotFoundException } from '@nestjs/common';
import * as fs from 'node:fs';
import * as path from 'node:path';

export type RegionNode = {
  code: string;
  name: string;
  nameEn?: string;
  level: number;
  countryCode: string;
  parentCode: string;
  hasChildren: boolean;
};

type ChildrenPayload = {
  countryCode: string;
  parentCode: string;
  items: RegionNode[];
};

@Injectable()
export class RegionService {
  private readonly dataDir = this.resolveDataDir();

  private resolveDataDir(): string {
    const candidates = [
      path.join(__dirname, 'data'),
      path.join(process.cwd(), 'src', 'region', 'data'),
      path.join(process.cwd(), 'dist', 'src', 'region', 'data'),
      path.join(process.cwd(), 'dist', 'region', 'data'),
    ];
    for (const dir of candidates) {
      if (fs.existsSync(path.join(dir, 'countries.json'))) {
        return dir;
      }
    }
    return path.join(__dirname, 'data');
  }

  getMeta() {
    return this.readJson<Record<string, unknown>>('meta.json');
  }

  listCountries() {
    return this.readJson<{ items: RegionNode[] }>('countries.json');
  }

  listChildren(countryCode: string, parentCode?: string) {
    const country = countryCode.toUpperCase();
    const parent = (parentCode ?? '').trim();
    const effectiveParent = parent || country;

    if (parent === '' || parent === country) {
      const countries = this.listCountries().items;
      const match = countries.find((c) => c.code === country);
      if (!match) {
        throw new NotFoundException(`Country ${country} not supported`);
      }
      if (parent === '') {
        return {
          countryCode: country,
          parentCode: '',
          items: countries.filter((c) => c.code === country),
        };
      }
    }

    const shard = this.readChildrenShard(country, effectiveParent);
    if (!shard) {
      throw new NotFoundException(
        `No region children for ${country}/${effectiveParent}`,
      );
    }
    return shard;
  }

  private readChildrenShard(
    countryCode: string,
    parentCode: string,
  ): ChildrenPayload | null {
    const file = path.join(
      this.dataDir,
      'children',
      countryCode,
      `${parentCode || 'root'}.json`,
    );
    if (!fs.existsSync(file)) return null;
    return JSON.parse(fs.readFileSync(file, 'utf8')) as ChildrenPayload;
  }

  private readJson<T>(name: string): T {
    const file = path.join(this.dataDir, name);
    if (!fs.existsSync(file)) {
      throw new NotFoundException(`Region data file missing: ${name}`);
    }
    return JSON.parse(fs.readFileSync(file, 'utf8')) as T;
  }
}
