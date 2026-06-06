import 'package:flutter/material.dart';

import '../theme/hos_colors.dart';
import '../theme/hos_typography.dart';

/// 带下划线指示器的 Tab 导航封装。
///
/// 参考文章扩展建议：统一 Tab 样式，避免各页面重复写 TabBar + TabBarView。
///
/// ```dart
/// SHOAppTabBar(
///   tabs: const ['All', 'Pending', 'Shipped'],
///   children: [
///     OrderList(type: 'all'),
///     OrderList(type: 'pending'),
///     OrderList(type: 'shipped'),
///   ],
/// )
/// ```
class SHOAppTabBar extends StatefulWidget {
  const SHOAppTabBar({
    super.key,
    required this.tabs,
    required this.children,
    this.initialIndex = 0,
    this.onTabChanged,
    this.isScrollable = true,
  }) : assert(tabs.length == children.length);

  final List<String> tabs;
  final List<Widget> children;
  final int initialIndex;
  final ValueChanged<int>? onTabChanged;
  final bool isScrollable;

  @override
  State<SHOAppTabBar> createState() => _SHOAppTabBarState();
}

class _SHOAppTabBarState extends State<SHOAppTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _controller.addListener(() {
      if (!_controller.indexIsChanging) {
        widget.onTabChanged?.call(_controller.index);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: SHOAppColors.surface,
          child: TabBar(
            controller: _controller,
            isScrollable: widget.isScrollable,
            labelColor: SHOAppColors.textPrimary,
            unselectedLabelColor: SHOAppColors.textMuted,
            labelStyle: SHOAppTypography.textTheme.labelLarge,
            unselectedLabelStyle: SHOAppTypography.textTheme.bodyMedium,
            indicatorColor: SHOAppColors.accent,
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: SHOAppColors.divider,
            tabs: widget.tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _controller,
            children: widget.children,
          ),
        ),
      ],
    );
  }
}
