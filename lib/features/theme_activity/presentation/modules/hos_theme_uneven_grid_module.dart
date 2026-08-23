import 'package:flutter/material.dart';
import 'package:shoo/core/widgets/hos_network_image.dart';
import 'package:shoo/features/theme_activity/presentation/navigation/hos_theme_activity_link_handler.dart';
import 'package:shoo/features/theme_activity/presentation/style/hos_module_style.dart';

class SHOThemeUnevenGridModule extends StatelessWidget {
  const SHOThemeUnevenGridModule({
    super.key,
    required this.raw,
    required this.style,
  });

  final Map<String, dynamic> raw;
  final Map<String, dynamic> style;

  List<Map<String, dynamic>> get _slots {
    final slots = raw['slots'];
    if (slots is! List) return const [];
    return slots.whereType<Map<String, dynamic>>().toList();
  }

  @override
  Widget build(BuildContext context) {
    final slots = _slots;
    if (slots.isEmpty) return const SizedBox.shrink();

    final preset = raw['layoutPreset'] as String? ?? 'leftBig_rightTwo';
    final gap = themeNumber(raw['gap'], fallback: 8);
    final aspectRatio = themeNumber(raw['aspectRatio'], fallback: 1.6);

    if (preset == 'leftBig_rightTwo' && slots.length >= 3) {
      return AspectRatio(
        aspectRatio: aspectRatio,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: _slot(context, slots[0]),
            ),
            SizedBox(width: gap),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Expanded(child: _slot(context, slots[1])),
                  SizedBox(height: gap),
                  Expanded(child: _slot(context, slots[2])),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (preset == 'leftBig_rightThree' && slots.length >= 4) {
      return AspectRatio(
        aspectRatio: aspectRatio,
        child: Row(
          children: [
            Expanded(flex: 1, child: _slot(context, slots[0])),
            SizedBox(width: gap),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Expanded(child: _slot(context, slots[1])),
                  SizedBox(height: gap),
                  Expanded(child: _slot(context, slots[2])),
                  SizedBox(height: gap),
                  Expanded(child: _slot(context, slots[3])),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Row(
        children: [
          for (var i = 0; i < slots.length; i++) ...[
            if (i > 0) SizedBox(width: gap),
            Expanded(child: _slot(context, slots[i])),
          ],
        ],
      ),
    );
  }

  Widget _slot(BuildContext context, Map<String, dynamic> slot) {
    final image = slot['image'] as String? ?? '';
    final link = slot['link'] as String? ?? raw['defaultLink'] as String?;
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        themeNumber(style['borderRadius'], fallback: 8),
      ),
      child: InkWell(
        onTap: link == null || link.isEmpty
            ? null
            : () => SHOThemeActivityLinkHandler.open(
                  context,
                  link,
                  moduleId: raw['moduleId'] as String?,
                  itemId: slot['itemId'] as String?,
                ),
        child: image.isEmpty
            ? const ColoredBox(color: Color(0xFFEEEEEE))
            : SHOAppNetworkImage(url: image, fit: BoxFit.cover),
      ),
    );
  }
}
