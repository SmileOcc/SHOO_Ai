import { Injectable } from '@nestjs/common';
import { DocumentsService } from '../documents/documents.service';
import { PrismaService } from '../prisma/prisma.service';
import {
  resolveFlashSaleCalendar,
  resolveFlashSalePage,
  resolveFlashSaleProductActivity,
} from './flash-sale-mock';

@Injectable()
export class MarketingService {
  constructor(
    private readonly docs: DocumentsService,
    private readonly prisma: PrismaService,
  ) {}

  activityPopup() {
    return this.docs.getPayload('activity_popup');
  }

  async saveActivityPopup(payload: unknown) {
    return this.docs.upsertPayload('activity_popup', payload);
  }

  async homeQuickEntries() {
    const payload = await this.docs.getPayloadOrNull<{
      items?: Array<Record<string, unknown>>;
    }>('home_quick_entries');
    const items = Array.isArray(payload?.items) ? payload.items : [];
    return {
      items: items
        .filter((item) => item.enabled !== false)
        .sort(
          (a, b) => Number(a.sort ?? 0) - Number(b.sort ?? 0),
        )
        .map((item) => ({
          id: String(item.id ?? ''),
          title: String(item.title ?? item.name ?? ''),
          icon: String(item.icon ?? '🏷️'),
          link: String(item.link ?? '/'),
          sort: Number(item.sort ?? 0),
          enabled: item.enabled !== false,
        })),
    };
  }

  async adminHomeQuickEntries() {
    const payload = await this.docs.getPayloadOrNull<{
      items?: Array<Record<string, unknown>>;
    }>('home_quick_entries');
    const items = Array.isArray(payload?.items) ? payload.items : [];
    return {
      items: items
        .map((item) => ({
          id: String(item.id ?? ''),
          title: String(item.title ?? item.name ?? ''),
          icon: String(item.icon ?? '🏷️'),
          link: String(item.link ?? '/'),
          sort: Number(item.sort ?? 0),
          enabled: item.enabled !== false,
        }))
        .sort((a, b) => a.sort - b.sort),
    };
  }

  async saveHomeQuickEntries(payload: {
    items: Array<{
      id: string;
      title: string;
      icon?: string;
      link: string;
      sort?: number;
      enabled?: boolean;
    }>;
  }) {
    const items = (payload.items ?? []).map((item, index) => ({
      id: item.id,
      title: item.title,
      icon: item.icon ?? '🏷️',
      link: item.link,
      sort: item.sort ?? index,
      enabled: item.enabled !== false,
    }));
    return this.docs.upsertPayload('home_quick_entries', { items });
  }

  async homeFeedConfig() {
    const payload = await this.docs.getPayloadOrNull<Record<string, unknown>>(
      'home_feed_config',
    );
    return normalizeHomeFeedConfig(payload);
  }

  async saveHomeFeedConfig(payload: Record<string, unknown>) {
    const next = normalizeHomeFeedConfig(payload);
    await this.docs.upsertPayload('home_feed_config', next);
    return next;
  }

  cartMarquee() {
    return this.docs.getPayload('cart_marquee');
  }

  async adminCartMarquee() {
    return this.docs.getPayloadOrNull('cart_marquee');
  }

  async saveCartMarquee(payload: unknown) {
    return this.docs.upsertPayload('cart_marquee', payload);
  }

  async adminFlashSaleCatalog() {
    return this.docs.getPayloadOrNull('flash_sale_catalog');
  }

  async saveFlashSaleCatalog(payload: unknown) {
    return this.docs.upsertPayload('flash_sale_catalog', payload);
  }

  activityData() {
    return this.docs.getPayload('activity_data');
  }

  activityDetail() {
    return this.docs.getPayload('activity_detail');
  }

  activityDetailLevel3() {
    return this.docs.getPayload('activity_level3_detail');
  }

  activityUserCheck() {
    return this.docs.getPayload('activity_user_check');
  }

  activityUrlRules() {
    return this.docs.getPayload('activity_url_rules');
  }

  async adminActivityData() {
    return this.docs.getPayloadOrNull('activity_data');
  }

  async saveActivityData(payload: unknown) {
    return this.docs.upsertPayload('activity_data', payload);
  }

  async adminActivityDetail() {
    return this.docs.getPayloadOrNull('activity_detail');
  }

  async saveActivityDetail(payload: unknown) {
    return this.docs.upsertPayload('activity_detail', payload);
  }

  async adminActivityDetailLevel3() {
    return this.docs.getPayloadOrNull('activity_level3_detail');
  }

