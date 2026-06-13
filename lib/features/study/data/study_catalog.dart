import 'package:flutter/material.dart';

import '../domain/study_article.dart';

abstract final class SHOStudyCatalog {
  static const flutterMobileCategory = 'flutter_mobile';

  static const articles = <SHOStudyArticle>[
    SHOStudyArticle(
      id: 'flutter_mobile_interview',
      title: 'Flutter 移动端面试题',
      subtitle: 'Widget 生命周期 · Riverpod · GoRouter · 性能 · 网络',
      assetPath: 'study/flutter_mobile_interview.md',
      icon: Icons.phone_android_outlined,
      color: Color(0xFF42A5F5),
      category: flutterMobileCategory,
    ),
  ];

  static SHOStudyArticle? findById(String id) {
    for (final article in articles) {
      if (article.id == id) return article;
    }
    return null;
  }
}
