import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/network/hos_dio_client.dart';
import 'package:shoo/features/toolbox/domain/entities/hos_contact.dart';

final contactApiProvider = Provider<SHOContactApi>((ref) {
  return SHOContactApi(ref.watch(dioProvider));
});

class SHOContactApi {
  SHOContactApi(this._dio);

  final Dio _dio;

  Future<List<SHOContact>> fetchContacts({String? query}) {
    return _dio.getData<List<SHOContact>>(
      '/contacts',
      queryParameters: query != null && query.isNotEmpty ? {'q': query} : null,
      parser: (data) => (data as List<dynamic>)
          .map((e) => SHOContact.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
