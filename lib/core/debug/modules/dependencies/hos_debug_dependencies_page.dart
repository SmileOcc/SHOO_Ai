import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/pages/hos_pages.dart';

/// 调试 InheritedWidget 依赖变化的 Widget
/// 监听所有依赖的 InheritedWidget 变化并输出日志
class DebugAllDependenciesWidget extends ConsumerStatefulWidget {
  final Widget child;
  const DebugAllDependenciesWidget({required this.child, super.key});

  @override
  ConsumerState<DebugAllDependenciesWidget> createState() =>
      _DebugAllDependenciesWidgetState();
}

class _DebugAllDependenciesWidgetState
    extends ConsumerState<DebugAllDependenciesWidget>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  @override
  String get pageName => 'debug_dependencies';

  int _changeCount = 0;
  final List<String> _logs = [];

  // 记录上一次的值，用于对比具体变化
  Size _lastSize = Size.zero;
  double _lastKeyboardHeight = 0;
  Brightness _lastBrightness = Brightness.light;
  double _lastTextScaleFactor = 1.0;
  Locale? _lastLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _changeCount++;

    final buffer = StringBuffer();
    buffer.writeln('┌──────────────────────────────────────────┐');
    buffer.writeln('│ didChangeDependencies 被调用 (第 $_changeCount 次) ');
    buffer.writeln('│ 时间: ${DateTime.now().toString().substring(11, 19)}');
    buffer.writeln('├──────────────────────────────────────────┤');

    // ========== 1. MediaQuery 相关 ==========
    final mediaQuery = MediaQuery.of(context);

    // 屏幕尺寸变化
    if (mediaQuery.size != _lastSize) {
      buffer.writeln('│ [MediaQuery] 屏幕尺寸: ${_lastSize} → ${mediaQuery.size}');
      _lastSize = mediaQuery.size;
    }

    // 键盘弹出/收起
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    if (keyboardHeight != _lastKeyboardHeight) {
      buffer.writeln(
          '│ [MediaQuery] 键盘高度: ${_lastKeyboardHeight.toStringAsFixed(1)} → ${keyboardHeight.toStringAsFixed(1)}');
      _lastKeyboardHeight = keyboardHeight;
    }

    // 字体缩放
    if (mediaQuery.textScaleFactor != _lastTextScaleFactor) {
      buffer.writeln(
          '│ [MediaQuery] 字体缩放: $_lastTextScaleFactor → ${mediaQuery.textScaleFactor}');
      _lastTextScaleFactor = mediaQuery.textScaleFactor;
    }

    // 无障碍模式
    buffer.writeln('│ [MediaQuery] 无障碍模式: ${mediaQuery.accessibleNavigation}');

    // 反转颜色
    buffer.writeln('│ [MediaQuery] 反转颜色: ${mediaQuery.invertColors}');

    // 粗体文本
    buffer.writeln('│ [MediaQuery] 粗体文本: ${mediaQuery.boldText}');

    // 减弱动态效果
    buffer.writeln('│ [MediaQuery] 减弱动画: ${mediaQuery.disableAnimations}');

    // 高对比度
    buffer.writeln('│ [MediaQuery] 高对比度: ${mediaQuery.highContrast}');

    // 像素密度
    buffer.writeln('│ [MediaQuery] 像素密度: ${mediaQuery.devicePixelRatio}');

    // 边距（安全区域 + 系统栏）
    buffer.writeln('│ [MediaQuery] 内边距: ${mediaQuery.padding}');
    buffer.writeln('│ [MediaQuery] 视图边距: ${mediaQuery.viewPadding}');
    buffer.writeln('│ [MediaQuery] 系统手势边距: ${mediaQuery.systemGestureInsets}');

    // ========== 2. Theme 相关 ==========
    final theme = Theme.of(context);

    if (theme.brightness != _lastBrightness) {
      buffer.writeln(
          '│ [Theme] 亮度切换: $_lastBrightness → ${theme.brightness}');
      _lastBrightness = theme.brightness;
    }

    buffer.writeln('│ [Theme] 主色: ${theme.colorScheme.primary}');
    buffer.writeln('│ [Theme] 背景色: ${theme.colorScheme.surface}');
    buffer.writeln(
        '│ [Theme] 是否 Material3: ${theme.useMaterial3}');
    buffer.writeln('│ [Theme] 平台: ${theme.platform}');

    // ========== 3. 路由相关 ==========
    try {
      final route = ModalRoute.of(context);
      if (route != null) {
        buffer.writeln('│ [Route] 路由名称: ${route.settings.name ?? "未命名"}');
        buffer.writeln('│ [Route] 路由参数: ${route.settings.arguments}');
        buffer.writeln('│ [Route] 当前是否激活: ${route.isCurrent}');
        buffer.writeln('│ [Route] 是否弹出中: ${route.isActive}');
      }
    } catch (e) {
      buffer.writeln('│ [Route] 无路由上下文');
    }

    // ========== 4. Localizations 相关 ==========
    try {
      final locale = Localizations.localeOf(context);
      if (locale != _lastLocale) {
        buffer.writeln('│ [i18n] 语言切换: $_lastLocale → $locale');
        _lastLocale = locale;
      }
      buffer.writeln('│ [i18n] 当前语言: $locale');

      // Material 本地化
      final materialLocale = MaterialLocalizations.of(context);
      buffer.writeln(
          '│ [i18n] 文本方向: ${materialLocale.scriptCategory}');
    } catch (e) {
      buffer.writeln('│ [i18n] 无法获取本地化信息');
    }

    // ========== 5. Directionality ==========
    try {
      final textDirection = Directionality.of(context);
      buffer.writeln('│ [Direction] 文本方向: $textDirection');
    } catch (e) {
      buffer.writeln('│ [Direction] 无法获取');
    }

    // ========== 6. Navigator ==========
    try {
      buffer.writeln('│ [Navigator] canPop: ${Navigator.canPop(context)}');
    } catch (e) {
      buffer.writeln('│ [Navigator] 无法访问');
    }

    // ========== 7. Scaffold 相关 ==========
    try {
      final scaffold = Scaffold.maybeOf(context);
      if (scaffold != null) {
        buffer.writeln('│ [Scaffold] 是否有 Drawer: ${scaffold.hasDrawer}');
        buffer.writeln(
            '│ [Scaffold] 是否有 FloatingActionButton: ${scaffold.hasFloatingActionButton}');
      } else {
        buffer.writeln('│ [Scaffold] 不在 Scaffold 内');
      }
    } catch (e) {
      buffer.writeln('│ [Scaffold] 无法获取');
    }

    // ========== 8. ScrollConfiguration ==========
    try {
      final scrollConfig = ScrollConfiguration.of(context);
      buffer.writeln('│ [Scroll] 滚动行为: ${scrollConfig.runtimeType}');
      buffer.writeln(
          '│ [Scroll] 物理模拟: ${scrollConfig.getScrollPhysics(context).runtimeType}');
    } catch (e) {
      buffer.writeln('│ [Scroll] 无法获取');
    }

    buffer.writeln('└──────────────────────────────────────────┘');

    final log = buffer.toString();
    debugPrint(log);
    
    setState(() {
      _logs.insert(0, log);
      if (_logs.length > 50) {
        _logs.removeLast();
      }
    });
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return buildTrackedPage(
      Scaffold(
      appBar: AppBar(
        title: const Text('InheritedWidget 依赖监听'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearLogs,
            tooltip: '清空日志',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '依赖变化日志',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '当前监听次数: $_changeCount',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '触发 didChangeDependencies 的常见场景:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• 首次挂载后\n'
                    '• 键盘弹出/收起\n'
                    '• 屏幕旋转/尺寸变化\n'
                    '• 系统亮度切换\n'
                    '• 语言切换\n'
                    '• 路由切换\n'
                    '• Theme 变化\n'
                    '• 任何 InheritedWidget 变化',
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  ..._logs.map((log) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          log,
                          style: const TextStyle(
                            fontFamily: 'Monaco',
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      )),
                  if (_logs.isEmpty)
                    const Text(
                      '等待依赖变化...\n\n尝试：\n• 切换系统亮度\n• 打开/关闭键盘\n• 切换语言\n• 旋转屏幕',
                      style: TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}