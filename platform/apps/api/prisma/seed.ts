import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcryptjs';
import * as fs from 'fs';
import * as path from 'path';

const prisma = new PrismaClient();

type Envelope<T> = { code: number; message: string; data: T };

function readMock<T>(file: string): T {
  const candidates = [
    process.env.MOCK_DATA_DIR,
    path.resolve(__dirname, '../../../../../assets/mock'),
    path.resolve(process.cwd(), '../../../assets/mock'),
    path.resolve(process.cwd(), '../../../../assets/mock'),
  ].filter(Boolean) as string[];

  for (const dir of candidates) {
    const full = path.join(dir, file);
    if (fs.existsSync(full)) {
      const raw = JSON.parse(fs.readFileSync(full, 'utf8')) as Envelope<T>;
      return raw.data;
    }
  }
  throw new Error(`Mock file not found: ${file}`);
}

function tryReadMock<T>(file: string): T | null {
  try {
    return readMock<T>(file);
  } catch {
    return null;
  }
}

function resolveMockPath(file: string): string | null {
  const candidates = [
    process.env.MOCK_DATA_DIR,
    path.resolve(__dirname, '../../../../../assets/mock'),
    path.resolve(process.cwd(), '../../../assets/mock'),
    path.resolve(process.cwd(), '../../../../assets/mock'),
  ].filter(Boolean) as string[];

  for (const dir of candidates) {
    const full = path.join(dir, file);
    if (fs.existsSync(full)) return full;
  }
  return null;
}

/** Read mock JSON as-is (no {code,data} envelope). */
function tryReadRawJson<T>(file: string): T | null {
  const full = resolveMockPath(file);
  if (!full) return null;
  try {
    return JSON.parse(fs.readFileSync(full, 'utf8')) as T;
  } catch {
    return null;
  }
}

async function upsertDocument(key: string, payload: unknown) {
  await prisma.appDocument.upsert({
    where: { key },
    create: { key, payload: payload as object },
    update: { payload: payload as object },
  });
}

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

  const logisticsTemplate = tryReadMock<{
    orderId?: string;
    carrier?: string;
    trackingNumber?: string;
    events?: unknown[];
  }>('order_logistics.json');
  if (logisticsTemplate) {
    const orderId = logisticsTemplate.orderId ?? 'o1';
    await upsertDocument('order_logistics_catalog', {
      byOrder: {
        [orderId]: {
          carrier: logisticsTemplate.carrier ?? '',
          trackingNumber: logisticsTemplate.trackingNumber ?? '',
          events: logisticsTemplate.events ?? [],
        },
      },
    });
    console.log(`Order logistics catalog seeded for ${orderId}`);
  }

  // Document-backed domains (App API parity)
  const documentFiles: Array<[string, string]> = [
    ['messages', 'messages.json'],
    ['addresses', 'addresses.json'],
    ['coupons', 'coupons.json'],
    ['search_hot', 'search_hot.json'],
    ['search', 'search.json'],
    ['reviews_catalog', 'product_reviews_catalog.json'],
    ['order_logistics', 'order_logistics.json'],
    ['after_sales', 'after_sales.json'],
    ['after_sale_create', 'after_sale_create.json'],
    ['community_feed', 'community_feed.json'],
    ['activity_popup', 'activity_popup.json'],
    ['home_quick_entries', 'home_quick_entries.json'],
    ['home_feed_config', 'home_feed_config.json'],
    ['cart_marquee', 'cart_marquee.json'],
    ['activity_data', 'activity_data.json'],
    ['activity_detail', 'activity_detail.json'],
    ['activity_level3_detail', 'activity_level3_detail.json'],
    ['activity_user_check', 'activity_user_check.json'],
    ['activity_url_rules', 'activity_url_rules.json'],
    ['flash_sale_catalog', 'flash_sale_catalog.json'],
    ['flash_sale_follows', 'flash_sale_follows.json'],
    ['app_version', 'app_version.json'],
    ['cart', 'cart.json'],
    ['contacts', 'contacts.json'],
    ['documents', 'documents.json'],
    ['push_register_ok', 'push_register_ok.json'],
  ];

  for (const [key, file] of documentFiles) {
    const data = tryReadMock<unknown>(file);
    if (data == null) {
      console.warn(`Skip missing mock: ${file}`);
      continue;
    }
    await upsertDocument(key, data);
    console.log(`Document seeded: ${key}`);
  }

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

  // Coupon templates (wallet + theme + flash-sale ids)
  const couponTemplates: Array<{
    id: string;
    title: string;
    description: string;
    type: string;
    discountCents: number;
    discountPercent: number;
    minOrderCents: number;
    source: string;
  }> = [];

  const walletCoupons = tryReadMock<
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
  if (walletCoupons) {
    for (const item of walletCoupons) {
      couponTemplates.push({
        id: item.id,
        title: item.title,
        description: item.description ?? '',
        type: item.type ?? 'fixed',
        discountCents: item.discountCents ?? 0,
        discountPercent: item.discountPercent ?? 0,
        minOrderCents: item.minOrderCents ?? 0,
        source: 'wallet',
      });
    }
  }

  const extraTemplates = [
    {
      id: 'c_all_10',
      title: '新人券',
      description: '满99可用',
      type: 'fixed',
      discountCents: 1000,
      discountPercent: 0,
      minOrderCents: 9900,
      source: 'theme',
    },
    {
      id: 'c_all_20',
      title: '满减券',
      description: '满199可用',
      type: 'fixed',
      discountCents: 2000,
      discountPercent: 0,
      minOrderCents: 19900,
      source: 'theme',
    },
    {
      id: 'c_all_30',
      title: '大额券',
      description: '满299可用',
      type: 'fixed',
      discountCents: 3000,
      discountPercent: 0,
      minOrderCents: 29900,
      source: 'theme',
    },
    {
      id: 'fc-10-1',
      title: '满200减30',
      description: '全场通用',
      type: 'fixed',
      discountCents: 3000,
      discountPercent: 0,
      minOrderCents: 20000,
      source: 'flash',
    },
    {
      id: 'fc-10-2',
      title: '满500减80',
      description: '限抢购商品',
      type: 'fixed',
      discountCents: 8000,
      discountPercent: 0,
      minOrderCents: 50000,
      source: 'flash',
    },
    {
      id: 'fc-10-3',
      title: '9折券',
      description: '会员专享',
      type: 'percent',
      discountCents: 0,
      discountPercent: 10,
      minOrderCents: 0,
      source: 'flash',
    },
    {
      id: 'fc-14-1',
      title: '满300减50',
      description: '品类满减',
      type: 'fixed',
      discountCents: 5000,
      discountPercent: 0,
      minOrderCents: 30000,
      source: 'flash',
    },
    {
      id: 'fc-14-2',
      title: '满100减15',
      description: '跨店满减',
      type: 'fixed',
      discountCents: 1500,
      discountPercent: 0,
      minOrderCents: 10000,
      source: 'flash',
    },
    {
      id: 'fc-20-1',
      title: '满400减60',
      description: '限时满减',
      type: 'fixed',
      discountCents: 6000,
      discountPercent: 0,
      minOrderCents: 40000,
      source: 'flash',
    },
    {
      id: 'fc-20-2',
      title: '满150减25',
      description: '夜间专场',
      type: 'fixed',
      discountCents: 2500,
      discountPercent: 0,
      minOrderCents: 15000,
      source: 'flash',
    },
  ];
  couponTemplates.push(...extraTemplates);

  for (const item of couponTemplates) {
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
        validDays: 30,
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
  console.log(`Coupon templates upserted: ${couponTemplates.length}`);

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
