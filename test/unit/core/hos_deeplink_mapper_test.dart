import 'package:flutter_test/flutter_test.dart';
import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/deeplink/hos_deeplink_mapper.dart';

void main() {
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

  test('maps flash-sale to search', () {
    final path = SHODeepLinkMapper.toAppPath(
      Uri.parse('https://shoo.app/flash-sale'),
    );
    expect(path, '${SHOAppRoutes.search}?q=flash%20sale');
  });

  test('linkToAppPath maps in-app flash-sale path', () {
    final path = SHODeepLinkMapper.linkToAppPath('/flash-sale');
    expect(path, '${SHOAppRoutes.search}?q=flash%20sale');
  });

  test('linkToAppPath maps banner new-arrivals and trending', () {
    expect(
      SHODeepLinkMapper.linkToAppPath('/new-arrivals'),
      '${SHOAppRoutes.search}?q=new%20arrivals',
    );
    expect(
      SHODeepLinkMapper.linkToAppPath('/trending'),
      '${SHOAppRoutes.search}?q=trending',
    );
  });
}
