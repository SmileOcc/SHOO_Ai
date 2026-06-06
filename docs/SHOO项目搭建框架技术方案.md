# SHOO 项目搭建框架技术方案

> **版本**：v1.1  
> **日期**：2026-06-06  
> **项目版本**：SHOO v0.4.0+1（Phase 3 + UX/原生/路由增强）  
> **定位**：Shein 风格 Flutter 电商客户端 — Clean Architecture + Mock 可演示 + 可扩展生产化

---

## 一、方案总览

### 1.1 架构分层

```
┌─────────────────────────────────────────────────────────┐
│  app/          入口、bootstrap、MaterialApp.router、Shell │
├─────────────────────────────────────────────────────────┤
│  features/     按业务垂直切分（auth/cart/order/...）     │
│    domain/     实体、纯函数、Repository 接口             │
│    data/       API、Repository 实现                      │
│    presentation/ 页面、Controller、Provider              │
├─────────────────────────────────────────────────────────┤
│  core/         跨模块基建（网络、主题、路由常量、调试）   │
├─────────────────────────────────────────────────────────┤
│  assets/mock/  Mock JSON 单一数据源                      │
│  server/       可选本地 HTTP Mock API（Node.js）        │
└─────────────────────────────────────────────────────────┘
```

### 1.2 核心设计原则

| 原则 | 实践 |
|------|------|
| Feature-First | 业务代码按 `features/{name}/` 隔离，避免巨型 `lib/` |
| 单向依赖 | `features → core`，`core` 不依赖 `features`（网络 Token 通过 `authTokenProvider` 解环） |
| 声明式路由 | 路径常量在 `hos_routes.dart`；各 feature 导出 `router.dart`，由 `hos_router.dart` 组装 |
| Mock 先行 | 内置 Dio 拦截器 + 可选 HTTP Server，前后端并行 |
| 可测试 | Domain 纯函数（如价格计算）、路由常量、模型反序列化均有单测 |

---

## 二、三方组件清单

### 2.1 运行时依赖

| 组件 | 版本约束 | 基本功能 | 在本项目中的用途 |
|------|----------|----------|------------------|
| **flutter_riverpod** | ^2.6 | 编译期安全的依赖注入与状态管理 | Session、购物车、订单列表、主题/语言、Dio 实例、路由 Notifier |
| **go_router** | ^14.8 | 声明式路由，支持深链、嵌套、Shell | 全站路由表、Tab Shell、登录守卫、`context.push/go` |
| **dio** | ^5.8 | HTTP 客户端 + 拦截器链 | REST API、Mock 拦截、Auth 头注入、统一错误映射 |
| **freezed** + **json_serializable** | ^2.5 / ^6.9 | 不可变数据类 + JSON 代码生成 | 订单、商品、优惠券、售后等领域模型 |
| **shared_preferences** | ^2.5 | 轻量 KV 本地存储 | 主题模式、语言、购物车快照、调试配置 |
| **flutter_secure_storage** | ^9.2 | 系统级加密存储 | Token 安全持久化，不明文落盘 |
| **cached_network_image** | ^3.4 | 网络图片 + 磁盘缓存 | 商品图、Banner、活动弹窗图 |
| **flutter_cache_manager** | ^3.4 | 通用文件缓存管理 | 与 `SHOImageCacheManager` 配合，图片索引与文件落盘 |
| **path_provider** | ^2.1 | 获取应用沙盒目录 | 图片缓存目录（Application Support） |
| **connectivity_plus** | ^6.1 | 网络连接状态监听 | 顶部离线提示条 `SHOAppShell` |
| **permission_handler** | ^11.4 | 跨平台权限申请 | 相机/相册/通知/定位等统一封装 |
| **intl** | ^0.20 | 国际化格式化 | 价格、日期与 `flutter gen-l10n` 配合 |
| **flutter_localizations** | SDK | Material/Cupertino 组件本地化 | 与 ARB 双语资源联动 |
| **package_info_plus** | ^8.3 | 读取 App 版本信息 | 版本更新对比、`versionLabel` 展示 |
| **url_launcher** | ^6.3 | 打开外部 URL | 版本更新跳转商店、外链 |
| **share_plus** | ^10.1 | 系统分享面板 | 商品卡片图 + 链接分享 |
| **image_picker** | ^1.1 | 相机/相册选图 | 评价晒图、售后凭证上传 |
| **app_links** | ^6.4 | 深链 / Universal Link 监听 | 外部 URL → `go_router` 导航 |
| **cupertino_icons** | ^1.0 | iOS 风格图标 | 辅助图标资源 |

