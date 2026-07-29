import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:shoo/core/logging/hos_log_manager.dart';
import 'package:shoo/core/logging/hos_logger.dart';

final logReportServiceProvider = Provider<SHOLogReportService>((ref) {
  return const SHOLogReportService();
});

class SHOLogReportService {
  const SHOLogReportService();

  Future<int> cachedByteSize() => SHOAppLogManager.instance.cachedByteSize();

  /// 导出并调起系统分享。
  ///
  /// [context] 用于计算 iPad/Mac 所需的 [sharePositionOrigin]，避免原生抛错。
  Future<bool> reportLogs({BuildContext? context}) async {
    // 分享前先算好 origin，避免 async gap 后读 context。
    final origin = _shareOrigin(context);
    try {
      final file = await SHOAppLogManager.instance.exportFile();
      if (file == null) return false;

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/plain', name: 'shoo_app_logs.txt')],
        subject: 'SHOO App Logs',
        text: 'SHOO diagnostic logs',
        sharePositionOrigin: origin,
        fileNameOverrides: const ['shoo_app_logs.txt'],
      );
      return true;
    } catch (error, stack) {
      SHOAppLogger.e('reportLogs failed', error, stack);
      return false;
    }
  }

  /// iPad/Mac 要求非零且落在屏幕内的 origin，否则 share_plus 会抛 PlatformException。
  Rect? _shareOrigin(BuildContext? context) {
    if (context == null || !context.mounted) return null;
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize && box.size.width > 0 && box.size.height > 0) {
      final topLeft = box.localToGlobal(Offset.zero);
      return topLeft & box.size;
    }
    final size = MediaQuery.sizeOf(context);
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.4),
      width: 80,
      height: 80,
    );
  }
}
