import 'package:flutter/material.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/widgets/hos_network_image.dart';
import 'package:shoo/features/theme_activity/domain/entities/hos_theme_activity_config.dart';
import 'package:shoo/features/theme_activity/presentation/modules/hos_theme_countdown_module.dart';
import 'package:shoo/features/theme_activity/presentation/modules/hos_theme_coupon_module.dart';
import 'package:shoo/features/theme_activity/presentation/modules/hos_theme_marquee_module.dart';
import 'package:shoo/features/theme_activity/presentation/modules/hos_theme_product_scroll_module.dart';
import 'package:shoo/features/theme_activity/presentation/modules/hos_theme_uneven_grid_module.dart';
import 'package:shoo/features/theme_activity/presentation/modules/hos_theme_web_module.dart';
import 'package:shoo/features/theme_activity/presentation/navigation/hos_theme_activity_link_handler.dart';
import 'package:shoo/features/theme_activity/presentation/style/hos_module_style.dart';

typedef SHOThemeActivityModuleBuilder = Widget Function(
  BuildContext context,
  SHOThemeActivityModule module,
  Map<String, dynamic> defaultStyle,
);

final Map<String, SHOThemeActivityModuleBuilder> themeActivityModuleBuilders = {
  'bannerRow': _buildBannerRow,
  'bannerStack': _buildBannerStack,
  'grid': _buildGrid,
  'countdown': _buildCountdown,
  'coupon': _buildCoupon,
  'marquee': _buildMarquee,
  'productScroll': _buildProductScroll,
  'unevenGrid': _buildUnevenGrid,
  'web': _buildWeb,
  'menu': _buildMenu,
};

Widget buildThemeActivityModule(
  BuildContext context,
  SHOThemeActivityModule module,
  Map<String, dynamic> defaultStyle,
) {
  final builder = themeActivityModuleBuilders[module.type];
  if (builder == null) return const SizedBox.shrink();
  final style = Map<String, dynamic>.from(module.raw['style'] as Map? ?? {});
  final margin = themeEdgeInsets(module.raw['margin']);
  final padding = themeEdgeInsets(module.raw['padding']);
  final merged = {...defaultStyle, ...style};
  final child = builder(context, module, merged);
  return Padding(
    padding: margin,
    child: DecoratedBox(
      decoration: moduleBoxDecoration(style, fallback: defaultStyle),
      child: Padding(padding: padding, child: child),
    ),
  );
}

Widget _buildCountdown(
  BuildContext context,
  SHOThemeActivityModule module,
  Map<String, dynamic> style,
) {
  return SHOThemeCountdownModule(raw: module.raw, style: style);
}

Widget _buildCoupon(
  BuildContext context,
  SHOThemeActivityModule module,
  Map<String, dynamic> style,
) {
  return SHOThemeCouponModule(raw: module.raw, style: style);
}

Widget _buildMarquee(
  BuildContext context,
  SHOThemeActivityModule module,
  Map<String, dynamic> style,
) {
  return SHOThemeMarqueeModule(raw: module.raw, style: style);
}

Widget _buildProductScroll(
  BuildContext context,
  SHOThemeActivityModule module,
  Map<String, dynamic> style,
) {
  return SHOThemeProductScrollModule(raw: module.raw, style: style);
}

Widget _buildUnevenGrid(
  BuildContext context,
  SHOThemeActivityModule module,
  Map<String, dynamic> style,
) {
  return SHOThemeUnevenGridModule(raw: module.raw, style: style);
}

Widget _buildWeb(
  BuildContext context,
  SHOThemeActivityModule module,
  Map<String, dynamic> style,
) {
  return SHOThemeWebModule(raw: module.raw, style: style);
}

Widget _buildMenu(
  BuildContext context,
  SHOThemeActivityModule module,
  Map<String, dynamic> style,
) {
  final gridModule = SHOThemeActivityModule(
    moduleId: module.moduleId,
    type: 'grid',
    raw: module.raw,
    visible: module.visible,
    sort: module.sort,
  );
  final grid = _buildGrid(context, gridModule, style);
  return SHOThemeMenuModule(raw: module.raw, style: style, child: grid);
}

