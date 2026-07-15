import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';

// SHOSkuChipRow（主组件）
// ├── _SHOSkuChipRowState（状态管理）
// ├── _computeCollapsedLayout（核心布局算法）
// │   └── _CollapsedLayout（布局结果模型）
// ├── _SkuChipLine（标签行）
// │   ├── _SkuChip（单个标签）
// │   └── _ArrowButton（展开/收起按钮）

// ###  核心布局算法 _computeCollapsedLayout
// 这是组件的 核心逻辑 ，负责计算标签如何排列才能在指定行数内最优展示。
// ┌─────────────────────────────────────────────────────────────┐
// │  输入：attributes, maxWidth, maxLines, maxChipWidth          │
// └─────────────────────────────────────────────────────────────┘
//                               │
//                               ▼
// ┌─────────────────────────────────────────────────────────────┐
// │  步骤1：逐行填充标签                                          │
// │  - 当前行剩余空间能容纳下一个标签 → 添加到当前行                 │
// │  - 当前行放不下，但当前行为空 → 强制放入（保证单个标签一定显示）   │
// │  - 当前行放不下且非空 → 换行                                   │
// └─────────────────────────────────────────────────────────────┘
//                               │
//                               ▼
// ┌─────────────────────────────────────────────────────────────┐
// │  步骤2：最后一行预留展开箭头空间                                │
// │  - 如果有隐藏标签，计算最后一行需要腾出多少空间给箭头             │
// │  - 从后往前移除标签，直到箭头能放下                            │
// └─────────────────────────────────────────────────────────────┘
//                               │
//                               ▼
// ┌─────────────────────────────────────────────────────────────┐
// │  输出：_CollapsedLayout(lines, showExpandArrow)              │
// └─────────────────────────────────────────────────────────────┘

/// SKU 属性标签行：可配置默认展示行数、单标签最大宽度；不配置行数时展示全部。
class SHOSkuChipRow extends StatefulWidget {
  const SHOSkuChipRow({
    super.key,
    required this.attributes,
    this.initialMaxLines,
    this.maxChipWidth = 150,
  });

  final List<String> attributes;

  /// 收起态最多展示行数；`null` 表示始终展示全部且不显示展开/收起。
  final int? initialMaxLines;

  /// 单个 SKU 标签最大宽度。
  final double maxChipWidth;

  @override
  State<SHOSkuChipRow> createState() => _SHOSkuChipRowState();
}

class _SHOSkuChipRowState extends State<SHOSkuChipRow> {
  bool _expanded = false;

  static const _chipTextStyle = TextStyle(
    fontSize: 10,
    color: SHOAppColors.textSecondary,
  );

  static const _chipHorizontalPadding = 16.0;
  static const _chipBorderWidth = 2.0;
  static const _chipSpacing = SHOAppSpacing.xs;
  static const _arrowSize = 16.0;
  static const _layoutSlop = 6.0;

  @override
  Widget build(BuildContext context) {
    if (widget.attributes.isEmpty) return const SizedBox.shrink();

    final maxLines = widget.initialMaxLines;
    if (maxLines == null) {
      return _SkuChipLine(
        labels: widget.attributes,
        maxChipWidth: widget.maxChipWidth,
      );
    }

    if (_expanded) {
      return Wrap(
        spacing: _chipSpacing,
        runSpacing: _chipSpacing,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final attr in widget.attributes)
            _SkuChip(label: attr, maxWidth: widget.maxChipWidth),
          _ArrowButton(
            icon: Icons.keyboard_arrow_up,
            onTap: () => setState(() => _expanded = false),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final layout = _computeCollapsedLayout(
          attributes: widget.attributes,
          maxWidth: maxWidth,
          maxLines: maxLines,
          maxChipWidth: widget.maxChipWidth,
          measureChipWidth: (label) => _measureChipWidth(context, label),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < layout.lines.length; i++) ...[
              if (i > 0) const SizedBox(height: _chipSpacing),
              _SkuChipLine(
                labels: layout.lines[i],
                maxChipWidth: widget.maxChipWidth,
                maxWidth: maxWidth,
                trailing: layout.showExpandArrow && i == layout.lines.length - 1
                    ? _ArrowButton(
                        icon: Icons.keyboard_arrow_down,
                        onTap: () => setState(() => _expanded = true),
                      )
                    : null,
              ),
            ],
          ],
        );
      },
    );
  }

  // 标签宽度测量 方法通过 TextPainter 精确计算文本宽度
  double _measureChipWidth(BuildContext context, String label) {
    final textMax =
        widget.maxChipWidth - _chipHorizontalPadding - _chipBorderWidth;
    final painter = TextPainter(
      text: TextSpan(text: label, style: _chipTextStyle),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout(maxWidth: math.max(0, textMax));
    final raw = painter.width + _chipHorizontalPadding + _chipBorderWidth;
    return raw.ceilToDouble().clamp(0.0, widget.maxChipWidth);
  }
}

