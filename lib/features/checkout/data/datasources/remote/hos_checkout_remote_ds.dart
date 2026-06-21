import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/config/hos_config.dart';
import 'package:shoo/core/network/hos_dio_client.dart';
import 'package:shoo/core/network/security/hos_crypto_service.dart';
import 'package:shoo/core/network/security/hos_rsa_api_helper.dart';
import 'package:shoo/features/checkout/domain/entities/hos_payment_result.dart';
import 'package:shoo/features/order/domain/entities/hos_order.dart';

final checkoutApiProvider = Provider<SHOCheckoutApi>((ref) {
  return SHOCheckoutApi(
    ref.watch(dioProvider),
    ref.watch(cryptoServiceProvider),
    ref.watch(appConfigProvider),
  );
});

class SHOCheckoutApi {
  SHOCheckoutApi(this._dio, this._crypto, this._config);

  final Dio _dio;
  final SHOCryptoService _crypto;
  final SHOAppConfig _config;

  Future<SHOOrderDetail> createOrder({
    required String addressId,
    required List<Map<String, dynamic>> items,
    String? couponId,
  }) async {
    final plainBody = {
      'addressId': addressId,
      'items': items,
      if (couponId != null) 'couponId': couponId,
    };
    final prepared = await SHORsaApiHelper.prepareRsaPost(
      config: _config,
      crypto: _crypto,
      plainBody: plainBody,
    );
    return _dio.postData<SHOOrderDetail>(
      '/orders',
      data: prepared.body,
      headers: prepared.headers.isEmpty ? null : prepared.headers,
      skipPayloadEncrypt: true,
      parser: (data) => SHOOrderDetail.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<SHOPaymentResult> payOrder(String orderId) {
    return _dio.postData<SHOPaymentResult>(
      '/orders/$orderId/pay',
      parser: (data) => SHOPaymentResult.fromJson(data as Map<String, dynamic>),
    );
  }
}
