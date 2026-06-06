import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/product/domain/hos_product_detail.dart';
import '../../l10n/app_localizations.dart';
import '../feedback/hos_toast.dart';
import '../theme/hos_colors.dart';
import '../theme/hos_spacing.dart';
import '../widgets/hos_dialog.dart';
import 'hos_share_service.dart';

/// 成熟分享弹窗面板（复制链接 / 系统分享 / 商品卡片图 / 第三方入口占位）。
abstract final class SHOSharePanel {
  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String link,
    SHOProductDetail? product,
    GlobalKey? cardKey,
  }) {
    final l10n = AppLocalizations.of(context);
    final share = ref.read(shareServiceProvider);

    return SHOAppDialog.showBottomSheet<void>(
      context,
      child: Padding(
        padding: const EdgeInsets.all(SHOAppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.sharePanelTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: SHOAppSpacing.xl),
            if (product != null && cardKey != null)
              _SHOShareTile(
                icon: Icons.image_outlined,
                label: l10n.shareProductCard,
                onTap: () async {
                  Navigator.pop(context);
                  await share.shareProductCard(
                    context: context,
                    product: product,
                    cardKey: cardKey,
                  );
                },
              ),
            _SHOShareTile(
              icon: Icons.share_rounded,
              label: l10n.shareSystem,
              onTap: () async {
                Navigator.pop(context);
                await share.shareProduct(title: title, link: link);
              },
            ),
            _SHOShareTile(
              icon: Icons.link_rounded,
              label: l10n.shareCopyLink,
              onTap: () async {
                Navigator.pop(context);
                await share.copyLink(link);
                SHOAppToast.success(l10n.shareLinkCopied);
              },
            ),
            _SHOShareTile(
              icon: Icons.chat_bubble_outline,
              label: l10n.shareWechat,
              onTap: () {
                Navigator.pop(context);
                SHOAppToast.info(l10n.shareWechatMock);
              },
            ),
            _SHOShareTile(
              icon: Icons.more_horiz,
              label: l10n.shareMore,
              onTap: () async {
                Navigator.pop(context);
                await share.shareText('$title\n$link');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SHOShareTile extends StatelessWidget {
  const _SHOShareTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: SHOAppColors.primary),
      title: Text(label),
      onTap: onTap,
    );
  }
}
