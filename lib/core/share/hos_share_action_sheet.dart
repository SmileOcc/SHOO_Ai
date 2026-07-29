import 'package:flutter/material.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/theme/hos_theme_extension.dart';

/// 分享入口类型。
///
/// - [thirdParty]: 三方应用（如微信、微博等）
/// - [custom]: 自定义事件（如复制链接、举报等）
enum SHOShareActionKind {
  /// 三方应用分享入口
  thirdParty,

  /// 自定义操作入口
  custom,
}

/// 单个分享入口配置项。
///
/// 包含图标、文案和点击回调，支持两种类型：
/// - 三方应用分享（微信、微博等）
/// - 自定义操作（复制链接、举报等）
class SHOShareActionItem {
  const SHOShareActionItem({
    required this.id,
    required this.label,
    required this.onTap,
    this.kind = SHOShareActionKind.custom,
    this.icon,
    this.iconWidget,
    this.backgroundColor,
  });

  /// 分享入口唯一标识，用于追踪和区分
  final String id;

  /// 分享入口文案，显示在图标下方
  final String label;

  /// 点击回调，触发分享或自定义操作
  final VoidCallback onTap;

  /// 分享入口类型，决定背景色和样式
  final SHOShareActionKind kind;

  /// 图标数据（IconData），与 [iconWidget] 二选一
  final IconData? icon;

  /// 自定义图标 Widget，优先级高于 [icon]
  final Widget? iconWidget;

  /// 图标背景色，默认使用主题色
  final Color? backgroundColor;
}

/// 分享操作面板，采用底部弹出的两行横向布局。
///
/// 布局结构：
/// - **标题区域**：居中显示分享标题
/// - **第一行**：可配置的三方应用分享入口（如微信、微博）+ 自定义事件
/// - **第二行**：自定义操作入口（如复制链接、举报等）
/// - **取消按钮**：底部独立一行，点击关闭面板
///
/// 每行从左往右排列，默认一屏展示 **5.5** 个入口（露出半个暗示可滑动），
/// 超出部分支持左右滑动浏览。
class SHOShareActionSheet extends StatelessWidget {
  const SHOShareActionSheet({
    super.key,
    required this.title,
    required this.channelRow,
    required this.actionRow,
    this.cancelLabel,
    this.onCancel,
    this.visibleSlots = 5.5,
  });

  /// 分享面板标题，居中显示在顶部
  final String title;

  /// 第一行分享入口列表，支持三方应用和自定义事件混合
  final List<SHOShareActionItem> channelRow;

  /// 第二行操作入口列表，通常为自定义事件
  final List<SHOShareActionItem> actionRow;

  /// 取消按钮文案，默认使用系统本地化文案
  final String? cancelLabel;

  /// 取消按钮点击回调，默认关闭弹窗
  final VoidCallback? onCancel;

  /// 一屏可见的入口数量（默认 5.5，露出半个暗示可滑动）
  final double visibleSlots;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Material(
      color: context.shoSurface,//用 context.shoSurface 获取主题定义的表面色，保持视觉一致性
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(SHOAppSpacing.xl),
      ),
      clipBehavior: Clip.antiAlias,// 裁剪：抗锯齿圆角
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          0,
          SHOAppSpacing.lg,
          0,
          bottom + SHOAppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.xl),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: SHOAppSpacing.xl),
            if (channelRow.isNotEmpty) ...[
              _SHOShareActionRow(items: channelRow, visibleSlots: visibleSlots),
              const SizedBox(height: SHOAppSpacing.lg),
            ],
            if (actionRow.isNotEmpty) ...[
              _SHOShareActionRow(items: actionRow, visibleSlots: visibleSlots),
              const SizedBox(height: SHOAppSpacing.lg),
            ],
            Divider(height: 1, color: context.shoTheme.border),
            InkWell(
              onTap: onCancel ?? () => Navigator.maybePop(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: SHOAppSpacing.lg),
                child: Text(
                  cancelLabel ??
                      MaterialLocalizations.of(context).cancelButtonLabel,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 单行分享入口列表，横向滚动布局。
///
/// 根据屏幕宽度和可见槽位数动态计算每个入口的尺寸：
/// - 入口宽度 = (屏幕宽度 - 左侧padding) / visibleSlots
/// - 图标尺寸 = 入口宽度 × 0.52，限制在 40px ~ 56px 之间
/// - 行高 = 图标尺寸 + 间距 + 文案高度
class _SHOShareActionRow extends StatelessWidget {
  const _SHOShareActionRow({required this.items, required this.visibleSlots});

  /// 分享入口列表
  final List<SHOShareActionItem> items;

  /// 一屏可见的入口数量，用于计算每个入口的宽度
  final double visibleSlots;

  @override
  Widget build(BuildContext context) {
    const hPad = SHOAppSpacing.md;
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - hPad) / visibleSlots;
        final iconSize = (itemWidth * 0.52).clamp(40.0, 56.0);
        final rowHeight = iconSize + 8 + 32;

        return SizedBox(
          height: rowHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: hPad),
            itemCount: items.length,
            itemExtent: itemWidth,
            itemBuilder: (context, index) {
              return _SHOShareActionCell(
                item: items[index],
                iconSize: iconSize,
              );
            },
          ),
        );
      },
    );
  }
}

/// 单个分享入口单元格，包含圆形图标和下方文案。
///
/// 布局结构：
/// - 顶部：圆形图标（支持自定义背景色和图标）
/// - 底部：单行文案（超出省略）
///
/// 支持点击交互，点击时触发 [SHOShareActionItem.onTap] 回调。
class _SHOShareActionCell extends StatelessWidget {
  const _SHOShareActionCell({required this.item, required this.iconSize});

  /// 分享入口配置项
  final SHOShareActionItem item;

  /// 图标尺寸，由父组件根据屏幕宽度动态计算
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final bg =
        item.backgroundColor ??
        (item.kind == SHOShareActionKind.thirdParty
            ? SHOAppColors.surfaceMuted
            : SHOAppColors.surfaceMuted);

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(SHOAppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              clipBehavior: Clip.antiAlias,
              child:
                  item.iconWidget ??
                  Icon(
                    item.icon ?? Icons.share_rounded,
                    size: iconSize * 0.44,
                    color: SHOAppColors.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 11,
                color: SHOAppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
