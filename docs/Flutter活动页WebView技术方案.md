# Flutter 活动页 WebView 框架 — 需求方案与技术实现（SHOO 落地版）

> **版本**：v1.0  
> **日期**：2026-06  
> **状态**：Phase 1 已落地（百宝箱 → WebView活动）  
> **关联**：`SHOO调整后项目框架.md`、`lib/core/platform/hybrid/SHO_HYBRID_BRIDGE.md`

---

## 一、文档目的

本文将「生产级 Flutter WebView 活动页」完整需求，**映射到 SHOO 现有技术栈与基建**，明确：

1. 哪些能力 **可直接复用** 现有代码；
2. 哪些需要 **新增依赖与模块**；
3. 如何按 **分期** 在 SHOO 内落地，而非另起独立工程；
4. 与现有 **S活动（原生混合）**、**营销弹窗活动** 的边界与演进关系。

---

## 二、与 SHOO 现状对照

### 2.1 技术栈契合度

| 需求项 | 目标方案 | SHOO 现状 | 落地结论 |
|--------|----------|-----------|----------|
| 路由 | go_router | ✅ `lib/app/router/hos_router.dart` + 各 feature `router.dart` | **直接沿用** `shoXxxRoutes()` 工厂模式 |
| 状态管理 | Riverpod | ✅ `flutter_riverpod` 全项目 | **直接沿用** Provider / Notifier 分层 |
| 网络 | Dio + 拦截器链 | ✅ `dioProvider` + Auth / Mock / Log | **扩展拦截器**，复用 `getData` 信封解析 |
| WebView | webview_flutter | ❌ 仅 iOS `WKWebView` Demo（`NativeComponentDemos.swift`） | **需新增** `webview_flutter`（或 `flutter_inappwebview`） |
| URL 外跳 | url_launcher | ✅ 已在 `pubspec.yaml` | **直接复用** |
| 分享 | share_plus | ✅ 已集成 | **直接复用** |
| 下载 | DownloadManager | ⚠️ Toolbox 有 `hos_download_controller`（文件下载，非 WebView 资源） | **可抽象共用** 任务模型，WebView 下载走独立 Notifier |
| 原生桥 | MethodChannel | ✅ `com.shoo.shoo/native_bridge` 等 | **扩展协议**，对齐活动页 10 个原生事件 |
| 混合导航 | Hybrid Bridge | ✅ `SHOHybridBridge` + `native_host` | **活动页作为新 Flutter 路由**，与 S活动并行 |
| Mock API | localhost:8888 HttpServer | ⚠️ 现有 `SHOMockInterceptor` + assets JSON | **双轨 Mock**（见 §5.4） |
| 生命周期 | AppLifecycle | ✅ `SHOAppLifecycleBinder` | **扩展监听**，挂 WebView 暂停/恢复 |
| 图片预览 | PhotoView | ❌ 未集成 | **需新增** `photo_view` |
| 截图 | RepaintBoundary | ✅ Flutter 内置 | **可直接实现** |

### 2.2 三类「活动」概念边界（避免混淆）

| 名称 | 位置 | 形态 | 本文范围 |
|------|------|------|----------|
| **营销弹窗活动** | `core/marketing/hos_activity_popup_*` | 首页弹窗 + Dio 拉配置 | 可 **跳转链接** 到 WebView 活动页，不改造弹窗本身 |
| **S活动（混合 Demo）** | `HybridBridge` + `SActivityViewController.swift` | 原生瀑布流 + 唤起 Flutter 路由 | **保留**；WebView 活动页是 **纯 Flutter 方案** 的正式版 |
| **WebView 活动页（本文）** | 新建 `features/activity_webview/` | Flutter WebView + JS Bridge + Mock H5 | **本文实施对象** |

**演进建议**：百宝箱入口由「S活动（iOS 原生 Demo）」旁新增「WebView 活动页」，长期可让 S活动 内嵌跳转 `/activity`。

---

## 三、目标架构（SHOO 目录映射）

