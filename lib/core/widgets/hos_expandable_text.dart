import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/hos_colors.dart';

/// 可配置样式的文本组件，支持最大行数、省略号，以及「更多 / 收起」展开交互。
///
/// ```dart
/// SHOAppExpandableText(
///   text: longContent,
///   maxLines: 3,
///   padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
///   enableExpand: true,
/// )
/// ```
class SHOAppExpandableText extends StatefulWidget {
  const SHOAppExpandableText({
    super.key,
    required this.text,
    this.style,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.padding = EdgeInsets.zero,
    this.maxLines = 3,
    this.showEllipsis = true,
    this.enableExpand = true,
    this.expandLabel = '更多',
    this.collapseLabel = '收起',
    this.actionColor = SHOAppColors.accent,
    this.actionFontWeight = FontWeight.w600,
    this.onExpandedChanged,
  });

  final String text;
  final TextStyle? style;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? height;
  final EdgeInsetsGeometry padding;
  final int maxLines;
  final bool showEllipsis;
  final bool enableExpand;
  final String expandLabel;
  final String collapseLabel;
  final Color actionColor;
  final FontWeight actionFontWeight;
  final ValueChanged<bool>? onExpandedChanged;

  @override
  State<SHOAppExpandableText> createState() => _SHOAppExpandableTextState();
}

class _SHOAppExpandableTextState extends State<SHOAppExpandableText> {
  TapGestureRecognizer? _expandRecognizer;
  TapGestureRecognizer? _collapseRecognizer;

  @override
  void dispose() {
    _expandRecognizer?.dispose();
    _collapseRecognizer?.dispose();
    super.dispose();
  }

  TextStyle _contentStyle(BuildContext context) {
    final base = widget.style ?? DefaultTextStyle.of(context).style;
    return base.copyWith(
      color: widget.color ?? base.color,
      fontSize: widget.fontSize ?? base.fontSize,
      fontWeight: widget.fontWeight ?? base.fontWeight,
      height: widget.height ?? base.height,
    );
  }

  TextStyle _actionStyle(TextStyle contentStyle) {
    return contentStyle.copyWith(
      color: widget.actionColor,
      fontWeight: widget.actionFontWeight,
    );
  }

  void _setExpanded(bool value) {
    if (value == _expanded) return;
    setState(() => _expanded = value);
    widget.onExpandedChanged?.call(value);
  }

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.text.isEmpty) {
      return Padding(padding: widget.padding, child: const SizedBox.shrink());
    }

    final contentStyle = _contentStyle(context);
    final actionStyle = _actionStyle(contentStyle);
    final textDirection = Directionality.of(context);

    return Padding(
      padding: widget.padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          if (!maxWidth.isFinite || maxWidth <= 0) {
            return _plainText(
              contentStyle: contentStyle,
              textDirection: textDirection,
            );
          }

          final overflows = _textOverflows(
            text: widget.text,
            style: contentStyle,
            maxWidth: maxWidth,
            maxLines: widget.maxLines,
            textDirection: textDirection,
          );

          if (!overflows) {
            return Text(
              widget.text,
              style: contentStyle,
              textDirection: textDirection,
            );
          }

          if (!widget.enableExpand) {
            return Text(
              widget.text,
              style: contentStyle,
              maxLines: widget.maxLines,
              overflow: widget.showEllipsis
                  ? TextOverflow.ellipsis
                  : TextOverflow.clip,
              textDirection: textDirection,
            );
          }

          if (_expanded) {
            _collapseRecognizer ??= TapGestureRecognizer()
              ..onTap = () => _setExpanded(false);

            return Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: widget.text, style: contentStyle),
                  TextSpan(
                    text: ' ${widget.collapseLabel}',
                    style: actionStyle,
                    recognizer: _collapseRecognizer,
                  ),
                ],
              ),
              textDirection: textDirection,
            );
          }

          _expandRecognizer ??= TapGestureRecognizer()
            ..onTap = () => _setExpanded(true);

          final ellipsis = widget.showEllipsis ? '...' : '';
          final visibleLength = _truncateLength(
            text: widget.text,
            style: contentStyle,
            ellipsis: ellipsis,
            suffix: widget.expandLabel,
            suffixStyle: actionStyle,
            maxWidth: maxWidth,
            maxLines: widget.maxLines,
            textDirection: textDirection,
          );

          return Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: widget.text.substring(0, visibleLength),
                  style: contentStyle,
                ),
                if (ellipsis.isNotEmpty)
                  TextSpan(text: ellipsis, style: contentStyle),
                TextSpan(
                  text: widget.expandLabel,
                  style: actionStyle,
                  recognizer: _expandRecognizer,
                ),
              ],
            ),
            maxLines: widget.maxLines,
            textDirection: textDirection,
          );
        },
      ),
    );
  }

  Widget _plainText({
    required TextStyle contentStyle,
    required TextDirection textDirection,
  }) {
    return Text(
      widget.text,
      style: contentStyle,
      maxLines: _expanded || !widget.enableExpand ? null : widget.maxLines,
      overflow: widget.showEllipsis ? TextOverflow.ellipsis : TextOverflow.clip,
      textDirection: textDirection,
    );
  }

  bool _textOverflows({
    required String text,
    required TextStyle style,
    required double maxWidth,
    required int maxLines,
    required TextDirection textDirection,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: textDirection,
    )..layout(maxWidth: maxWidth);
    return painter.didExceedMaxLines;
  }

  int _truncateLength({
    required String text,
    required TextStyle style,
    required String ellipsis,
    required String suffix,
    required TextStyle suffixStyle,
    required double maxWidth,
    required int maxLines,
    required TextDirection textDirection,
  }) {
    var low = 0;
    var high = text.length;
    var best = 0;

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      final spans = <InlineSpan>[
        TextSpan(text: text.substring(0, mid), style: style),
        if (ellipsis.isNotEmpty) TextSpan(text: ellipsis, style: style),
        TextSpan(text: suffix, style: suffixStyle),
      ];
      final fits = !_spanExceeds(
        spans: spans,
        maxWidth: maxWidth,
        maxLines: maxLines,
        textDirection: textDirection,
      );
      if (fits) {
        best = mid;
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    return best.clamp(0, text.length);
  }

  bool _spanExceeds({
    required List<InlineSpan> spans,
    required double maxWidth,
    required int maxLines,
    required TextDirection textDirection,
  }) {
    final painter = TextPainter(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      textDirection: textDirection,
    )..layout(maxWidth: maxWidth);
    return painter.didExceedMaxLines;
  }
}
