import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:shoo/core/feedback/hos_toast.dart';
import 'package:shoo/core/platform/bridge/hos_native_bridge.dart';
import 'package:shoo/core/platform/bridge/hos_native_bridge_exception.dart';
import 'package:shoo/core/platform/webview/hos_payment_handler.dart';

class SHOActivityNativeDispatcher {
  const SHOActivityNativeDispatcher();

  Future<void> dispatch(
    BuildContext context,
    String action,
    Map<String, dynamic> params,
  ) async {
    try {
      switch (action) {
        case 'openCamera':
          await _openCamera(context, params);
        case 'openAlbum':
          await _openAlbum(context, params);
        case 'openLocation':
          await _openLocation(context, params);
        case 'callPhone':
          await _callPhone(params);
        case 'shareActivity':
        case 'shareToWechat':
          await _share(params);
        case 'openPayment':
          await SHOPaymentHandler.openPaymentUrl(
            params['url']?.toString() ?? '',
          );
        case 'biometricAuth':
        case 'scanQRCode':
        case 'saveContact':
          await _nativeStub(context, action);
        case 'vibrate':
          await HapticFeedback.mediumImpact();
        default:
          if (context.mounted) {
            context.showToast('暂不支持: $action');
          }
      }
    } on PlatformException {
      if (context.mounted) {
        context.showToast(_unavailableLabel(action));
      }
    } on SHONativeBridgeException {
      if (context.mounted) {
        context.showToast(_unavailableLabel(action));
      }
    } catch (error) {
      if (context.mounted) {
        context.showToast('$action 失败: $error');
      }
    }
  }

  Future<void> _openCamera(
    BuildContext context,
    Map<String, dynamic> params,
  ) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera);
    if (!context.mounted) return;
    if (file != null) {
      context.showToast('已拍照: ${file.name}');
    }
  }

  Future<void> _openAlbum(
    BuildContext context,
    Map<String, dynamic> params,
  ) async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    if (!context.mounted) return;
    context.showToast('已选择 ${files.length} 张图片');
  }

  Future<void> _openLocation(
    BuildContext context,
    Map<String, dynamic> params,
  ) async {
    final lat = params['lat'];
    final lng = params['lng'];
    final uri = Uri.parse('https://maps.apple.com/?ll=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (context.mounted) {
      context.showToast('无法打开地图');
    }
  }

  Future<void> _callPhone(Map<String, dynamic> params) async {
    final phone = params['phoneNumber']?.toString() ?? '';
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _share(Map<String, dynamic> params) async {
    final title = params['title']?.toString() ?? 'SHOO 活动';
    final desc = params['desc']?.toString() ?? '';
    await Share.share('$title\n$desc');
  }

  Future<void> _nativeStub(BuildContext context, String action) async {
    try {
      await SHONativeBridge.invoke(method: 'activity/$action', args: {});
    } on SHONativeBridgeException {
      if (context.mounted) {
        context.showToast(_unavailableLabel(action));
      }
    }
  }

  String _unavailableLabel(String action) {
    return switch (action) {
      'openCamera' => '拍照功能暂不可用',
      'openAlbum' => '相册功能暂不可用',
      'openLocation' => '定位功能暂不可用',
      'biometricAuth' => '生物识别暂不可用',
      'scanQRCode' => '扫码功能暂不可用',
      'saveContact' => '保存联系人暂不可用',
      _ => '$action 功能暂不可用',
    };
  }
}

Map<String, dynamic>? parseBridgeMessage(String raw) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
  } catch (_) {}
  return null;
}
