import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/core/pages/hos_data_page.dart';

/// 选择器页模板：`?select=1` + `context.pop(result)`。
///
/// 适用于选地址、选优惠券等列表选择场景；数据层仍走 [SHODataPage]。
abstract class SHOSelectorPage<T> extends SHODataPage<List<T>> {
  const SHOSelectorPage({super.key, required this.selectMode});

  final bool selectMode;
}

abstract class SHOSelectorPageState<T, W extends SHOSelectorPage<T>>
    extends SHODataPageState<List<T>, W> {
  bool get isSelectMode => widget.selectMode;

  @override
  Map<String, Object?> get pageAnalyticsExtra => {
    if (widget.selectMode) 'select_mode': true,
  };

  /// 选中后 pop 回传结果。
  @protected
  void popSelectResult<R>(R result) {
    if (mounted) context.pop<R>(result);
  }

  /// 选择器模式下的 AppBar 标题。
  @protected
  String selectorTitle({
    required String selectTitle,
    required String listTitle,
  }) {
    return widget.selectMode ? selectTitle : listTitle;
  }
}
