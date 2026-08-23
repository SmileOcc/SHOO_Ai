import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { DocumentsService } from '../documents/documents.service';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class TradeService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly docs: DocumentsService,
  ) {}

  async listOrders(query: { page?: number; pageSize?: number }) {
    const page = Math.max(1, Number(query.page) || 1);
    const pageSize = Math.min(100, Math.max(1, Number(query.pageSize) || 20));
    const [total, rows] = await Promise.all([
      this.prisma.order.count(),
      this.prisma.order.findMany({
        skip: (page - 1) * pageSize,
        take: pageSize,
        orderBy: { createdAt: 'desc' },
        include: { items: true },
      }),
    ]);

    return {
      items: rows.map((o) => this.toAppOrder(o)),
      page,
      pageSize,
      total,
      hasMore: page * pageSize < total,
    };
  }

  async getOrder(id: string) {
    const order = await this.prisma.order.findUnique({
      where: { id },
      include: { items: true },
    });
    if (!order) {
      throw new NotFoundException(`Order ${id} not found`);
    }
    return this.toAppOrder(order);
  }

  async getLogistics(orderId: string) {
    const catalog = await this.docs.getPayloadOrNull<{
      byOrder?: Record<
        string,
        {
          carrier?: string;
          trackingNumber?: string;
          events?: unknown[];
        }
      >;
    }>('order_logistics_catalog');
    const entry = catalog?.byOrder?.[orderId];
    if (entry) {
      return {
        orderId,
        carrier: entry.carrier ?? '',
        trackingNumber: entry.trackingNumber ?? '',
        events: entry.events ?? [],
      };
    }

    const template = await this.docs.getPayload<{
      orderId?: string;
      carrier?: string;
      trackingNumber?: string;
      events?: unknown[];
    }>('order_logistics');
    return {
      ...template,
      orderId,
    };
  }

  async adminGetOrder(id: string) {
    return this.getOrder(id);
  }

  async adminUpdateOrder(
    id: string,
    body: Partial<{
      status: string;
      shippingAddress: string;
      hasLogistics: boolean;
    }>,
  ) {
    const order = await this.prisma.order.update({
      where: { id },
      data: {
        ...(body.status != null ? { status: body.status } : {}),
        ...(body.shippingAddress != null
          ? { shippingAddress: body.shippingAddress }
          : {}),
        ...(body.hasLogistics != null ? { hasLogistics: body.hasLogistics } : {}),
      },
      include: { items: true },
    });
    return this.toAppOrder(order);
  }

  async adminGetLogistics(orderId: string) {
    return this.getLogistics(orderId);
  }

  async adminSaveLogistics(
    orderId: string,
    body: {
      carrier?: string;
      trackingNumber?: string;
      events?: Array<{
        time: string;
        status: string;
        description: string;
        isActive?: boolean;
      }>;
    },
  ) {
    const catalog = (await this.docs.getPayloadOrNull<{
      byOrder?: Record<string, unknown>;
    }>('order_logistics_catalog')) ?? { byOrder: {} };
    const byOrder = { ...(catalog.byOrder ?? {}) };
    byOrder[orderId] = {
      carrier: body.carrier ?? '',
      trackingNumber: body.trackingNumber ?? '',
      events: body.events ?? [],
    };
    await this.docs.upsertPayload('order_logistics_catalog', { byOrder });
    await this.prisma.order.update({
      where: { id: orderId },
      data: { hasLogistics: true },
    });
    return this.getLogistics(orderId);
  }

  async createOrder(body: {
    items: Array<{
      productId: string;
      title: string;
      imageUrl: string;
      price: number;
      quantity: number;
      variantLabel?: string;
    }>;
    totalCents?: number;
    userId?: string;
    addressId?: string;
    couponId?: string;
  }) {
    void body.addressId;
    void body.couponId;

    // App 若仍发送 RSA 密文且本地 API 未解密，会出现 { algorithm, payload } 而无 items。
    if (
      body &&
      typeof body === 'object' &&
      'algorithm' in body &&
      'payload' in body &&
      !('items' in body)
    ) {
      throw new BadRequestException(
        'Encrypted order payload is not supported by local platform API. Use ENV=local plaintext (skip RSA).',
      );
    }

    const items = Array.isArray(body?.items) ? body.items : [];
    if (items.length === 0) {
      throw new BadRequestException('Order items are required');
    }

    const totalCents =
      body.totalCents ??
      items.reduce((sum, i) => sum + Number(i.price) * Number(i.quantity), 0);
    const orderNo = `SH${Date.now()}`;
    const order = await this.prisma.order.create({
      data: {
        orderNo,
        status: 'pending_payment',
        totalCents,
        userId: body.userId,
        items: {
          create: items.map((i) => ({
            productId: i.productId,
            title: i.title,
            imageUrl: i.imageUrl,
            price: i.price,
            quantity: i.quantity,
            variantLabel: i.variantLabel ?? '',
          })),
        },
      },
      include: { items: true },
    });
    return this.toAppOrder(order);
  }

  async payOrder(id: string) {
    const order = await this.prisma.order.update({
      where: { id },
      data: { status: 'paid' },
      include: { items: true },
    });
    return {
      success: true,
      order: this.toAppOrder(order),
    };
  }

  adminListOrders(query: { page?: number; pageSize?: number; status?: string }) {
    const page = Math.max(1, Number(query.page) || 1);
    const pageSize = Math.min(100, Math.max(1, Number(query.pageSize) || 20));
    const where = query.status ? { status: query.status } : {};
    return Promise.all([
      this.prisma.order.count({ where }),
      this.prisma.order.findMany({
        where,
        skip: (page - 1) * pageSize,
        take: pageSize,
        orderBy: { createdAt: 'desc' },
        include: { items: true },
      }),
    ]).then(([total, rows]) => ({
      items: rows.map((o) => this.toAppOrder(o)),
      page,
      pageSize,
      total,
      hasMore: page * pageSize < total,
    }));
  }

  async adminUpdateStatus(id: string, status: string) {
    const order = await this.prisma.order.update({
      where: { id },
      data: { status },
      include: { items: true },
    });
    return this.toAppOrder(order);
  }

  private toAppOrder(order: {
    id: string;
    orderNo: string;
    status: string;
    totalCents: number;
    shippingAddress?: string;
    hasLogistics?: boolean;
    createdAt: Date;
    items: Array<{
      productId: string;
      title: string;
      imageUrl: string;
      price: number;
      quantity: number;
      variantLabel: string;
    }>;
  }) {
    const pad = (n: number) => String(n).padStart(2, '0');
    const d = order.createdAt;
    const createdAt = `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`;
    return {
      id: order.id,
      orderNo: order.orderNo,
      status: order.status,
      totalCents: order.totalCents,
      createdAt,
      shippingAddress: order.shippingAddress ?? '',
      hasLogistics: order.hasLogistics ?? false,
      items: order.items.map((i) => ({
        productId: i.productId,
        title: i.title,
        imageUrl: i.imageUrl,
        price: i.price,
        quantity: i.quantity,
        variantLabel: i.variantLabel,
      })),
    };
  }
}