  async saveActivityDetailLevel3(payload: unknown) {
    return this.docs.upsertPayload('activity_level3_detail', payload);
  }

  async adminActivityUserCheck() {
    return this.docs.getPayloadOrNull('activity_user_check');
  }

  async saveActivityUserCheck(payload: unknown) {
    return this.docs.upsertPayload('activity_user_check', payload);
  }

  async adminActivityUrlRules() {
    return this.docs.getPayloadOrNull('activity_url_rules');
  }

  async saveActivityUrlRules(payload: unknown) {
    return this.docs.upsertPayload('activity_url_rules', payload);
  }

  async flashSaleCalendar(query: Record<string, string>) {
    const data = await this.docs.getPayload('flash_sale_catalog');
    return resolveFlashSaleCalendar({ code: 0, message: 'ok', data }, query);
  }

  async flashSalePage(query: Record<string, string>, userId?: string) {
    const data = await this.docs.getPayload('flash_sale_catalog');
    const page = resolveFlashSalePage(
      { code: 0, message: 'ok', data },
      query,
    ) as {
      code: number;
      message: string;
      data: {
        products?: Array<Record<string, unknown> & { sessionId?: string; id?: string }>;
        [key: string]: unknown;
      };
    };
    const follows = userId
      ? await this.prisma.flashSaleFollow.findMany({ where: { userId } })
      : [];
    const followed = new Set(
      follows.map((f) => `${f.sessionId}::${f.productId}`),
    );
    const products = Array.isArray(page.data.products)
      ? page.data.products.map((p) => ({
          ...p,
          isFollowed: followed.has(`${p.sessionId ?? ''}::${p.id ?? ''}`),
        }))
      : [];
    return {
      ...page,
      data: {
        ...page.data,
        products,
      },
    };
  }

  async flashSaleProductActivity(
    query: Record<string, string>,
    userId?: string,
  ) {
    const data = await this.docs.getPayload('flash_sale_catalog');
    const result = resolveFlashSaleProductActivity(
      { code: 0, message: 'ok', data },
      query,
    ) as {
      code: number;
      message: string;
      data: (Record<string, unknown> & { isFollowed?: boolean }) | null;
    };
    if (result.data && query.sessionId && query.productId && userId) {
      const followed = await this.prisma.flashSaleFollow.findUnique({
        where: {
          userId_sessionId_productId: {
            userId,
            sessionId: query.sessionId,
            productId: query.productId,
          },
        },
      });
      result.data.isFollowed = Boolean(followed);
    }
    return result;
  }

  async listFollows(userId: string) {
    const rows = await this.prisma.flashSaleFollow.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
    return rows.map((row) => ({
      sessionId: row.sessionId,
      productId: row.productId,
      title: row.title,
      imageUrl: row.imageUrl,
    }));
  }

  async follow(
    userId: string,
    body: {
      sessionId?: string;
      productId?: string;
      title?: string;
      imageUrl?: string;
    },
  ) {
    const sessionId = body.sessionId ?? '';
    const productId = body.productId ?? '';
    if (sessionId && productId) {
      await this.prisma.flashSaleFollow.upsert({
        where: {
          userId_sessionId_productId: { userId, sessionId, productId },
        },
        create: {
          userId,
          sessionId,
          productId,
          title: body.title ?? '',
          imageUrl: body.imageUrl ?? '',
        },
        update: {
          title: body.title ?? '',
          imageUrl: body.imageUrl ?? '',
        },
      });
    }
    return { success: true };
  }

  async unfollow(
    userId: string,
    body: { sessionId?: string; productId?: string },
  ) {
    const sessionId = body.sessionId ?? '';
    const productId = body.productId ?? '';
    if (sessionId && productId) {
      await this.prisma.flashSaleFollow.deleteMany({
        where: { userId, sessionId, productId },
      });
    }
    return { success: true };
  }
}

function normalizeHomeFeedConfig(payload: Record<string, unknown> | null) {
  const modeRaw = String(payload?.mode ?? 'latest');
  const mode =
    modeRaw === 'category' || modeRaw === 'productIds' ? modeRaw : 'latest';
  const productIds = Array.isArray(payload?.productIds)
    ? payload.productIds.map((id) => String(id)).filter(Boolean)
    : [];
  return {
    title: String(payload?.title ?? 'Recommended'),
    mode,
    categoryId: String(payload?.categoryId ?? ''),
    productIds,
    pageSize: Math.min(
      100,
      Math.max(1, Number(payload?.pageSize ?? 50) || 50),
    ),
  };
}
