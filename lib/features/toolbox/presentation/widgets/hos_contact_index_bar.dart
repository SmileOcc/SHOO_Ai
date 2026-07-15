import 'package:flutter/material.dart';

import 'package:shoo/core/theme/hos_colors.dart';

/// 单个索引字母高度（与 [_IndexLetter] 一致，供气泡定位计算）。
const kSHOContactIndexLetterHeight = 18.0;

/// 侧边索引字母气泡（仿微信）：从字母位置向右滑入并淡出。
class SHOContactLetterBubble extends StatefulWidget {
  const SHOContactLetterBubble({
    super.key,
    required this.letter,
    required this.visible,
  });

  final String letter;
  final bool visible;

  static const bubbleSize = 56.0;

  @override
  State<SHOContactLetterBubble> createState() => _SHOContactLetterBubbleState();
}

class _SHOContactLetterBubbleState extends State<SHOContactLetterBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slide;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 160),
    );
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<double>(begin: -28, end: 0).animate(curve);
    _opacity = Tween<double>(begin: 0, end: 1).animate(curve);
    _scale = Tween<double>(begin: 0.55, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    if (widget.visible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(SHOContactLetterBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && widget.letter != oldWidget.letter) {
      _controller.forward(from: 0);
    } else if (widget.visible && !oldWidget.visible) {
      _controller.forward(from: 0);
    } else if (!widget.visible && oldWidget.visible) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible && _controller.isDismissed) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacity.value,
            child: Transform.translate(
              offset: Offset(_slide.value, 0),
              child: Transform.scale(
                scale: _scale.value,
                alignment: Alignment.centerRight,
                child: child,
              ),
            ),
          );
        },
        child: Container(
          width: SHOContactLetterBubble.bubbleSize,
          height: SHOContactLetterBubble.bubbleSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF4A4A4A).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            widget.letter,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

typedef SHOContactIndexLetterSelected = void Function(
  String letter,
  double letterCenterDy,
);

/// 右侧 A-Z 索引条。
class SHOContactIndexBar extends StatefulWidget {
  const SHOContactIndexBar({
    super.key,
    required this.letters,
    required this.activeLetter,
    required this.onLetterSelected,
    this.onInteractionEnd,
  });

  final List<String> letters;
  final String? activeLetter;
  final SHOContactIndexLetterSelected onLetterSelected;
  final VoidCallback? onInteractionEnd;

  static const _verticalPadding = 8.0;
  static const _horizontalPadding = 4.0;

  @override
  State<SHOContactIndexBar> createState() => _SHOContactIndexBarState();
}

class _SHOContactIndexBarState extends State<SHOContactIndexBar> {
  //GlobalKey 是 Flutter 中唯一能跨 Widget 树访问 Widget 状态和位置的 Key 。
  final _barKey = GlobalKey();
  final _letterKeys = <String, GlobalKey>{};


// didUpdateWidget 是 State 的生命周期方法 ，当 Widget 的配置（ widget 属性）变化时调用。
  @override
  void didUpdateWidget(SHOContactIndexBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当 letters 列表变化时，更新 GlobalKey 映射
    for (final letter in widget.letters) {
      // 如果字母不存在于 map 中，创建新的 GlobalKey；已存在则保持不变
      _letterKeys.putIfAbsent(letter, GlobalKey.new);
    }
    // 步骤2：移除不再存在的字母的 GlobalKey
    _letterKeys.removeWhere((letter, _) => !widget.letters.contains(letter));
  }

  @override
  void initState() {
    super.initState();
    for (final letter in widget.letters) {
      _letterKeys[letter] = GlobalKey();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          key: _barKey,// 绑定到整个索引条
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: (details) => _pickLetter(
            details.localPosition.dy,
            constraints.maxHeight,
          ),
          onVerticalDragEnd: (_) => widget.onInteractionEnd?.call(),
          onTapDown: (details) => _pickLetter(
            details.localPosition.dy,
            constraints.maxHeight,
          ),
          onTapUp: (_) => widget.onInteractionEnd?.call(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: SHOContactIndexBar._verticalPadding,
              horizontal: SHOContactIndexBar._horizontalPadding,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final letter in widget.letters)
                  _IndexLetter(
                    key: _letterKeys[letter], // 每个字母绑定唯一的 GlobalKey 用于获取每个字母 Widget 的精确位置。
                    letter: letter,
                    selected: letter == widget.activeLetter,
                    onTap: () => _selectLetter(letter),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _selectLetter(String letter) {
    widget.onLetterSelected(letter, _letterCenterDy(letter));
  }

  void _pickLetter(double dy, double barHeight) {
    if (widget.letters.isEmpty || barHeight <= 0) return;
    final index = _letterIndexForDy(dy, barHeight);
    _selectLetter(widget.letters[index]);
  }

  int _letterIndexForDy(double dy, double barHeight) {
    final contentHeight = widget.letters.length * kSHOContactIndexLetterHeight;
    final columnTop =
        (barHeight - contentHeight) / 2 + SHOContactIndexBar._verticalPadding;
    final columnBottom = columnTop + contentHeight;

    if (dy <= columnTop) return 0;
    if (dy >= columnBottom - 0.5) return widget.letters.length - 1;

    final relativeDy = dy - columnTop;
    final index = (relativeDy / kSHOContactIndexLetterHeight).floor();
    return index.clamp(0, widget.letters.length - 1);
  }

  // 用途 ：计算字母在索引条中的精确垂直位置，用于定位字母气泡（ SHOContactLetterBubble ）。
  double _letterCenterDy(String letter) {
    // 通过 GlobalKey 获取 BuildContext
    final key = _letterKeys[letter];
    final letterContext = key?.currentContext;
    final barContext = _barKey.currentContext;
    if (letterContext != null && barContext != null) {
      final letterBox = letterContext.findRenderObject() as RenderBox?;
      final barBox = barContext.findRenderObject() as RenderBox?;
      if (letterBox != null &&
          barBox != null &&
          letterBox.hasSize &&
          barBox.hasSize) {
            // 通过 RenderBox 获取精确的位置信息
        final letterCenter = letterBox.size.center(Offset.zero);
        final local = barBox.globalToLocal(
          letterBox.localToGlobal(letterCenter),
        );
        // 返回字母在索引条中的垂直中心位置
        return local.dy;
      }
    }

    // ... 兜底计算
    final index = widget.letters.indexOf(letter);
    if (index < 0) return 0;
    final barBox = barContext?.findRenderObject() as RenderBox?;
    final barHeight = barBox?.size.height ?? 0;
    final contentHeight = widget.letters.length * kSHOContactIndexLetterHeight;
    final columnTop =
        (barHeight - contentHeight) / 2 + SHOContactIndexBar._verticalPadding;
    return columnTop +
        index * kSHOContactIndexLetterHeight +
        kSHOContactIndexLetterHeight / 2;
  }
}

class _IndexLetter extends StatelessWidget {
  const _IndexLetter({
    super.key,
    required this.letter,
    required this.selected,
    required this.onTap,
  });

  final String letter;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 18,
        height: kSHOContactIndexLetterHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? SHOAppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : SHOAppColors.textMuted,
            height: 1,
          ),
        ),
      ),
    );
  }
}
