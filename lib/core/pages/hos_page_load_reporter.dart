import 'package:flutter/foundation.dart';

import 'package:shoo/core/analytics/hos_analytics_manager.dart';
import 'package:shoo/core/analytics/hos_analytics_registry.dart';
import 'package:shoo/core/logging/hos_logger.dart';

/// 页面加载阶段。
enum SHOPageLoadPhase {
  /// 首帧渲染完成（Scaffold / 壳层可见）。
  firstFrame('first_frame'),

  /// 业务数据首屏就绪（[SHODataPage] content）。
  contentReady('content_ready'),

  /// WebView onPageFinished。
  webViewFinished('webview_finished');

  const SHOPageLoadPhase(this.value);

  final String value;
}

/// 页面 / WebView 加载耗时上报。
abstract final class SHOPageLoadReporter {
  static Future<void> report({
    required String pageName,
    required int durationMs,
    required SHOPageLoadPhase phase,
    String? routePath,
    Map<String, Object?> extra = const {},
  }) async {
    SHOAppLogger.d(
      '[PageLoad] $pageName phase=${phase.value} ${durationMs}ms',
    );

    await SHOAnalyticsManager.instance.trackEvent(
      SHOAnalyticsRegistry.pageLoadTime,
      {
        'page_name': pageName,
        'duration_ms': durationMs,
        'load_phase': phase.value,
        if (routePath != null && routePath.isNotEmpty) 'route_path': routePath,
        ...extra,
      },
    );
  }

  static Future<void> reportRenderError({
    required String pageName,
    required FlutterErrorDetails details,
    String? routePath,
    Map<String, Object?> extra = const {},
  }) async {
    final exception = details.exceptionAsString();
    SHOAppLogger.w('[PageRenderError] $pageName $exception');

    await SHOAnalyticsManager.instance.trackEvent(
      SHOAnalyticsRegistry.pageRenderError,
      {
        'page_name': pageName,
        'error': exception,
        if (routePath != null && routePath.isNotEmpty) 'route_path': routePath,
        ...extra,
      },
    );
  }

  static Future<void> reportWebView({
    required String url,
    required int durationMs,
    required bool success,
    int? errorCode,
    String? errorMessage,
  }) async {
    SHOAppLogger.d(
      '[WebViewLoad] ${success ? 'ok' : 'fail'} ${durationMs}ms $url',
    );

    await SHOAnalyticsManager.instance.trackEvent(
      SHOAnalyticsRegistry.webViewPageLoad,
      {
        'url': url,
        'duration_ms': durationMs,
        'success': success,
        if (errorCode != null) 'error_code': errorCode,
        if (errorMessage != null && errorMessage.isNotEmpty)
          'error_message': errorMessage,
      },
    );
  }

  static Future<void> reportBridgeError({
    required String pageName,
    required String error,
    String? bridgeType,
    String? bridgeAction,
    Map<String, Object?> extra = const {},
  }) async {
    SHOAppLogger.w('[BridgeError] $pageName $error');

    await SHOAnalyticsManager.instance.trackEvent(
      SHOAnalyticsRegistry.bridgeError,
      {
        'page_name': pageName,
        'error': error,
        if (bridgeType != null && bridgeType.isNotEmpty) 'bridge_type': bridgeType,
        if (bridgeAction != null && bridgeAction.isNotEmpty)
          'bridge_action': bridgeAction,
        ...extra,
      },
    );
  }
}
