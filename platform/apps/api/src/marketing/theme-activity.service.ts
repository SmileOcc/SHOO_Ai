import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import {
  ThemeValidationResult,
  validateThemeActivityConfig,
} from './theme-activity.validate';

export type ThemeActivityListItem = {
  activityId: string;
  title: string;
  status: string;
  startAt: string | null;
  endAt: string | null;
  expiredBehavior: string;
  updatedAt: string;
  moduleCount: number;
  hasFooter: boolean;
};

function isRecord(v: unknown): v is Record<string, unknown> {
  return Boolean(v) && typeof v === 'object' && !Array.isArray(v);
}

function toIso(d: Date | null | undefined): string | null {
  return d ? d.toISOString() : null;
}

function productLink(productId: string): string {
  return `https://shoo.app/product/${productId}`;
}

@Injectable()
export class ThemeActivityService {
  constructor(private readonly prisma: PrismaService) {}

  validate(config: unknown): ThemeValidationResult {
    return validateThemeActivityConfig(config);
  }

  /**
   * Admin: preview payload (any status; uses current JSON or saved row).
   */
  async previewAdmin(body: {
    activityId?: string;
    title?: string;
    status?: string;
    startAt?: string | null;
    endAt?: string | null;
    expiredBehavior?: string;
    config?: Record<string, unknown>;
  }) {
    let config: Record<string, unknown>;
    if (isRecord(body.config)) {
      config = this.mergeMetaIntoConfig(body);
    } else if (body.activityId) {
      const row = await this.requireRow(body.activityId);
      config = this.mergeMetaIntoConfig({
        ...body,
        config: this.normalizeConfigPayload(row),
      });
    } else {
      throw new BadRequestException('请提供 config 或 activityId');
    }

    const validation = validateThemeActivityConfig(config);
    const status = String(config.status ?? 'draft');
    return {
      preview: this.buildAppPreviewPayload(config),
      validation,
      appApiAvailable: status === 'online',
      deepLink: `https://shoo.app/theme-activity/${String(config.activityId ?? '')}`,
      appPreviewPath: `/api/v1/theme-activities/${String(config.activityId ?? '')}`,
      note:
        status !== 'online'
          ? '当前非 online 状态，App 公开接口不可访问；下方为运营预览（保存并设为 online 后 App 可拉取）'
          : null,
    };
  }

  async listAdmin(): Promise<ThemeActivityListItem[]> {
    const rows = await this.prisma.themeActivity.findMany({
      orderBy: { updatedAt: 'desc' },
    });
    return rows.map((row) => this.toListItem(row));
  }

  async getAdmin(activityId: string) {
    const row = await this.requireRow(activityId);
    return this.toAdminDetail(row);
  }

  async createAdmin(body: {
    activityId?: string;
    title?: string;
    status?: string;
    startAt?: string | null;
    endAt?: string | null;
    expiredBehavior?: string;
    config?: Record<string, unknown>;
  }) {
    const config = this.mergeMetaIntoConfig(body);
    const result = validateThemeActivityConfig(config);
    if (!result.ok) {
      throw new BadRequestException({
        message: 'ThemeActivity 配置校验失败',
        validation: result,
      });
    }
    const activityId = String(config.activityId);
    const existing = await this.prisma.themeActivity.findUnique({
      where: { activityId },
    });
    if (existing) {
      throw new BadRequestException(`activityId 已存在: ${activityId}`);
    }
    const row = await this.prisma.themeActivity.create({
      data: this.toPrismaData(config),
    });
    return {
      ...this.toAdminDetail(row),
      validation: result,
    };
  }

