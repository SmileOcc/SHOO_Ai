import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { CouponTemplate, Prisma } from '@prisma/client';
import { DocumentsService } from '../documents/documents.service';
import { PrismaService } from '../prisma/prisma.service';
import {
  buildCouponTemplatesFromWallet,
  getRegistryDefault,
} from './coupon-registry';

export type CouponAppItem = {
  id: string;
  title: string;
  description: string;
  type: 'fixed' | 'percent';
  discountCents: number;
  discountPercent: number;
  minOrderCents: number;
  expiresAt: string;
  isAvailable: boolean;
};

type TemplateInput = {
  id: string;
  title: string;
  description?: string;
  type?: string;
  discountCents?: number;
  discountPercent?: number;
  minOrderCents?: number;
  validDays?: number;
  stock?: number | null;
  enabled?: boolean;
  source?: string;
};

@Injectable()
export class CouponService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly docs: DocumentsService,
  ) {}

  async listUserCoupons(userId: string): Promise<CouponAppItem[]> {
    const rows = await this.prisma.userCoupon.findMany({
      where: { userId },
      include: { template: true },
      orderBy: { claimedAt: 'desc' },
    });
    return rows.map((row) => this.toAppItem(row.template, row.expiresAt, row.isUsed));
  }

  async claimCoupon(userId: string, couponId: string) {
    const template = await this.ensureTemplate(couponId);
    if (!template.enabled) {
      throw new BadRequestException('Coupon is disabled');
    }

    const existing = await this.prisma.userCoupon.findUnique({
      where: {
        userId_templateId: { userId, templateId: couponId },
      },
    });
    if (existing) {
      return {
        success: true,
        status: 'claimed',
        couponId,
        alreadyClaimed: true,
      };
    }

    if (template.stock != null && template.claimedCount >= template.stock) {
      throw new ConflictException('Coupon sold out');
    }

    const expiresAt = this.computeExpiresAt(template.validDays);
    await this.prisma.$transaction([
      this.prisma.userCoupon.create({
        data: {
          userId,
          templateId: couponId,
          expiresAt,
        },
      }),
      this.prisma.couponTemplate.update({
        where: { id: couponId },
        data: { claimedCount: { increment: 1 } },
      }),
    ]);

    return { success: true, status: 'claimed', couponId };
  }

  async listTemplates() {
    return this.prisma.couponTemplate.findMany({
      orderBy: [{ source: 'asc' }, { id: 'asc' }],
    });
  }

  async createTemplate(body: TemplateInput) {
    const id = String(body.id ?? '').trim();
    if (!id) throw new BadRequestException('id is required');
    return this.prisma.couponTemplate.create({
      data: this.normalizeTemplateData(body),
    });
  }

  async updateTemplate(id: string, body: Partial<TemplateInput>) {
    await this.getTemplateOrThrow(id);
    return this.prisma.couponTemplate.update({
      where: { id },
      data: this.normalizeTemplatePatch(body),
    });
  }

  async deleteTemplate(id: string) {
    await this.getTemplateOrThrow(id);
    await this.prisma.userCoupon.deleteMany({ where: { templateId: id } });
    await this.prisma.couponTemplate.delete({ where: { id } });
    return { success: true };
  }

  async seedTemplatesFromMocks() {
    const wallet = await this.docs.getPayloadOrNull<
      Array<{
        id: string;
        title: string;
        description?: string;
        type?: string;
        discountCents?: number;
        discountPercent?: number;
        minOrderCents?: number;
      }>
    >('coupons');

    const templates = buildCouponTemplatesFromWallet(wallet);

    for (const item of templates) {
      await this.prisma.couponTemplate.upsert({
        where: { id: item.id },
        create: this.normalizeTemplateData(item),
        update: this.normalizeTemplatePatch(item),
      });
    }

    return { count: templates.length };
  }

  private async ensureTemplate(couponId: string): Promise<CouponTemplate> {
    const existing = await this.prisma.couponTemplate.findUnique({
      where: { id: couponId },
    });
    if (existing) return existing;

    const fromRegistry = getRegistryDefault(couponId);
    if (fromRegistry) {
      return this.prisma.couponTemplate.create({
        data: this.normalizeTemplateData({ id: couponId, ...fromRegistry }),
      });
    }

    const wallet = await this.docs.getPayloadOrNull<
      Array<{
        id: string;
        title: string;
        description?: string;
        type?: string;
        discountCents?: number;
        discountPercent?: number;
        minOrderCents?: number;
      }>
    >('coupons');
    const match = Array.isArray(wallet)
      ? wallet.find((item) => item.id === couponId)
      : undefined;
    if (match) {
      return this.prisma.couponTemplate.create({
        data: this.normalizeTemplateData({
          id: couponId,
          title: match.title,
          description: match.description ?? '',
          type: match.type ?? 'fixed',
          discountCents: match.discountCents ?? 0,
          discountPercent: match.discountPercent ?? 0,
          minOrderCents: match.minOrderCents ?? 0,
          source: 'wallet',
        }),
      });
    }

    throw new NotFoundException(`Coupon template not found: ${couponId}`);
  }

  private async getTemplateOrThrow(id: string) {
    const row = await this.prisma.couponTemplate.findUnique({ where: { id } });
    if (!row) throw new NotFoundException(`Coupon template not found: ${id}`);
    return row;
  }

  private toAppItem(
    template: CouponTemplate,
    expiresAt: Date,
    isUsed: boolean,
  ): CouponAppItem {
    const now = new Date();
    const type = template.type === 'percent' ? 'percent' : 'fixed';
    return {
      id: template.id,
      title: template.title,
      description: template.description,
      type,
      discountCents: template.discountCents,
      discountPercent: template.discountPercent,
      minOrderCents: template.minOrderCents,
      expiresAt: expiresAt.toISOString().slice(0, 10),
      isAvailable: !isUsed && expiresAt.getTime() > now.getTime(),
    };
  }

  private computeExpiresAt(validDays: number) {
    const days = Number.isFinite(validDays) && validDays > 0 ? validDays : 30;
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + days);
    return expiresAt;
  }

  private normalizeTemplateData(body: TemplateInput): Prisma.CouponTemplateCreateInput {
    const type = body.type === 'percent' ? 'percent' : 'fixed';
    return {
      id: body.id,
      title: String(body.title ?? body.id),
      description: String(body.description ?? ''),
      type,
      discountCents: Number(body.discountCents ?? 0),
      discountPercent: Number(body.discountPercent ?? 0),
      minOrderCents: Number(body.minOrderCents ?? 0),
      validDays: Number(body.validDays ?? 30),
      stock: body.stock ?? null,
      enabled: body.enabled !== false,
      source: String(body.source ?? 'wallet'),
    };
  }

  private normalizeTemplatePatch(
    body: Partial<TemplateInput>,
  ): Prisma.CouponTemplateUpdateInput {
    const patch: Prisma.CouponTemplateUpdateInput = {};
    if (body.title != null) patch.title = String(body.title);
    if (body.description != null) patch.description = String(body.description);
    if (body.type != null) {
      patch.type = body.type === 'percent' ? 'percent' : 'fixed';
    }
    if (body.discountCents != null) {
      patch.discountCents = Number(body.discountCents);
    }
    if (body.discountPercent != null) {
      patch.discountPercent = Number(body.discountPercent);
    }
    if (body.minOrderCents != null) {
      patch.minOrderCents = Number(body.minOrderCents);
    }
    if (body.validDays != null) patch.validDays = Number(body.validDays);
    if (body.stock !== undefined) patch.stock = body.stock;
    if (body.enabled != null) patch.enabled = Boolean(body.enabled);
    if (body.source != null) patch.source = String(body.source);
    return patch;
  }
}
