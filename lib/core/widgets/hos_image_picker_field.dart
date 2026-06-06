import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/app_localizations.dart';
import '../media/hos_image_picker_service.dart';
import '../theme/hos_colors.dart';
import '../theme/hos_spacing.dart';

/// 多图选择字段（相机 / 相册），用于评价晒图、售后凭证等。
class SHOImagePickerField extends ConsumerWidget {
  const SHOImagePickerField({
    super.key,
    required this.images,
    required this.onChanged,
    this.maxCount = 6,
    this.label,
  });

  final List<XFile> images;
  final ValueChanged<List<XFile>> onChanged;
  final int maxCount;
  final String? label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final picker = ref.read(imagePickerServiceProvider);

    Future<void> addFromGallery() async {
      if (images.length >= maxCount) return;
      final picked = await picker.pickMultipleFromGallery(
        maxCount: maxCount - images.length,
      );
      if (picked.isEmpty) return;
      onChanged([...images, ...picked].take(maxCount).toList());
    }

    Future<void> addFromCamera() async {
      if (images.length >= maxCount) return;
      final picked = await picker.pickFromCamera();
      if (picked == null) return;
      onChanged([...images, picked]);
    }

    void removeAt(int index) {
      final next = [...images]..removeAt(index);
      onChanged(next);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: SHOAppSpacing.md),
        ],
        Wrap(
          spacing: SHOAppSpacing.sm,
          runSpacing: SHOAppSpacing.sm,
          children: [
            ...images.asMap().entries.map((entry) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
                    child: Image.file(
                      File(entry.value.path),
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => removeAt(entry.key),
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            }),
            if (images.length < maxCount) ...[
              _SHOImageAddButton(
                icon: Icons.photo_library_outlined,
                label: l10n.imagePickerGallery,
                onTap: addFromGallery,
              ),
              _SHOImageAddButton(
                icon: Icons.photo_camera_outlined,
                label: l10n.imagePickerCamera,
                onTap: addFromCamera,
              ),
            ],
          ],
        ),
        const SizedBox(height: SHOAppSpacing.xs),
        Text(
          l10n.imagePickerHint(maxCount),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: SHOAppColors.textMuted,
              ),
        ),
      ],
    );
  }
}

class _SHOImageAddButton extends StatelessWidget {
  const _SHOImageAddButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          border: Border.all(color: SHOAppColors.border),
          borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
          color: SHOAppColors.surfaceMuted,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: SHOAppColors.primary),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: SHOAppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
