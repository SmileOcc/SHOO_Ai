import { PrismaClient } from '@prisma/client';
import { tryReadMock } from '../lib/mock-reader';
import { upsertDocument } from '../lib/upsert-document';

const DOCUMENT_FILES: Array<[string, string]> = [
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

export async function seedDocuments(prisma: PrismaClient) {
  for (const [key, file] of DOCUMENT_FILES) {
    const data = tryReadMock<unknown>(file);
    if (data == null) {
      console.warn(`Skip missing mock: ${file}`);
      continue;
    }
    await upsertDocument(prisma, key, data);
    console.log(`Document seeded: ${key}`);
  }
}

export async function seedOrderLogisticsCatalog(prisma: PrismaClient) {
  const logisticsTemplate = tryReadMock<{
    orderId?: string;
    carrier?: string;
    trackingNumber?: string;
    events?: unknown[];
  }>('order_logistics.json');
  if (!logisticsTemplate) return;

  const orderId = logisticsTemplate.orderId ?? 'o1';
  await upsertDocument(prisma, 'order_logistics_catalog', {
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