  async updateAdmin(
    activityId: string,
    body: {
      title?: string;
      status?: string;
      startAt?: string | null;
      endAt?: string | null;
      expiredBehavior?: string;
      config?: Record<string, unknown>;
    },
  ) {
    await this.requireRow(activityId);
    const config = this.mergeMetaIntoConfig({
      ...body,
      activityId,
      config: {
        ...(isRecord(body.config) ? body.config : {}),
        activityId,
      },
    });
    // Keep path id authoritative
    config.activityId = activityId;
    const result = validateThemeActivityConfig(config);
    if (!result.ok) {
      throw new BadRequestException({
        message: 'ThemeActivity 配置校验失败',
        validation: result,
      });
    }
    const row = await this.prisma.themeActivity.update({
      where: { activityId },
      data: this.toPrismaData(config),
    });
    return {
      ...this.toAdminDetail(row),
      validation: result,
    };
  }

  async deleteAdmin(activityId: string) {
    await this.requireRow(activityId);
    await this.prisma.themeActivity.delete({ where: { activityId } });
    return { success: true };
  }

  /**
   * App: full page config. Online only; respects start/end + expiredBehavior.
   */
  async getAppConfig(activityId: string) {
    const row = await this.prisma.themeActivity.findUnique({
      where: { activityId },
    });
    if (!row || row.status !== 'online') {
      throw new NotFoundException(`ThemeActivity not found: ${activityId}`);
    }

    const config = this.normalizeConfigPayload(row);
    return this.buildAppPreviewPayload(config, {
      startAt: row.startAt,
      endAt: row.endAt,
      expiredBehavior: row.expiredBehavior,
    });
  }

  private buildAppPreviewPayload(
    config: Record<string, unknown>,
    rowMeta?: {
      startAt?: Date | null;
      endAt?: Date | null;
      expiredBehavior?: string;
    },
  ) {
    const startAt =
      rowMeta?.startAt ??
      (config.startAt != null && String(config.startAt)
        ? new Date(String(config.startAt))
        : null);
    const endAt =
      rowMeta?.endAt ??
      (config.endAt != null && String(config.endAt)
        ? new Date(String(config.endAt))
        : null);
    const expiredBehavior = String(
      rowMeta?.expiredBehavior ?? config.expiredBehavior ?? 'browse',
    );

    const now = Date.now();
    const start =
      startAt && !Number.isNaN(startAt.getTime()) ? startAt.getTime() : null;
    const end = endAt && !Number.isNaN(endAt.getTime()) ? endAt.getTime() : null;
    const notStarted = start != null && now < start;
    const ended = end != null && now > end;
    const expired = notStarted || ended;

    if (expired && expiredBehavior === 'block') {
      return {
        ...config,
        _access: {
          allowed: false,
          reason: notStarted ? 'not_started' : 'ended',
          startAt: toIso(startAt),
          endAt: toIso(endAt),
        },
      };
    }

    return {
      ...config,
      _access: {
        allowed: true,
        expired,
        reason: expired ? (notStarted ? 'not_started' : 'ended') : 'ok',
        startAt: toIso(startAt),
        endAt: toIso(endAt),
      },
    };
  }

