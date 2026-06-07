import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'hos_analytics_manager.dart';

final analyticsManagerProvider = Provider<SHOAnalyticsManager>((ref) {
  return SHOAnalyticsManager.instance;
});
