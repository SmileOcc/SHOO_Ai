import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/network/hos_dio_client.dart';
import 'package:shoo/features/address/domain/entities/hos_address.dart';

final addressApiProvider = Provider<SHOAddressApi>((ref) {
  return SHOAddressApi(ref.watch(dioProvider));
});

class SHOAddressApi {
  SHOAddressApi(this._dio);

  final Dio _dio;

  Future<List<SHOAddress>> fetchAddresses() {
    return _dio.getData<List<SHOAddress>>(
      '/addresses',
      parser: (data) => (data as List<dynamic>)
          .map((e) => SHOAddress.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
