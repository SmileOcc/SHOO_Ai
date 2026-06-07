import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'hos_log_manager.dart';

final logReportServiceProvider = Provider<SHOLogReportService>((ref) {
  return const SHOLogReportService();
});

class SHOLogReportService {
  const SHOLogReportService();

  Future<int> cachedByteSize() => SHOAppLogManager.instance.cachedByteSize();

  Future<bool> reportLogs() async {
    final file = await SHOAppLogManager.instance.exportFile();
    if (file == null) return false;
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/plain')],
      subject: 'SHOO App Logs',
      text: 'SHOO diagnostic logs',
    );
    return true;
  }
}
