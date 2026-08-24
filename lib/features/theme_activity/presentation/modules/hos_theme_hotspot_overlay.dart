import 'package:flutter/material.dart';
import 'package:shoo/features/theme_activity/presentation/navigation/hos_theme_activity_link_handler.dart';

List<Map<String, dynamic>> parseThemeHotspots(dynamic raw) {
  if (raw is! List) return const [];
  return raw.whereType<Map<String, dynamic>>().toList();
}

double _hotspotPercent(dynamic value) {
  if (value is num) return (value / 100).clamp(0.0, 1.0);
  final text = value?.toString().trim() ?? '';
  if (text.endsWith('%')) {
    final parsed = double.tryParse(text.replaceAll('%', ''));
    if (parsed != null) return (parsed / 100).clamp(0.0, 1.0);
  }
  return (double.tryParse(text) ?? 0).clamp(0.0, 1.0);
}

/// 图片 + 热区叠加；整图 link 与热区 link 可并存。
Widget buildThemeHotspotImage({
  required BuildContext context,
  required Widget image,
  List<Map<String, dynamic>> hotspots = const [],
  String? link,
  String? defaultLink,
  String? moduleId,
  String? itemId,
}) {
  final layers = <Widget>[image];

  final wholeImageLink = (link != null && link.isNotEmpty) ? link : defaultLink;
  if (wholeImageLink != null && wholeImageLink.isNotEmpty) {
    layers.add(
      Positioned.fill(
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => SHOThemeActivityLinkHandler.open(
              context,
              wholeImageLink,
              moduleId: moduleId,
              itemId: itemId,
            ),
          ),
        ),
      ),
    );
  }

  if (hotspots.isNotEmpty) {
    layers.add(
      LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              for (final hotspot in hotspots)
                Positioned(
                  left: _hotspotPercent(hotspot['x']) * constraints.maxWidth,
                  top: _hotspotPercent(hotspot['y']) * constraints.maxHeight,
                  width: _hotspotPercent(hotspot['w']) * constraints.maxWidth,
                  height: _hotspotPercent(hotspot['h']) * constraints.maxHeight,
                  child: _HotspotTapTarget(
                    link: hotspot['link'] as String?,
                    moduleId: moduleId,
                    itemId: itemId ?? hotspot['itemId'] as String?,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  if (layers.length == 1) return image;
  return Stack(fit: StackFit.passthrough, children: layers);
}

class _HotspotTapTarget extends StatelessWidget {
  const _HotspotTapTarget({
    required this.link,
    this.moduleId,
    this.itemId,
  });

  final String? link;
  final String? moduleId;
  final String? itemId;

  @override
  Widget build(BuildContext context) {
    final target = link?.trim() ?? '';
    if (target.isEmpty) return const SizedBox.shrink();

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => SHOThemeActivityLinkHandler.open(
          context,
          target,
          moduleId: moduleId,
          itemId: itemId,
        ),
      ),
    );
  }
}
