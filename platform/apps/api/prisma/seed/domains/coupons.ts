import { PrismaClient } from '@prisma/client';
import { buildCouponTemplatesFromWallet } from '../../../src/coupon/coupon-registry';
import { tryReadMock } from '../lib/mock-reader';

export async function seedCouponTemplates(prisma: PrismaClient) {
  const wallet = tryReadMock<
    Array<{
      id: string;
      title: string;
      description?: string;
      type?: string;
      discountCents?: number;
      discountPercent?: number;
      minOrderCents?: number;
    }>
  >('coupons.json');

  const templates = buildCouponTemplatesFromWallet(wallet);

  for (const item of templates) {
    await prisma.couponTemplate.upsert({
      where: { id: item.id },
      create: {
        id: item.id,
        title: item.title,
        description: item.description,
        type: item.type,
        discountCents: item.discountCents,
        discountPercent: item.discountPercent,
        minOrderCents: item.minOrderCents,
        source: item.source,
        validDays: item.validDays ?? 30,
        enabled: true,
      },
      update: {
        title: item.title,
        description: item.description,
        type: item.type,
        discountCents: item.discountCents,
        discountPercent: item.discountPercent,
        minOrderCents: item.minOrderCents,
        source: item.source,
      },
    });
  }

  console.log(`Coupon templates upserted: ${templates.length}`);
}
