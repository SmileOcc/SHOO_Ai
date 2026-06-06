import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../storage/hos_local_storage.dart';
import '../widgets/hos_activity_popup_dialog.dart';
import 'hos_activity_popup_service.dart';
import 'hos_activity_prefetch_service.dart';

String _dailyCountKey(String activityId) {
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  return 'activity_daily_${activityId}_$today';
}

/// 活动弹窗广告管理：排期、每日次数、预拉取、延时展示。
abstract final class SHOActivityPopupManager {
  static bool isWithinSchedule(SHOActivityPopup activity) {
    final now = DateTime.now();
    if (activity.startAt != null && now.isBefore(activity.startAt!)) return false;
    if (activity.endAt != null && now.isAfter(activity.endAt!)) return false;
    return true;
  }

  static Future<bool> canShowToday(SHOLocalStorage storage, SHOActivityPopup activity) async {
    final count = await storage.read<int>(_dailyCountKey(activity.id)) ?? 0;
    return count < activity.maxDailyShows;
  }

  static Future<void> recordShow(SHOLocalStorage storage, SHOActivityPopup activity) async {
    final key = _dailyCountKey(activity.id);
    final count = await storage.read<int>(key) ?? 0;
    await storage.write(key, count + 1);
  }

  static Future<SHOActivityPopup?> resolveActivity(WidgetRef ref) async {
    final activity = await ref.read(activityPopupServiceProvider).fetchActive();
    if (activity == null) return null;

    if (!isWithinSchedule(activity)) return null;
    if (!await canShowToday(ref.read(localStorageProvider), activity)) return null;

    if (activity.prefetchEnabled) {
      final cached = await ref.read(activityPrefetchServiceProvider).loadPrefetched(activity.id);
      return cached ?? activity;
    }
    return activity;
  }

  /// 在升级弹窗之后调用；支持延时秒数。
  static Future<void> showIfNeeded(
    BuildContext context,
    WidgetRef ref, {
    int extraDelaySeconds = 0,
  }) async {
    try {
      final activity = await resolveActivity(ref);
      if (activity == null || !context.mounted) return;

      final delay = Duration(seconds: activity.delaySeconds + extraDelaySeconds);
      if (delay > Duration.zero) {
        await Future<void>.delayed(delay);
        if (!context.mounted) return;
      }

      final stillValid = await resolveActivity(ref);
      if (stillValid == null || !context.mounted) return;

      if (stillValid.prefetchEnabled) {
        await ref.read(activityPrefetchServiceProvider).prefetch(stillValid);
      }

      await SHOActivityPopupDialog.show(context, activity: stillValid);
      await recordShow(ref.read(localStorageProvider), stillValid);
    } catch (_) {
      // 静默
    }
  }
}
