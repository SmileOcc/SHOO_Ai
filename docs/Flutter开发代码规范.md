# Flutter 开发代码规范

> **版本**：v1.0  
> **日期**：2026-06-27  
> **适用范围**：SHOO 及同架构 Flutter 客户端项目  
> **基准**：[Effective Dart](https://dart.dev/effective-dart)、[Flutter Lints](https://pub.dev/packages/flutter_lints)、Clean Architecture + Feature-First

---

## 一、目标与原则

### 1.1 规范目标

| 目标 | 说明 |
|------|------|
| **可读** | 新人 30 分钟内能定位任意业务代码 |
| **可测** | Domain 可单测，Presentation 可 Widget 冒烟 |
| **可扩展** | 新 Feature 不改动 core，不破坏依赖方向 |
| **可协作** | 命名、目录、提交信息统一，Review 有章可循 |
| **可交付** | CI 静态分析零 error，主分支可发布 |

### 1.2 核心原则

1. **Feature-First**：按业务垂直切分，禁止「万能 utils 包」堆逻辑。
2. **单向依赖**：`app → features → core`；`core` 不得 import `features`。
3. **显式优于隐式**：状态来源、路由参数、错误处理必须可追溯。
4. **小步提交**：一个 PR 只做一类事（功能 / 修复 / 重构分开）。
5. **平台差异收敛到 core**：业务页不写 `Platform.isAndroid` 分支。

---

## 二、工程结构

### 2.1 目录约定

```
lib/
├── app/                    # 入口、bootstrap、MaterialApp.router
├── features/               # 业务模块（垂直切分）
│   └── {feature}/
│       ├── domain/         # 实体、Repository 接口、纯函数
│       ├── data/           # API、DTO、Repository 实现
│       └── presentation/   # Page、Widget、Controller/Provider
├── core/                   # 跨模块基建（主题、网络、路由、通用 Widget）
├── l10n/                   # gen-l10n 生成物 + ARB 源文件
└── main.dart
```

### 2.2 依赖规则

```
✅ features/order/presentation  →  features/order/domain
✅ features/order/data          →  features/order/domain
✅ features/*                   →  core/*
❌ core/*                       →  features/*
❌ features/order               →  features/cart（跨 Feature 直接依赖）
```

跨 Feature 共享：通过 `core` 抽象，或 Domain 层定义接口 + 依赖注入。

### 2.3 文件命名

| 类型 | 规则 | 示例 |
|------|------|------|
| 库文件 | `snake_case.dart` | `hos_order_list_page.dart` |
| 页面 | `*_page.dart` | `hos_flash_sale_page.dart` |
| 状态/控制器 | `*_controller.dart` / `*_provider.dart` | `hos_flash_sale_controller.dart` |
| 组件 | `*_widget.dart` 或语义名 | `hos_product_card.dart` |
| 路由 | `router.dart`（Feature 内） | `features/order/router.dart` |
| 测试 | `{源文件名}_test.dart` | `hos_price_utils_test.dart` |

**SHOO 前缀**：公共基建类使用 `SHO` / `SHOApp` 前缀（如 `SHOAppCustomRefresh`），Feature 内业务类可使用 Feature 前缀（如 `SHOFlashSaleProductCard`）。

---

## 三、Dart 语言规范

### 3.1 基础风格（遵循 Effective Dart）

```dart
// ✅ 推荐
class OrderRepository {
  const OrderRepository(this._client);
  final Dio _client;

  Future<Order> fetch(String id) async { ... }
}

// ❌ 避免
class order_repository {  // 类名 PascalCase
  var client;            // 公共可变字段
}
```

- 类 / 枚举 / typedef / 扩展：`UpperCamelCase`
- 文件 / 变量 / 参数 / 方法：`lowerCamelCase`
- 常量：`lowerCamelCase` 或 `SCREAMING_CAPS`（仅真正全局编译期常量）
- 私有成员：前缀 `_`

### 3.2 类型与空安全

```dart
// ✅ 明确类型，避免 dynamic
final List<Product> products = [...];

// ✅ 可空显式处理
final name = user?.name ?? l10n.anonymous;

// ❌ 滥用 !
final id = map['id']!;  // 除非上游已保证非空
```

- 公共 API 必须标注参数与返回值类型。
- 禁用 `// ignore:` 除非附带原因注释。

### 3.3 异步与错误

```dart
Future<void> load() async {
  state = state.copyWith(isLoading: true, error: null);
  try {
    final data = await _repo.fetch();
    state = state.copyWith(data: data, isLoading: false);
  } catch (e, st) {
    SHOLogger.e('load failed', error: e, stackTrace: st);
    state = state.copyWith(isLoading: false, error: e.toString());
  }
}
```

- `async` 函数必须有明确的错误路径，禁止空 `catch`。
- 页面销毁后更新状态：检查 `mounted` / `ref.mounted`。
- 禁止在 `build` 中直接 `await` 或触发副作用。

### 3.4 不可变数据

- Domain / State 模型优先 **freezed** + **json_serializable**。
- Widget 字段尽量 `final`；能 `const` 则 `const`。
- 状态更新用 `copyWith`，禁止原地 mutate 列表/Map。

---

## 四、静态分析与 Lint

### 4.1 基线配置（当前项目）

```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_declarations: true
    avoid_print: true
    require_trailing_commas: true
    prefer_const_literals_to_create_immutables: true
```

### 4.2 推荐逐步启用（Phase 进阶）

| 规则包 | 用途 |
|--------|------|
| [very_good_analysis](https://pub.dev/packages/very_good_analysis) | Very Good Ventures 严格规则集 |
| `always_declare_return_types` | 公共 API 强制返回类型 |
| `avoid_redundant_argument_values` | 减少噪音参数 |
| `unawaited_futures` | 防止遗漏 await |
| `cancel_subscriptions` | Stream 订阅泄漏 |

### 4.3 CI 门禁

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
flutter test
```

- **主分支**：analyze 零 error；info 级别逐步清零。
- 提交前本地跑 `dart analyze` + `dart format .`。

---

## 五、状态管理（Riverpod）

### 5.1 选型约定

| 场景 | 方案 |
|------|------|
| 全局 Session / 主题 / 语言 | `Provider` / `NotifierProvider` |
| 页面级业务状态 | `AsyncNotifier` / `@riverpod` Notifier |
| 分页列表 | 统一 `SHOPagedListState` + Controller |
| 一次性读取 | `ref.read` |
| 响应式 UI | `ref.watch` |
| 事件触发 | `ref.read(...notifier).action()` |

### 5.2 规范

```dart
// ✅ Controller 只管状态与用例编排，不持有 BuildContext
@riverpod
class FlashSaleController extends _$FlashSaleController {
  @override
  FlashSaleState build(String activityId) => FlashSaleState.initial();

  Future<void> refresh() async { ... }
}

// ✅ 页面只 watch 必要字段，避免整棵 State 重建
final products = ref.watch(
  flashSaleControllerProvider(id).select((s) => s.products),
);

// ❌ 在 build 里修改 Provider
ref.read(cartProvider.notifier).add(item);  // 放 initState / 回调中
```

- Provider 定义靠近 Feature `presentation/state/`。
- 代码生成：`build_runner` 变更后必须提交 `.g.dart` / `.freezed.dart`。
- 禁止循环依赖：core 通过 `Provider` 注入 Token，不 import auth Feature。

---

## 六、路由（go_router）

### 6.1 约定

- 路径常量集中 `core/router/hos_routes.dart`。
- 各 Feature 导出 `router.dart`，由 `hos_router.dart` 组装。
- 页面参数优先 **路径参数** / **query**，复杂对象用 `extra` 并文档化。

```dart
// ✅
static const orderDetail = '/orders/:id';
context.push(SHOAppRoutes.orderDetailPath(orderId));

// ❌ 魔法字符串
context.push('/orders/$id');
```

### 6.2 守卫与深链

- 登录守卫：`redirect` + `refreshListenable`（Session 变化自动重算）。
- 深链统一走 `SHODeepLinkNavigator`，业务页不直接解析 URL。

---

## 七、UI 与 Widget

### 7.1 分层

| 层级 | 位置 | 职责 |
|------|------|------|
| 设计 Token | `core/theme/` | 颜色、间距、字体、圆角 |
| 通用组件 | `core/widgets/` | Button、Empty、Error、Refresh |
| 业务组件 | `features/*/presentation/widgets/` | 商品卡、订单 Cell |

### 7.2 Widget 规范

```dart
// ✅ 小 Widget、命名参数、const 构造
class SHOProductCard extends StatelessWidget {
  const SHOProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  final Product product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) { ... }
}
```

- 单文件超过 **400 行**考虑拆分 private Widget 或独立文件。
- 禁止硬编码颜色/字号：使用 `SHOAppColors`、`SHOAppSpacing`、`Theme.of(context)`。
- 文案必须走 **l10n**，禁止用户可见硬编码中文/英文（Debug 面板除外）。

### 7.3 布局与性能

- 列表用 `ListView.builder` / `SliverList`，禁止长列表 `Column` 全量构建。
- 图片用 `cached_network_image` + 统一 CacheManager。
- 避免无边界 `shrinkWrap: true` 嵌套滚动（除非明确需求）。
- `setState` / `notifyListeners` 范围最小化。

### 7.4 刷新与分页

- 轻量场景：`SHOAppPullRefresh`（系统 RefreshIndicator）。
- 品牌定制：`SHOAppCustomRefresh` + `headerSliver` / `footerSliver`。
- 分页列表：优先 `SHOPagedDataPage` / `SHOPagedScrollView` 统一模式。

---

## 八、网络与数据

### 8.1 Dio 约定

```dart
// Repository 实现层
class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._dio);
  final Dio _dio;

  @override
  Future<Order> getOrder(String id) async {
    final response = await _dio.get('/orders/$id');
    return Order.fromJson(response.data as Map<String, dynamic>);
  }
}
```

- 拦截器链顺序：Log → Auth → Mock → ErrorMap。
- DTO 与 Domain 分离：Data 层 `*Dto` / `*Model`，Domain 层纯 Entity。
- 错误映射为业务异常（`SHOAppException`），UI 不解析 Dio 原始错误。

### 8.2 Mock 策略

- 开发期 Mock 走 `SHOMockInterceptor` 或本地 Mock Server。
- Mock JSON 放 `assets/mock/`，字段与正式 API 对齐。

---

## 九、国际化（l10n）

```
lib/l10n/
├── app_zh.arb      # 源文件（中文为 master 或英文，团队统一即可）
├── app_en.arb
└── app_localizations*.dart  # 生成，勿手改
```

- 新增文案只改 ARB，运行 `flutter gen-l10n`。
- Key 命名：`{模块}{描述}` camelCase，如 `customRefreshPull`。
- 带参数：`"greeting": "Hello, {name}"` + `@greeting` metadata。

---

## 十、日志、埋点与调试

| 类型 | 规范 |
|------|------|
| 开发日志 | `SHOLogger.d/i/w/e`，禁止 `print` |
| 埋点 | `SHOPageAnalytics` / `SHOAnalyticsManager`，页面用 `SHOAppTrackedPageMixin` |
| 调试能力 | 仅 Debug / 内测入口，不污染 Release 主路径 |

- 日志不得输出 Token、手机号、完整支付信息。
- 新页面必须定义 `pageName` 与关键 `pageAnalyticsExtra`。

---

## 十一、测试

### 11.1 金字塔

```
        ┌─────────────┐
        │  Widget 冒烟 │  少量关键路径
        ├─────────────┤
        │  集成 / 黄金图 │  可选
        ├─────────────┤
        │  单元测试     │  Domain、Utils、Repository 映射
        └─────────────┘
```

### 11.2 必测项

- Domain 纯函数（价格、格式化、校验）。
- JSON 序列化/反序列化。
- 路由路径 helper。
- 核心 State  reducer / Controller 分支。

```dart
test('pullProgress clamps 0..1', () {
  final ctrl = SHOAppCustomRefreshController();
  ctrl.updateDrag(32, dragging: true);
  expect(ctrl.pullProgress(64), 0.5);
});
```

- 测试文件镜像 `lib/` 结构：`test/features/order/...`。
- 命名：`test('should xxx when yyy', () { ... })`。

---

## 十二、Git 与 Code Review

### 12.1 分支

| 分支 | 用途 |
|------|------|
| `main` / `master` | 可发布稳定线 |
| `develop` | 日常集成（可选） |
| `feature/*` | 新功能 |
| `fix/*` | Bug 修复 |
| `refactor/*` | 重构 |

### 12.2 Commit Message（Conventional Commits）

```
<type>(<scope>): <subject>

feat(flash_sale): 接入 SHOAppCustomRefresh 一体滚动
fix(refresh): Android overscroll 重复累计
refactor(order): 拆分 OrderListTab Controller
docs: 补充 Flutter 代码规范
test(cart): 覆盖优惠券叠加计算
```

**type**：`feat` | `fix` | `refactor` | `docs` | `test` | `chore` | `perf` | `style`

### 12.3 PR Checklist

- [ ] `dart analyze` 无 error
- [ ] 已格式化 `dart format`
- [ ] 新增 UI 已走 l10n
- [ ] 无调试 `print` / 临时代码
- [ ] 依赖方向未破坏（core ↛ features）
- [ ] 必要测试已补充或说明原因
- [ ] 截图/录屏（UI 变更）

---

## 十三、平台与原生

- 平台通道统一放 `core/platform/`，业务 Feature 不直接写 MethodChannel。
- Hybrid / WebView / 深链 走已有 Bridge 与 Navigator 封装。
- 权限申请统一 `SHOPermissionService`。
- 平台差异（Android/iOS）在 core 层消化，对 Feature 暴露一致 API。

---

## 十四、安全与发布

| 项 | 要求 |
|----|------|
| 密钥 | 不进 Git；用 `--dart-define` / 原生配置 |
| Token | `flutter_secure_storage` |
| 网络安全 | 生产 HTTPS；证书锁定按需 |
| Obfuscation | Release 开启 `--obfuscate`（可选） |
| 版本号 | `pubspec.yaml` + `package_info_plus` 一致 |

---

## 十五、推荐工具链

| 工具 | 用途 |
|------|------|
| **VS Code / Android Studio** | IDE + Flutter 插件 |
| **dart format** | 统一格式 |
| **dart analyze** | 静态分析 |
| **build_runner** | freezed / json / riverpod 生成 |
| **flutter gen-l10n** | 国际化生成 |
| **melos**（可选） | Monorepo 多包管理 |
| **lefthook / husky**（可选） | Git hooks 预检 |

### 15.1 可选 CI 模板（GitHub Actions）

```yaml
name: Flutter CI
on: [push, pull_request]
jobs:
  analyze-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.x'
          channel: 'stable'
      - run: flutter pub get
      - run: dart format --output=none --set-exit-if-changed .
      - run: dart analyze --fatal-infos
      - run: flutter test
```

---

## 十六、反模式清单（禁止）

| 反模式 | 原因 |
|--------|------|
| God Widget（单文件 1000+ 行） | 难维护、难测试 |
| 业务页直接 `Dio.get` | 绕过 Repository，难 Mock |
| `features` 互相 import | 耦合、循环依赖 |
| 全局单例滥用 | 难测试、隐式状态 |
| build 里发起网络/改 Provider | 重复调用、副作用 |
| 硬编码文案/颜色 | 无法主题化与国际化 |
| 复制粘贴相似 Page | 应抽 core 组件或 Mixin |
| 忽略 analyze warning 累积 | 技术债失控 |

---

## 十七、与 SHOO 基建的对照表

| 能力 | 规范入口 |
|------|----------|
| 路由 | `go_router` + `SHOAppRoutes` |
| 状态 | `flutter_riverpod` + Feature Controller |
| 分页 | `SHOPagedDataPage` / `SHOPagedListState` |
| 下拉刷新 | `SHOAppPullRefresh` / `SHOAppCustomRefresh` |
| 页面埋点 | `SHOAppTrackedPageMixin` |
| 错误边界 | `SHOPageErrorBoundary` |
| Tab 保活 | `SHOTabKeepAlivePage` |
| 主题 | `SHOAppColors` / `SHOAppSpacing` |
| 日志 | `SHOLogger` |

---

## 十八、落地路线图

| 阶段 | 动作 | 优先级 |
|------|------|--------|
| **P0** | 统一 `analysis_options` + CI analyze/test | ✅ 已落地 |
| **P0** | 新代码强制 l10n + 主题 Token | 立即 |
| **P1** | 补充 PR Template + Commit 规范 | ✅ 已落地 |
| **P1** | Cursor Rules（`.cursor/rules/*.mdc`） | ✅ 已落地 |
| **P1** | 核心 Domain 单测覆盖率 > 60% | 2 周 |
| **P2** | 启用 `analysis_options` P2 规则 + strict-casts | ✅ 已落地 |
| **P2** | 引入 `very_good_analysis`（可选） | 1 月 |
| **P2** | 黄金图 / 集成测试关键路径 | 按需 |

---

## 附录 A：文件头注释（可选）

```dart
/// 闪购活动页：日历、场次、商品列表、下拉刷新与分页加载。
///
/// 路由：[SHOAppRoutes.flashSale]
/// 埋点：pageName = `flash_sale`
```

## 附录 B：import 顺序

```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter SDK
import 'package:flutter/material.dart';

// 3. 第三方包（字母序）
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 4. 项目内（字母序）
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/features/order/domain/entities/order.dart';
```

## 附录 C：参考链接

- [Effective Dart](https://dart.dev/effective-dart)
- [Flutter Architecture Recommendations](https://docs.flutter.dev/app-architecture/recommendations)
- [Riverpod Documentation](https://riverpod.dev)
- [go_router](https://pub.dev/packages/go_router)
- [Very Good Ventures Engineering](https://verygood.ventures/blog)

---

## 十九、已落地资产（仓库内）

| 资产 | 路径 |
|------|------|
| 完整规范文档 | `docs/Flutter开发代码规范.md` |
| Cursor 规则（AI 自动遵循） | `.cursor/rules/flutter-*.mdc` |
| PR 模板 | `.github/pull_request_template.md` |
| CI（format + analyze + test） | `.github/workflows/ci.yml` |
| 静态分析 | `analysis_options.yaml`（P1 + P2 已启用，`--fatal-warnings`） |

---

**维护**：架构组 / Tech Lead 每季度 Review 一次，与 `analysis_options.yaml` 及基建 API 同步更新。