按 `SHOO调整后项目框架.md`，**不采用独立 `lib/router/`、`lib/providers/` 平铺**，而是新建垂直 Feature：

```
lib/features/activity_webview/
├── router.dart                              # shoActivityWebviewRoutes()
├── domain/
│   ├── entities/
│   │   ├── hos_activity_config.dart         # 活动配置 + modules/images/coupons
│   │   ├── hos_url_decision.dart            # webview | external | payment
│   │   ├── hos_download_task.dart           # WebView 下载任务（可与 toolbox 模型对齐）
│   │   ├── hos_offline_package.dart
│   │   ├── hos_webview_metrics.dart
│   │   └── hos_cookie_config.dart
│   └── repositories/                        # 可选：activity_repository 抽象
│       └── hos_activity_repository.dart
├── data/
│   ├── datasources/
│   │   ├── remote/
│   │   │   └── hos_activity_remote_ds.dart  # Dio API
│   │   └── local/
│   │       ├── hos_activity_mock_server.dart # HttpServer :8888（可选）
│   │       └── hos_offline_package_storage.dart
│   └── repositories/
│       └── hos_activity_repository_impl.dart
└── presentation/
    ├── pages/
    │   ├── hos_activity_home_page.dart      # 入口 Home（或合并到 toolbox）
    │   ├── hos_activity_page.dart           # 主活动 WebView
    │   ├── hos_webview_page.dart            # 通用 WebView
    │   └── hos_image_preview_page.dart
    ├── widgets/
    │   ├── webview/                         # 容器壳、进度条、错误页等
    │   └── dialogs/                         # 8 个弹窗
    └── state/
        ├── hos_activity_config_provider.dart
        ├── hos_mock_server_provider.dart
        ├── hos_webview_loading_provider.dart
        ├── hos_js_bridge_provider.dart
        ├── hos_url_router_provider.dart
        ├── hos_payment_provider.dart
        ├── hos_share_provider.dart
        ├── hos_image_preview_provider.dart
        ├── hos_dialog_provider.dart
        ├── hos_download_manager_provider.dart
        ├── hos_offline_package_provider.dart
        ├── hos_webview_performance_provider.dart
        ├── hos_white_screen_provider.dart
        ├── hos_webview_pool_provider.dart
        ├── hos_cookie_manager_provider.dart
        ├── hos_cache_manager_provider.dart
        └── hos_webview_controller_provider.dart

lib/core/platform/webview/                   # ★ 跨 Feature 可复用基建（推荐）
├── hos_webview_security.dart
├── hos_url_navigator.dart
├── hos_url_router_service.dart
├── hos_payment_handler.dart
├── hos_js_bridge_service.dart
├── hos_cookie_manager.dart
├── hos_webview_config_factory.dart
└── hos_webview_pool.dart

lib/app/router/
├── hos_routes.dart                          # 追加 SHOAppRoutes.activity*
└── hos_router.dart                          # 注册 shoActivityWebviewRoutes()
```

**命名约定**：延续 `hos_` 文件前缀、`SHO` 类前缀，与全项目一致。

---

## 四、路由设计（go_router）

### 4.1 路由表

在 `SHOAppRoutes` 中新增：

| 路径 | 页面 | 参数 |
|------|------|------|
| `/activity` | `SHOActivityPage` | — |
| `/activity/webview` | `SHOWebViewPage` | `url`, `title?` |
| `/activity/image-preview` | `SHOImagePreviewPage` | `images`（JSON/逗号分隔）, `index` |
| `/activity/payment` | redirect | `url` → URLRouter 分发 |
| `/activity/external` | redirect | `url`（编码）→ url_launcher |

### 4.2 Redirect 中间件

在 `shoActivityWebviewRoutes()` 内配置 `GoRoute` + `redirect`：

```dart
// 伪代码 — 与 hos_router_notifier 守卫链独立
GoRoute(
  path: '/activity/payment',
  redirect: (context, state) {
    final url = state.uri.queryParameters['url'];
    if (url == null) return SHOAppRoutes.notFound;
  },
  builder: (_, state) {
    // redirect 返回 null 时由 PaymentHandler 处理，不渲染页面
    return const SizedBox.shrink();
  },
),
```

