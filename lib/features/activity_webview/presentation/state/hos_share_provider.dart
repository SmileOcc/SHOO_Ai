import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:shoo/core/feedback/hos_toast.dart';
import 'package:shoo/core/media/hos_gallery_saver_service.dart';
import 'package:shoo/core/platform/webview/hos_webview_capture.dart';
import 'package:shoo/features/activity_webview/domain/entities/hos_activity_config.dart';

class SHOShareState {
  const SHOShareState({
    this.capturing = false,
    this.imageBytes,
    this.visible = false,
  });

  final bool capturing;
  final Uint8List? imageBytes;
  final bool visible;

  SHOShareState copyWith({
    bool? capturing,
    Uint8List? imageBytes,
    bool? visible,
    bool clearImage = false,
  }) {
    return SHOShareState(
      capturing: capturing ?? this.capturing,
      imageBytes: clearImage ? null : (imageBytes ?? this.imageBytes),
      visible: visible ?? this.visible,
    );
  }
}

class SHOShareNotifier extends Notifier<SHOShareState> {
  Completer<Uint8List?>? _screenshotCompleter;

  @override
  SHOShareState build() => const SHOShareState();

  Future<void> captureFromWebView(WebViewController controller) async {
    if (state.capturing) return;

    state = state.copyWith(capturing: true, visible: false);
    final completer = Completer<Uint8List?>();
    _screenshotCompleter = completer;

    try {
      await controller.runJavaScript(SHOWebViewCapture.captureScript);
      final bytes = await completer.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () => null,
      );
      if (bytes != null && bytes.isNotEmpty) {
        state = state.copyWith(
          imageBytes: bytes,
          visible: true,
          capturing: false,
        );
      } else {
        state = state.copyWith(capturing: false);
      }
    } catch (_) {
      state = state.copyWith(capturing: false);
    } finally {
      _screenshotCompleter = null;
    }
  }

  void completeScreenshot(Uint8List? bytes) {
    final completer = _screenshotCompleter;
    if (completer == null || completer.isCompleted) return;
    completer.complete(bytes);
  }

  void hide() => state = state.copyWith(visible: false);

  Future<void> shareTo(
    BuildContext context,
    WidgetRef ref,
    String channel,
    SHOActivityConfig config,
  ) async {
    final text = '${config.shareTitle}\n${config.shareDesc}\n${config.shareUrl}';
    final bytes = state.imageBytes;
    final saver = ref.read(gallerySaverProvider);

    switch (channel) {
      case 'wechat':
      case 'moments':
        if (bytes != null) {
          final file = await saver.writeTempPng(bytes, prefix: 'activity_share');
          if (file != null) {
            await Share.shareXFiles(
              [XFile(file.path)],
              text: text,
            );
            return;
          }
        }
        await Share.share(text);
      case 'copy':
        await Share.share(text);
      case 'save':
        if (bytes == null) {
          if (context.mounted) {
            context.showToast('暂无截图可保存');
          }
          return;
        }
        final result = await saver.saveImageBytes(bytes, name: 'activity');
        if (!context.mounted) return;
        switch (result) {
          case SHOGallerySaveResult.success:
            context.showToast('已保存到相册');
          case SHOGallerySaveResult.permissionDenied:
            context.showToast('需要相册权限才能保存图片');
          case SHOGallerySaveResult.pluginUnavailable:
            context.showToast('保存功能未就绪，请完全退出后重新运行应用');
          case SHOGallerySaveResult.failed:
            context.showToast('保存失败，请稍后重试');
        }
    }
  }
}

final shareProvider = NotifierProvider<SHOShareNotifier, SHOShareState>(
  SHOShareNotifier.new,
);