### 2.2 开发期依赖

| 组件 | 用途 |
|------|------|
| **build_runner** | 触发 freezed / json_serializable 代码生成 |
| **freezed** / **json_serializable** | 模型代码生成器 |
| **flutter_lints** | 静态分析规则 |
| **flutter_test** | 单元测试、Widget 冒烟测试 |

### 2.3 未引入但可评估的组件（Phase 4+）

| 组件 | 场景 |
|------|------|
| **sentry_flutter** | 崩溃与性能监控 |
| **firebase_analytics** / **友盟** | 埋点统计 |
| **pigeon** | 大规模原生 Channel 的类型安全代码生成 |
| **go_router_builder** / **auto_route** | 路由代码生成、强类型传参 |
| **hive** / **isar** | 更大规模本地结构化数据库（搜索历史已用 SharedPreferences） |
| **flutter_stripe** / 微信/支付宝 SDK | 真支付 |

---

## 三、路由方案详解

### 3.1 选型：go_router + StatefulShellRoute

本项目采用 **go_router** 作为唯一路由方案，配合 **Riverpod `SHORouterNotifier`** 实现守卫刷新。

#### 3.1.1 与主流方案对比

| 方案 | 优点 | 缺点 | 适用场景 |
|------|------|------|----------|
| **Navigator 1.0**（`Navigator.push`） | 简单直观 | 命令式、难维护、深链弱、全局守卫困难 | 小型 Demo |
| **Navigator 2.0 手写** | 完全可控 | 模板代码多、易出错、团队成本高 | 极度定制 |
| **go_router** ✅ | 官方推荐、声明式、深链友好、ShellRoute 原生支持、与 `MaterialApp.router` 一体 | 复杂嵌套时学习曲线；`extra` 传参无类型约束；大表需拆分 | **中大型 App、电商 Tab 结构** |
| **auto_route** | 注解生成路由、强类型参数、`@RoutePage` | 代码生成依赖、构建慢一步、生成文件多 | 路由数量极大、强类型诉求强 |
| **beamer** | 声明式、灵活 delegate | 社区小于 go_router、文档相对少 | 多 Beam 并行导航 |
| **flutter_modular** | 模块化 DI + 路由一体 | 与 Riverpod 体系重叠、迁移成本高 | GetIt/Modular 技术栈团队 |

#### 3.1.2 选择 go_router 的原因（结合 SHOO）

1. **四 Tab + 大量全屏二级页**：`StatefulShellRoute.indexedStack` 可让首页/分类/购物袋/我的 **各自保留导航栈**，切 Tab 不丢状态；商品详情、结算等通过 `parentNavigatorKey: _rootNavigatorKey` 盖住 Tab，符合电商交互。
2. **登录守卫与深链**：`redirect` + `refreshListenable` 可在 Session 变化时自动重算路由，支持 `?redirect=` 回跳。
3. **路径即文档**：`/orders/:id/logistics`、`/product/:id/reviews` 清晰可读，利于 Mock Server、测试与运营配置深链。
4. **与 Flutter 生态对齐**：`MaterialApp.router(routerConfig:)` 是官方推荐入口，后续接入 Web/桌面改动小。
5. **团队成本**：无需额外代码生成管线（相对 auto_route），与现有 Riverpod 架构自然融合。

#### 3.1.3 本方案的不足与应对

| 不足 | 现状 | 建议补全 |
|------|------|----------|
| 路由表集中在一个文件，变大后难维护 | ✅ 已按 feature 拆分 `router.dart`，`hos_router.dart` 仅组装 | 后续可引入 `go_router_builder` 强类型参数 |
| Query 传参无编译期检查 | `?select=1` 靠字符串约定 | 引入 `go_router_builder` 或封装 Typed Go helpers |
| 复杂对象不宜放 URL | ✅ 结算选地址/券已用 `await context.push<T>()` + Provider 持久化 | 更多选择器页面可复用同一模式 |
| 全站 404 未单独配置 | ✅ `errorBuilder` → `SHONotFoundPage` | — |

---

### 3.2 路由结构图

