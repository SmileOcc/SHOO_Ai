import 'package:flutter/material.dart';

import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';

class SHOSkuChipRow extends StatefulWidget {
  const SHOSkuChipRow({
    super.key,
    required this.attributes,
  });

  final List<String> attributes;

  @override
  State<SHOSkuChipRow> createState() => _SHOSkuChipRowState();
}

class _SHOSkuChipRowState extends State<SHOSkuChipRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.attributes.isEmpty) return const SizedBox.shrink();

    if (_expanded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: SHOAppSpacing.xs,
            runSpacing: SHOAppSpacing.xs,
            children: [
              for (final attr in widget.attributes) _SkuChip(label: attr),
            ],
          ),
          GestureDetector(
            onTap: () => setState(() => _expanded = false),
            child: const Padding(
              padding: EdgeInsets.only(top: SHOAppSpacing.xs),
              child: Icon(Icons.keyboard_arrow_up, size: 16, color: SHOAppColors.textMuted),
            ),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return _CollapsedSkuRow(
          maxWidth: constraints.maxWidth,
          attributes: widget.attributes,
          onExpand: () => setState(() => _expanded = true),
        );
      },
    );
  }
}

class _CollapsedSkuRow extends StatelessWidget {
  const _CollapsedSkuRow({
    required this.maxWidth,
    required this.attributes,
    required this.onExpand,
  });

  final double maxWidth;
  final List<String> attributes;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    const spacing = SHOAppSpacing.xs;
    const arrowWidth = 18.0;
    var used = 0.0;
    final visible = <String>[];
    var hasHidden = false;

    for (var i = 0; i < attributes.length; i++) {
      final chipWidth = _estimateChipWidth(attributes[i]);
      final next = used == 0 ? chipWidth : used + spacing + chipWidth;
      final reserve = i < attributes.length - 1 ? arrowWidth + spacing : 0;
      if (next + reserve > maxWidth && visible.isNotEmpty) {
        hasHidden = true;
        break;
      }
      if (next > maxWidth && visible.isEmpty) {
        visible.add('${attributes[i]}…');
        hasHidden = i < attributes.length - 1;
        break;
      }
      visible.add(attributes[i]);
      used = next;
    }

    if (visible.isEmpty && attributes.isNotEmpty) {
      visible.add('${attributes.first}…');
      hasHidden = attributes.length > 1;
    }

    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: spacing,
            runSpacing: 0,
            children: [for (final label in visible) _SkuChip(label: label)],
          ),
        ),
        if (hasHidden)
          GestureDetector(
            onTap: onExpand,
            child: const Icon(Icons.keyboard_arrow_down, size: 16, color: SHOAppColors.textMuted),
          ),
      ],
    );
  }

  double _estimateChipWidth(String label) {
    return label.length * 8.0 + 16;
  }
}

class _SkuChip extends StatelessWidget {
  const _SkuChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        style: const TextStyle(fontSize: 10, color: SHOAppColors.textSecondary),
      ),
    );
  }
}
