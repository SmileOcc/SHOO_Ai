import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/product/domain/hos_product_detail.dart';
import 'hos_share_panel.dart';
import 'hos_share_service.dart';

/// 商品详情分享按钮（含离屏卡片渲染）。
class SHOProductShareButton extends ConsumerStatefulWidget {
  const SHOProductShareButton({super.key, required this.product});

  final SHOProductDetail product;

  @override
  ConsumerState<SHOProductShareButton> createState() =>
      _SHOProductShareButtonState();
}

class _SHOProductShareButtonState extends ConsumerState<SHOProductShareButton> {
  final _cardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final share = ref.read(shareServiceProvider);
    final link = share.productLink(widget.product.id);

    return Stack(
      clipBehavior: Clip.hardEdge,
      alignment: Alignment.center,
      children: [
        Offstage(
          offstage: true,
          child: SHOShareService.offscreenShareCard(
            cardKey: _cardKey,
            product: widget.product,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.ios_share_rounded),
          onPressed: () => SHOSharePanel.show(
            context,
            ref,
            title: widget.product.title,
            link: link,
            product: widget.product,
            cardKey: _cardKey,
          ),
        ),
      ],
    );
  }
}