```
/splash                          → 启动页
/onboarding                      → 引导页
/login?redirect=                 → 登录（守卫跳转）
/register

StatefulShellRoute (Tab)
├── /          → 首页 (branch: shellHome)
├── /category  → 分类 (branch: shellCategory)
├── /cart      → 购物袋 (branch: shellCart)
└── /profile   → 我的 (branch: shellProfile)

Root 全屏栈 (parentNavigatorKey: root)
├── /search?q=
├── /product/:id
│   └── reviews
├── /checkout
├── /payment/:orderId
├── /coupons?select=1
├── /addresses?select=1
├── /orders?status=
│   └── :id
│       └── logistics
├── /after-sales
│   └── apply/:orderId
├── /settings, /messages
└── /debug
    ├── update
    ├── activity
    └── native/:id
```

**Navigator Key 分工**（`app/router/hos_router_keys.dart`）

| Key | 作用 |
|-----|------|
| `rootNavigatorKey` | 全屏页、登录、结算、详情 |
| `shellNavigatorHomeKey` 等 4 个 | 各 Tab 独立栈 |

**模块化路由文件**

| 文件 | 导出 |
|------|------|
| `features/splash/router.dart` | Splash、Onboarding |
| `features/auth/router.dart` | Login、Register |
| `features/order/router.dart` | 订单列表/详情/物流 |
| `features/product/router.dart` | 商详、评价 |
| `features/checkout/router.dart` | 结算、支付 |
| `features/address/router.dart` | 地址列表（含 `?select=1`） |
| `features/coupon/router.dart` | 优惠券列表（含 `?select=1`） |
| `features/after_sale/router.dart` | 售后列表/申请 |
| `features/search/router.dart` | 搜索 |
| `core/debug/router.dart` | 调试面板及子模块 |
| `app/router/hos_shell_routes.dart` | Tab Shell、Settings、Messages |

---

### 3.3 路由守卫（拦截）

实现位置：`lib/app/router/hos_router_notifier.dart`

```dart
GoRouter(
  refreshListenable: notifier,   // Session 变化 → 重新 redirect
  redirect: notifier.redirect,
)
```

**当前守卫规则**

| 条件 | 行为 |
|------|------|
| `session.isRestoring == true` | 不拦截（避免启动闪跳登录页） |
| 访问 `/debug*` 且非 Debug 包 | 重定向到 `/` |
| 未登录访问 `protectedRoutes` | 跳转 `/login?redirect={当前完整 URI}` |
| 已登录访问 `/login` 或 `/register` | 重定向到 `/profile` |

**受保护路由**（`hos_routes.dart`）：`settings`、`messages`、`checkout`

**可补全的守卫能力**

- [ ] 角色/权限守卫（VIP、商家、地区限制）
- [ ] 业务守卫：购物车为空时禁止 `/checkout`
- [ ] 版本强更守卫：强制跳转更新页
- [ ] 维护模式守卫：全站降级页
- [ ] 路由级埋点 `NavigatorObserver` / go_router `onException`

---

### 3.4 传参方案

#### 3.4.1 路径参数（Path Parameters）

适用于 **资源 ID**，RESTful 风格，可分享、可深链。

```dart
// 定义
static String product(String id) => '/product/$id';

// 跳转
context.push(SHOAppRoutes.product(product.id));

// 接收
SHOProductDetailPage(productId: state.pathParameters['id']!)
```

**本项目使用**：`productId`、`orderId`、售后 `orderId`、调试 `native/:id`

#### 3.4.2 查询参数（Query Parameters）

适用于 **筛选、模式开关**，可选、可组合。

| 路由 | 参数 | 含义 |
|------|------|------|
| `/search` | `q` | 初始搜索词 |
| `/orders` | `status` | 订单状态筛选 |
| `/coupons` | `select=1` | 选择模式（结算页选券） |
| `/addresses` | `select=1` | 选择模式（结算页选地址） |
| `/login` | `redirect` | 登录后回跳 URI（需 `Uri.encodeComponent`） |

```dart
// 登录回跳示例（checkout_page）
context.push('${SHOAppRoutes.login}?redirect=${Uri.encodeComponent(SHOAppRoutes.checkout)}');
```

#### 3.4.3 状态传参（Riverpod / 内存）

适用于 **复杂对象、临时 UI 状态**，不宜序列化进 URL。

