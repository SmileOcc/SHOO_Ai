import 'dart:io';

import 'package:flutter/material.dart';

class SHOUserAvatar extends StatelessWidget {
  const SHOUserAvatar({
    super.key,
    this.avatarUrl,
    this.radius = 36,
    this.backgroundColor,
    this.foregroundColor,
    this.fallbackIcon = Icons.person,
    this.fallbackText,
  });

  final String? avatarUrl;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData fallbackIcon;
  final String? fallbackText;

  ImageProvider? _resolveImage() {
    final url = avatarUrl?.trim();
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return NetworkImage(url);
    }
    final path = url.startsWith('file://') ? Uri.parse(url).toFilePath() : url;
    final file = File(path);
    if (!file.existsSync()) return null;
    return FileImage(file);
  }

  @override
  Widget build(BuildContext context) {
    final image = _resolveImage();
    final text = fallbackText?.trim();
    final showText = image == null && text != null && text.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.white24,
      backgroundImage: image,
      foregroundColor: foregroundColor ?? Colors.white,
      child: image != null
          ? null
          : showText
          ? Text(
              text[0].toUpperCase(),
              style: TextStyle(
                fontSize: radius * 0.9,
                fontWeight: FontWeight.w800,
              ),
            )
          : Icon(fallbackIcon, size: radius),
    );
  }
}
