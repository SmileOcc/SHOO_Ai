import 'dart:io';

import 'package:flutter/material.dart';

import '../marketing/hos_activity_popup_service.dart';
import '../theme/hos_spacing.dart';
import 'hos_button.dart';
import 'hos_network_image.dart';

/// 活动运营弹窗广告（描述超 5 行可滚动）。
class SHOActivityPopupDialog extends StatelessWidget {
  const SHOActivityPopupDialog({super.key, required this.activity});

  final SHOActivityPopup activity;

  static const int _maxScrollLines = 5;

  static Future<void> show(BuildContext context, {required SHOActivityPopup activity}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => SHOActivityPopupDialog(activity: activity),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    final lineHeight = (style?.fontSize ?? 14) * (style?.height ?? 1.4);
    final maxDescHeight = lineHeight * _maxScrollLines;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: _buildImage(),
          ),
          Padding(
            padding: const EdgeInsets.all(SHOAppSpacing.xl),
            child: Column(
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
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: SHOAppSpacing.sm),
                SHOAppButton(
                  label: 'Close',
                  isExpanded: true,
                  variant: SHOAppButtonVariant.ghost,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final local = activity.cachedImagePath;
    if (local != null && File(local).existsSync()) {
      return Image.file(File(local), fit: BoxFit.cover);
    }
    return SHOAppNetworkImage(url: activity.imageUrl, fit: BoxFit.cover);
  }
}