| 状态 | Provider | 场景 |
|------|----------|------|
| 选中优惠券 | `selectedCouponIdProvider` | 结算页 ↔ 优惠券列表 |
| 选中地址 | `selectedAddressProvider` | 结算页 ↔ 地址列表 |
| 购物车 | `cartProvider` | 全站角标、结算 |

**注意**：页面刷新或进程被杀后丢失，电商里可接受；若要可恢复需落盘或改 query。

#### 3.4.4 extra 传参（尚未使用，建议补全）

go_router 支持 `context.push('/path', extra: object)`，适合中等复杂度对象。

**建议**：封装 `SHORouteExtra` sealed class，避免 `dynamic` 强转。

---

### 3.5 跳转 API 使用规范

| API | 语义 | 本项目典型场景 |
|-----|------|----------------|
| **`context.push()`** | 压栈，可 `pop` 返回 | 商品详情、订单详情、搜索、选券/选地址 |
| **`context.go()`** | 替换路由栈到目标路径 | 登录成功回跳、支付成功去订单/首页、售后提交完成 |
| **`context.pop()`** | 弹出当前页 | 选券/选地址确认后返回结算页 |
| **`context.replace()`** | 替换当前页（栈深度不变） | ✅ Splash → Onboarding/Home、Onboarding → Home（无回退） |
| **`navigationShell.goBranch()`** | 切换 Tab 分支 | 底部导航切换 |

**支付成功页**（`go` 清理栈，防止返回到收银台）：

```dart
context.go(SHOAppRoutes.order(widget.orderId));
context.go(SHOAppRoutes.home);
```

**选券/选地址模式**（`push<T>` + `pop(result)`，Provider 同步持久化）：

```dart
// 结算页
final address = await context.push<SHOAddress>(SHOAppRoutes.addressesSelect);
final couponId = await context.push<String>(SHOAppRoutes.couponsSelect);
// couponId == '' 表示不使用优惠券；null 表示用户取消（返回键）

// 地址列表（selectMode）
context.pop<SHOAddress>(address);

// 优惠券列表（selectMode）
context.pop<String>(coupon.id);  // 或 pop('') 表示不使用
```

---

### 3.6 返回与结果传递

| 模式 | 实现 | 优点 | 缺点 |
|------|------|------|------|
| **Provider 共享** | 选券/地址写 Provider 并持久化（地址） | 跨页面、进程内可恢复 | 与页面返回值并存时需约定优先级 |
| **`pop(result)`** ✅ 选择器主模式 | `await context.push<T>()` | 显式、可区分取消 vs 清空 | 需 async 跳转 |
| **URL query 回写** | `pop` 前 `go` 带 query | 可深链 | URL 变丑，状态暴露 |

结算页策略：优先使用 `push` 返回值更新本地状态，同时列表页写入 Provider 保证地址持久化。

---

### 3.8 深链与 in-app 链接

| 模块 | 路径 | 功能 |
|------|------|------|
| Deep Link Config | `core/deeplink/hos_deeplink_config.dart` | Scheme `shoo`、Host `shoo.app` |
| Deep Link Mapper | `core/deeplink/hos_deeplink_mapper.dart` | URI / `/flash-sale` → go_router 路径 |
| Deep Link Listener | `core/deeplink/hos_deeplink_listener.dart` | `app_links` 监听 → `router.go()` |
| Route Navigator | `app/router/hos_route_navigator.dart` | 活动弹窗/Banner CTA 统一 `followLink()` |

**平台配置**

- **Android**：`AndroidManifest.xml` — `shoo://` + `https://shoo.app` App Links（`autoVerify`）
- **iOS**：`Info.plist` URL Scheme + `Runner.entitlements` Associated Domains（`applinks:shoo.app`）

**in-app 运营路径映射**（Banner / 活动弹窗 `link` 字段）

| Mock `link` | 跳转目标 |
|-------------|----------|
| `/flash-sale` | `/search?q=flash%20sale` |
| `/new-arrivals` | `/search?q=new%20arrivals` |
| `/trending` | `/search?q=trending` |
| `/product/:id` | 商品详情 |
| `https://shoo.app/...` | 同深链规则 |

**测试命令**

```bash
adb shell am start -a android.intent.action.VIEW -d "https://shoo.app/product/p-1"
xcrun simctl openurl booted "https://shoo.app/product/p-1"
# 首页 Banner：点击 FLASH SALE → 搜索页（flash sale）
```

> 生产 Universal Links 还需在域名部署 `apple-app-site-association` 与 Android `assetlinks.json`。