**推荐实现**：payment/external 使用 `redirect` 回调内直接调用 `SHOURLNavigator.open()`，返回 `null` 阻止入栈；或返回 `/activity/webview?url=...` 完成分发。

### 4.3 与现有 Router 集成

```dart
// hos_router.dart
...shoActivityWebviewRoutes(rootKey: rootNavigatorKey),
```

入口挂载：

- **百宝箱**：`SHOToolboxPage` 新增「WebView 活动」→ `context.push(SHOAppRoutes.activity)`
- **营销弹窗**：`link` 字段支持 `shoo://activity` 或 `https://m.shoo.com/activity/...` → DeepLink / URLRouter

---

## 五、网络层与 Mock 方案

### 5.1 Dio 配置（复用 + 扩展）

**复用** `dioProvider`（`lib/core/network/hos_dio_client.dart`）。

活动页专用 API 建议 **不新建 Dio 实例**，通过 `Provider` 注入：

```dart
final activityApiProvider = Provider<SHOActivityApi>((ref) {
  return SHOActivityApi(ref.watch(dioProvider));
});
```

### 5.2 拦截器链映射

| 需求拦截器 | SHOO 对应 | 动作 |
|------------|-----------|------|
| LogInterceptor | `SHONetworkLogInterceptor` / debug `LogInterceptor` | 已有 |
| AuthInterceptor | `SHOAuthInterceptor` | 已有，Token 同步 Cookie |
| CacheInterceptor | 无 | **新增** `SHOCacheInterceptor`（活动 API 可缓存） |
| RetryInterceptor | 无 | **新增** `SHORetryInterceptor`（max 2） |
| ErrorInterceptor | `hos_error_mapper.dart` | **包装** 为统一 `DioException` → UI 错误码 |

### 5.3 ApiService 接口

| 方法 | 路径 | Mock 数据 |
|------|------|-----------|
| `fetchActivityConfig()` | `GET /api/activity/data` | 需求 JSON |
| `checkUserStatus()` | `GET /api/user/check` | 需求 JSON |
| `downloadImage(url)` | Dio `GET` bytes | 网络图 |
| `fetchURLRouterConfig()` | `GET /api/config/url-rules` | 可选动态规则 |

**信封格式**：与现有 Mock 一致 `{code, data, message}`，`getData` 解析。

### 5.4 Mock 双轨策略（关键决策）

| 方案 | 说明 | 优点 | 缺点 | 建议 |
|------|------|------|------|------|
| **A. SHOMockInterceptor** | 在 `SHOMockRouteRegistry` 注册 `/api/activity/*`，H5 放 `assets/activity/index.html` | 与全 App Mock 一致；无端口冲突；CI 友好 | 无法用真实 HttpServer 测 H5 导航 | **Phase 1 默认** |
| **B. dart:io HttpServer :8888** | 需求原文方案 | 完整还原 H5 + API 同源；可测 Cookie/离线包 | 真机需改 IP；与 Mock 双环境；Web 不支持 | **Phase 2 调试开关** |

**落地建议**：

1. `mockServerProvider`：`FutureProvider`，Debug 模式且 `useLocalActivityServer=true` 时启动 HttpServer；
2. 默认走 **方案 A**，`activityConfigProvider` 读 Mock JSON；
3. `SHOActivityPage` WebView 加载 `file:///assets` 或 `http://10.0.2.2:8888`（Android 模拟器）/ `http://127.0.0.1:8888`（iOS 模拟器）。

---

## 六、双引擎 WebView + URL 智能分发

### 6.1 新增依赖

```yaml
dependencies:
  webview_flutter: ^4.x          # 首选，官方维护
  webview_flutter_wkwebview: ^3.x # iOS 增强（按需）
  photo_view: ^0.15.x            # 图片预览
  # 备选：flutter_inappwebview — 需 JS Bridge、拦截、Cookie 更强时评估
```

### 6.2 URLRouter（`core/platform/webview/`）

