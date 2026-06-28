import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/activity_webview/data/datasources/remote/hos_activity_remote_ds.dart';
import 'package:shoo/features/activity_webview/domain/entities/hos_activity_config.dart';
import 'package:shoo/features/activity_webview/domain/entities/hos_activity_detail.dart';

final activityConfigProvider = FutureProvider<SHOActivityConfig>((ref) async {
  final api = ref.watch(activityApiProvider);
  return api.fetchActivityConfig();
});

final activityUserStatusProvider = FutureProvider<SHOActivityUserStatus>((
  ref,
) async {
  final api = ref.watch(activityApiProvider);
  return api.checkUserStatus();
});

final activityDetailProvider = FutureProvider<SHOActivityDetail>((ref) async {
  final api = ref.watch(activityApiProvider);
  return api.fetchActivityDetail();
});

final activityLevel3DetailProvider = FutureProvider<SHOActivityLevel3Detail>((
  ref,
) async {
  final api = ref.watch(activityApiProvider);
  return api.fetchActivityLevel3Detail();
});
