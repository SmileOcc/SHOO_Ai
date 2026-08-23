import 'package:flutter/material.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/widgets/hos_network_image.dart';
import 'package:shoo/core/widgets/hos_price_text.dart';
import 'package:shoo/features/theme_activity/presentation/navigation/hos_theme_activity_link_handler.dart';
import 'package:shoo/features/theme_activity/presentation/style/hos_module_style.dart';
import 'package:shoo/features/theme_activity/presentation/widgets/hos_theme_horizontal_strip.dart';

class SHOThemeProductScrollModule extends StatelessWidget {
  const SHOThemeProductScrollModule({
    super.key,
    required this.raw,
    required this.style,
  });

  final Map<String, dynamic> raw;
  final Map<String, dynamic> style;

  List<Map<String, dynamic>> get _items {
    final direct = raw['items'];
    if (direct is List) {
      return direct.whereType<Map<String, dynamic>>().toList();
    }
    final ds = raw['dataSource'];
    if (ds is Map<String, dynamic>) {
      final items = ds['items'];
      if (items is List) {
        return items.whereType<Map<String, dynamic>>().toList();
      }
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    if (items.isEmpty) return const SizedBox.shrink();

    final cardWidth = themeNumber(raw['cardWidth'], fallback: 120);
    final imageRatio = themeNumber(raw['imageAspectRatio'], fallback: 1);
    final showOrigin = raw['showOriginPrice'] as bool? ?? true;

    final stripHeight = cardWidth / imageRatio + 72;

    return SHOThemeHorizontalStrip(
      height: stripHeight,
      padding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.md),
      children: [
        for (var index = 0; index < items.length; index++) ...[
          if (index > 0) const SizedBox(width: 8),
          SizedBox(
            width: cardWidth,
            child: Builder(
              builder: (context) {
                final item = items[index];
                final productId =
                    item['productId'] as String? ?? item['id'] as String? ?? '';
                final link = item['link'] as String? ??
                    (productId.isNotEmpty
                        ? 'https://shoo.app/product/$productId'
                        : '');
                final image = item['image'] as String? ??
                    item['imageUrl'] as String? ??
                    '';
                final title = item['title'] as String? ?? '';
                final price = (item['price'] as num?)?.toInt() ?? 0;
                final origin = (item['originPrice'] as num?)?.toInt() ??
                    (item['originalPrice'] as num?)?.toInt() ??
                    0;

                return InkWell(
                  onTap: link.isEmpty
                      ? null
                      : () => SHOThemeActivityLinkHandler.open(
                            context,
                            link,
                            moduleId: raw['moduleId'] as String?,
                            itemId: item['itemId'] as String? ?? productId,
                          ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: imageRatio,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SHOAppNetworkImage(
                            url: image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      SHOAppPriceText(
                        priceCents: price,
                        originalCents: showOrigin ? origin : null,
                        showOriginal: showOrigin,
                        size: SHOAppPriceSize.small,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
