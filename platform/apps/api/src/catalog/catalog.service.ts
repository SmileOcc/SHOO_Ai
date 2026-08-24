import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { DocumentsService } from '../documents/documents.service';
import { PrismaService } from '../prisma/prisma.service';
import {
  emptyFlashSaleProductReviews,
  isFlashSaleProductId,
  lookupFlashSaleProductDetail,
} from '../marketing/flash-sale-mock';
import { toCartBatchItem } from './catalog-batch.util';

@Injectable()
export class CatalogService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly docs: DocumentsService,
  ) {}

  listBanners() {
    return this.prisma.banner.findMany({
      where: { enabled: true },
      orderBy: [{ sort: 'asc' }, { createdAt: 'asc' }],
      select: {
        id: true,
        imageUrl: true,
        link: true,
        title: true,
      },
    });
  }

  async getCategories() {
    const row = await this.prisma.categoryTree.findUnique({
      where: { id: 'default' },
    });
    return row?.payload ?? [];
  }

  async listProducts(query: {
    page?: number;
    pageSize?: number;
    categoryId?: string;
  }) {
    const page = Math.max(1, Number(query.page) || 1);
    const pageSize = Math.min(100, Math.max(1, Number(query.pageSize) || 20));
    const where: Prisma.ProductWhereInput = {
      enabled: true,
      ...(query.categoryId ? { categoryId: query.categoryId } : {}),
    };

    const [total, items] = await Promise.all([
      this.prisma.product.count({ where }),
      this.prisma.product.findMany({
        where,
        skip: (page - 1) * pageSize,
        take: pageSize,
        orderBy: { id: 'asc' },
        select: {
          id: true,
          categoryId: true,
          title: true,
          imageUrl: true,
          price: true,
          originalPrice: true,
          discountLabel: true,
          rating: true,
          soldCount: true,
        },
      }),
    ]);

    return {
      items,
      page,
      pageSize,
      total,
      hasMore: page * pageSize < total,
    };
  }

  async getProduct(id: string, query: Record<string, string> = {}) {
    const product = await this.prisma.product.findFirst({
      where: { id, enabled: true },
    });
    if (product) {
      return {
        id: product.id,
        categoryId: product.categoryId,
        title: product.title,
        imageUrl: product.imageUrl,
        price: product.price,
        originalPrice: product.originalPrice,
        discountLabel: product.discountLabel,
        rating: product.rating,
        soldCount: product.soldCount,
        description: product.description,
        images: product.images,
        reviewCount: product.reviewCount,
      };
    }

    const flashCatalog = await this.docs.getPayloadOrNull('flash_sale_catalog');
    if (flashCatalog) {
      const flash = lookupFlashSaleProductDetail(
        { code: 0, message: 'ok', data: flashCatalog },
        id,
        query,
      );
      if (flash.code !== 404) {
        return flash.data;
      }
    }

    throw new NotFoundException(`Product ${id} not found`);
  }

  async getProductReviews(
    id: string,
    query: { page?: number; pageSize?: number } = {},
  ) {
    const catalog = await this.docs.getPayloadOrNull<{
      byProduct?: Record<
        string,
        {
          averageRating?: number;
          totalCount?: number;
          items?: unknown[];
          hasMore?: boolean;
        }
      >;
    }>('reviews_catalog');
    const reviews = catalog?.byProduct?.[id];
    if (reviews) {
      const page = Math.max(1, Number(query.page) || 1);
      const pageSize = Math.min(50, Math.max(1, Number(query.pageSize) || 20));
      const items = Array.isArray(reviews.items) ? reviews.items : [];
      const start = (page - 1) * pageSize;
      const slice = items.slice(start, start + pageSize);
      return {
        averageRating: reviews.averageRating ?? 0,
        totalCount: reviews.totalCount ?? items.length,
        items: slice,
        hasMore: start + pageSize < items.length,
      };
    }

    const flashCatalog = await this.docs.getPayloadOrNull('flash_sale_catalog');
    if (
      flashCatalog &&
      isFlashSaleProductId({ data: flashCatalog }, id)
    ) {
      return emptyFlashSaleProductReviews().data;
    }

    throw new NotFoundException(`Reviews not found for product ${id}`);
  }

  async searchHot() {
    return this.docs.getPayload('search_hot');
  }

  async search(query: { q?: string; page?: number; pageSize?: number }) {
    const page = Math.max(1, Number(query.page) || 1);
    const pageSize = Math.min(100, Math.max(1, Number(query.pageSize) || 20));
    const q = query.q?.trim() ?? '';

    const where: Prisma.ProductWhereInput = {
      enabled: true,
      ...(q
        ? {
            OR: [
              { title: { contains: q, mode: 'insensitive' } },
              { id: { contains: q, mode: 'insensitive' } },
              { categoryId: { contains: q, mode: 'insensitive' } },
            ],
          }
        : {}),
    };

    const [total, items] = await Promise.all([
      this.prisma.product.count({ where }),
      this.prisma.product.findMany({
        where,
        skip: (page - 1) * pageSize,
        take: pageSize,
        orderBy: { soldCount: 'desc' },
        select: {
          id: true,
          categoryId: true,
          title: true,
          imageUrl: true,
          price: true,
          originalPrice: true,
          discountLabel: true,
          rating: true,
          soldCount: true,
        },
      }),
    ]);

    if (total > 0 || q) {
      return {
        items,
        page,
        pageSize,
        total,
        hasMore: page * pageSize < total,
      };
    }

    // Fallback to seeded search fixture when catalog is empty.
    return this.docs.getPayload('search');
  }

  async batchProducts(ids: string[], skuIds: string[] = []) {
    if (!ids.length) {
      return { items: [], missingIds: [] as string[] };
    }

    const requestedSkuIds = new Set(skuIds);
    const rows = await this.prisma.product.findMany({
      where: { id: { in: ids }, enabled: true },
    });
    const byId = new Map(rows.map((product) => [product.id, product]));
    const missingIds = ids.filter((id) => !byId.has(id));

    return {
      items: rows.map((product) => toCartBatchItem(product, requestedSkuIds)),
      missingIds,
    };
  }

  // --- Admin ---

  adminListBanners() {
    return this.prisma.banner.findMany({
      orderBy: [{ sort: 'asc' }, { createdAt: 'asc' }],
    });
  }

  createBanner(data: {
    imageUrl: string;
    link: string;
    title: string;
    sort?: number;
    enabled?: boolean;
  }) {
    return this.prisma.banner.create({ data });
  }

  updateBanner(
    id: string,
    data: Partial<{
      imageUrl: string;
      link: string;
      title: string;
      sort: number;
      enabled: boolean;
    }>,
  ) {
    return this.prisma.banner.update({ where: { id }, data });
  }

  deleteBanner(id: string) {
    return this.prisma.banner.delete({ where: { id } });
  }

  async adminGetCategories() {
    return this.getCategories();
  }

  async adminSaveCategories(payload: unknown) {
    await this.prisma.categoryTree.upsert({
      where: { id: 'default' },
      create: { id: 'default', payload: payload as Prisma.InputJsonValue },
      update: { payload: payload as Prisma.InputJsonValue },
    });
    return payload;
  }

  adminListProducts(query: { page?: number; pageSize?: number; q?: string }) {
    const page = Math.max(1, Number(query.page) || 1);
    const pageSize = Math.min(100, Math.max(1, Number(query.pageSize) || 20));
    const where: Prisma.ProductWhereInput = query.q
      ? {
          OR: [
            { title: { contains: query.q, mode: 'insensitive' } },
            { id: { contains: query.q, mode: 'insensitive' } },
          ],
        }
      : {};

    return Promise.all([
      this.prisma.product.count({ where }),
      this.prisma.product.findMany({
        where,
        skip: (page - 1) * pageSize,
        take: pageSize,
        orderBy: { updatedAt: 'desc' },
      }),
    ]).then(([total, items]) => ({
      items,
      page,
      pageSize,
      total,
      hasMore: page * pageSize < total,
    }));
  }

  createProduct(data: {
    id: string;
    categoryId?: string;
    title: string;
    imageUrl: string;
    price: number;
    originalPrice: number;
    discountLabel?: string;
    rating?: number;
    soldCount?: number;
    description?: string;
    images?: string[];
    reviewCount?: number;
    enabled?: boolean;
  }) {
    return this.prisma.product.create({
      data: {
        id: data.id,
        categoryId: data.categoryId ?? '',
        title: data.title,
        imageUrl: data.imageUrl,
        price: data.price,
        originalPrice: data.originalPrice,
        discountLabel: data.discountLabel ?? '',
        rating: data.rating ?? 0,
        soldCount: data.soldCount ?? 0,
        description: data.description ?? '',
        images: data.images ?? [],
        reviewCount: data.reviewCount ?? 0,
        enabled: data.enabled ?? true,
      },
    });
  }

  updateProduct(
    id: string,
    data: Partial<{
      categoryId: string;
      title: string;
      imageUrl: string;
      price: number;
      originalPrice: number;
      discountLabel: string;
      rating: number;
      soldCount: number;
      description: string;
      images: string[];
      reviewCount: number;
      enabled: boolean;
    }>,
  ) {
    return this.prisma.product.update({
      where: { id },
      data: {
        ...data,
        images: data.images as Prisma.InputJsonValue | undefined,
      },
    });
  }

  deleteProduct(id: string) {
    return this.prisma.product.delete({ where: { id } });
  }

  async adminSearchHot() {
    return this.docs.getPayloadOrNull('search_hot');
  }

  async saveSearchHot(payload: unknown) {
    return this.docs.upsertPayload('search_hot', payload);
  }

  async adminReviewsCatalog() {
    return this.docs.getPayloadOrNull('reviews_catalog');
  }

  async saveReviewsCatalog(payload: unknown) {
    return this.docs.upsertPayload('reviews_catalog', payload);
  }

  async adminProductReviews(productId: string) {
    const catalog = await this.docs.getPayloadOrNull<{
      byProduct?: Record<string, unknown>;
    }>('reviews_catalog');
    return catalog?.byProduct?.[productId] ?? null;
  }

  async saveProductReviews(productId: string, payload: unknown) {
    const catalog = (await this.docs.getPayloadOrNull<{
      byProduct?: Record<string, unknown>;
    }>('reviews_catalog')) ?? { byProduct: {} };
    const byProduct = { ...(catalog.byProduct ?? {}) };
    byProduct[productId] = payload;
    await this.docs.upsertPayload('reviews_catalog', { byProduct });
    return byProduct[productId];
  }
}