---

### 3.7 Tab 与全屏页协作要点

- Tab 页使用 `NoTransitionPage`：切换 Tab 无动画，性能更好。
- 二级页一律挂 `parentNavigatorKey: _rootNavigatorKey`：避免详情页被嵌在 Tab 栈内导致返回行为异常。
- 首页 AppBar 内嵌搜索入口：`context.push(SHOAppRoutes.search)`，搜索为全屏而非 Tab 子页。

---

## 四、基建功能清单

以下为项目搭建阶段在 `core/` 与 `app/` 中落地的基建能力（含 Phase 0～3 及近期增强）。

### 4.1 应用入口与配置

| 模块 | 路径 | 功能描述 |
|------|------|----------|
| Bootstrap | `app/hos_bootstrap.dart` | `WidgetsFlutterBinding`、AppConfig 初始化、图片缓存预热、全局异步错误兜底 |
| AppConfig | `core/config/hos_config.dart` | `ENV` / `USE_MOCK_API` / `API_BASE_URL` / `MOCK_DELAY_MS` dart-define；Release 强制关 Debug 面板 |
| Environment | `core/config/hos_environment.dart` | dev / local / staging / prod 环境枚举与默认 API 地址 |
| Constants | `core/constants/hos_constants.dart` | 应用名、版本、Storage Key、SKU 尺码等全局常量 |

### 4.2 网络层

| 模块 | 路径 | 功能描述 |
|------|------|----------|
| Dio Client | `core/network/hos_dio_client.dart` | 单例 Dio、超时、统一 `getData/postData`、错误映射 |
| Mock Interceptor | `core/network/hos_mock_interceptor.dart` | 读 `assets/mock/*.json`，模拟延迟与 envelope |
| Mock Registry | `core/network/hos_mock_route_registry.dart` | 可扩展 Mock 路由表（20+ 接口） |
| Auth Interceptor | `core/network/hos_auth_interceptor.dart` | 自动附加 Bearer Token |
| API Response | `core/network/hos_api_response.dart` | `{code, message, data}` 统一响应壳 |
| Connectivity | `core/network/hos_connectivity_service.dart` | 网络状态流，驱动离线条 |
| Local Mock Server | `server/` | Node Express，与 Registry 同步，支持 curl/Postman/Docker |

### 4.3 存储与会话

| 模块 | 路径 | 功能描述 |
|------|------|----------|
| Secure Storage | `core/storage/hos_secure_storage.dart` | Token 加密存储 |
| Local Storage | `core/storage/hos_local_storage.dart` | SharedPreferences 封装 |
| Image Cache | `core/storage/hos_image_cache_manager.dart` | 统一磁盘缓存，修复 sqflite 只读库问题 |
| Session | `features/auth/.../hos_session_provider.dart` | 登录/恢复/登出；与 `authTokenProvider` 同步供 Dio 使用 |

### 4.4 路由与导航

| 模块 | 路径 | 功能描述 |
|------|------|----------|
| Route Constants | `app/router/hos_routes.dart` | 全站路径常量、受保护路由、调试路由表 |
| Router Keys | `app/router/hos_router_keys.dart` | root / shell NavigatorKey 集中导出 |
| Router | `app/router/hos_router.dart` | GoRouter 组装、`errorBuilder`、合并各 feature 路由 |
| Feature Routers | `features/*/router.dart` | 各业务模块 `List<RouteBase>` |
| Shell Routes | `app/router/hos_shell_routes.dart` | Tab Shell、Settings、Messages |
| Not Found | `app/router/hos_not_found_page.dart` | 全局 404 页 |
| Route Navigator | `app/router/hos_route_navigator.dart` | 活动弹窗 CTA、**首页 Banner** in-app / 深链统一跳转 |
| Router Notifier | `app/router/hos_router_notifier.dart` | 登录/Debug 守卫 |
| Main Shell | `app/shell/hos_main_shell.dart` | 四 Tab、角标、首页搜索栏、Debug 连点入口 |
| Tab Badge | `core/navigation/hos_tab_badge_provider.dart` | 购物袋等 Tab 角标 |
| Deep Link | `core/deeplink/` | app_links 监听、URI 映射、配置 |

### 4.5 UI 基建