```dart
enum SHOURLTarget { inAppWebView, externalBrowser, payment }

class SHOURLRouterService {
  SHOURLDecision resolve(String url, {SHOURLRouterConfig? remote});
}
```

**规则优先级**（与需求一致）：

1. 支付域名（微信/支付宝/银行）→ `payment` / `externalBrowser`
2. OAuth / 应用商店 / 短链 → `externalBrowser`
3. 白名单（`shoo.com`、`localhost`、`127.0.0.1`）→ `inAppWebView`
4. 兜底 → `externalBrowser`（安全降级）

### 6.3 URLNavigator 统一入口

```dart
class SHOURLNavigator {
  static Future<void> open(BuildContext context, WidgetRef ref, String url);
  static Future<void> openInWebView(BuildContext context, String url, {String? title});
  static Future<void> openInExternalBrowser(String url);
}
```

**与 go_router 关系**：`openInWebView` 内部 `context.push(SHOAppRoutes.activityWebview, queryParameters: {...})`。

### 6.4 PaymentHandler

复用 `url_launcher` + 可选 URL Scheme：

```
weixin:// → canLaunchUrl → launchUrl
失败 → https://wx.tenpay.com/... 系统浏览器
```

状态写入 `paymentProvider`：`idle | launching | success | cancelled | failed`。

### 6.5 WebView 安全（`hos_webview_security.dart`）

| 项 | 实现 |
|----|------|
| 域名白名单 | `NavigationDelegate.onNavigationRequest` 拦截 |
| Scheme 黑名单 | `weixin://`、`alipay://`、`tel://` 等转交 URLRouter |
| SSL | Debug 允许 localhost 自签名；Release `onReceivedSslError` 拒绝 |
| 用户代理 | 可选追加 App 标识，便于 H5 识别 |

---

## 七、WebView 封装功能 — 分期落地矩阵

| 功能 | 优先级 | Phase | 技术要点 | SHOO 复用 |
|------|--------|-------|----------|-----------|
| 统一容器壳 `webview_container` | P0 | 1 | Stack：ProgressBar + RefreshIndicator + WebView + Overlay | `hos_spacing`、主题 |
| 加载状态 `webviewLoadingProvider` | P0 | 1 | Notifier：progress/error/retry | — |
| 进度条 `webview_progress_bar` | P0 | 1 | 渐隐动画、颜色分段 | — |
| 错误页 + 重试 | P0 | 1 | 按 errorCode 映射文案 | `hos_error_mapper` 错误码 |
| JS Bridge 基础 | P0 | 1 | `addJavaScriptChannel` + 注入脚本 | 参考 `native_message` JSON 协议 |
| URL 拦截 + 外跳 | P0 | 1 | NavigationDelegate | `url_launcher` |
| 返回键 PopScope | P0 | 1 | `canGoBack` → `goBack` | — |
| Cookie 同步 | P1 | 2 | `WebViewCookieManager` + Auth Token | `SHOAuthInterceptor` token |
| 下拉刷新 | P1 | 2 | `RefreshIndicator` + reload | `hos_toast` |
| 8 个 Flutter 弹窗 | P1 | 2 | `dialogProvider` + Overlay | 可参考 `hos_confirm_card_dialog` |
| 10 个原生事件 | P1 | 2 | 扩展 `SHONativeBridge` | 已有 Channel 基建 |
| 图片点击预览 | P1 | 2 | JS → `imagePreviewProvider` → PhotoView | 新增 `photo_view` |
| 截图分享 | P1 | 2 | RepaintBoundary + `share_plus` | Toolbox 分享模式 |
| 长按菜单 | P2 | 3 | JS 长按 + `webview_context_menu` | Clipboard、`share_plus` |
| 下载管理器 | P2 | 3 | Dio 下载 + 通知 UI | 对齐 `hos_download_task` 模型 |
| WebView 池化 | P2 | 3 | 预创建 2–3 控制器 | 内存敏感，可配置关闭 |
| 缓存策略 | P2 | 3 | `clearCache` / mode 枚举 | — |
| 离线包 | P3 | 4 | `archive` 解压 + ResourceInterceptor | 已有 `archive` 依赖 |
| 白屏检测 | P3 | 4 | 截图像素分析 | 平台差异大，iOS 优先 |
| 性能监控 | P3 | 4 | JS Performance API + 上报 | `core/analytics` |
| 视频全屏 | P3 | 4 | JS Bridge + 横屏 | `fullscreen_manager` |
| 生命周期联动 | P1 | 2 | paused/resumed | `SHOAppLifecycleBinder` |

