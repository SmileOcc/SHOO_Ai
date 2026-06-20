// 自定义 B 的命中测试行为
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// 定义带字符串参数的回调类型
typedef TapWithLabelCallback = void Function(String label);

class SHOWidgetWithCustomHitTest extends StatelessWidget {
  final TapWithLabelCallback? onMessageBlock; // 带参数的回调

  // 或者直接写
  // final void Function(String label)? onTap;

  const SHOWidgetWithCustomHitTest({super.key, this.onMessageBlock});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 关键理解：_CustomHitTestRenderBox 的 hitTest 返回 false，
        //只是让这个 RenderBox 自己和它的子节点不响应事件，
        //但它的父 Widget（内层 Stack、外层 Stack 中的 B 位置）仍然认为自己被命中了
        // B 的实际内容 如果这个打开了，就拦截了
        // Container(
        //   color: Colors.red.withAlpha(125),
        //   child: Center(child: Text('B 区域')),
        // ),

        // B 的视觉内容（不参与命中测试）
        Positioned.fill(
          child: IgnorePointer(
            // ← 关键：视觉层不拦截事件
            child: Container(
              color: Colors.red.withAlpha(125),
              child: Center(child: Text('B 区域: 左边50px 内响应的是A事件')),
            ),
          ),
        ),

        // 自定义命中测试层
        Positioned.fill(
          child: _CustomHitTestWidget(
            child: GestureDetector(
              onTap: () => onMessageBlock?.call('B 被点击'),
              behavior: HitTestBehavior.opaque,
              // child: Container( //或这个显示
              //   color: Colors.red.withAlpha(125),
              //   child: Center(child: Text('B 区域 左边50px 内响应的是A事件')),
              // ),
            ),
          ),
        ),
      ],
    );
  }
}

// 自定义 RenderBox 控制命中区域
class _CustomHitTestWidget extends SingleChildRenderObjectWidget {
  const _CustomHitTestWidget({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _CustomHitTestRenderBox();
  }
}

class _CustomHitTestRenderBox extends RenderProxyBoxWithHitTestBehavior {
  _CustomHitTestRenderBox() : super(behavior: HitTestBehavior.opaque);

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // 在这里判断：如果点击位置在某个区域内，就不响应
    // 例如：B 的左边 50px 不响应（让 A 响应）
    print('点击 position: $position');
    if (position.dx < 50 || position.dx > 200) {
      print('点击 position: $position 事件穿透给 A');
      return false; // 不命中，事件穿透给 A
    }

    // 其他区域正常命中
    return super.hitTest(result, position: position);
  }
}

/////////////
///
class SHOWidgetWithCustomHitTest2 extends StatelessWidget {
  final void Function(String label)? onMessageBlock;

  const SHOWidgetWithCustomHitTest2({super.key, this.onMessageBlock});
  @override
  Widget build(BuildContext context) {
    return _CustomHitTestStack22(
      children: [
        // A 视图（渲染到独立 Layer）
        _CustomHitTestBox(
          // 位置：距离左边 30，距离顶部 40
          x: 30,
          y: 40,
          // 大小：宽 200，高 300
          width: 200,
          height: 300,
          color: Colors.blue.withAlpha(90),
          onTap: () => onMessageBlock?.call('🔵 A 被点击'),
          debugLabel: 'A',
        ),

        // B 视图（带自定义命中区域）
        _CustomHitTestBox(
          // 位置：与 A 的右下角重叠
          x: 130,
          y: 200,
          // 大小：宽 150，高 100
          width: 150,
          height: 100,
          color: Colors.red.withAlpha(125),
          hitTestFilter: (size, position) {
            // 只响应右半部分
            return position.dx > size.width / 2;
          },
          onTap: () => onMessageBlock?.call('🔴 B 被点击（右半部分）'),
          debugLabel: 'B',
        ),
      ],
    );
  }
}

// ============================================
// _CustomHitTestStack（多子节点 Stack）
// ============================================

class _CustomHitTestStack22 extends MultiChildRenderObjectWidget {
  final bool debugMode;

  _CustomHitTestStack22({
    required List<Widget> children,
    this.debugMode = false,
    super.key,
  }) : super(children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _CustomHitTestRenderStack22(debugMode: debugMode);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _CustomHitTestRenderStack22 renderObject,
  ) {
    renderObject.debugMode = debugMode;
  }
}

// ============================================
// _CustomHitTestRenderStack
// ============================================

class _CustomHitTestRenderStack22 extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, StackParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, StackParentData> {
  bool debugMode;

  _CustomHitTestRenderStack22({this.debugMode = false});

