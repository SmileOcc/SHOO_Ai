# 页面通用埋点实现方案（方案 B：RouteAware + RouteObserver）

## 目标

在 `lib/core/analytics/` 提供统一的页面可见性监听与埋点能力，覆盖：

| 语义 | RouteAware 回调 | 事件 key |
|------|-----------------|----------|
| 页面显示（入栈） | `didPush` | `page_enter` |
| 页面退出（出栈） | `didPop` | `page_exit` |
| 被上层覆盖（仍留栈） | `didPushNext` | `page_cover` |
| 覆盖解除后恢复 | `didPopNext` | `page_resume` |

并辅以 **NavigatorObserver** 栈级埋点（无需页面接入）：

| 语义 | NavigatorObserver | 事件 key |
|------|-------------------|----------|
| 推入 | `didPush` | `route_push` |
| 弹出 | `didPop` | `route_pop` |
| 替换 | `didReplace` | `route_replace` |
| 移除 | `didRemove` | `route_remove` |

**Shell Tab 切换**（`SHOMainShell.onTap`）：

| 语义 | 触发 | 事件 key |
|------|------|----------|
| Tab 切换 / 重复点击 | `navigationShell.goBranch` | `tab_switch` |

## 架构

```
MaterialApp.router
  └── GoRouter.observers
        ├── shoPageRouteObserver              # RouteAware 订阅源
        ├── SHOPageAnalyticsNavigatorObserver # 栈级 push/pop
        └── SHOMusicNavigatorObserver         # 音乐业务路由同步（并存）

页面接入（任选其一）
  ├── SHOPageRouteAnalyticsMixin            # StatefulWidget / ConsumerStatefulWidget
  └── SHOPageAnalyticsBinder                # StatelessWidget 包裹
```

与 **App 生命周期**（`SHOAppLifecycleBinder` → `app_launch` / `app_close`）互补，不重复。

## 文件清单

| 文件 | 职责 |
|------|------|
| `hos_page_analytics.dart` | 库入口与方案说明 |
| `hos_page_route_observer.dart` | 全局 `RouteObserver` |
| `hos_page_route_analytics_mixin.dart` | 单页 `RouteAware` mixin |
| `hos_page_analytics_binder.dart` | Stateless 页面包裹 |
| `hos_page_analytics_nav_observer.dart` | 栈级 `NavigatorObserver` |
| `hos_page_analytics_reporter.dart` | 统一上报 `SHOAnalyticsManager` |
| `hos_page_route_info.dart` | 路由 path / uri / pageName 解析 |
| `hos_tab_analytics.dart` | Shell Tab 切换埋点 |
| `hos_analytics_registry.dart` | 事件注册（page_* / route_* / tab_switch） |

## 接入步骤

### 1. 路由（已完成）

`hos_router.dart` 已注册：

```dart
observers: [
  shoPageRouteObserver,
  SHOPageAnalyticsNavigatorObserver.root,
  SHOMusicNavigatorObserver(syncMusicRoute),
],
```

### 2. StatefulWidget 页面

```dart
class _MyPageState extends ConsumerState<MyPage>
    with SHOPageRouteAnalyticsMixin {

  @override
  String get pageAnalyticsName => 'MyPage';

  @override
  Map<String, Object?> get pageAnalyticsExtra => {
    'product_id': widget.productId,
  };
}
```

### 3. StatelessWidget 页面

```dart
return SHOPageAnalyticsBinder(
  pageName: 'SHOStudyHomePage',
  child: Scaffold(...),
);
```

### 4. 调试

Debug 面板 → Analytics 可查看 `page_enter` / `route_push` 等历史记录。

## 已接入示例

- `SHOMusicPlayerPage` — mixin + `track_id` 附加字段
- `SHODownloadListPage` — mixin
- `SHOStudyHomePage` — `SHOPageAnalyticsBinder`
- `SHOStudyArticlePage` — mixin + `article_id`

## 注意事项

1. **Shell Tab**：Tab 切换由 `SHOTabAnalyticsReporter` 在 `SHOMainShell` 的 `onTap` 上报 `tab_switch`；重复点击当前 Tab 时 `is_reselect: true`。
2. **重复事件**：同一导航动作可能同时触发 `route_push`（栈级）与 `page_enter`（单页），语义不同，分析时按需选用。
3. **Dialog / BottomSheet**：若使用独立 Navigator，需在对应 `showDialog` 的 `routeSettings` 或子 Navigator 上另行挂载 Observer（当前仅 root Navigator）。

## 扩展

- 新业务页：mixin 或 Binder 即可，无需改 Reporter。
- 新事件字段：在 `SHOAnalyticsRegistry` 对应事件下增字段，并在 `pageAnalyticsExtra` 传入。
