import 'package:flutter/material.dart';

import '../../../core/theme/hos_spacing.dart';
import '../../../core/theme/hos_theme_extension.dart';

class SHOSettingsGroup extends StatelessWidget {
  const SHOSettingsGroup({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = context.shoTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            SHOAppSpacing.xl,
            SHOAppSpacing.lg,
            SHOAppSpacing.xl,
            SHOAppSpacing.sm,
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: theme.textMuted,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.pagePadding),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.shoSurface,
              borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
              border: Border.all(color: theme.border),
            ),
            child: Column(
              children: _withDividers(children, theme.divider),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _withDividers(List<Widget> items, Color dividerColor) {
    if (items.length <= 1) return items;
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(Divider(height: 1, thickness: 1, color: dividerColor, indent: 16));
      }
    }
    return result;
  }
}

class SHOSettingsTile extends StatelessWidget {
  const SHOSettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.titleColor,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Color? titleColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.lg),
      leading: leading,
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 14,
              color: titleColor,
            ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.shoTheme.textMuted,
                  ),
            )
          : null,
      trailing: trailing ??
          Icon(
            Icons.chevron_right,
            size: 18,
            color: context.shoTheme.textMuted,
          ),
      onTap: onTap,
    );
  }
}
