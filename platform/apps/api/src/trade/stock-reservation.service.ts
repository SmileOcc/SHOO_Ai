import { BadRequestException, Injectable } from '@nestjs/common';
import { mockStockFor } from '../catalog/catalog-batch.util';
import { DocumentsService } from '../documents/documents.service';

export const ORDER_PAYMENT_WINDOW_MS = 20 * 60 * 1000;

type ReservationStatus = 'locked' | 'consumed';

type StockReservation = {
  orderId: string;
  productId: string;
  variantLabel: string;
  quantity: number;
  expiresAt: string;
  status: ReservationStatus;
};

type StockLedgerDoc = {
  consumed: Record<string, number>;
  reservations: StockReservation[];
};

@Injectable()
export class StockReservationService {
  private static readonly DOC_KEY = 'product_stock_ledger';

  constructor(private readonly docs: DocumentsService) {}

  private stockKey(productId: string, variantLabel = '') {
    const variant = variantLabel.trim();
    return variant.length === 0 ? productId : `${productId}::${variant}`;
  }

  private async loadLedger(): Promise<StockLedgerDoc> {
    const raw = await this.docs.getPayloadOrNull<Partial<StockLedgerDoc>>(
      StockReservationService.DOC_KEY,
    );
    return {
      consumed: { ...(raw?.consumed ?? {}) },
      reservations: [...(raw?.reservations ?? [])],
    };
  }

  private async saveLedger(ledger: StockLedgerDoc) {
    await this.docs.upsertPayload(StockReservationService.DOC_KEY, ledger);
  }

  private purgeExpired(ledger: StockLedgerDoc, now = Date.now()) {
    ledger.reservations = ledger.reservations.filter((entry) => {
      if (entry.status !== 'locked') return true;
      return Date.parse(entry.expiresAt) > now;
    });
  }

  availableQuantity(productId: string, variantLabel: string, ledger: StockLedgerDoc) {
    const key = this.stockKey(productId, variantLabel);
    const base = mockStockFor(productId);
    const consumed = ledger.consumed[key] ?? 0;
    const locked = ledger.reservations
      .filter(
        (entry) =>
          entry.status === 'locked' &&
          this.stockKey(entry.productId, entry.variantLabel) === key &&
          Date.parse(entry.expiresAt) > Date.now(),
      )
      .reduce((sum, entry) => sum + entry.quantity, 0);
    return Math.max(0, base - consumed - locked);
  }

  async assertCanReserve(
    items: Array<{
      productId: string;
      quantity: number;
      variantLabel?: string;
      title?: string;
    }>,
  ) {
    const ledger = await this.loadLedger();
    this.purgeExpired(ledger);
    for (const item of items) {
      const available = this.availableQuantity(
        item.productId,
        item.variantLabel ?? '',
        ledger,
      );
      if (item.quantity > available) {
        const label = item.title?.trim() || item.productId;
        throw new BadRequestException(
          `Insufficient stock for ${label}. Available: ${available}`,
        );
      }
    }
  }

  async lockForOrder(
    orderId: string,
    items: Array<{
      productId: string;
      quantity: number;
      variantLabel?: string;
    }>,
    expiresAt: Date,
  ) {
    const ledger = await this.loadLedger();
    this.purgeExpired(ledger);
    await this.assertCanReserve(items);
    const expiresIso = expiresAt.toISOString();
    for (const item of items) {
      ledger.reservations.push({
        orderId,
        productId: item.productId,
        variantLabel: item.variantLabel?.trim() ?? '',
        quantity: item.quantity,
        expiresAt: expiresIso,
        status: 'locked',
      });
    }
    await this.saveLedger(ledger);
  }

  async consumeForOrder(orderId: string) {
    const ledger = await this.loadLedger();
    this.purgeExpired(ledger);
    for (const entry of ledger.reservations) {
      if (entry.orderId !== orderId || entry.status !== 'locked') continue;
      const key = this.stockKey(entry.productId, entry.variantLabel);
      ledger.consumed[key] = (ledger.consumed[key] ?? 0) + entry.quantity;
      entry.status = 'consumed';
    }
    await this.saveLedger(ledger);
  }

  async releaseForOrder(orderId: string) {
    const ledger = await this.loadLedger();
    ledger.reservations = ledger.reservations.filter(
      (entry) => entry.orderId !== orderId || entry.status !== 'locked',
    );
    await this.saveLedger(ledger);
  }
}
