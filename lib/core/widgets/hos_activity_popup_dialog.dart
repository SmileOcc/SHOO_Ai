import 'dart:io';

import 'package:flutter/material.dart';
import '../../app/router/hos_route_navigator.dart';
import '../../l10n/app_localizations.dart';
import '../marketing/hos_activity_popup_service.dart';
import '../theme/hos_spacing.dart';
import 'hos_button.dart';
import 'hos_network_image.dart';

/// 活动运营弹窗广告（描述超 5 行可滚动）。
class SHOActivityPopupDialog extends StatelessWidget {
  const SHOActivityPopupDialog({super.key, required this.activity});

  final SHOActivityPopup activity;

  static const int _maxScrollLines = 5;
  static const double _popupRadius = 12;

  static Future<void> show(BuildContext context, {required SHOActivityPopup activity}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => SHOActivityPopupDialog(activity: activity),
    );
  }

  void _onCta(BuildContext context) {
    Navigator.pop(context);
    if (activity.link.trim().isNotEmpty) {
      SHORouteNavigator.followLink(context, activity.link);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final style = Theme.of(context).textTheme.bodyMedium;
    final lineHeight = (style?.fontSize ?? 14) * (style?.height ?? 1.4);
    final maxDescHeight = lineHeight * _maxScrollLines;
    final maxDialogHeight = MediaQuery.sizeOf(context).height * 0.82;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: SHOAppSpacing.xxxl,
        vertical: SHOAppSpacing.xl,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_popupRadius),
        child: Material(
          color: Theme.of(context).dialogTheme.backgroundColor ??
              Theme.of(context).colorScheme.surface,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxDialogHeight),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: InkWell(
                      onTap: activity.link.trim().isNotEmpty
                          ? () => _onCta(context)
                          : null,
                      child: _buildImage(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(SHOAppSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          activity.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (activity.description.isNotEmpty) ...[
                          const SizedBox(height: SHOAppSpacing.md),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: maxDescHeight),
                            child: SingleChildScrollView(
                              child: Text(
                                activity.description,
                                style: style,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: SHOAppSpacing.lg),
                        SHOAppButton(
                          label: activity.buttonText,
                          isExpanded: true,
                          variant: SHOAppButtonVariant.accent,
                          onPressed: () => _onCta(context),
                        ),
                        const SizedBox(height: SHOAppSpacing.sm),
                        SHOAppButton(
                          label: l10n.dialogClose,
                          isExpanded: true,
                          variant: SHOAppButtonVariant.ghost,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final local = activity.cachedImagePath;
    if (local != null && File(local).existsSync()) {
      return Image.file(File(local), fit: BoxFit.cover, width: double.infinity);
    }
    return SHOAppNetworkImage(
      url: activity.imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
    );
  }
}
