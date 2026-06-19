import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/network/hos_dio_client.dart';
import 'package:shoo/core/constants/hos_constants.dart';
import 'package:shoo/features/community/domain/entities/hos_community_models.dart';

final communityApiProvider = Provider<SHOCommunityApi>((ref) {
  return SHOCommunityApi(ref.watch(dioProvider));
});

class SHOCommunityApi {
  SHOCommunityApi(this._dio);

  final Dio _dio;

  Future<SHOCommunityFeedPage> fetchFeed({
    required SHOCommunitySort sort,
    int page = 1,
    int pageSize = SHOAppConstants.defaultPageSize,
  }) {
    return _dio.getData<SHOCommunityFeedPage>(
      '/community/feed',
      queryParameters: {
        'sort': communitySortToQuery(sort),
        'page': page,
        'pageSize': pageSize,
      },
      parser: (data) =>
          SHOCommunityFeedPage.fromJson(data as Map<String, dynamic>),
    );
  }
}
