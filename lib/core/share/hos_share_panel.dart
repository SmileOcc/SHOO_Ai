import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/hos_colors.dart';
import '../theme/hos_spacing.dart';
import '../widgets/hos_dialog.dart';
import 'hos_share_service.dart';
import '../../l10n/app_localizations.dart';

/// 成熟分享弹窗面板（复制链接 / 系统分享 / 第三方入口占位）。
///
/// ```dart
/// SHOSharePanel.show(context, ref, title: 'SHOProduct', link: 'https://...');
/// ```
abstract final class SHOSharePanel {
  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String link,
  }) {
    final l10n = AppLocalizations.of(context);
    return SHOAppDialog.showBottomSheet<void>(
      context,
      child: Padding(
        padding: const EdgeInsets.all(SHOAppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.sharePanelTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: SHOAppSpacing.xl),
            _SHOShareTile(
              icon: Icons.share_rounded,
              label: l10n.shareSystem,
              onTap: () async {
                Navigator.pop(context);
                await ref.read(shareServiceProvider).shareProduct(title: title, link: link);
              },
            ),
            _SHOShareTile(
              icon: Icons.link_rounded,
              label: l10n.shareCopyLink,
              onTap: () async {
                Navigator.pop(context);
                await ref.read(shareServiceProvider).shareLink(link, message: title);
              },
            ),
            _SHOShareTile(
              icon: Icons.chat_bubble_outline,
              label: l10n.shareWechat,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.shareWechatMock)),
                );
              },
            ),
            _SHOShareTile(
              icon: Icons.more_horiz,
              label: l10n.shareMore,
              onTap: () async {
                Navigator.pop(context);
                await ref.read(shareServiceProvider).shareText('$title\n$link');
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
