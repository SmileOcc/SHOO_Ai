import { mockStockFor } from '../catalog/catalog-batch.util';
import { StockReservationService } from './stock-reservation.service';

describe('StockReservationService', () => {
  const docs = {
    payload: null as unknown,
    async getPayloadOrNull<T>(_key: string) {
      return this.payload as T | null;
    },
    async upsertPayload(_key: string, payload: unknown) {
      this.payload = payload;
    },
  };

  const service = new StockReservationService(docs as never);

  beforeEach(() => {
    docs.payload = null;
  });

  it('locks and releases stock for pending orders', async () => {
    const productId = 'p-test';
    const expiresAt = new Date(Date.now() + 20 * 60 * 1000);

    await service.lockForOrder(
      'order-1',
      [{ productId, quantity: 2, variantLabel: 'M' }],
      expiresAt,
    );

    await expect(
      service.lockForOrder(
        'order-2',
        [{ productId, quantity: mockStockFor(productId), variantLabel: 'M' }],
        expiresAt,
      ),
    ).rejects.toThrow('Insufficient stock');

    await service.releaseForOrder('order-1');

    await expect(
      service.lockForOrder(
        'order-2',
        [{ productId, quantity: 2, variantLabel: 'M' }],
        expiresAt,
      ),
    ).resolves.toBeUndefined();
  });
});
