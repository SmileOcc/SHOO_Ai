import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shoo/core/constants/hos_constants.dart';
import 'package:shoo/core/storage/key_value/hos_local_storage.dart';
import 'package:shoo/features/cart/domain/entities/hos_cart.dart';
import 'package:shoo/features/cart/presentation/state/hos_cart_controller.dart';

void main() {
  SHOCartItem line({
    required String productId,
    required String variant,
    int quantity = 1,
    String? title,
  }) {
    return SHOCartItem(
      id: '$productId::$variant',
      productId: productId,
      title: title ?? productId,
      imageUrl: 'https://example.com/$productId.png',
      price: 1000,
      quantity: quantity,
      variantLabel: variant,
      stock: 20,
    );
  }

  Future<ProviderContainer> pumpCart(SHOCartSnapshot initial) async {
    SharedPreferences.setMockInitialValues({
      SHOAppConstants.cartStorageKey: jsonEncode(initial.toJson()),
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    // 等 build() 里的 restore microtask 跑完，再显式 restore 一次作为权威数据。
    await Future<void>.delayed(Duration.zero);
    await container.read(cartProvider.notifier).restore();
    return container;
  }

  test('changeVariant keeps same productId and list position', () async {
    final container = await pumpCart(
      SHOCartSnapshot(
        items: [
          line(productId: 'a', variant: 'Size M', title: 'Alpha'),
          line(productId: 'b', variant: 'Size L', title: 'Beta'),
        ],
      ),
    );
    addTearDown(container.dispose);

    await container.read(cartProvider.notifier).changeVariant(
          lineId: 'a::Size M',
          newVariantLabel: 'Size XL',
          quantity: 2,
          expectedProductId: 'a',
        );

    final items = container.read(cartProvider).items;
    expect(items, hasLength(2));
    expect(items[0].productId, 'a');
    expect(items[0].title, 'Alpha');
    expect(items[0].variantLabel, 'Size XL');
    expect(items[0].quantity, 2);
    expect(items[0].id, 'a::Size XL');
    expect(items[1].productId, 'b');
    expect(items[1].title, 'Beta');
  });

  test('changeVariant rejects mismatched expectedProductId', () async {
    final container = await pumpCart(
      SHOCartSnapshot(
        items: [line(productId: 'a', variant: 'Size M', title: 'Alpha')],
      ),
    );
    addTearDown(container.dispose);

    await container.read(cartProvider.notifier).changeVariant(
          lineId: 'a::Size M',
          newVariantLabel: 'Size L',
          quantity: 1,
          expectedProductId: 'other',
        );

    final items = container.read(cartProvider).items;
    expect(items.single.variantLabel, 'Size M');
  });

  test('changeVariant merges duplicate sku onto edited slot', () async {
    final container = await pumpCart(
      SHOCartSnapshot(
        items: [
          line(productId: 'a', variant: 'Size M', quantity: 1, title: 'Alpha'),
          line(productId: 'b', variant: 'Size M', quantity: 1, title: 'Beta'),
          line(productId: 'a', variant: 'Size L', quantity: 2, title: 'Alpha'),
        ],
      ),
    );
    addTearDown(container.dispose);

    await container.read(cartProvider.notifier).changeVariant(
          lineId: 'a::Size M',
          newVariantLabel: 'Size L',
          quantity: 1,
          expectedProductId: 'a',
        );

    final items = container.read(cartProvider).items;
    expect(items, hasLength(2));
    expect(items[0].productId, 'a');
    expect(items[0].variantLabel, 'Size L');
    expect(items[0].quantity, 3);
    expect(items[1].productId, 'b');
  });
}
