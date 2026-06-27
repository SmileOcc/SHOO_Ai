import 'package:flutter_test/flutter_test.dart';
import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/deeplink/hos_deeplink_action_type.dart';
import 'package:shoo/core/deeplink/hos_deeplink_mapper.dart';
import 'package:shoo/core/deeplink/hos_deeplink_resolver.dart';

void main() {
  group('SHODeepLinkMapper', () {
    test('maps https product link', () {
      final path = SHODeepLinkMapper.toAppPath(
        Uri.parse('https://shoo.app/product/p-100'),
      );
      expect(path, SHOAppRoutes.product('p-100'));
    });

    test('maps custom scheme product link', () {
      final path = SHODeepLinkMapper.toAppPath(
        Uri.parse('shoo://product/p-100'),
      );
      expect(path, SHOAppRoutes.product('p-100'));
    });

    test('maps orders list', () {
      final path = SHODeepLinkMapper.toAppPath(
        Uri.parse('https://shoo.app/orders'),
      );
      expect(path, SHOAppRoutes.orders);
    });

    test('maps category products', () {
      final path = SHODeepLinkMapper.toAppPath(
        Uri.parse(
          'https://shoo.app/category/products?leafId=c1&title=Test',
        ),
      );
      expect(
        path,
        SHOAppRoutes.categoryProductsFiltered(leafId: 'c1', title: 'Test'),
      );
    });

    test('maps flash-sale to flash sale page', () {
      final path = SHODeepLinkMapper.toAppPath(
        Uri.parse('https://shoo.app/flash-sale'),
      );
      expect(path, SHOAppRoutes.flashSale);
    });

    test('linkToAppPath maps in-app flash-sale path', () {
      final path = SHODeepLinkMapper.linkToAppPath('/flash-sale');
      expect(path, SHOAppRoutes.flashSale);
    });
  });

  group('SHODeepLinkResolver', () {
    test('product detail type', () {
      final target = SHODeepLinkResolver.resolveLink(
        'https://shoo.app/product/p-1',
      );
      expect(target?.type, SHODeepLinkActionType.productDetail);
      expect(target?.requiresAuth, isFalse);
    });

    test('orders requires auth', () {
      final target = SHODeepLinkResolver.resolveLink('https://shoo.app/orders');
      expect(target?.type, SHODeepLinkActionType.orders);
      expect(target?.requiresAuth, isTrue);
      expect(target?.appPath, SHOAppRoutes.orders);
    });

    test('product list type', () {
      final target = SHODeepLinkResolver.resolveLink(
        'https://shoo.app/category/products?leafId=a&title=List',
      );
      expect(target?.type, SHODeepLinkActionType.productList);
      expect(target?.requiresAuth, isFalse);
    });

    test('external https url is not deep link', () {
      expect(
        SHODeepLinkResolver.resolveLink('https://www.example.com'),
        isNull,
      );
      expect(
        SHODeepLinkResolver.isDeepLink('https://www.google.com'),
        isFalse,
      );
    });

    test('shoo.app root maps to home', () {
      final target = SHODeepLinkResolver.resolveLink('https://shoo.app/');
      expect(target?.appPath, SHOAppRoutes.home);
    });

    test('profile deep link', () {
      final target = SHODeepLinkResolver.resolveLink('https://shoo.app/profile');
      expect(target?.type, SHODeepLinkActionType.profile);
      expect(target?.appPath, SHOAppRoutes.profile);
      expect(target?.requiresAuth, isFalse);
    });
  });
}
