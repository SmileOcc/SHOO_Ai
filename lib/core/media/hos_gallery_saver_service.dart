import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

import 'package:shoo/core/logging/hos_logger.dart';
import 'package:shoo/core/permissions/hos_permission_service.dart';

final gallerySaverProvider = Provider<SHOGallerySaverService>((ref) {
  return SHOGallerySaverService(ref.watch(permissionServiceProvider));
});

enum SHOGallerySaveResult {
  success,
  permissionDenied,
  pluginUnavailable,
  failed,
}

/// 保存图片到系统相册。
class SHOGallerySaverService {
  const SHOGallerySaverService(this._permissions);

  final SHOPermissionService _permissions;

  Future<SHOGallerySaveResult> saveImageBytes(
    Uint8List bytes, {
    String name = 'shoo',
  }) async {
    if (bytes.isEmpty) return SHOGallerySaveResult.failed;

    try {
      final granted = await _ensureAlbumAccess();
      if (!granted) return SHOGallerySaveResult.permissionDenied;

      await Gal.putImageBytes(
        bytes,
        name: '$name-${DateTime.now().millisecondsSinceEpoch}.png',
      );
      return SHOGallerySaveResult.success;
    } on MissingPluginException catch (error, stack) {
      SHOAppLogger.error('Gal plugin not registered — rebuild the app', error, stack);
      return SHOGallerySaveResult.pluginUnavailable;
    } on GalException catch (error, stack) {
      SHOAppLogger.error('Save image to gallery failed', error, stack);
      return SHOGallerySaveResult.failed;
    } catch (error, stack) {
      SHOAppLogger.error('Save image to gallery failed', error, stack);
      return SHOGallerySaveResult.failed;
    }
  }

  Future<File?> writeTempPng(
    Uint8List bytes, {
    String prefix = 'shoo_share',
  }) async {
    if (bytes.isEmpty) return null;
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/$prefix-${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<bool> _ensureAlbumAccess() async {
    try {
      if (await Gal.hasAccess(toAlbum: true)) return true;
    } on MissingPluginException {
      rethrow;
    } catch (error, stack) {
      SHOAppLogger.error('Gal.hasAccess failed, fallback to permission_handler', error, stack);
    }

    final granted = await _permissions.requestPhotos();
    if (!granted) return false;

    try {
      return await Gal.requestAccess(toAlbum: true);
    } on MissingPluginException {
      rethrow;
    } catch (error, stack) {
      SHOAppLogger.error('Gal.requestAccess failed', error, stack);
      return false;
    }
  }
}