  /**
   * App: footer product pagination.
   * Request: activityId, moduleId?, page, pageSize, extra?
   */
  async getAppProducts(
    activityId: string,
    query: {
      page?: string | number;
      pageSize?: string | number;
      moduleId?: string;
    },
  ) {
    const row = await this.prisma.themeActivity.findUnique({
      where: { activityId },
    });
    if (!row || row.status !== 'online') {
      throw new NotFoundException(`ThemeActivity not found: ${activityId}`);
    }

    const config = isRecord(row.config) ? row.config : {};
    const footer = isRecord(config.footer) ? config.footer : null;
    if (!footer) {
      return {
        list: [],
        page: 1,
        pageSize: 10,
        hasMore: false,
        total: 0,
      };
    }

    const ds = isRecord(footer.dataSource) ? footer.dataSource : {};
    const page = Math.max(1, Number(query.page) || 1);
    const pageSize = Math.min(
      50,
      Math.max(
        1,
        Number(query.pageSize) ||
          Number(footer.pageSize) ||
          Number(ds.pageSize) ||
          10,
      ),
    );

    const mode = String(ds.mode ?? 'productQuery');

    if (mode === 'static' && Array.isArray(ds.items)) {
      const all = ds.items
        .filter(isRecord)
        .map((item) => this.mapStaticCard(item as Record<string, unknown>));
      const startIdx = (page - 1) * pageSize;
      const list = all.slice(startIdx, startIdx + pageSize);
      return {
        list,
        page,
        pageSize,
        hasMore: startIdx + pageSize < all.length,
        total: all.length,
        moduleId: query.moduleId ?? null,
      };
    }

    // productQuery (default)
    const where: Prisma.ProductWhereInput = { enabled: true };
    const ids = Array.isArray(ds.ids)
      ? ds.ids.map((id) => String(id)).filter(Boolean)
      : [];
    if (ids.length) {
      where.id = { in: ids };
    } else if (ds.categoryId) {
      where.categoryId = String(ds.categoryId);
    } else if (ds.tag) {
      where.OR = [
        { title: { contains: String(ds.tag), mode: 'insensitive' } },
        { discountLabel: { contains: String(ds.tag), mode: 'insensitive' } },
      ];
    }

    const orderBy: Prisma.ProductOrderByWithRelationInput =
      String(ds.sort) === 'sold'
        ? { soldCount: 'desc' }
        : String(ds.sort) === 'priceAsc'
          ? { price: 'asc' }
          : String(ds.sort) === 'priceDesc'
            ? { price: 'desc' }
            : { id: 'asc' };

    // When ids[] provided, preserve order after fetch
    const [total, products] = await Promise.all([
      this.prisma.product.count({ where }),
      this.prisma.product.findMany({
        where,
        skip: ids.length ? 0 : (page - 1) * pageSize,
        take: ids.length ? undefined : pageSize,
        orderBy,
      }),
    ]);

    let ordered = products;
    if (ids.length) {
      const map = new Map(products.map((p) => [p.id, p]));
      ordered = ids.map((id) => map.get(id)).filter(Boolean) as typeof products;
      const startIdx = (page - 1) * pageSize;
      ordered = ordered.slice(startIdx, startIdx + pageSize);
    }

    const list = ordered.map((p) => ({
      productId: p.id,
      image: p.imageUrl,
      title: p.title,
      subtitle: p.discountLabel || '',
      price: p.price,
      originPrice: p.originalPrice,
      currency: 'USD',
      tags: p.discountLabel ? [p.discountLabel] : [],
      salesText: p.soldCount > 0 ? `${p.soldCount} sold` : '',
      badge: p.discountLabel || '',
      link: productLink(p.id),
      cartAction: 'addToCart',
    }));

    const effectiveTotal = ids.length ? ids.length : total;
    return {
      list,
      page,
      pageSize,
      hasMore: page * pageSize < effectiveTotal,
      total: effectiveTotal,
      moduleId: query.moduleId ?? null,
    };
  }

  async upsertSeed(
    activityId: string,
    title: string,
    status: string,
    config: Record<string, unknown>,
  ) {
    const payload = { ...config, activityId, title, status };
    await this.prisma.themeActivity.upsert({
      where: { activityId },
      create: this.toPrismaData(payload),
      update: this.toPrismaData(payload),
    });
  }

  private async requireRow(activityId: string) {
    const row = await this.prisma.themeActivity.findUnique({
      where: { activityId },
    });
    if (!row) {
      throw new NotFoundException(`ThemeActivity not found: ${activityId}`);
    }
    return row;
  }

  private mergeMetaIntoConfig(body: {
    activityId?: string;
    title?: string;
    status?: string;
    startAt?: string | null;
    endAt?: string | null;
    expiredBehavior?: string;
    config?: Record<string, unknown>;
  }): Record<string, unknown> {
    const base = isRecord(body.config) ? { ...body.config } : {};
    if (body.activityId) base.activityId = body.activityId;
    if (body.title != null) base.title = body.title;
    if (body.status != null) base.status = body.status;
    if (body.expiredBehavior != null) {
      base.expiredBehavior = body.expiredBehavior;
    }
    if (body.startAt !== undefined) {
      base.startAt = body.startAt;
    }
    if (body.endAt !== undefined) {
      base.endAt = body.endAt;
    }
    if (!base.activityId && body.activityId) {
      base.activityId = body.activityId;
    }
    return base;
  }

