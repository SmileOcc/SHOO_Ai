import { mockStockFor, toCartBatchItem } from './catalog-batch.util';

describe('catalog-batch.util', () => {
  const product = {
    id: 'p-a',
    categoryId: 'c1',
    title: 'Demo',
    imageUrl: 'https://example.com/p.jpg',
    price: 1299,
    originalPrice: 1599,
    discountLabel: '',
    rating: 4.5,
    soldCount: 10,
    description: '',
    images: [],
    reviewCount: 3,
  };

  it('returns positive stock for cart reconcile', () => {
    const item = toCartBatchItem(product, new Set(['p-a::尺码 M']));
    expect(item.stock).toBeGreaterThan(0);
    expect(item.available).toBe(true);
    expect(item.productId).toBe('p-a');
  });

  it('includes default and requested sku entries', () => {
    const item = toCartBatchItem(product, new Set(['p-a::尺码 M', 'p-a::Weird']));
    const skuIds = item.skus.map((sku) => sku.skuId);
    expect(skuIds).toContain('p-a::尺码 M');
    expect(skuIds).toContain('p-a::Size M');
    const weird = item.skus.find((sku) => sku.skuId === 'p-a::Weird');
    expect(weird?.available).toBe(false);
  });

  it('mockStockFor is stable', () => {
    expect(mockStockFor('p-a')).toBe(mockStockFor('p-a'));
    expect(mockStockFor('p-a')).toBeGreaterThan(0);
  });
});