---

## 八、JS Bridge 协议（与 H5 对齐）

### 8.1 Channel 命名

| 方向 | 机制 |
|------|------|
| H5 → Flutter | `JavascriptChannel('FlutterBridge')` |
| H5 → Native | Flutter 中转 → `SHONativeBridge.invoke` |
| Flutter → H5 | `controller.runJavaScript('window.onFlutterMessage(...)')` |

### 8.2 消息格式

```json
{
  "type": "flutter" | "native" | "preview" | "longPress" | "pageReady",
  "action": "showCouponDialog",
  "params": { "amount": 100 },
  "callbackId": "optional"
}
```

### 8.3 与现有 Hybrid Bridge 关系

- **不替换** `native_host` / `native_bridge`；
- 活动页 JS `onNativeEvent` → Dart `SHOActivityNativeDispatcher` → 按 action 映射到：
  - 已有：`SHONativeBridge`（ping、设备信息）
  - 新增：`camera`、`album`、`location` 等 Channel（`com.shoo.shoo/activity_*` 或统一 `activity/invoke`）

**原生未实现**：`PlatformException` → `context.showToast('xxx功能暂不可用')`（复用 `hos_toast`）。

---

## 九、Provider 清单与职责

### 9.1 全局 / Core 级

| Provider | 类型 | 文件 | 说明 |
|----------|------|------|------|
| `urlRouterProvider` | Provider | `hos_url_router_provider.dart` | 规则单例 |
| `cookieManagerProvider` | Provider | `hos_cookie_manager_provider.dart` | Cookie CRUD |
| `cacheManagerProvider` | Provider | `hos_cache_manager_provider.dart` | WebView 缓存模式 |
| `webviewPoolProvider` | Provider | `hos_webview_pool_provider.dart` | 实例池 |
| `appLifecycleProvider` | Provider | 扩展 `hos_app_lifecycle` | WebView 暂停策略 |

### 9.2 Feature 级

| Provider | 类型 | 说明 |
|----------|------|------|
| `mockServerProvider` | FutureProvider | 可选启动 :8888 |
| `activityConfigProvider` | FutureProvider | 活动配置 |
| `webViewControllerProvider` | Provider.family | 按 routeId 持有 Controller |
| `webviewLoadingProvider` | NotifierProvider | 加载态 |
| `jsBridgeProvider` | NotifierProvider | Bridge 消息队列 |
| `imagePreviewProvider` | NotifierProvider | 预览列表 + index |
| `shareProvider` | NotifierProvider | 截图 + 分享渠道 |
| `paymentProvider` | NotifierProvider | 支付状态机 |
| `dialogProvider` | StateProvider\<String?\> | 当前弹窗 kind |
| `downloadManagerProvider` | NotifierProvider | WebView 下载任务 |
| `offlinePackageProvider` | FutureProvider | 离线包版本 |
| `webviewPerformanceProvider` | NotifierProvider | 性能指标 |
| `whiteScreenDetectorProvider` | NotifierProvider | 白屏检测 |

**注意**：`webViewControllerProvider` 建议 `autoDispose` + `family(url)`，避免泄漏。

---

## 十、页面与 UI 实现要点

### 10.1 SHOActivityPage

```
AppBar: 标题(activityConfig.title) + 分享按钮(shareProvider)
Body: SHOWebViewContainer(initialUrl: mockH5Url)
Overlay: DialogHost(dialogProvider) — 监听并展示 8 类弹窗
```

### 10.2 SHOWebViewContainer 结构

与需求一致，自上而下：

