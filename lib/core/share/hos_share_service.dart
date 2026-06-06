import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../logging/hos_logger.dart';

final shareServiceProvider = Provider<SHOShareService>((ref) => const SHOShareService());

/// 三方分享管理（系统分享面板 + 业务封装）。
///
/// ```dart
/// await ref.read(shareServiceProvider).shareProduct(
///   title: product.title,
///   link: 'https://shoo.app/product/${product.id}',
/// );
/// ```
class SHOShareService {
  const SHOShareService();

  Future<void> shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
    SHOAppLogger.info('Shared text');
  }

  Future<void> shareProduct({
    required String title,
    required String link,
    String? imageUrl,
  }) async {
    final text = '$title\n$link';
    await Share.share(text, subject: title);
    SHOAppLogger.info('Shared product: $title');
  }

  Future<void> shareLink(String link, {String? message}) async {
    await Share.share(message != null ? '$message\n$link' : link);
  }
}
