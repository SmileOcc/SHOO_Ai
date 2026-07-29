import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/product/domain/entities/hos_product_detail.dart';
import 'package:shoo/l10n/app_localizations.dart';
import 'package:shoo/core/feedback/hos_toast.dart';
import 'package:shoo/core/share/hos_share_action_sheet.dart';
import 'package:shoo/core/share/hos_share_service.dart';
import 'package:shoo/core/widgets/hos_dialog.dart';

/// 分享弹窗入口：组装「三方渠道行 + 自定义事件行」后交给 [SHOShareActionSheet]。
abstract final class SHOSharePanel {
  /// 展示分享面板。
  ///
  /// [extraChannels] 追加到第一行（三方/渠道）；
  /// [extraActions] 追加到第二行（自定义事件）。
  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String link,
    SHOProductDetail? product,
    GlobalKey? cardKey,
    List<SHOShareActionItem> extraChannels = const [],
    List<SHOShareActionItem> extraActions = const [],
  }) {
    final l10n = AppLocalizations.of(context);
    final share = ref.read(shareServiceProvider);

    Future<void> closeThen(FutureOr<void> Function() action) async {
      Navigator.pop(context);
      try {
        await action();
      } catch (_) {
        SHOAppToast.error(l10n.shareFailed);
      }
    }

    final channelRow = <SHOShareActionItem>[
      SHOShareActionItem(
        id: 'wechat',
        label: l10n.shareWechat,
        kind: SHOShareActionKind.thirdParty,
        icon: Icons.chat_bubble_rounded,
        backgroundColor: const Color(0xFF07C160).withValues(alpha: 0.15),
        onTap: () => closeThen(() => SHOAppToast.info(l10n.shareWechatMock)),
      ),
      SHOShareActionItem(
        id: 'moments',
        label: l10n.shareMoments,
        kind: SHOShareActionKind.thirdParty,
        icon: Icons.public_rounded,
        backgroundColor: const Color(0xFF07C160).withValues(alpha: 0.15),
        onTap: () => closeThen(() => SHOAppToast.info(l10n.shareWechatMock)),
      ),
      SHOShareActionItem(
        id: 'weibo',
        label: l10n.shareWeibo,
        kind: SHOShareActionKind.thirdParty,
        icon: Icons.campaign_outlined,
        backgroundColor: const Color(0xFFE6162D).withValues(alpha: 0.12),
        onTap: () => closeThen(
          () => SHOAppToast.info('${l10n.shareWeibo}（Mock）'),
        ),
      ),
      SHOShareActionItem(
        id: 'qq',
        label: l10n.shareQQ,
        kind: SHOShareActionKind.thirdParty,
        icon: Icons.forum_outlined,
        backgroundColor: const Color(0xFF12B7F5).withValues(alpha: 0.12),
        onTap: () => closeThen(
          () => SHOAppToast.info('${l10n.shareQQ}（Mock）'),
        ),
      ),
      SHOShareActionItem(
        id: 'facebook',
        label: l10n.shareFacebook,
        kind: SHOShareActionKind.thirdParty,
        icon: Icons.facebook_rounded,
        backgroundColor: const Color(0xFF1877F2).withValues(alpha: 0.12),
        onTap: () => closeThen(
          () => SHOAppToast.info('${l10n.shareFacebook}（Mock）'),
        ),
      ),
      SHOShareActionItem(
        id: 'twitter',
        label: l10n.shareTwitter,
        kind: SHOShareActionKind.thirdParty,
        icon: Icons.alternate_email_rounded,
        backgroundColor: const Color(0xFF1D9BF0).withValues(alpha: 0.12),
        onTap: () => closeThen(
          () => SHOAppToast.info('${l10n.shareTwitter}（Mock）'),
        ),
      ),
      SHOShareActionItem(
        id: 'system',
        label: l10n.shareSystem,
        icon: Icons.ios_share_rounded,
        onTap: () => closeThen(
          () => share.shareViaSystem(title: title, link: link),
        ),
      ),
      ...extraChannels,
    ];

    final actionRow = <SHOShareActionItem>[
      SHOShareActionItem(
        id: 'copy_link',
        label: l10n.shareCopyLink,
        icon: Icons.link_rounded,
        onTap: () => closeThen(() async {
          await share.copyLink(link);
          SHOAppToast.success(l10n.shareLinkCopied);
        }),
      ),
      if (product != null && cardKey != null)
        SHOShareActionItem(
          id: 'product_card',
          label: l10n.shareProductCard,
          icon: Icons.image_outlined,
          onTap: () => closeThen(() async {
            await share.shareProductCard(
              context: context,
              product: product,
              cardKey: cardKey,
            );
          }),
        ),
      SHOShareActionItem(
        id: 'save_image',
        label: l10n.shareSaveImage,
        icon: Icons.download_rounded,
        onTap: () => closeThen(
          () => SHOAppToast.info('${l10n.shareSaveImage}（Mock）'),
        ),
      ),
      SHOShareActionItem(
        id: 'more',
        label: l10n.shareMore,
        icon: Icons.more_horiz_rounded,
        onTap: () => closeThen(
          () => share.shareMoreOptions(title: title, link: link),
        ),
      ),
      ...extraActions,
    ];

    return SHOAppDialog.showBottomSheet<void>(
      context,
      child: SHOShareActionSheet(
        title: l10n.sharePanelTitle,
        channelRow: channelRow,
        actionRow: actionRow,
        cancelLabel: l10n.shareCancel,
      ),
    );
  }
}
