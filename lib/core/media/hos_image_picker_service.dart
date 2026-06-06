import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../logging/hos_logger.dart';
import '../permissions/hos_permission_service.dart';

final imagePickerServiceProvider = Provider<SHOImagePickerService>((ref) {
  return SHOImagePickerService(ref.watch(permissionServiceProvider));
});

/// 相机 / 相册选图，统一权限申请。
class SHOImagePickerService {
  SHOImagePickerService(this._permissions);

  final SHOPermissionService _permissions;
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickFromGallery() async {
    final granted = await _permissions.requestPhotos();
    if (!granted) return null;
    return _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
  }

  Future<XFile?> pickFromCamera() async {
    final granted = await _permissions.requestCamera();
    if (!granted) return null;
    return _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
  }

  Future<List<XFile>> pickMultipleFromGallery({int maxCount = 6}) async {
    final granted = await _permissions.requestPhotos();
    if (!granted) return [];

    final files = await _picker.pickMultiImage(imageQuality: 85);
    SHOAppLogger.info('Picked ${files.length} images from gallery');
    return files.take(maxCount).toList();
  }
}
