import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/hos_dio_client.dart';
import '../domain/hos_message.dart';

final messageApiProvider = Provider<SHOMessageApi>((ref) {
  return SHOMessageApi(ref.watch(dioProvider));
});

class SHOMessageApi {
  SHOMessageApi(this._dio);

  final Dio _dio;

  Future<List<SHOAppMessage>> fetchMessages() {
    return _dio.getData<List<SHOAppMessage>>(
      '/messages',
      parser: (data) => (data as List<dynamic>)
          .map((e) => SHOAppMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
