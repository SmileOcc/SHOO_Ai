export type CouponTemplateSeed = {
  id: string;
  title: string;
  description: string;
  type: string;
  discountCents: number;
  discountPercent: number;
  minOrderCents: number;
  source: string;
  validDays?: number;
};

export type CouponRegistryDefaults = Omit<CouponTemplateSeed, 'id'>;

export const THEME_COUPON_DEFAULTS: Record<string, CouponRegistryDefaults> = {
  c_all_10: {
    title: '新人券',
    description: '满99可用',
    type: 'fixed',
    discountCents: 1000,
    discountPercent: 0,
    minOrderCents: 9900,
    source: 'theme',
  },
  c_all_20: {
    title: '满减券',
    description: '满199可用',
    type: 'fixed',
    discountCents: 2000,
    discountPercent: 0,
    minOrderCents: 19900,
    source: 'theme',
  },
  c_all_30: {
    title: '大额券',
    description: '满299可用',
    type: 'fixed',
    discountCents: 3000,
    discountPercent: 0,
    minOrderCents: 29900,
    source: 'theme',
  },
  c_spring_10: {
    title: '春日券',
    description: '满100可用',
    type: 'fixed',
    discountCents: 1000,
    discountPercent: 0,
    minOrderCents: 10000,
    source: 'theme',
  },
  c_spring_20: {
    title: '大额券',
    description: '满200可用',
    type: 'fixed',
    discountCents: 2000,
    discountPercent: 0,
    minOrderCents: 20000,
    source: 'theme',
  },
};

export const FLASH_COUPON_DEFAULTS: Record<string, CouponRegistryDefaults> = {
  'fc-10-1': {
    title: '满200减30',
    description: '全场通用',
    type: 'fixed',
    discountCents: 3000,
    discountPercent: 0,
    minOrderCents: 20000,
    source: 'flash',
  },
  'fc-10-2': {
    title: '满500减80',
    description: '限抢购商品',
    type: 'fixed',
    discountCents: 8000,
    discountPercent: 0,
    minOrderCents: 50000,
    source: 'flash',
  },
  'fc-10-3': {
    title: '9折券',
    description: '会员专享',
    type: 'percent',
    discountCents: 0,
    discountPercent: 10,
    minOrderCents: 0,
    source: 'flash',
  },
  'fc-14-1': {
    title: '满300减50',
    description: '品类满减',
    type: 'fixed',
    discountCents: 5000,
    discountPercent: 0,
    minOrderCents: 30000,
    source: 'flash',
  },
  'fc-14-2': {
    title: '满100减15',
    description: '跨店满减',
    type: 'fixed',
    discountCents: 1500,
    discountPercent: 0,
    minOrderCents: 10000,
    source: 'flash',
  },
  'fc-20-1': {
    title: '满400减60',
    description: '限时满减',
    type: 'fixed',
    discountCents: 6000,
    discountPercent: 0,
    minOrderCents: 40000,
    source: 'flash',
  },
  'fc-20-2': {
    title: '满150减25',
    description: '夜间专场',
    type: 'fixed',
    discountCents: 2500,
    discountPercent: 0,
    minOrderCents: 15000,
    source: 'flash',
  },
};

export function getRegistryDefault(
  couponId: string,
): CouponRegistryDefaults | undefined {
  return THEME_COUPON_DEFAULTS[couponId] ?? FLASH_COUPON_DEFAULTS[couponId];
}

export function listRegistryTemplates(): CouponTemplateSeed[] {
  const rows: CouponTemplateSeed[] = [];
  for (const [id, defaults] of Object.entries(THEME_COUPON_DEFAULTS)) {
    rows.push({ id, ...defaults });
  }
  for (const [id, defaults] of Object.entries(FLASH_COUPON_DEFAULTS)) {
    rows.push({ id, ...defaults });
  }
  return rows;
}

export function buildCouponTemplatesFromWallet(
  wallet: Array<{
    id: string;
    title: string;
    description?: string;
    type?: string;
    discountCents?: number;
    discountPercent?: number;
    minOrderCents?: number;
  }> | null,
): CouponTemplateSeed[] {
  const templates: CouponTemplateSeed[] = [];
  if (Array.isArray(wallet)) {
    for (const item of wallet) {
      templates.push({
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
  templates.push(...listRegistryTemplates());
  return templates;
}
