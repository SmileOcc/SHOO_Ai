import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/domain/hos_profile_activity_product.dart';
import '../../profile/presentation/hos_profile_controller.dart';
import '../domain/hos_product_detail.dart';

/// 商品详情加载后写入足迹（含缓存快照）。
class SHOProductFootprintRecorder extends ConsumerStatefulWidget {
  const SHOProductFootprintRecorder({super.key, required this.detail});

  final SHOProductDetail detail;

  @override
  ConsumerState<SHOProductFootprintRecorder> createState() =>
      _SHOProductFootprintRecorderState();
}

class _SHOProductFootprintRecorderState
    extends ConsumerState<SHOProductFootprintRecorder> {
  static final Set<String> _recorded = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _record());
  }

  Future<void> _record() async {
    if (_recorded.contains(widget.detail.id)) return;
    _recorded.add(widget.detail.id);
    await ref.read(profileActivityProvider.notifier).recordFootprint(
          widget.detail.id,
          cache: widget.detail.toActivityCache(),
        );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