| 模块 | 路径 | 功能描述 |
|------|------|----------|
| Design Token | `core/theme/hos_colors.dart` 等 | Shein 风格色板、间距、排版 |
| Theme | `core/theme/hos_theme.dart` | 亮/暗 `ThemeData` |
| ThemeMode Provider | `core/theme/hos_theme_mode_provider.dart` | 主题持久化 |
| Widgets 库 | `core/widgets/hos_*.dart` | 按钮、骨架屏、商品卡、价格、空态、错误页、物流时间轴等 |
| Banner Carousel | `core/widgets/hos_banner_carousel.dart` | 首页轮播；`link` 点击 → `SHORouteNavigator` |
| Paged Scroll | `core/widgets/hos_paged_scroll_view.dart` | 下拉刷新 + 上拉分页 Footer |
| Image Picker Field | `core/widgets/hos_image_picker_field.dart` | 多图选择（相册/相机） |
| Loading State | `core/widgets/hos_loading_state.dart` | 统一 Loading / 空态 / 错误 |
| Offline Banner | `core/widgets/hos_offline_banner.dart` | `SHOAppShell` 全局离线 + Loading 遮罩 |
| Responsive | `core/widgets/hos_responsive.dart` | 响应式辅助 |
| Feedback | `core/feedback/hos_toast.dart` 等 | 全局 Toast、`scaffoldMessengerKey`、Overlay Loading |
| Pagination | `core/pagination/hos_paged_list_state.dart` | 通用分页状态模型 |

### 4.6 国际化与格式化

| 模块 | 路径 | 功能描述 |
|------|------|----------|
| ARB 双语 | `lib/l10n/app_en.arb` / `app_zh.arb` | 中英文案 |
| Locale Provider | `core/l10n/hos_locale_provider.dart` | 语言切换与持久化 |
| Price Formatter | `core/utils/hos_price_formatter.dart` | 分→元展示 |
| Validators | `core/utils/hos_validators.dart` | 表单校验（必填、手机号等） |

### 4.7 领域与业务基建

| 模块 | 路径 | 功能描述 |
|------|------|----------|
| Price Calculator | `core/pricing/hos_price_calculator.dart` | 优惠券抵扣纯函数 |
| Page Result | `core/models/hos_page_result.dart` | 分页列表通用模型 |
| Error 体系 | `core/errors/hos_exception.dart` | 网络/服务/缓存异常分层 |
| Error Mapper | `core/errors/hos_error_mapper.dart` | Dio/原生桥错误 → 用户文案 |
| Logger | `core/logging/hos_logger.dart` | 分级日志 |
| Permission | `core/permissions/hos_permission_service.dart` | 权限统一申请 |
| Share | `core/share/` | 系统分享、商品卡片图生成、`SHOSharePanel` |
| Media | `core/media/hos_image_picker_service.dart` | 相机/相册选图 + 权限 |
| Widget Capture | `core/utils/hos_widget_capture.dart` | RepaintBoundary → PNG（分享卡片） |
| Update | `core/update/` | 版本检测、弹窗、**EventChannel 下载进度** |
| Marketing | `core/marketing/hos_*` | 活动弹窗编排、预拉取、频次控制；**CTA 深链跳转** |
| Cart Reconcile | `features/cart/data/hos_cart_reconcile_service.dart` | 购物车失效/变价对账 |

### 4.8 原生交互基建

| 模块 | 路径 | 功能描述 |
|------|------|----------|
| Native Bridge | `core/platform/hos_native_bridge.dart` | MethodChannel 泛型调用 + 统一异常 |
| Event Bridge | `core/platform/hos_native_event_bridge.dart` | EventChannel 流封装 |
| Business Events | `core/platform/hos_native_business_event*.dart` | 支付/下载/物流业务事件模型与服务 |
| Message Bridge | `core/platform/hos_native_message_bridge.dart` | BasicMessageChannel 双向通信 |
| Channel Names | `core/platform/hos_channel_names.dart` | 通道名常量，防拼写错误 |
| Native Stubs | `android/ios/macos NativeBridgeHandler` | ping / echo / **payment·download·logistics Mock 流** |

### 4.9 Debug 调试体系

| 模块 | 路径 | 功能描述 |
|------|------|----------|
| Debug Panel | `core/debug/panel/` | 环境切换、清缓存、模块入口 |
| Update Debug | `core/debug/modules/update/` | 版本更新弹窗调试 |
| Activity Debug | `core/debug/modules/activity/` | 活动广告弹窗调试 |
| Native Debug | `core/debug/modules/native/` | 原生 Channel 示例调试台 |
| Tap Detector | `core/debug/core/hos_debug_tap_detector.dart` | 连点 5 次进入调试 |

