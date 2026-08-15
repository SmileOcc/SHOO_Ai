import { Injectable } from '@nestjs/common';
import { DocumentsService } from '../documents/documents.service';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class UserService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly docs: DocumentsService,
  ) {}

  listAfterSales() {
    return this.prisma.afterSale.findMany({
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        orderId: true,
        orderNo: true,
        type: true,
        status: true,
        reason: true,
        productTitle: true,
        createdAt: true,
      },
    }).then((rows) =>
      rows.map((row) => ({
        ...row,
        createdAt: formatAppDate(row.createdAt),
      })),
    );
  }

  async createAfterSale(body: {
    orderId?: string;
    orderNo?: string;
    type?: string;
    reason?: string;
    productTitle?: string;
  }) {
    const template = await this.docs.getPayloadOrNull<{
      id?: string;
      orderId?: string;
      orderNo?: string;
      type?: string;
      status?: string;
      reason?: string;
      productTitle?: string;
      createdAt?: string;
    }>('after_sale_create');

    const created = await this.prisma.afterSale.create({
      data: {
        orderId: body.orderId ?? template?.orderId ?? '',
        orderNo: body.orderNo ?? template?.orderNo ?? '',
        type: body.type ?? template?.type ?? 'refund',
        status: template?.status ?? 'pending',
        reason: body.reason ?? template?.reason ?? '',
        productTitle: body.productTitle ?? template?.productTitle ?? '',
      },
    });

    return {
      id: created.id,
      orderId: created.orderId,
      orderNo: created.orderNo,
      type: created.type,
      status: created.status,
      reason: created.reason,
      productTitle: created.productTitle,
      createdAt: formatAppDate(created.createdAt),
    };
  }

  async listContacts(q?: string) {
    const payload = await this.docs.getPayload<unknown>('contacts');
    if (!q || !q.trim()) return payload;

    const needle = q.trim().toLowerCase();
    if (Array.isArray(payload)) {
      return payload.filter((item) => {
        if (!item || typeof item !== 'object') return false;
        const row = item as Record<string, unknown>;
        const hay = [row.name, row.phone, row.email, row.company]
          .filter(Boolean)
          .join(' ')
          .toLowerCase();
        return hay.includes(needle);
      });
    }

    if (payload && typeof payload === 'object') {
      const data = payload as { items?: unknown[] };
      if (Array.isArray(data.items)) {
        return {
          ...data,
          items: data.items.filter((item) => {
            if (!item || typeof item !== 'object') return false;
            const row = item as Record<string, unknown>;
            const hay = [row.name, row.phone, row.email, row.company]
              .filter(Boolean)
              .join(' ')
              .toLowerCase();
            return hay.includes(needle);
          }),
        };
      }
    }
    return payload;
  }
}

function formatAppDate(d: Date): string {
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`;
}
