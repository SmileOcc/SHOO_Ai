import '../analytics/hos_analytics_manager.dart';
import '../analytics/hos_analytics_registry.dart';
import '../analytics/hos_app_startup_timer.dart';
import 'hos_log_manager.dart';

/// 启动耗时日志（上下分隔线，便于筛选）。
abstract final class SHOStartupTimingLog {
  static const _border =
      '═══════════════════ SHOO STARTUP TIME ═══════════════════';

  static Future<void> printAndTrack() async {
    final bootstrapMs = SHOAppStartupTimer.bootstrapMs;
    final firstFrameMs = SHOAppStartupTimer.firstFrameMs;
    final renderMs = SHOAppStartupTimer.bootstrapToFirstFrameMs;

    final buffer = StringBuffer()
      ..writeln(_border)
      ..writeln('[SHOO STARTUP TIMING]')
      ..writeln('bootstrapMs: ${bootstrapMs ?? 'n/a'}')
      ..writeln('firstFrameMs: ${firstFrameMs ?? 'n/a'}')
      ..writeln('bootstrapToFirstFrameMs: ${renderMs ?? 'n/a'}')
      ..writeln(_border);

    final text = buffer.toString();
    // ignore: avoid_print
    print(text);
    await SHOAppLogManager.instance.append('INFO', text);

    if (bootstrapMs != null && firstFrameMs != null) {
      await SHOAnalyticsManager.instance.trackEvent(
        SHOAnalyticsRegistry.appStartupTime,
        {
          'bootstrap_ms': bootstrapMs,
          'first_frame_ms': firstFrameMs,
          'bootstrap_to_first_frame_ms': renderMs ?? 0,
        },
      );
    }
  }
}