### 4.10 工程与质量

| 项 | 说明 |
|----|------|
| CI | `.github/workflows/ci.yml` — `flutter analyze` + `flutter test` |
| 代码生成 | `build_runner` + freezed/json |
| 单测 | phase1/2/3、价格计算、校验器、Widget 冒烟等 |

---

## 五、业务阶段交付（Feature 层摘要）

| 阶段 | 版本 | 已交付能力 |
|------|------|------------|
| Phase 0 | v0.0 | 四 Tab、Shein 风格首页、组件库 |
| Phase 0.5 | v0.0.5 | Config、Session、i18n、暗黑、Mock 扩展 |
| Phase 1 | v0.3 | 购物车、SKU、结算、模拟支付、地址 |
| Phase 2 | v0.2 | 搜索、商详、评价、订单、物流 |
| Phase 3 | v0.4 | 优惠券、售后、价格计算 Domain |
| Phase 3.5 | v0.4+ | UX 规范、分页/搜索历史、购物车对账、支付防重复 |
| Phase 3.5 | v0.4+ | 深链、分享卡片、选图、EventChannel 业务流、路由模块化 |
| Phase 4 | 规划 | Sentry、真支付、CI 打包、Flavors |

---

## 六、补全进度（安全 · 体验 · 交互 · 路由）

> 以下标注 **✅ 已完成** 的项已在 v0.4.0+1 落地；未标注项仍为规划。

### 6.1 安全

| 优先级 | 项 | 说明 |
|--------|-----|------|
| P0 | **证书固定（SSL Pinning）** | 防中间人；Dio `HttpClient` 自定义 |
| P0 | **Token 刷新与过期** | Refresh Token 轮换、401 统一登出 |
| P0 | **敏感数据脱敏日志** | 生产关 body 日志；手机号/Token 打码 |
| P1 | **Root/越狱检测** | 高风险操作（支付）前提示或降级 |
| P1 | **代码混淆与加固** | Release 开启 `--obfuscate`、R8/ProGuard 规则 |
| P1 | **API 签名校验** | 防重放、时间戳 + nonce |
| P2 | **生物识别二次验证** | 支付确认、地址修改 |
| P2 | **安全键盘** | 支付密码输入防录屏 |

### 6.2 体验（UX / 性能）

| 优先级 | 项 | 状态 | 说明 |
|--------|-----|------|------|
| P0 | **全局 Loading / Toast 规范** | ✅ | `SHOAppToast`、`SHOGlobalLoadingOverlay`、`SHOAppLoadingState` |
| P0 | **错误重试与空态统一** | ✅ | `SHOAppErrorView` 一键重试；`whenLoadingState` 扩展 |
| P0 | **图片占位与渐进加载** | ✅ | 骨架屏 + 渐变占位 + `fadeIn` + 下载进度环 |
| P1 | **列表分页与下拉刷新** | ✅ | 订单/评价/搜索 — `SHOPagedScrollView` + Mock `?page=` |
| P1 | **搜索历史与热词本地化** | ✅ | `SharedPreferences` 持久化 + 去重清空 |
| P1 | **购物车合并与失效商品提示** | ✅ | `SHOCartReconcileService` + Banner/Toast |
| P1 | **支付结果页防重复提交** | ✅ | 按钮防抖 + `PopScope` + 订单轮询 + 原生支付事件 |
| P2 | **无障碍（Semantics）** | 待办 | 读屏、对比度、最小点击区域 |
| P2 | **大字体 / 系统字体缩放适配** | 待办 | `MediaQuery.textScaler` 回归测试 |
| P2 | **动画与转场统一** | 待办 | 商品详情共享元素（Hero）可选 |

### 6.3 交互（原生 · 系统 · 深链）

