import 'package:flutter/material.dart';

import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/utils/hos_text_highlight.dart';
import 'package:shoo/features/toolbox/domain/entities/hos_contact.dart';

class SHOContactListTile extends StatelessWidget {
  const SHOContactListTile({
    super.key,
    required this.contact,
    this.searchQuery = '',
    this.onTap,
  });

  final SHOContact contact;
  final String searchQuery;
  final VoidCallback? onTap;

  String get _subtitle {
    final company = contact.company.trim();
    final phone = contact.phone.trim();
    if (company.isEmpty) return '($phone)';
    return '$company ($phone)';
  }

  @override
  Widget build(BuildContext context) {
    const nameStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: SHOAppColors.textPrimary,
    );
    const subtitleStyle = TextStyle(
      fontSize: 12,
      color: SHOAppColors.textMuted,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: SHOContactListTile.itemHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.xl),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: SHOAppColors.surfaceMuted,
                  child: Text(
                    contact.displayInitial,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: SHOAppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: SHOAppSpacing.md),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SHOTextHighlight.rich(
                        text: contact.name,
                        query: searchQuery,
                        style: nameStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      SHOTextHighlight.rich(
                        text: _subtitle,
                        query: searchQuery,
                        style: subtitleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const itemHeight = 72.0;
}

class SHOContactSectionHeader extends StatelessWidget {
  const SHOContactSectionHeader({super.key, required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SHOContactSectionHeader.headerHeight,
      width: double.infinity,
      color: SHOAppColors.surfaceMuted.withValues(alpha: 0.55),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.xl),
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: SHOAppColors.textSecondary,
        ),
      ),
    );
  }

  static const headerHeight = 32.0;
}
