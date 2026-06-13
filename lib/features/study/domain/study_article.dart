import 'package:flutter/material.dart';

class SHOStudyArticle {
  const SHOStudyArticle({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.icon,
    required this.color,
    required this.category,
  });

  final String id;
  final String title;
  final String subtitle;
  final String assetPath;
  final IconData icon;
  final Color color;
  final String category;
}