  // set debugMode(bool value) {
  //   if (debugMode != value) {
  //     debugMode = value;
  //     markNeedsPaint();
  //   }
  // }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (debugMode) {
      debugPrint(
        '═══ Stack hitTest start, position=(${position.dx.toStringAsFixed(1)}, ${position.dy.toStringAsFixed(1)}) ═══',
      );
    }

    var hitChild = false;

    // 从上层到下层遍历（倒序）
    for (var child = lastChild; child != null; child = childBefore(child)) {
      final childParentData = child.parentData as StackParentData;

      if (debugMode) {
        debugPrint('  Testing: ${child.runtimeType}');
      }

      final isHit = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (result, transformed) {
          return child?.hitTest(result, position: transformed) ?? false;
        },
      );

      if (isHit) {
        hitChild = true;
        if (debugMode) {
          debugPrint('  ✅ Hit!');
        }
        // 不 break，继续测试下层
        // 这样 A 和 B 都能收到事件
      } else {
        if (debugMode) {
          debugPrint('  ❌ Miss (穿透)');
        }
      }
    }

    if (debugMode) {
      debugPrint('═══ Stack hitTest end, hitChild=$hitChild ═══');
    }

    return hitChild;
  }

  @override
  void performLayout() {
    Size childSize = Size.zero;

    for (var child = firstChild; child != null; child = childAfter(child)) {
      child.layout(constraints.loosen(), parentUsesSize: true);
      final childParentData = child.parentData as StackParentData;
      childParentData.offset = Offset.zero;

      childSize = Size(
        max(childSize.width, child.size.width),
        max(childSize.height, child.size.height),
      );
    }

    size = constraints.constrain(childSize);
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! StackParentData) {
      child.parentData = StackParentData();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    for (var child = firstChild; child != null; child = childAfter(child)) {
      final childParentData = child.parentData as StackParentData;
      context.paintChild(child, childParentData.offset + offset);
    }
  }
}

// ============================================
// _CustomHitTestBox（叶子 Widget）
// ============================================

class _CustomHitTestBox extends LeafRenderObjectWidget {
  /// X 坐标（相对于父 Stack）
  final double x;

  /// Y 坐标（相对于父 Stack）
  final double y;

  /// 宽度
  final double width;

  /// 高度
  final double height;

  /// 背景颜色
  final Color color;

  /// 点击回调
  final VoidCallback? onTap;

  /// 命中测试过滤器
  final bool Function(Size size, Offset position)? hitTestFilter;

  /// 是否阻止事件穿透
  final bool blockHit;

  /// 是否显示调试信息
  final bool debug;

  /// 调试标签
  final String? debugLabel;

  const _CustomHitTestBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.color,
    this.onTap,
    this.hitTestFilter,
    this.blockHit = true,
    this.debug = false,
    this.debugLabel,
    super.key,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _CustomHitTestRenderBox22(
      x: x,
      y: y,
      width: width,
      height: height,
      color: color,
      onTap: onTap,
      hitTestFilter: hitTestFilter,
      blockHit: blockHit,
      debug: debug,
      debugLabel: debugLabel,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _CustomHitTestRenderBox22 renderObject,
  ) {
    renderObject
      ..x = x
      ..y = y
      ..width = width
      ..height = height
      ..color = color
      ..onTap = onTap
      ..hitTestFilter = hitTestFilter
      ..blockHit = blockHit
      ..debug = debug
      ..debugLabel = debugLabel;
  }

  @override
  void didUnmountRenderObject(_CustomHitTestRenderBox22 renderObject) {
    super.didUnmountRenderObject(renderObject);
  }
}

// ============================================
// _CustomHitTestRenderBox
// ============================================

class _CustomHitTestRenderBox22 extends RenderBox {
  double _x;
  double _y;
  double _width;
  double _height;
  Color _color;
  VoidCallback? _onTap;
  bool Function(Size size, Offset position)? _hitTestFilter;
  bool _blockHit;
  bool _debug;
  String? _debugLabel;

  _CustomHitTestRenderBox22({
    required double x,
    required double y,
    required double width,
    required double height,
    required Color color,
    VoidCallback? onTap,
    bool Function(Size size, Offset position)? hitTestFilter,
    bool blockHit = true,
    bool debug = false,
    String? debugLabel,
  }) : _x = x,
       _y = y,
       _width = width,
       _height = height,
       _color = color,
       _onTap = onTap,
       _hitTestFilter = hitTestFilter,
       _blockHit = blockHit,
       _debug = debug,
       _debugLabel = debugLabel;

  // ========== Getters/Setters ==========

  double get x => _x;
  set x(double value) {
    if (_x != value) {
      _x = value;
      _updateParentData();
    }
  }

  double get y => _y;
  set y(double value) {
    if (_y != value) {
      _y = value;
      _updateParentData();
    }
  }

  double get width => _width;
  set width(double value) {
    if (_width != value) {
      _width = value;
      markNeedsLayout();
    }
  }

