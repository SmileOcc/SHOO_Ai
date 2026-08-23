# SHOO Deep Link 使用文档

## 1. 概述

SHOO Deep Link 模块统一管理应用外链（系统级深链、Universal Link）和应用内链（活动 Banner、H5 点击、分享卡片）的解析、鉴权与导航。

### 链路形式

| 形式 | 示例 | 触发场景 |
|------|------|----------|
| Custom Scheme | `shoo://product/p-1` | 系统分享、第三方 App 唤起 |
| Universal Link | `https://shoo.app/product/p-1` | Web/H5 页面跳转、推送通知 |
| In-App 路径 | `/product/p-1` 或 `product/p-1` | 活动 Banner、分享卡片 |

### 架构层次

```
外部 / H5 触发
       │
       ▼
┌──────────────────┐
│ SHODeepLinkListener   ← 系统级监听 (Custom Scheme / Universal Link)
│ SHODeepLinkNavigator  ← 应用内主动调用 (openLink / openFromWebView)
└──────────────────┘
       │
       ▼
┌──────────────────┐
│ SHODeepLinkResolver  ← 解析原始 URL → SHODeepLinkTarget
└──────────────────┘
       │
       ▼
┌──────────────────┐
│ SHODeepLinkMapper    ← URI → go_router appPath 映射
└──────────────────┘
       │
       ▼
┌──────────────────┐
│ SHODeepLinkTarget    ← (type, appPath, requiresAuth)
└──────────────────┘
       │
       ▼
┌──────────────────┐
│ SHODeepLinkNavigator ← 鉴权检查 → go / push / login?redirect
└──────────────────┘
       │
       ▼
┌──────────────────┐
│ GoRouter 导航        ← 最终页面跳转
└──────────────────┘
```

### 核心文件

| 文件 | 职责 |
|------|------|
| `hos_deeplink_config.dart` | Scheme / Host 配置，静态链接生成器 |
| `hos_deeplink_target.dart` | 解析结果实体（路径 + 鉴权标记） |
| `hos_deeplink_action_type.dart` | 链接类型枚举 |
| `hos_deeplink_mapper.dart` | URI → go_router 路径映射 |
| `hos_deeplink_resolver.dart` | 完整解析链（URI → Target） |
| `hos_deeplink_listener.dart` | 系统级链接监听（启动/前台切换） |
| `hos_deeplink_navigator.dart` | 统一导航（鉴权 + 跳转） |

---

## 2. 支持的链接格式

### 2.1 Custom Scheme

```
shoo://product/p-1
shoo://orders/o-1
shoo://activity
shoo://login?redirect=%2Fcheckout
```

- Scheme: `shoo`
- Host 非 `open` 时作为第一个路径段：`shoo://product/p-1` → pathSegments: `[product, p-1]`

### 2.2 Universal Link / App Links（HTTPS）

```
https://shoo.app/product/p-1
https://shoo.app/cart
https://shoo.app/profile
https://shoo.app/search?q=flash
https://www.shoo.app/orders/o-1
```

- 仅接受 Host: `shoo.app` 或 `www.shoo.app`
- 路径直接映射为应用内路由
- **Android**：`AndroidManifest` 已声明 App Links（`autoVerify`）
- **iOS**：配置约定为 `applinks:shoo.app`（见 `SHODeepLinkConfig.associatedDomains`），**Associated Domains 暂未写入 entitlements**；系统级 Universal Link 正式上线再开
- Flutter 引擎内置 Deep Link 已关闭（`FlutterDeepLinkingEnabled=false`），统一由 `app_links` + `SHODeepLinkListener` 处理

### 2.3 应用内相对路径

```
/product/p-1
flash-sale
/cart?from=home
```

- 以 `/` 开头或直接路径均可
- 无 scheme 时按相对路径解析

---

## 3. 支持的路由映射

| 链接路径 | 映射路由 | 是否需要登录 |
|----------|---------|------------|
| `product/{id}` | `/product/:id` | 否 |
| `product/{id}/reviews` | `/product/:id/reviews` | 否 |
| `orders` | `/orders` | **是** |
| `orders/{id}` | `/orders/:id` | **是** |
| `orders/{id}/logistics` | `/orders/:id/logistics` | **是** |
| `payment/{id}` | `/payment/:id` | **是** |
| `after-sales` | `/after-sales` | **是** |
| `after-sales/apply/{id}` | `/after-sales/apply/:id` | **是** |
| `checkout` | `/checkout` | **是** |
| `coupons` | `/coupons` | **是** |
| `coupons?select=1` | `/coupons?select=1` | **是** |
| `search?q=xxx` | `/search?q=xxx` | 否 |
| `search` | `/search` | 否 |
| `category` | `/category` | 否 |
| `category/products?leafId=..&title=..` | `/category/products` | 否 |
| `cart` | `/cart` | 否 |
| `profile` | `/profile` | 否 |
| `activity` | `/activity` | 否 |
| `webview?url=..&title=..` | WebView 页 | 否 |
| `login` | `/login` | — |
| `login?redirect=/checkout` | `/login`（登录后跳转） | — |
| `flash-sale` | `/flash-sale` | 否 |
| `theme-activity/{activityId}` | `/theme-activity/:activityId` | 否 |
| `new-arrivals` | `/search?q=new arrivals` | 否 |
| `trending` | `/search?q=trending` | 否 |

