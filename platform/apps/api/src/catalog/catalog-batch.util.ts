const SKU_SIZES = ['S', 'M', 'L', 'XL'] as const;

/** 与 Flutter `SHOCartReconcileService.mockStockFor` 对齐的稳定库存。 */
export function mockStockFor(productId: string): number {
  let hash = 0;
  for (let i = 0; i < productId.length; i++) {
    hash = productId.charCodeAt(i) + ((hash << 5) - hash);
  }
  return 5 + (Math.abs(hash) % 20);
}

function mockSkuStockFor(skuId: string, productStock: number): number {
  let hash = 0;
  for (let i = 0; i < skuId.length; i++) {
    hash = skuId.charCodeAt(i) + ((hash << 5) - hash);
  }
  const cap = Math.max(1, productStock);
  return 1 + (Math.abs(hash) % cap);
}

function buildDefaultSkus(productId: string, productStock: number) {
  const skus: Array<{
    skuId: string;
    variantLabel: string;
    stock: number;
    available: boolean;
  }> = [];
  for (const size of SKU_SIZES) {
    for (const label of [`Size ${size}`, `尺码 ${size}`]) {
      const skuId = `${productId}::${label}`;
      const stock = mockSkuStockFor(skuId, productStock);
      skus.push({
        skuId,
        variantLabel: label,
        stock,
        available: stock > 0,
      });
    }
  }
  return skus;
}

export type BatchProductRow = {
  id: string;
  categoryId: string;
  title: string;
  imageUrl: string;
  price: number;
  originalPrice: number;
  discountLabel: string;
  rating: number;
  soldCount: number;
  description: string;
  images: unknown;
  reviewCount: number;
};

export function toCartBatchItem(
  product: BatchProductRow,
  requestedSkuIds: Set<string>,
) {
  const productId = product.id;
  const stock = mockStockFor(productId);
  const skus = buildDefaultSkus(productId, stock);

  for (const skuId of requestedSkuIds) {
    if (!skuId.startsWith(`${productId}::`)) continue;
    if (skus.some((sku) => sku.skuId === skuId)) continue;
    const variant = skuId.slice(productId.length + 2);
    skus.push({
      skuId,
      variantLabel: variant,
      stock: 0,
      available: false,
    });
  }

  return {
    productId,
    id: productId,
    title: product.title,
    imageUrl: product.imageUrl,
    price: product.price,
    originalPrice: product.originalPrice,
    stock,
    available: stock > 0,
    skus,
  };
}
