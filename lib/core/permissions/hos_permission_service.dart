import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../logging/hos_logger.dart';

final permissionServiceProvider = Provider<SHOPermissionService>((ref) {
  return const SHOPermissionService();
});

/// 权限申请统一管理。
///
/// ```dart
/// final granted = await ref.read(permissionServiceProvider).request(Permission.camera);
/// ```
class SHOPermissionService {
  const SHOPermissionService();

  Future<bool> request(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      SHOAppLogger.warn('Permission permanently denied: $permission');
      return false;
    }

    final result = await permission.request();
    SHOAppLogger.info('Permission $permission → $result');
    return result.isGranted;
  }

  Future<bool> requestCamera() => request(Permission.camera);

  Future<bool> requestPhotos() => request(Permission.photos);

  Future<bool> requestNotification() => request(Permission.notification);

  Future<bool> requestLocation() => request(Permission.locationWhenInUse);

  Future<void> openSettings() => openAppSettings();
}