---

## 4. 鉴权逻辑

当解析出的 `target.requiresAuth = true` 且用户未登录时：

```
Auth 路由（orders / payment / checkout / coupons / after-sales 等）
  ├─ 已登录 → 直接导航到目标页
  └─ 未登录 → push /login?redirect=<target.appPath>
                 ↓
           登录成功后根据 redirect 参数跳转到目标页
```

### 在 `GoRouter` redirect 中配置登录页面接收 `redirect` 参数处理：

```dart
// 登录成功回调
final redirect = state.uri.queryParameters['redirect'];
if (redirect != null && redirect.isNotEmpty) {
  context.go(redirect);
} else {
  context.go(SHOAppRoutes.home);
}
```

---

## 5. 使用场景

### 5.1 系统级监听（启动 / 前台切换）

由 `deepLinkListenerProvider` 在 `SHOApp.build()` 中初始化：

```dart
// hos_shoo_app.dart
ref.watch(deepLinkListenerProvider);
```

监听器自动处理：
- 冷启动时的 `getInitialLink()`
- 应用在前台时的 `uriLinkStream` 流

### 5.2 应用内主动调用

```dart
// 从 Banner / 活动页跳转
final session = ref.read(sessionProvider);
await SHODeepLinkNavigator.openLink(
  context,
  'product/p-1',
  session: session,
);

// 带关闭当前页
await SHODeepLinkNavigator.openLink(
  context,
  'checkout',
  session: session,
  closeCurrentPage: true,
);
```

### 5.3 WebView / H5 跳转

WebView 内通过 JS Bridge 触发：

```dart
// hos_webview_bridge_handler.dart
SHODeepLinkNavigator.openFromWebView(
  context,
  url,
  session: ref.read(sessionProvider),
);
```

特性：
- 通过 `scheduleMicrotask` 异步执行，不阻塞 WebView
- 自动防抖（同一链接 600ms 内不重复跳转）
- 目标为 Tab 页时自动关闭 WebView

### 5.4 生成分享链接

```dart
// 商品分享
final link = SHODeepLinkConfig.productLink('p-1');
// → https://shoo.app/product/p-1

// 订单分享
final link = SHODeepLinkConfig.orderLink('o-1');
// → https://shoo.app/orders/o-1

// 商品列表分享
final link = SHODeepLinkConfig.productListLink(
  leafId: 'cat-1',
  title: '服装',
);
// → https://shoo.app/category/products?leafId=cat-1&title=%E6%9C%8D%E8%A3%85
```

---

## 6. 路由导航规则

| 目标类型 | 导航方式 | 说明 |
|----------|---------|------|
| Shell Tab（home/category/cart/profile） | `go()` | 替换当前路由栈 |
| 非 Shell Tab | `push()` | 叠在当前页上方 |

通过 `SHOAppRoutes.isShellTabRoute(path)` 判断。

---

## 7. 配置

### iOS（`Info.plist`）

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>shoo</string>
    </array>
  </dict>
</array>
```

### Android（`AndroidManifest.xml`）

```xml
<activity>
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="shoo" />
  </intent-filter>
  <!-- Universal Link -->
  <intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" android:host="shoo.app" />
  </intent-filter>
</activity>
```

---

## 8. 新增链接路径步骤

1. 在 `SHODeepLinkMapper.toAppPath()` 添加 `switch case`，路由映射
2. 在 `SHODeepLinkResolver._actionTypeFromUri()` 添加 `switch case`，指定 `SHODeepLinkActionType`
3. 如需鉴权，在 `SHODeepLinkResolver._requiresAuth()` 中将类型加入 `authTypes`
4. 如需快捷链接生成，在 `SHODeepLinkConfig` 添加静态方法

---

## 9. 调试

在 Debug 面板的"安全网络 / 加密调试"页面中，可通过 GET/POST 调试模块直接输入完整链接进行调试。

测试链接示例：

```
shoo://product/p-1
https://shoo.app/cart
activity
flash-sale
new-arrivals
orders/o-1
checkout
```