1. `SHOWebViewProgressBar` ← `webviewLoadingProvider.progress`
2. `RefreshIndicator` → `controller.reload()`
3. `Stack`：ErrorWidget | WebViewWidget | LoadingOverlay | WhiteScreenOverlay

### 10.3 弹窗（8 个）

| kind | 组件 | 触发 |
|------|------|------|
| coupon | `SHOCouponDialog` | JS `showCouponDialog` |
| lottery | `SHOLotteryDialog` | JS `showLotteryDialog` |
| rules | `SHORulesDialog` | JS `showRulesDialog` |
| prize | `SHOPrizeDialog` | 抽奖结束 |
| countdown | `SHOCountdownDialog` | 配置 `endTime` |
| address | `SHOAddressPicker` | JS / 按钮 |
| loading | `SHOWebViewLoadingWidget` | 全屏遮罩 |
| toast | `SHOToastWidget` | 独立 Overlay（已有 `hos_toast` 可复用） |

### 10.4 SHOImagePreviewPage

- 依赖 `photo_view`
- 路由参数：`images` JSON 数组 + `index`
- 底部：保存（`image_download_service`）、分享、查看原图

### 10.5 截图分享

- `RepaintBoundary` 包裹 WebView 区域（**注意**：Platform View 截图在部分 Android 版本有限制，降级为整页截图或原生截图 API）
- `SHOShareDialog`：微信/朋友圈/复制链接/保存图片

---

## 十一、原生事件映射（10 个）

统一 Dart 门面 `SHOActivityNativeDispatcher`：

| # | 事件 | 实现路径 | Phase |
|---|------|----------|-------|
| 1 | openCamera | `image_picker` 先落地；原生 Channel 后续 | 2 |
| 2 | openAlbum | `image_picker` multi | 2 |
| 3 | openLocation | 扩展 NativeBridge / 地图 Demo | 2 |
| 4 | callPhone | `url_launcher` `tel:` | 1 |
| 5 | shareToWechat | NativeBridge + 降级 `share_plus` | 2 |
| 6 | openPayment | URLRouter | 1 |
| 7 | biometricAuth | NativeBridge 桩 | 3 |
| 8 | scanQRCode | NativeBridge 桩 | 3 |
| 9 | saveContact | NativeBridge 桩 | 3 |
| 10 | vibrate | `HapticFeedback` / NativeBridge | 2 |

**Channel 命名建议**：统一 `com.shoo.shoo/activity` + method 分发，避免 10 个 Channel 碎片化。

---

## 十二、分期实施计划

### Phase 1 — 可演示 MVP（约 1–2 周）

**目标**：百宝箱进入 → 加载 Mock H5 → JS 调 Flutter 弹窗 → 支付链接触发外跳。

- [ ] 新增 `webview_flutter`、`photo_view` 依赖
- [ ] 创建 `features/activity_webview/` 骨架 + `router.dart`
- [ ] Mock：`SHOMockRouteRegistry` 注册 activity API + `assets/activity/index.html`
- [ ] `SHOWebViewContainer` + Loading + Error + Progress
- [ ] `SHOURLRouter` + `SHOURLNavigator` + payment redirect
- [ ] JS Bridge 基础（`onFlutterEvent`、`pageReady`）
- [ ] `dialogProvider` + coupon/rules 弹窗（至少 2 个）
- [ ] 百宝箱入口 + 路由常量
- [ ] 单元测试：URLRouter 规则表

**验收**：模拟器打开活动页，点击「领优惠券」弹窗，点击「微信支付测试」跳转系统浏览器。

### Phase 2 — 生产可用（约 2–3 周）

- [ ] 全部 8 弹窗 + 图片预览页
- [ ] 10 原生事件（Phase 1/2 项）
- [ ] Cookie 与登录态同步
- [ ] 下拉刷新、PopScope 返回栈
- [ ] 截图分享
- [ ] 生命周期：后台暂停 JS/媒体
- [ ] 可选 HttpServer Mock 开关
- [ ] i18n `app_zh.arb` / `app_en.arb`

### Phase 3 — 增强体验

