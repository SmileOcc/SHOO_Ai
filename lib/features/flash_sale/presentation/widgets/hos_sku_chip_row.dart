import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';

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

_CollapsedLayout _computeCollapsedLayout({
  required List<String> attributes,
  required double maxWidth,
  required int maxLines,
  required double maxChipWidth,
  required double Function(String label) measureChipWidth,
}) {
  const spacing = _SHOSkuChipRowState._chipSpacing;
  const arrowBlock = _SHOSkuChipRowState._arrowSize + spacing;
  const slop = _SHOSkuChipRowState._layoutSlop;
  final budget = math.max(0.0, maxWidth - slop);

  double chipWidthFor(String label) =>
      measureChipWidth(label).clamp(0.0, maxChipWidth);

  double lineWidth(List<String> line) {
    if (line.isEmpty) return 0;
    var used = 0.0;
    for (var i = 0; i < line.length; i++) {
      final gap = i == 0 ? 0.0 : spacing;
      used += gap + chipWidthFor(line[i]);
    }
    return used;
  }

  bool fitsOnLine({
    required List<String> line,
    required String label,
    required double reserveTrailing,
  }) {
    final gap = line.isEmpty ? 0.0 : spacing;
    return lineWidth(line) + gap + chipWidthFor(label) + reserveTrailing <=
        budget;
  }

  final lines = <List<String>>[];
  var attrIndex = 0;

  while (attrIndex < attributes.length && lines.length < maxLines) {
    final line = <String>[];
    final isLastAllowedLine = lines.length == maxLines - 1;

    while (attrIndex < attributes.length) {
      final label = attributes[attrIndex];
      final hasMoreAfter = attrIndex < attributes.length - 1;
      final reserveArrow = isLastAllowedLine && hasMoreAfter ? arrowBlock : 0.0;

      if (fitsOnLine(line: line, label: label, reserveTrailing: reserveArrow)) {
        line.add(label);
        attrIndex++;
        continue;
      }

      if (line.isNotEmpty) break;

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
