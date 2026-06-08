import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/hos_dio_client.dart';
import '../domain/hos_cart_marquee.dart';

final cartMarqueeApiProvider = Provider<SHOCartMarqueeApi>((ref) {
  return SHOCartMarqueeApi(ref.watch(dioProvider));
});

class SHOCartMarqueeApi {
  SHOCartMarqueeApi(this._dio);

  final Dio _dio;

  Future<List<SHOCartMarqueeItem>> fetchMarqueeItems() {
    return _dio.getData<List<SHOCartMarqueeItem>>(
      '/marketing/cart-marquee',
      parser: (data) => (data as List<dynamic>)
          .map((e) => SHOCartMarqueeItem.fromJson(e as Map<String, dynamic>))
          .where((item) => item.text.isNotEmpty)
          .toList(),
    );
  }
}
