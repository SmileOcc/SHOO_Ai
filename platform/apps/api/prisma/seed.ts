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

  for (const o of orders.items) {
    await prisma.orderItem.deleteMany({ where: { orderId: o.id } });
    await prisma.order.upsert({
      where: { id: o.id },
      create: {
        id: o.id,
        orderNo: o.orderNo,
        status: o.status,
        totalCents: o.totalCents,
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
      },
    });
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
