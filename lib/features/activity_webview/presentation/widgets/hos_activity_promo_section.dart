import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/core/platform/webview/hos_url_navigator.dart';
import 'package:shoo/features/activity_webview/domain/entities/hos_activity_promo.dart';
import 'package:shoo/features/activity_webview/presentation/state/hos_image_preview_provider.dart';

void shoOpenActivityPromoLink(
  BuildContext context,
  WidgetRef ref,
  String url,
) {
  if (url.startsWith('/')) {
    context.push(url);
    return;
  }
  unawaited(SHOURLNavigator.open(context, ref, url));
}

List<SHOImagePreviewItem> shoCollectPromoImages(
  List<SHOActivityPromoBlock> blocks,
) {
  return blocks
      .where((b) => b.type == 'image' && (b.url?.isNotEmpty ?? false))
      .map((b) => SHOImagePreviewItem(url: b.url!, title: b.caption ?? ''))
      .toList();
}

Future<void> shoOpenPromoImagePreview(
  BuildContext context,
  WidgetRef ref, {
  required List<SHOActivityPromoBlock> blocks,
  required String imageUrl,
}) async {
  final images = shoCollectPromoImages(blocks);
  final index = images.indexWhere((item) => item.url == imageUrl);
  await SHOURLNavigator.openImagePreview(
    context,
    ref,
    images: images,
    index: index >= 0 ? index : 0,
  );
}

class SHOActivityPromoSection extends ConsumerWidget {
  const SHOActivityPromoSection({
    super.key,
    required this.blocks,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 12),
  });

  final List<SHOActivityPromoBlock> blocks;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (blocks.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '活动宣传',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...blocks.map((block) => _PromoBlockTile(block: block, blocks: blocks)),
        ],
      ),
    );
  }
}

class _PromoBlockTile extends ConsumerWidget {
  const _PromoBlockTile({
    required this.block,
    required this.blocks,
  });

  final SHOActivityPromoBlock block;
  final List<SHOActivityPromoBlock> blocks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (block.type == 'image') {
      return _PromoImageTile(block: block, blocks: blocks);
    }
    return _PromoParagraph(block: block);
  }
}

class _PromoParagraph extends ConsumerWidget {
  const _PromoParagraph({required this.block});

  final SHOActivityPromoBlock block;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final linkStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.primary,
      decoration: TextDecoration.underline,
      decorationColor: theme.colorScheme.primary,
    );
    final spans = <InlineSpan>[];

    for (final segment in block.segments) {
      if (segment.type == 'link') {
        final url = segment.url ?? '';
        final label = segment.text ?? url;
        if (url.isEmpty) continue;
        spans.add(
          TextSpan(
            text: label,
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () => shoOpenActivityPromoLink(context, ref, url),
          ),
        );
      } else {
        spans.add(TextSpan(text: segment.content ?? ''));
      }
    }

    if (spans.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text.rich(
        TextSpan(
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          children: spans,
        ),
      ),
    );
  }
}

class _PromoImageTile extends ConsumerWidget {
  const _PromoImageTile({
    required this.block,
    required this.blocks,
  });

  final SHOActivityPromoBlock block;
  final List<SHOActivityPromoBlock> blocks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = block.url;
    if (url == null || url.isEmpty) return const SizedBox.shrink();

    final aspect = (block.width != null && block.height != null && block.height! > 0)
        ? block.width! / block.height!
        : 16 / 9;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: aspect,
              child: InkWell(
                onTap: () => shoOpenPromoImagePreview(
                  context,
                  ref,
                  blocks: blocks,
                  imageUrl: url,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(url, fit: BoxFit.cover),
                    const Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.zoom_in,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (block.caption != null && block.caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                block.caption!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
