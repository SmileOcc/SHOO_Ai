import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { formatAppDate } from '../common/format-app-date';
import { DocumentsService } from '../documents/documents.service';
import { PrismaService } from '../prisma/prisma.service';
import {
  ORDER_PAYMENT_WINDOW_MS,
  StockReservationService,
} from './stock-reservation.service';

@Injectable()
export class TradeService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly docs: DocumentsService,
    private readonly stock: StockReservationService,
  ) {}

  async listOrders(query: {
    userId: string;
    page?: number;
    pageSize?: number;
    status?: string;
  }) {
    await this.expireStalePendingOrders(query.userId);
    const page = Math.max(1, Number(query.page) || 1);
    const pageSize = Math.min(100, Math.max(1, Number(query.pageSize) || 20));
    const where = {
      userId: query.userId,
      ...(query.status ? { status: query.status } : {}),
    };
    const [total, rows] = await Promise.all([
      this.prisma.order.count({ where }),
      this.prisma.order.findMany({
        where,
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

  async getOrder(id: string, userId?: string) {
    if (userId) {
      await this.expireStalePendingOrders(userId);
    }
    const order = await this.findOrderForUser(id, userId);
    return this.toAppOrder(order);
  }

  async getLogistics(orderId: string, userId?: string) {
    await this.findOrderForUser(orderId, userId);
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
    const order = await this.prisma.order.findUnique({
      where: { id },
      include: { items: true },
    });
    if (!order) {
      throw new NotFoundException(`Order ${id} not found`);
    }
    return this.toAppOrder(order);
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
    if (!body.userId) {
      throw new BadRequestException('User is required');
    }

    const totalCents =
      body.totalCents ??
      items.reduce((sum, i) => sum + Number(i.price) * Number(i.quantity), 0);
    const paymentDeadlineAt = new Date(Date.now() + ORDER_PAYMENT_WINDOW_MS);
    const orderNo = `SH${Date.now()}`;

    const order = await this.prisma.order.create({
      data: {
        orderNo,
        status: 'pending_payment',
        totalCents,
        userId: body.userId,
        paymentDeadlineAt,
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

    await this.stock.lockForOrder(order.id, items, paymentDeadlineAt);
    return this.toAppOrder(order);
  }

  async payOrder(id: string, userId?: string) {
    const existing = await this.findOrderForUser(id, userId);
    if (existing.status !== 'pending_payment') {
      throw new BadRequestException('Order is not awaiting payment');
    }
    if (
      existing.paymentDeadlineAt &&
      existing.paymentDeadlineAt.getTime() <= Date.now()
    ) {
      await this.cancelPendingOrder(existing.id);
      throw new BadRequestException('Order payment window expired');
    }

    const order = await this.prisma.order.update({
      where: { id },
      data: { status: 'paid' },
      include: { items: true },
    });
    await this.stock.consumeForOrder(id);
    const appOrder = this.toAppOrder(order);
    return {
      orderId: appOrder.id,
      status: appOrder.status,
      paidAt: formatAppDate(order.updatedAt ?? order.createdAt),
      message: 'Payment successful',
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

  private async expireStalePendingOrders(userId: string) {
    const now = new Date();
    const stale = await this.prisma.order.findMany({
      where: {
        userId,
        status: 'pending_payment',
        paymentDeadlineAt: { lt: now },
      },
      select: { id: true },
    });
    for (const row of stale) {
      await this.cancelPendingOrder(row.id);
    }
  }

  private async cancelPendingOrder(orderId: string) {
    const order = await this.prisma.order.findUnique({
      where: { id: orderId },
      select: { id: true, status: true },
    });
    if (!order || order.status !== 'pending_payment') return;
    await this.stock.releaseForOrder(orderId);
    await this.prisma.order.update({
      where: { id: orderId },
      data: { status: 'cancelled' },
    });
  }

  private async findOrderForUser(id: string, userId?: string) {
    const order = await this.prisma.order.findFirst({
      where: userId ? { id, userId } : { id },
      include: { items: true },
    });
    if (!order) {
      throw new NotFoundException(`Order ${id} not found`);
    }
    return order;
  }

  private toAppOrder(order: {
    id: string;
    orderNo: string;
    status: string;
    totalCents: number;
    shippingAddress?: string;
    hasLogistics?: boolean;
    createdAt: Date;
    paymentDeadlineAt?: Date | null;
    items: Array<{
      productId: string;
      title: string;
      imageUrl: string;
      price: number;
      quantity: number;
      variantLabel: string;
    }>;
  }) {
    const createdAt = formatAppDate(order.createdAt);
    return {
      id: order.id,
      orderNo: order.orderNo,
      status: order.status,
      totalCents: order.totalCents,
      createdAt,
      paymentDeadlineAt: order.paymentDeadlineAt?.toISOString() ?? '',
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
