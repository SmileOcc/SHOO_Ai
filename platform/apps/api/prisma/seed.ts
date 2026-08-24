import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcryptjs';
import { seedCouponTemplates } from './seed/domains/coupons';
import {
  seedDocuments,
  seedOrderLogisticsCatalog,
} from './seed/domains/documents';
import { readMock, tryReadMock, tryReadRawJson } from './seed/lib/mock-reader';

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding SHOO platform from assets/mock...');

  const adminEmail = 'admin@shoo.local';
  const adminPassword = 'admin123456';
  const passwordHash = await bcrypt.hash(adminPassword, 10);

  await prisma.adminUser.upsert({
    where: { email: adminEmail },
    create: {
      email: adminEmail,
      name: 'SHOO Admin',
      passwordHash,
      role: 'super_admin',
    },
    update: { passwordHash, name: 'SHOO Admin' },
  });

  const userHash = await bcrypt.hash('shoo123456', 10);
  await prisma.user.upsert({
    where: { email: 'user@shoo.mock' },
    create: {
      email: 'user@shoo.mock',
      phone: '13800138000',
      nickname: 'SHOO User',
      avatarUrl: 'https://picsum.photos/seed/avatar/200/200',
      passwordHash: userHash,
    },
    update: {},
  });
  const demoUser = await prisma.user.findUnique({
    where: { email: 'user@shoo.mock' },
  });
  const demoUserId = demoUser?.id;

  const banners = readMock<
    Array<{ id: string; imageUrl: string; link: string; title: string }>
  >('banners.json');

  await prisma.banner.deleteMany();
  await prisma.banner.createMany({
    data: banners.map((b, index) => ({
      id: b.id,
      imageUrl: b.imageUrl,
      link: b.link,
      title: b.title,
      sort: index,
      enabled: true,
    })),
  });

  const categories = readMock<unknown>('categories.json');
  await prisma.categoryTree.upsert({
    where: { id: 'default' },
    create: { id: 'default', payload: categories as object },
    update: { payload: categories as object },
  });

  type ProductRow = {
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
  };

  let products: ProductRow[] = [];
  try {
    const catalog = readMock<{ items: ProductRow[] }>('product_catalog.json');
    products = catalog.items;
  } catch {
    const list = readMock<{ items: ProductRow[] }>('products.json');
    products = list.items;
  }

  const chunkSize = 100;
  for (let i = 0; i < products.length; i += chunkSize) {
    const chunk = products.slice(i, i + chunkSize);
    await Promise.all(
      chunk.map((p) =>
        prisma.product.upsert({
          where: { id: p.id },
          create: {
            id: p.id,
            categoryId: p.categoryId ?? '',
            title: p.title,
            imageUrl: p.imageUrl,
            price: p.price,
            originalPrice: p.originalPrice,
            discountLabel: p.discountLabel ?? '',
            rating: p.rating ?? 0,
            soldCount: p.soldCount ?? 0,
            description: p.description ?? '',
            images: p.images ?? [p.imageUrl],
            reviewCount: p.reviewCount ?? 0,
            enabled: true,
          },
          update: {
            categoryId: p.categoryId ?? '',
            title: p.title,
            imageUrl: p.imageUrl,
            price: p.price,
            originalPrice: p.originalPrice,
            discountLabel: p.discountLabel ?? '',
            rating: p.rating ?? 0,
            soldCount: p.soldCount ?? 0,
            description: p.description ?? '',
            images: p.images ?? [p.imageUrl],
            reviewCount: p.reviewCount ?? 0,
            enabled: true,
          },
        }),
      ),
    );
    console.log(
      `Products upserted: ${Math.min(i + chunkSize, products.length)}/${products.length}`,
    );
  }

  const orders = readMock<{
    items: Array<{
      id: string;
      orderNo: string;
      status: string;
      totalCents: number;
      createdAt: string;
      items: Array<{
        productId: string;
        title: string;
        imageUrl: string;
        price: number;
        quantity: number;
        variantLabel?: string;
      }>;
    }>;
  }>('orders.json');

  const orderDetail = tryReadMock<{
    id: string;
    shippingAddress?: string;
    hasLogistics?: boolean;
  }>('order_detail.json');
  const orderExtras: Record<
    string,
    { shippingAddress: string; hasLogistics: boolean }
  > = {};
  if (orderDetail) {
    orderExtras[orderDetail.id] = {
      shippingAddress: orderDetail.shippingAddress ?? '',
      hasLogistics: orderDetail.hasLogistics ?? false,
    };
  }

  for (const o of orders.items) {
    const extra = orderExtras[o.id] ?? {
      shippingAddress: '',
      hasLogistics: o.status === 'shipped' || o.status === 'delivered',
    };
    await prisma.orderItem.deleteMany({ where: { orderId: o.id } });
    await prisma.order.upsert({
      where: { id: o.id },
      create: {
        id: o.id,
        orderNo: o.orderNo,
        status: o.status,
        totalCents: o.totalCents,
        userId: demoUserId,
        shippingAddress: extra.shippingAddress,
        hasLogistics: extra.hasLogistics,
        createdAt: new Date(o.createdAt.replace(' ', 'T') + ':00'),
        items: {
          create: o.items.map((i) => ({
            productId: i.productId,
            title: i.title,
            imageUrl: i.imageUrl,
            price: i.price,
            quantity: i.quantity,
            variantLabel: i.variantLabel ?? '',
          })),
        },
      },
      update: {
        orderNo: o.orderNo,
        status: o.status,
        totalCents: o.totalCents,
        userId: demoUserId,
        shippingAddress: extra.shippingAddress,
        hasLogistics: extra.hasLogistics,
        items: {
          create: o.items.map((i) => ({
            productId: i.productId,
            title: i.title,
            imageUrl: i.imageUrl,
            price: i.price,
            quantity: i.quantity,
            variantLabel: i.variantLabel ?? '',
          })),
        },
      },
    });
  }

  await seedOrderLogisticsCatalog(prisma);

  await seedDocuments(prisma);

  const afterSales = tryReadMock<
    Array<{
      id: string;
      orderId: string;
      orderNo?: string;
      type: string;
      status?: string;
      reason?: string;
      productTitle?: string;
      createdAt?: string;
    }>
  >('after_sales.json');

  if (Array.isArray(afterSales)) {
    for (const row of afterSales) {
      await prisma.afterSale.upsert({
        where: { id: row.id },
        create: {
          id: row.id,
          orderId: row.orderId,
          orderNo: row.orderNo ?? '',
          type: row.type,
          status: row.status ?? 'pending',
          reason: row.reason ?? '',
          productTitle: row.productTitle ?? '',
          createdAt: row.createdAt
            ? new Date(row.createdAt.replace(' ', 'T') + ':00')
            : undefined,
        },
        update: {
          orderId: row.orderId,
          orderNo: row.orderNo ?? '',
          type: row.type,
          status: row.status ?? 'pending',
          reason: row.reason ?? '',
          productTitle: row.productTitle ?? '',
        },
      });
    }
    console.log(`After-sales seeded: ${afterSales.length}`);
  }

  const followsDoc = tryReadMock<{ items?: unknown[] } | unknown[]>(
    'flash_sale_follows.json',
  );
  const followItems = Array.isArray(followsDoc)
    ? followsDoc
    : ((followsDoc as { items?: unknown[] } | null)?.items ?? []);

  await prisma.flashSaleFollow.deleteMany();
  for (const raw of followItems) {
    if (!raw || typeof raw !== 'object') continue;
    const item = raw as {
      sessionId?: string;
      productId?: string;
      title?: string;
      imageUrl?: string;
    };
    if (!item.sessionId || !item.productId) continue;
    await prisma.flashSaleFollow.create({
      data: {
        userId: demoUserId ?? '',
        sessionId: item.sessionId,
        productId: item.productId,
        title: item.title ?? '',
        imageUrl: item.imageUrl ?? '',
      },
    });
  }
  console.log(`Flash-sale follows seeded: ${followItems.length}`);

  const themeFiles = [
    'theme_activity_demo_long_banner.json',
    'theme_activity_demo_coupon_rush.json',
    'theme_activity_demo_nine_waterfall.json',
    'theme_activity_demo_all_modules.json',
  ];
  for (const file of themeFiles) {
    const config = tryReadRawJson<Record<string, unknown>>(file);
    if (!config) {
      console.warn(`Skip missing theme activity: ${file}`);
      continue;
    }
    const activityId = String(config.activityId ?? '');
    const title = String(config.title ?? activityId);
    const status = String(config.status ?? 'online');
    if (!activityId) continue;
    const configJson = config as object;
    await prisma.themeActivity.upsert({
      where: { activityId },
      create: {
        activityId,
        title,
        status,
        expiredBehavior: String(config.expiredBehavior ?? 'browse'),
        startAt:
          config.startAt != null ? new Date(String(config.startAt)) : null,
        endAt: config.endAt != null ? new Date(String(config.endAt)) : null,
        config: configJson,
      },
      update: {
        title,
        status,
        expiredBehavior: String(config.expiredBehavior ?? 'browse'),
        startAt:
          config.startAt != null ? new Date(String(config.startAt)) : null,
        endAt: config.endAt != null ? new Date(String(config.endAt)) : null,
        config: configJson,
      },
    });
    console.log(`ThemeActivity seeded: ${activityId}`);
  }

  await seedCouponTemplates(prisma);

  console.log('Seed complete.');
  console.log(`Admin login: ${adminEmail} / ${adminPassword}`);
  console.log('App user login: user@shoo.mock / shoo123456');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
