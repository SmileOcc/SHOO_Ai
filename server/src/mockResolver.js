function mockPathParam(pattern, requestPath, name) {
  const patternParts = pattern.split('/');
  const pathParts = requestPath.split('/');
  if (patternParts.length !== pathParts.length) return null;

  for (let i = 0; i < patternParts.length; i++) {
    if (patternParts[i] === `{${name}}`) return pathParts[i];
  }
  return null;
}

function mockQueryInt(query, key, fallback) {
  const raw = query[key];
  if (raw == null) return fallback;
  const parsed = Number.parseInt(String(raw), 10);
  return Number.isNaN(parsed) ? fallback : parsed;
}

function paginateMockEnvelope(envelope, { page, pageSize, itemsKey = 'items' }) {
  const data = envelope.data;
  if (!data || typeof data !== 'object') return envelope;

  const items = data[itemsKey];
  if (!Array.isArray(items)) return envelope;

  const start = (page - 1) * pageSize;
  const slice = start >= items.length ? [] : items.slice(start, start + pageSize);

  return {
    ...envelope,
    data: {
      ...data,
      [itemsKey]: slice,
      page,
      pageSize,
      total: items.length,
      hasMore: start + pageSize < items.length,
    },
  };
}

function filterProductsByCategory(envelope, categoryId) {
  const data = envelope.data;
  if (!data || !Array.isArray(data.items)) return envelope;

  const filtered = data.items.filter((item) => item.categoryId === categoryId);
  return {
    ...envelope,
    data: {
      ...data,
      items: filtered,
      page: 1,
      pageSize: filtered.length,
      total: filtered.length,
      hasMore: false,
    },
  };
}

function lookupProductDetail(catalogEnvelope, productId) {
  const items = catalogEnvelope?.data?.items;
  if (!Array.isArray(items)) {
    return { code: 404, message: `Product not found: ${productId}`, data: null };
  }

  const product = items.find((item) => item.id === productId);
  if (!product) {
    return { code: 404, message: `Product not found: ${productId}`, data: null };
  }

  return {
    code: catalogEnvelope.code ?? 0,
    message: catalogEnvelope.message ?? 'ok',
    data: product,
  };
}

function lookupProductReviews(catalogEnvelope, productId) {
  const reviews = catalogEnvelope?.data?.byProduct?.[productId];
  if (!reviews) {
    return { code: 404, message: `Reviews not found: ${productId}`, data: null };
  }

  return {
    code: catalogEnvelope.code ?? 0,
    message: catalogEnvelope.message ?? 'ok',
    data: reviews,
  };
}

export async function resolveMockResponse({
  route,
  requestPath,
  query,
  envelope,
  loadMockJson,
}) {
  if (route.path === '/products') {
    let body = envelope;
    const categoryId = query.categoryId;
    if (categoryId) {
      body = filterProductsByCategory(body, String(categoryId));
    }
    const page = mockQueryInt(query, 'page', 0);
    if (page > 0) {
      const pageSize = mockQueryInt(query, 'pageSize', 10);
      body = paginateMockEnvelope(body, { page, pageSize });
    }
    return { status: 200, body };
  }

  if (route.path === '/products/{id}') {
    const productId = mockPathParam(route.path, requestPath, 'id');
    const catalog = await loadMockJson('product_catalog.json');
    const body = lookupProductDetail(catalog, productId ?? '');
    return { status: body.code === 404 ? 404 : 200, body };
  }

  if (route.path === '/products/{id}/reviews') {
    const productId = mockPathParam(route.path, requestPath, 'id');
    const catalog = await loadMockJson('product_reviews_catalog.json');
    const body = lookupProductReviews(catalog, productId ?? '');
    return { status: body.code === 404 ? 404 : 200, body };
  }

  const page = mockQueryInt(query, 'page', 0);
  if (page > 0) {
    const pageSize = mockQueryInt(query, 'pageSize', 10);
    return { status: 200, body: paginateMockEnvelope(envelope, { page, pageSize }) };
  }

  return { status: 200, body: envelope };
}