| 优先级 | 项 | 状态 | 说明 |
|--------|-----|------|------|
| P0 | **深链 / Universal Link** | ✅ | `app_links` + iOS/Android 配置 + `SHODeepLinkMapper` |
| P0 | **推送通知** | 待办 | FCM/APNs + 点击跳转订单/活动页 |
| P1 | **真支付 SDK** | 待办 | 微信/支付宝/Apple Pay；抽象 `PaymentGateway` |
| P1 | **原生分享扩展** | ✅ | `SHOShareProductCard` + `Share.shareXFiles` + 商详分享按钮 |
| P1 | **相机/相册选图** | ✅ | `image_picker` + `SHOImagePickerField`（评价/售后） |
| P1 | **EventChannel 业务流** | ✅ | 支付结果 / **更新下载进度** / 物流推送 Mock + Dart 服务 |
| P1 | **活动弹窗 CTA 深链** | ✅ | `SHORouteNavigator.followLink(activity.link)` |
| P1 | **更新包下载进度** | ✅ | `SHOAppUpdateDownloadService` + 更新弹窗进度条 |
| P2 | **Pigeon 迁移** | 待办 | Channel 增多时迁到代码生成 |
| P2 | **桌面/平板适配** | 待办 | `hos_responsive` 扩展 Breakpoint |
| P2 | **Widget 小组件** | 待办 | 订单状态、物流桌面组件 |
| P1 | **首页 Banner 深链** | ✅ | `SHOBannerCarousel` 点击 `banner.link` → `SHORouteNavigator` |

### 6.4 路由专项补全

| 项 | 状态 | 说明 |
|----|------|------|
| 全局 404 页 | ✅ | `GoRouter.errorBuilder` → `SHONotFoundPage` |
| `context.replace` 引导流 | ✅ | Splash → Onboarding → Home 无回退 |
| `push` 带返回值 | ✅ | 地址 `push<SHOAddress>`、优惠券 `push<String>` |
| 路由表模块化拆分 | ✅ | 各 `features/*/router.dart` 导出 `List<RouteBase>` |
| 路由埋点 | 待办 | 页面 PV/停留时长自动采集 |
| 路由动画策略 | 待办 | 商品详情右滑入、弹窗式结算可选 |

### 6.5 可观测性与生产化（Phase 4）

| 项 | 说明 |
|----|------|
| Sentry / Firebase Crashlytics | 崩溃、ANR、慢帧 |
| 埋点体系 | 曝光、点击、转化漏斗 |
| AppConfig Flavors | dev/staging/prod 分包名与图标 |
| Fastlane / CI 打包 | TestFlight、内测分发 |
| 隐私合规 | 隐私政策、权限申请说明文案、GDPR/个人信息导出 |

---

## 七、附录

### 7.1 环境启动命令

```bash
# 默认：dev + 内置 Mock
flutter run

# 本地 HTTP Mock Server
cd server && npm run dev
flutter run --dart-define=ENV=local --dart-define=USE_MOCK_API=false

# Android 模拟器连本地 Server
flutter run --dart-define=ENV=local --dart-define=USE_MOCK_API=false \
  --dart-define=API_BASE_URL=http://10.0.2.2:3847/api/v1
```

### 7.2 相关文档

- [Flutter 电商项目基建技术方案](./Flutter电商项目基建技术方案.md) — Phase 0/0.5 复刻手册  
- [项目方案报告](./项目方案报告.md) — 阶段交付与决策记录  
- Cursor Skill：`flutter-ecommerce-scaffold` / `new-project` — 一键搭建

---

### 7.3 关键 API 速查（v0.4+ 新增）

```dart
// 全局反馈
SHOAppToast.success('Saved');
ref.read(overlayLoadingProvider.notifier).show();

// 分页列表
ref.read(ordersPagedProvider.notifier).refresh();
ref.read(ordersPagedProvider.notifier).loadMore();

// 深链 / in-app 链接（活动弹窗 CTA、首页 Banner 共用）
SHORouteNavigator.followLink(context, '/flash-sale');
SHORouteNavigator.followLink(context, banner.link);
SHODeepLinkConfig.productLink(productId);

// 分享商品卡片
SHOSharePanel.show(context, ref, title: ..., link: ..., product: detail, cardKey: key);

// 选图
ref.read(imagePickerServiceProvider).pickFromGallery();

// 原生业务事件
ref.read(nativeBusinessEventServiceProvider).watchPayment(orderId: id);
ref.read(appUpdateDownloadServiceProvider).watchProgress();

// 选择器返回值
final address = await context.push<SHOAddress>(SHOAppRoutes.addressesSelect);
final couponId = await context.push<String>(SHOAppRoutes.couponsSelect);
```

---

**文档结束** — 本文档随 SHOO 版本迭代更新，当前对齐 **v0.4.0+1（Phase 3 + UX/原生/路由增强）**。
