import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../update/hos_update_dialog.dart';
import 'hos_activity_popup_manager.dart';
import 'hos_activity_prefetch_service.dart';
import 'hos_activity_popup_service.dart';

/// 弹窗编排：升级弹窗始终优先（最上层），活动弹窗在其后且层级更低。
///
/// 1. 先展示升级弹窗并等待关闭
/// 2. 再按配置延时展示活动弹窗
abstract final class SHOPopupOrchestrator {
  static Future<void> showHomePopups(BuildContext context, WidgetRef ref) async {
    SHOActivityPopup? pending;
    try {
      pending = await SHOActivityPopupManager.resolveActivity(ref);
      if (pending?.prefetchEnabled == true) {
        await ref.read(activityPrefetchServiceProvider).prefetch(pending!);
      }
    } catch (_) {
      // 预拉取失败不阻塞
    }

    await SHOAppUpdateDialog.showIfNeeded(context, ref);

    if (!context.mounted) return;
    await SHOActivityPopupManager.showIfNeeded(context, ref);
  }
}