class _CollapsedLayout {
  const _CollapsedLayout({required this.lines, required this.showExpandArrow});

  final List<List<String>> lines;
  final bool showExpandArrow;
}

// 贪心布局算法 ，核心目标是：在给定的宽度和行数限制下，最优地排列标签，并正确预留展开箭头的空间
_CollapsedLayout _computeCollapsedLayout({
  required List<String> attributes,
  required double maxWidth,// 容器最大宽度
  required int maxLines,// 最大展示行数
  required double maxChipWidth,// 单个 SKU 标签最大宽度。
  required double Function(String label) measureChipWidth,// 标签宽度测量函数
}) {
  const spacing = _SHOSkuChipRowState._chipSpacing;// 标签间距
  const arrowBlock = _SHOSkuChipRowState._arrowSize + spacing;// 16+4=20px（箭头+间距）
  const slop = _SHOSkuChipRowState._layoutSlop;// 6px（布局容差，避免边缘溢出）
  final budget = math.max(0.0, maxWidth - slop);// 实际可用宽度 = 最大宽度 - 容差

  // 获取标签宽度 通过 clamp 限制在 [0, maxChipWidth] 范围内
  double chipWidthFor(String label) =>
      measureChipWidth(label).clamp(0.0, maxChipWidth);

  // 计算整行宽度
  double lineWidth(List<String> line) {
    if (line.isEmpty) return 0;
    var used = 0.0;
    for (var i = 0; i < line.length; i++) {
      final gap = i == 0 ? 0.0 : spacing;
      used += gap + chipWidthFor(line[i]);
    }
    return used;
  }
  // 判断标签是否能放入当前行
  // 判断公式 ： 当前行宽度 + 间距 + 新标签宽度 + 预留空间 ≤ 预算宽度
  bool fitsOnLine({
    required List<String> line,
    required String label,
    required double reserveTrailing,// 预留空间（箭头或0）
  }) {
    final gap = line.isEmpty ? 0.0 : spacing;
    return lineWidth(line) + gap + chipWidthFor(label) + reserveTrailing <=
        budget;
  }

  final lines = <List<String>>[];
  var attrIndex = 0;

  // 外层循环：逐行处理
  while (attrIndex < attributes.length && lines.length < maxLines) {
    final line = <String>[];
    final isLastAllowedLine = lines.length == maxLines - 1;
    // 内层循环：填充当前行
    while (attrIndex < attributes.length) {
      final label = attributes[attrIndex];
      final hasMoreAfter = attrIndex < attributes.length - 1;
      final reserveArrow = isLastAllowedLine && hasMoreAfter ? arrowBlock : 0.0;

      if (fitsOnLine(line: line, label: label, reserveTrailing: reserveArrow)) {
        line.add(label);
        attrIndex++;
        continue;
      }
      // 当前行已满，无法添加更多标签,就换行
      if (line.isNotEmpty) break;
      // 当前行为空，强制放入（保底逻辑）
      line.add(label);
      attrIndex++;
      break;
    }

    lines.add(line);
  }

  final hasHidden = attrIndex < attributes.length;

  if (hasHidden && lines.isNotEmpty) {
    final last = lines.last;
    while (last.isNotEmpty) {
      final widthWithArrow = lineWidth(last) + arrowBlock;
      if (widthWithArrow <= budget) break;
      last.removeLast();
    }
  }

  if (lines.isEmpty) {
    lines.add([]);
  }

  final visibleCount = lines.fold<int>(0, (sum, line) => sum + line.length);

  return _CollapsedLayout(
    lines: lines,
    showExpandArrow: visibleCount < attributes.length,
  );
}

class _SkuChipLine extends StatelessWidget {
  const _SkuChipLine({
    required this.labels,
    required this.maxChipWidth,
    this.maxWidth,
    this.trailing,
  });

  final List<String> labels;
  final double maxChipWidth;
  final double? maxWidth;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty && trailing == null) {
      return const SizedBox.shrink();
    }

    final children = <Widget>[
      for (final label in labels)
        _SkuChip(label: label, maxWidth: maxChipWidth),
      if (trailing != null) trailing!,
    ];

    final line = Wrap(
      spacing: _SHOSkuChipRowState._chipSpacing,
      runSpacing: _SHOSkuChipRowState._chipSpacing,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );

    if (maxWidth == null) return line;

    return SizedBox(width: maxWidth, child: line);
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Icon(
        icon,
        size: _SHOSkuChipRowState._arrowSize,
        color: SHOAppColors.textMuted,
      ),
    );
  }
}

class _SkuChip extends StatelessWidget {
  const _SkuChip({required this.label, required this.maxWidth});

  final String label;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: SHOAppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: SHOAppColors.border),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _SHOSkuChipRowState._chipTextStyle,
        ),
      ),
    );
  }
}