Widget _buildBannerRow(
  BuildContext context,
  SHOThemeActivityModule module,
  Map<String, dynamic> style,
) {
  final image = module.raw['image'] as String? ?? '';
  if (image.isEmpty) return const SizedBox.shrink();
  final aspectRatio = themeNumber(
    module.raw['aspectRatio'],
    fallback: 2.5,
  );
  final link = module.raw['link'] as String?;
  return _linkedImage(
    context,
    image: image,
    aspectRatio: aspectRatio,
    link: link,
    defaultLink: module.raw['defaultLink'] as String?,
    moduleId: module.moduleId,
  );
}

Widget _buildBannerStack(
  BuildContext context,
  SHOThemeActivityModule module,
  Map<String, dynamic> style,
) {
  final items = module.raw['items'];
  if (items is! List || items.isEmpty) return const SizedBox.shrink();
  final gap = themeNumber(module.raw['gap']);
  final children = <Widget>[];
  for (final raw in items) {
    if (raw is! Map<String, dynamic>) continue;
    final image = raw['image'] as String? ?? '';
    if (image.isEmpty) continue;
    final aspectRatio = themeNumber(raw['aspectRatio'], fallback: 2.5);
    children.add(
      _linkedImage(
        context,
        image: image,
        aspectRatio: aspectRatio,
        link: raw['link'] as String?,
        defaultLink: module.raw['defaultLink'] as String?,
        moduleId: module.moduleId,
        itemId: raw['itemId'] as String?,
      ),
    );
    if (gap > 0 && raw != items.last) {
      children.add(SizedBox(height: gap));
    }
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: children,
  );
}

Widget _buildGrid(
  BuildContext context,
  SHOThemeActivityModule module,
  Map<String, dynamic> style,
) {
  final items = module.raw['items'];
  if (items is! List || items.isEmpty) return const SizedBox.shrink();
  final columns = (module.raw['columns'] as int? ?? 4).clamp(1, 6);
  final itemGap = themeNumber(style['itemGap'], fallback: SHOAppSpacing.sm);
  final titleStyle = moduleTextStyle(style, colorKey: 'titleColor');
  final itemStyle = module.raw['itemStyle'] as String? ?? 'imageTitle';

  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: items.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      mainAxisSpacing: itemGap,
      crossAxisSpacing: itemGap,
      childAspectRatio: themeNumber(
        module.raw['itemAspectRatio'],
        fallback: itemStyle == 'imageOnly' ? 1 : 0.82,
      ),
    ),
    itemBuilder: (context, index) {
      final raw = items[index];
      if (raw is! Map<String, dynamic>) return const SizedBox.shrink();
      final image = raw['image'] as String? ?? '';
      final title = raw['title'] as String? ?? '';
      final link = raw['link'] as String? ?? module.raw['defaultLink'] as String?;
      return InkWell(
        onTap: link == null || link.isEmpty
            ? null
            : () => SHOThemeActivityLinkHandler.open(
                  context,
                  link,
                  moduleId: module.moduleId,
                  itemId: raw['itemId'] as String?,
                ),
        borderRadius: BorderRadius.circular(
          themeNumber(style['borderRadius'], fallback: 8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (image.isNotEmpty)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SHOAppNetworkImage(url: image, fit: BoxFit.cover),
                ),
              ),
            if (title.isNotEmpty && itemStyle != 'imageOnly') ...[
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: titleStyle,
              ),
            ],
          ],
        ),
      );
    },
  );
}

Widget _linkedImage(
  BuildContext context, {
  required String image,
  required double aspectRatio,
  String? link,
  String? defaultLink,
  String? moduleId,
  String? itemId,
}) {
  final target = (link != null && link.isNotEmpty) ? link : defaultLink;
  return AspectRatio(
    aspectRatio: aspectRatio,
    child: InkWell(
      onTap: target == null || target.isEmpty
          ? null
          : () => SHOThemeActivityLinkHandler.open(
                context,
                target,
                moduleId: moduleId,
                itemId: itemId,
              ),
      child: SHOAppNetworkImage(url: image, fit: BoxFit.cover),
    ),
  );
}
