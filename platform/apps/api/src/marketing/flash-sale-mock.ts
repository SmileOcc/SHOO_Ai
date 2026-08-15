// @ts-nocheck
/* eslint-disable @typescript-eslint/no-explicit-any, @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-return, @typescript-eslint/no-unsafe-argument, @typescript-eslint/no-unsafe-call */
function formatDate(d) {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

function parseDate(raw) {
  const parts = String(raw).split('-');
  if (parts.length !== 3) return null;
  const y = Number.parseInt(parts[0], 10);
  const m = Number.parseInt(parts[1], 10);
  const d = Number.parseInt(parts[2], 10);
  if (Number.isNaN(y) || Number.isNaN(m) || Number.isNaN(d)) return null;
  return new Date(y, m - 1, d);
}

function weekdayLabel(weekday) {
  const labels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  return labels[(weekday - 1 + 7) % 7];
}

function sessionStatus(start, end, now) {
  if (now < start) return 'not_started';
  if (now < end) return 'ongoing';
  return 'ended';
}

function buildSessionsForDay(day, templates, now) {
  const dateStr = formatDate(day);
  const raw = templates.map((t) => {
    const suffix = t.idSuffix ?? '00';
    const start = new Date(day.getFullYear(), day.getMonth(), day.getDate(), t.startHour ?? 10, t.startMinute ?? 0);
    const end = new Date(start.getTime() + (t.durationMinutes ?? 120) * 60 * 1000);
    const claimStart = new Date(start.getTime() - (t.claimLeadMinutes ?? 30) * 60 * 1000);
    const claimEnd = new Date(start.getTime() + (t.claimTrailMinutes ?? 10) * 60 * 1000);
    return {
      id: `fs-${dateStr}-${suffix}`,
      label: t.label ?? `${suffix}:00场`,
      startAt: start.toISOString(),
      endAt: end.toISOString(),
      claimStartAt: claimStart.toISOString(),
      claimEndAt: claimEnd.toISOString(),
      status: sessionStatus(start, end, now),
    };
  });

  return raw;
}

function aggregateDayStatus(sessions) {
  if (!sessions.length) return 'not_started';
  const statuses = new Set(sessions.map((s) => s.status));
  if (statuses.has('ongoing')) return 'ongoing';
  if ([...statuses].every((s) => s === 'ended')) return 'ended';
  return 'not_started';
}

function pickDefaultSessionId(sessions) {
  const ongoing = sessions.find((s) => s.status === 'ongoing');
  if (ongoing) return ongoing.id;
  const upcoming = sessions.find((s) => s.status === 'not_started');
  if (upcoming) return upcoming.id;
  return sessions.length ? sessions[sessions.length - 1].id : '';
}

function resolveClaimPhase(session, now) {
  if (!session) return 'after_claim';
  const claimStart = new Date(session.claimStartAt);
  const claimEnd = new Date(session.claimEndAt);
  if (now < claimStart) return 'before_claim';
  if (now < claimEnd) return 'claiming';
  return 'after_claim';
}

function claimCountdownTarget(session, phase) {
  if (!session) return null;
  if (phase === 'before_claim') return session.claimStartAt;
  if (phase === 'claiming') return session.claimEndAt;
  return null;
}

function resolveProductStatus(session, stock, now) {
  if (!session) return 'ended';
  const start = new Date(session.startAt);
  const end = new Date(session.endAt);
  if (now < start) return 'not_started';
  if (now < end) return stock > 0 ? 'ongoing' : 'sold_out';
  return stock > 0 ? 'ended' : 'sold_out';
}

function hydrateCoupon(coupon, claimPhase, session) {
  let status = coupon.status ?? 'not_started';
  const today = formatDate(new Date());

  if (claimPhase === 'after_claim') {
    const startAt = session?.startAt;
    if (startAt && startAt.length >= 10) {
      const sessionDate = startAt.substring(0, 10);
      if (sessionDate === today && status !== 'claimed' && status !== 'sold_out') {
        status = 'claimable';
      } else {
        status = 'expired';
      }
    } else {
      status = 'expired';
    }
  } else if (claimPhase === 'claiming' && status === 'not_started') {
    status = 'claimable';
  } else if (claimPhase === 'before_claim') {
    const startAt = session?.startAt;
    if (startAt && startAt.length >= 10) {
      const sessionDate = startAt.substring(0, 10);
      if (sessionDate === today && status !== 'claimed' && status !== 'sold_out') {
        status = 'claimable';
      } else {
        status = 'not_started';
      }
    } else {
      status = 'not_started';
    }
  }
  return { ...coupon, status };
}

function sortPrice(p) {
  const status = p.status ?? 'not_started';
  if (status === 'ongoing') return p.activityPrice ?? 0;
  return p.originalPrice ?? 0;
}

function sortProducts(products, sort) {
  const list = products.map((p) => ({ ...p }));
  list.sort((a, b) => {
    if (sort === 'price_asc') return sortPrice(a) - sortPrice(b);
    if (sort === 'price_desc') return sortPrice(b) - sortPrice(a);
    if (sort === 'newest') return String(b.createdAt ?? '').localeCompare(String(a.createdAt ?? ''));
    return (b.soldCount ?? 0) - (a.soldCount ?? 0);
  });
  return list;
}

export function resolveFlashSaleCalendar(envelope, query = {}) {
  const now = new Date();
  const data = envelope.data ?? {};
  const templates = data.sessionTemplates ?? [];
  const activityId = query.activityId != null ? String(query.activityId) : '';
  const activity = resolveActivity(data, activityId);
  const days = [];

  for (let offset = -1; offset < 6; offset += 1) {
    const day = new Date(now.getFullYear(), now.getMonth(), now.getDate() + offset);
    const sessions = buildSessionsForDay(day, templates, now);
    days.push({
      date: formatDate(day),
      label: `${day.getMonth() + 1}/${day.getDate()}`,
      weekday: weekdayLabel(day.getDay() === 0 ? 7 : day.getDay()),
      status: aggregateDayStatus(sessions),
      sessionCount: sessions.length,
    });
  }

  return {
    code: envelope.code ?? 0,
    message: envelope.message ?? 'ok',
    data: {
      serverTime: now.toISOString(),
      days,
      ...(activity
        ? { activityId: activity.id, activityTitle: activity.title }
        : {}),
    },
  };
}

export function resolveFlashSalePage(envelope, query) {
  const now = new Date();
  const data = envelope.data ?? {};
  const templates = data.sessionTemplates ?? [];
  const allProducts = data.products ?? [];
  const promoEntries = data.promoEntries ?? [];
  const couponsBySuffix = data.couponsBySessionSuffix ?? {};
  const activityId = query.activityId != null ? String(query.activityId) : '';
  const activity = resolveActivity(data, activityId);
  const filteredProducts = filterProductsForActivity(allProducts, activity);

  const dateStr = query.date != null ? String(query.date) : formatDate(now);
  const day = parseDate(dateStr) ?? new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const sessions = buildSessionsForDay(day, templates, now);

  let sessionId = query.sessionId != null ? String(query.sessionId) : '';
  if (!sessionId) sessionId = pickDefaultSessionId(sessions);

  const session = sessions.find((s) => s.id === sessionId) ?? sessions[0] ?? null;
  sessionId = session?.id ?? sessionId;
  const suffix = sessionId.split('-').pop();
  const rawCoupons = couponsBySuffix[suffix] ?? [];
  const claimPhase = resolveClaimPhase(session, now);
  const claimTarget = claimCountdownTarget(session, claimPhase);

  let products = filteredProducts.map((p) => ({
    ...p,
    sessionId,
    status: resolveProductStatus(session, p.stock ?? 0, now),
    isFollowed: false,
  }));

  const sort = query.sort != null ? String(query.sort) : 'hot';
  products = sortProducts(products, sort);

  const page = Number.parseInt(String(query.page ?? '1'), 10) || 1;
  const pageSize = Number.parseInt(String(query.pageSize ?? '4'), 10) || 4;
  const start = (page - 1) * pageSize;
  const slice = start >= products.length ? [] : products.slice(start, start + pageSize);

  return {
    code: envelope.code ?? 0,
    message: envelope.message ?? 'ok',
    data: {
      serverTime: now.toISOString(),
      date: dateStr,
      sessionId,
      ...(activity
        ? { activityId: activity.id, activityTitle: activity.title }
        : {}),
      claimPhase,
      ...(claimTarget ? { claimCountdownTarget: claimTarget } : {}),
      sessions,
      promoEntries,
      coupons: rawCoupons.map((c) => hydrateCoupon(c, claimPhase, session)),
      products: slice,
      page,
      pageSize,
      total: products.length,
      hasMore: start + pageSize < products.length,
    },
  };
}

export function resolveFlashSaleProductActivity(envelope, query) {
  const now = new Date();
  const data = envelope.data ?? {};
  const activities = data.productActivities ?? {};
  const products = data.products ?? [];
  const templates = data.sessionTemplates ?? [];
  const productId = String(query.productId ?? '');
  const sessionId = String(query.sessionId ?? '');

  const product = products.find((p) => p.id === productId) ?? {};
  const activityBase = activities[productId] ?? product;
  if (!productId || (!Object.keys(product).length && !Object.keys(activityBase).length)) {
    return { code: 404, message: 'Activity not found', data: null };
  }

  const datePart = sessionId.includes('-') ? sessionId.split('-')[1] : formatDate(now);
  const day = parseDate(datePart) ?? new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const sessions = buildSessionsForDay(day, templates, now);
  const session = sessions.find((s) => s.id === sessionId) ?? sessions[0] ?? null;
  const stock = activityBase.stock ?? product.stock ?? 0;
  const status = resolveProductStatus(session, stock, now);

  let overlayLabel = null;
  if (status === 'not_started') overlayLabel = `活动未开始 · ${session?.label ?? ''}`;
  else if (status === 'ongoing') overlayLabel = '抢购进行中';
  else if (status === 'sold_out') overlayLabel = '已抢完';
  else overlayLabel = '活动已结束';

  return {
    code: 0,
    message: 'ok',
    data: {
      sessionId,
      status,
      originalPrice: activityBase.originalPrice ?? product.originalPrice ?? 0,
      activityPrice: activityBase.activityPrice ?? product.activityPrice ?? 0,
      primaryPromoType: activityBase.primaryPromoType ?? product.primaryPromoType,
      primaryPromoLabel: activityBase.primaryPromoLabel ?? product.primaryPromoLabel,
      promoTags: activityBase.promoTags ?? product.promoTags ?? [],
      sessionStartAt: session?.startAt,
      sessionEndAt: session?.endAt,
      overlayLabel,
      isFollowed: false,
      stock,
    },
  };
}

function findFlashSaleProduct(catalogEnvelope, productId) {
  const products = catalogEnvelope?.data?.products;
  if (!Array.isArray(products)) return null;
  return products.find((p) => p.id === productId) ?? null;
}

export function lookupFlashSaleProductDetail(catalogEnvelope, productId, query = {}) {
  const product = findFlashSaleProduct(catalogEnvelope, productId);
  if (!product) {
    return { code: 404, message: `Product not found: ${productId}`, data: null };
  }

  let price = product.originalPrice ?? 0;
  let discountLabel = product.primaryPromoLabel ?? '';
  const sessionId = query.sessionId != null ? String(query.sessionId) : '';

  if (sessionId) {
    const activity = resolveFlashSaleProductActivity(catalogEnvelope, {
      productId,
      sessionId,
    });
    if (activity.data) {
      if (activity.data.status === 'ongoing') {
        price = activity.data.activityPrice ?? price;
      } else {
        price = activity.data.originalPrice ?? price;
      }
      discountLabel = activity.data.primaryPromoLabel ?? discountLabel;
    }
  }

  const imageUrl = product.imageUrl ?? '';
  return {
    code: catalogEnvelope.code ?? 0,
    message: catalogEnvelope.message ?? 'ok',
    data: {
      id: productId,
      title: product.title,
      imageUrl,
      images: [imageUrl],
      price,
      originalPrice: product.originalPrice ?? price,
      discountLabel,
      rating: 4.6,
      soldCount: product.soldCount ?? 0,
      description: `${product.title} — 限时抢购专享商品，支持折扣/满减活动价（以场次状态为准）。`,
      reviewCount: 0,
    },
  };
}

export function emptyFlashSaleProductReviews() {
  return {
    code: 0,
    message: 'ok',
    data: {
      averageRating: 0,
      totalCount: 0,
      items: [],
    },
  };
}

export function isFlashSaleProductId(catalogEnvelope, productId) {
  if (findFlashSaleProduct(catalogEnvelope, productId)) return true;
  return String(productId).startsWith('fs-');
}

export function validateFlashSaleCheckoutItems(catalogEnvelope, items) {
  for (const raw of items) {
    if (!raw || typeof raw !== 'object') continue;
    const productId = String(raw.productId ?? '');
    const sessionId = String(raw.sessionId ?? '');
    const clientPrice = raw.unitPriceCents;
    if (!sessionId || !productId.startsWith('fs-')) continue;

    const activity = resolveFlashSaleProductActivity(catalogEnvelope, {
      productId,
      sessionId,
    });
    if (activity.code === 404) {
      return { code: 400, message: 'Flash sale activity not found', data: null };
    }
    const status = activity.data?.status ?? 'ended';
    if (status !== 'ongoing') {
      return { code: 400, message: `Flash sale is not active for ${productId}`, data: null };
    }
    const expected = activity.data?.activityPrice ?? 0;
    if (clientPrice != null && clientPrice !== expected) {
      return { code: 400, message: `Flash sale price mismatch for ${productId}`, data: null };
    }
  }
  return null;
}

function resolveActivity(data, activityId) {
  if (!activityId) return null;
  const activities = data.activities ?? [];
  return activities.find((item) => item.id === activityId) ?? null;
}

function filterProductsForActivity(allProducts, activity) {
  if (!activity) return allProducts;
  const kinds = (activity.kinds ?? []).map(String);
  if (!kinds.length) return allProducts;
  return allProducts.filter((product) => {
    const productKinds = (product.activityKinds ?? []).map(String);
    return productKinds.some((kind) => kinds.includes(kind));
  });
}
