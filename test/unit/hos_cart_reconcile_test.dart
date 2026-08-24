import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoo/features/cart/data/repositories/hos_cart_reconcile_service.dart';
import 'package:shoo/features/cart/domain/entities/hos_cart.dart';
import 'package:shoo/features/product/data/datasources/remote/hos_product_remote_ds.dart';
import 'package:shoo/features/product/domain/entities/hos_product_batch.dart';

class _FakeProductApi extends SHOProductApi {
  _FakeProductApi(this._result) : super(_FakeDio());

  final SHOProductBatchResult _result;

  @override
  Future<SHOProductBatchResult> fetchProductBatch({
    required List<String> productIds,
    List<String> skuIds = const [],
  }) async =>
      _result;
}

class _FakeDio implements Dio {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  group('SHOCartReconcileService', () {
    test('keeps valid sku line available when batch returns sku catalog', () async {
      const productId = 'p-a';
      const lineId = '$productId::尺码 M';
      final service = SHOCartReconcileService(
        _FakeProductApi(
          SHOProductBatchResult(
            items: [
              SHOProductBatchItem(
                productId: productId,
                price: 1299,
                originalPrice: 1599,
                stock: 12,
                available: true,
                title: 'Demo',
                imageUrl: 'https://example.com/p.jpg',
                skus: const [
                  SHOProductSkuStatus(
                    skuId: lineId,
                    variantLabel: '尺码 M',
                    stock: 8,
                    available: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      final report = await service.reconcile(
        SHOCartSnapshot(
          items: [
            SHOCartItem(
              id: lineId,
              productId: productId,
              title: 'Demo',
              imageUrl: 'https://example.com/p.jpg',
              price: 1299,
              quantity: 1,
              variantLabel: '尺码 M',
              stock: 8,
            ),
          ],
        ),
      );

      expect(report.unavailableCount, 0);
      expect(report.updatedItems.single.unavailable, isFalse);
    });

    test('does not mark unavailable when batch lacks sku list but product exists', () async {
      const productId = 'p-a';
      const lineId = '$productId::尺码 M';
      final service = SHOCartReconcileService(
        _FakeProductApi(
          SHOProductBatchResult(
            items: [
              SHOProductBatchItem(
                productId: productId,
                price: 1299,
                originalPrice: 1599,
                stock: 0,
                available: true,
                title: 'Demo',
                imageUrl: 'https://example.com/p.jpg',
              ),
            ],
          ),
        ),
      );

      final report = await service.reconcile(
        SHOCartSnapshot(
          items: [
            SHOCartItem(
              id: lineId,
              productId: productId,
              title: 'Demo',
              imageUrl: 'https://example.com/p.jpg',
              price: 1299,
              quantity: 1,
              variantLabel: '尺码 M',
              stock: 8,
            ),
          ],
        ),
      );

      expect(report.unavailableCount, 0);
      expect(report.updatedItems.single.unavailable, isFalse);
      expect(report.updatedItems.single.stock, greaterThan(0));
    });
  });
}