- [ ] 下载管理器 + 通知 UI
- [ ] 长按菜单
- [ ] WebView 池化 + 预加载
- [ ] 缓存策略 UI（设置页）

### Phase 4 — 高级能力

- [ ] 离线包 + ResourceInterceptor
- [ ] 白屏检测与恢复
- [ ] 性能监控 + 上报
- [ ] 视频全屏
- [ ] 动态 URL 规则 API

---

## 十三、测试策略

| 类型 | 范围 |
|------|------|
| 单元测试 | `SHOURLRouterService` 规则、`clampListIndex` 类工具、JSON 解析 |
| Widget 测试 | ProgressBar、ErrorWidget、Dialog 显隐 |
| 集成测试 | `activityConfigProvider` + Mock 拦截器 |
| 手动 | 真机支付外跳、Cookie、截图、Android Platform View 截图降级 |

测试目录：`test/unit/features/activity_webview/`、`test/integration/activity_webview_test.dart`。

---

## 十四、风险与对策

| 风险 | 影响 | 对策 |
|------|------|------|
| Platform View 截图不完整 | 分享图空白 | 降级 HTML2Canvas（H5 侧）或原生截图 |
| localhost Mock 真机访问 | 页面打不开 | 默认 assets Mock；Debug 配置局域网 IP |
| webview_flutter 与现有 WKWebView Demo 重复 | 维护两套 | Demo 保留；活动页统一 Flutter WebView |
| JS Bridge 安全 | XSS 调原生 | 白名单 action、参数校验、域名限制 |
| WebView 池化内存 | OOM | 默认关闭池化，仅高端机开启 |
| 离线包体积 | 包体增大 | Phase 4 可选；Wi-Fi 下载 |

---

## 十五、与需求原文差异说明（刻意裁剪）

| 需求原文 | SHOO 落地调整 | 原因 |
|----------|---------------|------|
| 独立工程 `lib/router/`、`lib/providers/` | Feature + `core/platform/webview` | 符合 SHOO 目标框架 |
| 固定 `localhost:8888` | Mock 拦截器为主 | 与全 App Mock 一致、CI 友好 |
| `com.app/xxx` Channel | `com.shoo.shoo/activity` | 与现有 Channel 命名统一 |
| 独立 `HomePage` at `/` | 百宝箱 / 营销弹窗入口 | SHOO 已有主 Tab 壳 |
| 全量一次交付 | 四期分期 | 控制风险、可演示优先 |

---

## 十六、评审检查清单

- [ ] 产品确认：百宝箱入口 vs 首页弹窗跳转 vs 独立 Tab
- [ ] 安全确认：URL 兜底外跳策略、支付域名清单
- [ ] 技术选型：`webview_flutter` vs `flutter_inappwebview` 终选
- [ ] Mock 方案：Phase 1 是否仅 assets（建议 Yes）
- [ ] 原生投入：Phase 2 哪些事件必须真原生（微信分享、生物识别）
- [ ] 与 S活动关系：并行维护 or 逐步替换

---

## 十七、参考文件（SHOO 仓库内）

| 主题 | 路径 |
|------|------|
| 目标框架 | `docs/SHOO调整后项目框架.md` |
| 路由 | `lib/app/router/hos_router.dart`、`hos_routes.dart` |
| Dio | `lib/core/network/hos_dio_client.dart` |
| Mock | `lib/core/network/hos_mock_interceptor.dart` |
| Hybrid Bridge | `lib/core/platform/hybrid/SHO_HYBRID_BRIDGE.md` |
| Native Bridge | `lib/core/platform/bridge/hos_native_bridge.dart` |
| 营销弹窗活动 | `lib/core/marketing/hos_activity_popup_service.dart` |
| 百宝箱 | `lib/features/toolbox/presentation/pages/hos_toolbox_page.dart` |
| iOS WKWebView Demo | `ios/Runner/NativeComponentDemos.swift` |

---

**下一步**：评审通过后，从 **Phase 1** 创建 `features/activity_webview/` 骨架并注册路由，提交首个可运行 PR。