  private toPrismaData(config: Record<string, unknown>) {
    const activityId = String(config.activityId ?? '').trim();
    const title = String(config.title ?? '').trim();
    const status = String(config.status ?? 'draft');
    const expiredBehavior = String(config.expiredBehavior ?? 'browse');
    const startAt =
      config.startAt != null && String(config.startAt)
        ? new Date(String(config.startAt))
        : null;
    const endAt =
      config.endAt != null && String(config.endAt)
        ? new Date(String(config.endAt))
        : null;

    return {
      activityId,
      title,
      status,
      expiredBehavior,
      startAt: startAt && !Number.isNaN(startAt.getTime()) ? startAt : null,
      endAt: endAt && !Number.isNaN(endAt.getTime()) ? endAt : null,
      config: config as Prisma.InputJsonValue,
    };
  }

  private normalizeConfigPayload(row: {
    activityId: string;
    title: string;
    status: string;
    startAt: Date | null;
    endAt: Date | null;
    expiredBehavior: string;
    config: Prisma.JsonValue;
  }) {
    const config = isRecord(row.config) ? { ...row.config } : {};
    return {
      ...config,
      activityId: row.activityId,
      title: row.title,
      status: row.status,
      startAt: toIso(row.startAt) ?? config.startAt ?? null,
      endAt: toIso(row.endAt) ?? config.endAt ?? null,
      expiredBehavior: row.expiredBehavior,
    };
  }

  private toListItem(row: {
    activityId: string;
    title: string;
    status: string;
    startAt: Date | null;
    endAt: Date | null;
    expiredBehavior: string;
    updatedAt: Date;
    config: Prisma.JsonValue;
  }): ThemeActivityListItem {
    const config = isRecord(row.config) ? row.config : {};
    const modules = Array.isArray(config.modules) ? config.modules : [];
    return {
      activityId: row.activityId,
      title: row.title,
      status: row.status,
      startAt: toIso(row.startAt),
      endAt: toIso(row.endAt),
      expiredBehavior: row.expiredBehavior,
      updatedAt: row.updatedAt.toISOString(),
      moduleCount: modules.length,
      hasFooter: isRecord(config.footer),
    };
  }

  private toAdminDetail(row: {
    activityId: string;
    title: string;
    status: string;
    startAt: Date | null;
    endAt: Date | null;
    expiredBehavior: string;
    updatedAt: Date;
    createdAt: Date;
    config: Prisma.JsonValue;
  }) {
    return {
      activityId: row.activityId,
      title: row.title,
      status: row.status,
      startAt: toIso(row.startAt),
      endAt: toIso(row.endAt),
      expiredBehavior: row.expiredBehavior,
      createdAt: row.createdAt.toISOString(),
      updatedAt: row.updatedAt.toISOString(),
      config: this.normalizeConfigPayload(row),
      appPreviewPath: `/api/v1/theme-activities/${row.activityId}`,
      deepLink: `https://shoo.app/theme-activity/${row.activityId}`,
    };
  }

  private mapStaticCard(item: Record<string, unknown>) {
    const productId = String(item.productId ?? item.id ?? '');
    return {
      productId,
      image: String(item.image ?? item.imageUrl ?? ''),
      title: String(item.title ?? ''),
      subtitle: String(item.subtitle ?? ''),
      price: Number(item.price ?? 0),
      originPrice: Number(item.originPrice ?? item.originalPrice ?? 0),
      currency: String(item.currency ?? 'USD'),
      tags: Array.isArray(item.tags) ? item.tags.map(String) : [],
      salesText: String(item.salesText ?? ''),
      badge: String(item.badge ?? ''),
      link: String(item.link ?? (productId ? productLink(productId) : '')),
      cartAction: String(item.cartAction ?? 'addToCart'),
      cartLink: item.cartLink != null ? String(item.cartLink) : undefined,
    };
  }
}
