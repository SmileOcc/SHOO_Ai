import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/product/domain/hos_product_detail.dart';
import '../deeplink/hos_deeplink_config.dart';
import '../logging/hos_logger.dart';
import '../utils/hos_widget_capture.dart';
import 'hos_share_card.dart';

final shareServiceProvider = Provider<SHOShareService>((ref) => const SHOShareService());

/// 三方分享管理（系统分享面板 + 商品卡片图 + 链接复制）。
class SHOShareService {
  const SHOShareService();

  String productLink(String productId) =>
      SHODeepLinkConfig.productLink(productId).toString();

  Future<void> shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
    SHOAppLogger.info('Shared text');
  }

  Future<void> copyLink(String link) async {
    await Clipboard.setData(ClipboardData(text: link));
    SHOAppLogger.info('Copied link');
  }

  Future<void> shareProduct({
    required String title,
    required String link,
    List<XFile>? files,
  }) async {
    if (files != null && files.isNotEmpty) {
      await Share.shareXFiles(files, text: '$title\n$link', subject: title);
    } else {
      await Share.share('$title\n$link', subject: title);
    }
    SHOAppLogger.info('Shared product: $title');
  }

  Future<void> shareProductCard({
    required BuildContext context,
    required SHOProductDetail product,
    required GlobalKey cardKey,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final file = await SHOWidgetCapture.toTempPngFile(
      cardKey,
      prefix: 'shoo_product_${product.id}',
    );
    if (file == null) {
      await shareProduct(title: product.title, link: productLink(product.id));
      return;
    }

    await shareProduct(
      title: product.title,
      link: productLink(product.id),
      files: [XFile(file.path, mimeType: 'image/png')],
    );
  }

  Future<void> shareLink(String link, {String? message}) async {
    await Share.share(message != null ? '$message\n$link' : link);
  }

  /// 离屏渲染分享卡片并返回用于截图的 [GlobalKey]。
  static Widget offscreenShareCard({
    required GlobalKey cardKey,
    required SHOProductDetail product,
  }) {
    return OverflowBox(
      alignment: Alignment.topLeft,
      maxWidth: 320,
      child: RepaintBoundary(
        key: cardKey,
        child: SHOShareProductCard(product: product),
      ),
    );
  }
}
