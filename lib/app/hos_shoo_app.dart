import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/analytics/hos_app_lifecycle_binder.dart';
import '../core/deeplink/hos_deeplink_listener.dart';
import '../core/feedback/hos_toast.dart';
import '../core/l10n/hos_locale_provider.dart';
import '../core/theme/hos_theme.dart';
import '../core/theme/hos_theme_mode_provider.dart';
import '../core/widgets/hos_offline_banner.dart' show SHOAppShell;
import '../l10n/app_localizations.dart';
import 'router/hos_router.dart';

//SHOApp 是 应用根 Widget，负责整合所有全局配置和基础设施。
//它是整个应用的入口点，协调路由、主题、国际化、生命周期监控等核心功能。
//ConsumerWidget（Riverpod 的响应式 Widget）
// 可以监听 Provider，自动响应状态变化
// 支持编译时创建，优化性能
// 所有配置通过 Provider 获取，避免硬编码

// scaffoldMessengerKey：
// 全局访问 ScaffoldMessenger，显示 Toast
// 无需 BuildContext 即可显示 SnackBar

class SHOApp extends ConsumerWidget {
  const SHOApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 路由管理 - 通过 go_router 管理全站路由和导航
    final router = ref.watch(routerProvider);
    // 深度链接监听 - 监听应用启动时的深度链接
    ref.watch(deepLinkListenerProvider);
    // 主题管理 - 支持亮色/暗色主题动态切换
    final themeMode = ref.watch(themeModeProvider);
    // 国际化管理 - 支持多语言切换
    final locale = ref.watch(localeProvider);

    //生命周期监控 - 监听应用启动、前后台切换等事件
    return SHOAppLifecycleBinder(
      child: MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,     // ← 全局 Toast Key 全局访问 ScaffoldMessenger，显示 Toast
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: SHOAppTheme.light,
      darkTheme: SHOAppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales, // ← 支持的语言列表
      localizationsDelegates: const [
        AppLocalizations.delegate,   // ← 应用国际化
        GlobalMaterialLocalizations.delegate, // ← Material 国际化
        GlobalWidgetsLocalizations.delegate,  // ← Widget 国际化
        GlobalCupertinoLocalizations.delegate, // ← Cupertino 国际化
      ],
      routerConfig: router,   // ← 路由配置（动态）
      builder: (context, child) {
        // 所有页面外层包裹离线提示条 监听网络状态，显示离线提示
        return SHOAppShell(child: child ?? const SizedBox.shrink());
      },
      ),
    );
  }
}


/*
┌─────────────────────────────────────────────────────────────┐
│              SHOApp 内部 Widget 重建的真正原因                │
└─────────────────────────────────────────────────────────────┘

【场景 1: 环境切换】
ProviderScope 重建（key 改变）
    ↓
创建新的 ProviderContainer
    ↓
SHOApp.build() 执行（ref 关联到新容器）
    ↓
所有 Provider 重新初始化
    ↓
内部 Widget 重建

【场景 2: 主题切换】
themeModeProvider 状态更新
    ↓
ref.watch(themeModeProvider) 检测到变化
    ↓
SHOApp.build() 执行（响应式机制）
    ↓
获取新的 themeMode 值
    ↓
MaterialApp.router 重建（参数变化）

【共同点】
const SHOApp() 实例不重建（编译时创建）
SHOApp.build() 都会执行（响应式机制）
内部 Widget 都会重建（参数变化）
*/


/*
关键理解:

const Widget 实例 ≠ Widget.build() 不执行
const 只保证实例不重建
build() 仍会因响应式机制执行
两种重建触发机制:
ProviderScope 重建 → 整个 Provider 树重建
Provider 值变化 → 部分 Widget 树重建
const 的真正作用:
避免不必要的 Widget 实例创建
减少内存占用和创建开销
但不能阻止响应式更新
所以答案是:

✅ 两种原因都会导致 SHOApp 内部 Widget 重建:

ProviderScope 重建（环境切换）→ 整个 Provider 树重建
Provider 值变化（主题切换）→ 部分 Widget 树重建
✅ const SHOApp() 的作用:

避免 Widget 实例重建（减少创建开销）
但不能阻止 build() 执行（响应式机制）
不能阻止内部 Widget 重建（参数变化）
这就是 Flutter + Riverpod 的响应式机制的核心原理！
*/

/**
 
 ┌─────────────────────────────────────────────────────────────┐
│                    SHOO 应用架构层次                          │
└─────────────────────────────────────────────────────────────┘

bootstrap() (启动引导)
         │
         │ runApp(SHOAppRestart)
         ▼
┌─────────────────────────────────────────────────────────────┐
│          SHOAppRestart (环境切换支持)                         │
│          ProviderScope (状态管理容器)                         │
└─────────────────────────────────────────────────────────────┘
         │
         │ const SHOApp()
         ▼
┌─────────────────────────────────────────────────────────────┐
│          SHOApp (应用根 Widget)                              │
├─────────────────────────────────────────────────────────────┤
│  监听 Provider:                                              │
│    - routerProvider (路由配置)                               │
│    - themeModeProvider (主题模式)                            │
│    - localeProvider (语言设置)                               │
│    - deepLinkListenerProvider (深链监听)                     │
│                                                              │
│  包裹组件:                                                    │
│    - SHOAppLifecycleBinder (生命周期监控)                    │
│    - MaterialApp.router (Material 应用框架)                  │
│    - SHOAppShell (离线提示条)                                │
└─────────────────────────────────────────────────────────────┘
         │
         │ routerConfig: router
         ▼
┌─────────────────────────────────────────────────────────────┐
│          GoRouter (路由系统)                                 │
├─────────────────────────────────────────────────────────────┤
│  路由表:                                                     │
│    - / (首页)                                                │
│    - /category (分类)                                        │
│    - /cart (购物袋)                                          │
│    - /profile (我的)                                         │
│    - /product/:id (商品详情)                                 │
│    - /checkout (结算)                                        │
│    - /orders (订单列表)                                      │
│    - ... (更多路由)                                          │
│                                                              │
│  路由守卫:                                                    │
│    - 登录状态检查                                            │
│    - Debug 路径限制                                          │
│    - 深链跳转                                                │
└─────────────────────────────────────────────────────────────┘

 */


/*
┌─────────────────────────────────────────────────────────────┐
│                    国际化架构层次                             │
└─────────────────────────────────────────────────────────────┘

localeProvider (语言设置)
         │
         │ locale: Locale('zh')
         ▼
┌─────────────────────────────────────────────────────────────┐
│          MaterialApp.router                                  │
├─────────────────────────────────────────────────────────────┤
│  localizationsDelegates:                                     │
│    - AppLocalizations.delegate (应用自定义翻译)              │
│    - GlobalMaterialLocalizations.delegate (Material 翻译)   │
│    - GlobalWidgetsLocalizations.delegate (Widget 翻译)      │
│    - GlobalCupertinoLocalizations.delegate (Cupertino 翻译) │
│                                                              │
│  supportedLocales:                                           │
│    - [Locale('en'), Locale('zh'), Locale('ja'), ...]        │
└─────────────────────────────────────────────────────────────┘
         │
         │ AppLocalizations.of(context)
         ▼
┌─────────────────────────────────────────────────────────────┐
│          UI 组件                                             │
├─────────────────────────────────────────────────────────────┤
│  Text(l10n.productDetailTitle)  // ← 使用翻译文本           │
│  Button(label: l10n.productBuyNow)                            │
│  ...                                                          │
└─────────────────────────────────────────────────────────────┘
*/