  double get height => _height;
  set height(double value) {
    if (_height != value) {
      _height = value;
      markNeedsLayout();
    }
  }

  Color get color => _color;
  set color(Color value) {
    if (_color != value) {
      _color = value;
      markNeedsPaint();
    }
  }

  VoidCallback? get onTap => _onTap;
  set onTap(VoidCallback? value) => _onTap = value;

  bool Function(Size size, Offset position)? get hitTestFilter =>
      _hitTestFilter;
  set hitTestFilter(bool Function(Size size, Offset position)? value) {
    _hitTestFilter = value;
    if (_debug) markNeedsPaint();
  }

  bool get blockHit => _blockHit;
  set blockHit(bool value) => _blockHit = value;

  bool get debug => _debug;
  set debug(bool value) {
    if (_debug != value) {
      _debug = value;
      markNeedsPaint();
    }
  }

  String? get debugLabel => _debugLabel;
  set debugLabel(String? value) {
    _debugLabel = value;
    if (_debug) markNeedsPaint();
  }

  /// 更新父节点的 StackParentData.offset
  void _updateParentData() {
    final parentData = this.parentData as StackParentData?;
    if (parentData != null) {
      parentData.offset = Offset(_x, _y);
      markNeedsPaint();
    }
  }

  // ========== 核心：命中测试 ==========

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (_debug) {
      debugPrint(
        '    [$_debugLabel] hitTest: position=(${position.dx.toStringAsFixed(1)}, ${position.dy.toStringAsFixed(1)}), size=${size.width}x${size.height}',
      );
    }

    // 1. 检查是否在范围内
    if (!size.contains(position)) {
      if (_debug) {
        debugPrint('    [$_debugLabel] out of bounds');
      }
      return false;
    }

    // 2. 应用自定义过滤器
    if (_hitTestFilter != null) {
      final shouldHit = _hitTestFilter!(size, position);
      if (_debug) {
        debugPrint('    [$_debugLabel] filter result: $shouldHit');
      }
      if (!shouldHit) {
        return false; // 穿透
      }
    }

    // 3. 添加到命中列表
    result.add(HitTestEntry(this));

    if (_debug) {
      debugPrint('    [$_debugLabel] added to hit result');
    }

    return _blockHit;
  }

  // ========== 事件处理 ==========

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    if (event is PointerUpEvent) {
      if (_debug) {
        debugPrint('    [$_debugLabel] PointerUp → trigger onTap');
      }
      _onTap?.call();
    }
  }

  // ========== 布局 ==========

  @override
  void performLayout() {
    size = constraints.constrain(Size(_width, _height));
  }

  // ========== 绘制 ==========

  @override
  void paint(PaintingContext context, Offset offset) {
    final paintRect = offset & size;

    // 1. 绘制背景色
    context.canvas.drawRect(paintRect, Paint()..color = _color);

    // 2. 绘制边框
    context.canvas.drawRect(
      paintRect,
      Paint()
        ..color = _color.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // 3. 绘制标签
    if (_debugLabel != null) {
      _paintLabel(context, offset, _debugLabel!);
    }

    // 4. 调试模式：绘制辅助信息
    if (_debug) {
      _paintDebugInfo(context, offset);
    }
  }

  /// 绘制文字标签
  void _paintLabel(PaintingContext context, Offset offset, String label) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$label (${size.width.toInt()}x${size.height.toInt()})',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black54, blurRadius: 2)],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(context.canvas, offset + const Offset(6, 6));
  }

  /// 绘制调试信息
  void _paintDebugInfo(PaintingContext context, Offset offset) {
    final paintRect = offset & size;

    // 绘制绿色虚线边框
    final dashWidth = 5.0;
    final dashSpace = 3.0;
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 上边
    for (double x = 0; x < size.width; x += dashWidth + dashSpace) {
      final endX = (x + dashWidth).clamp(0, size.width);
      context.canvas.drawLine(
        offset + Offset(x, 0),
        offset + Offset(endX.toDouble(), 0),
        paint,
      );
    }

    // 如果有过滤器，绘制采样点
    if (_hitTestFilter != null) {
      final step = 20.0;
      for (double y = step / 2; y < size.height; y += step) {
        for (double x = step / 2; x < size.width; x += step) {
          final localPos = Offset(x, y);
          final isHit = _hitTestFilter!(size, localPos);

          final dotColor = isHit ? Colors.green : Colors.red;
          final dotRadius = isHit ? 4.0 : 2.5;

          context.canvas.drawCircle(
            offset + localPos,
            dotRadius,
            Paint()..color = dotColor,
          );
        }
      }

      // 绘制分隔线（左右分界线）
      final midX = size.width / 2;
      context.canvas.drawLine(
        offset + Offset(midX, 0),
        offset + Offset(midX, size.height),
        Paint()
          ..color = Colors.yellow
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }
}
