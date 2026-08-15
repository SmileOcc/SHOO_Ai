import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class DocumentsService {
  constructor(private readonly prisma: PrismaService) {}

  async getPayload<T = unknown>(key: string): Promise<T> {
    const row = await this.prisma.appDocument.findUnique({ where: { key } });
    if (!row) {
      throw new NotFoundException(`Document not found: ${key}`);
    }
    return row.payload as T;
  }

  async getPayloadOrNull<T = unknown>(key: string): Promise<T | null> {
    const row = await this.prisma.appDocument.findUnique({ where: { key } });
    return (row?.payload as T) ?? null;
  }

  async upsertPayload(key: string, payload: unknown) {
    await this.prisma.appDocument.upsert({
      where: { key },
      create: { key, payload: payload as Prisma.InputJsonValue },
      update: { payload: payload as Prisma.InputJsonValue },
    });
    return payload;
  }
}
