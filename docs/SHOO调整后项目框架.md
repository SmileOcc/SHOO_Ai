# SHOO 调整后项目框架（目标版）

> **版本**：v1.1  
> **日期**：2026-06  
> **状态**：**已按本框架完成目录迁移**（core / features / app guards / auth 样板 / scripts / test）  
> **说明**：在你提供的通用 Flutter 架构模板基础上，结合 SHOO 现状与团队约定做的**目标框架**。

---

## 一、设计原则（相对原模板的调整）

| 原模板 | 调整后（SHOO） | 调整原因 |
|--------|----------------|----------|
| `service_locator.dart` + GetIt | **Riverpod Provider** | 与 `ConsumerWidget`、`GoRouter.redirect` 一体，测试可 `ProviderScope(overrides:)` |
| `app/theme/` | **`core/theme/`** | 主题被多 Feature 共享，属于基建而非应用壳 |
| `app/i18n/*.json` | **`lib/l10n/*.arb`** + gen-l10n | Flutter 官方工具链，支持占位符/复数 |
| `lib/platform/` | **`lib/core/platform/`** | 平台桥与 network/storage 同级，桶导出 `hos_platform.dart` |
| `features/*/xxx_module.dart` | **`features/*/router.dart` + Provider 分散注册** | 减少 Module 样板；路由工厂 `shoXxxRoutes()` 即模块边界 |
| 强制 `state/` 顶层 | **`presentation/state/`（按需）** | 小页面不必多一层；复杂模块再建子目录 |
| 强制 `use_cases/` | **按需新增** | 简单 CRUD 由 Repository 足够；支付/登录等多步编排再抽 |
| 强制 `repository_impl` 命名 | **`data/repositories/*_repository_impl.dart`** | 与 domain 接口成对，命名即职责 |
| Drift + Hive 全套 | **SP + SecureStorage + 按需 Drift** | 当前 Mock 为主；离线库上线前不引入复杂度 |
| `core/infrastructure/` 大套娃 | **`core/network` `storage` `cache` 平铺** | 目录更浅、import 更短，符合现有代码 |

---

## 二、目标目录结构

```
project_root/
│
├── lib/
│   ├── main.dart                              # 入口：main() → bootstrap()
│   │
│   ├── app/                                   # ===== 应用壳（只放「壳」相关）=====
│   │   ├── root/
│   │   │   ├── hos_bootstrap.dart             # 统一初始化入口
│   │   │   ├── hos_shoo_app.dart              # SHOApp：ProviderScope + MaterialApp.router
│   │   │   ├── hos_app_restart.dart           # Debug 热重启包装
│   │   │   └── hos_runtime_env_provider.dart  # 运行时 API 环境（Debug）
│   │   │
│   │   ├── shell/
│   │   │   ├── hos_main_shell.dart            # StatefulShellRoute 骨架
│   │   │   ├── hos_bottom_nav.dart            # ★ 从 shell 拆出（可选）
│   │   │   └── hos_home_drawer.dart           # 侧栏（home feature 提供内容）
│   │   │
│   │   └── router/
│   │       ├── hos_router.dart                # GoRouter 实例化（routerProvider）
│   │       ├── hos_routes.dart                # SHOAppRoutes 路径常量
│   │       ├── hos_shell_routes.dart          # Tab Shell 路由
│   │       ├── hos_router_notifier.dart       # refreshListenable + redirect 编排
│   │       ├── hos_router_keys.dart           # NavigatorKey
│   │       ├── hos_route_navigator.dart       # 跨模块导航辅助
│   │       ├── hos_not_found_page.dart
│   │       └── guards/                        # ★ 守卫纯函数（从 Notifier 抽出）
│   │           ├── hos_auth_redirect.dart
│   │           ├── hos_onboarding_redirect.dart
│   │           └── hos_maintenance_redirect.dart
│   │
│   ├── l10n/                                  # ===== 国际化（生成代码勿手改）=====
│   │   ├── app_en.arb
│   │   ├── app_zh.arb
│   │   └── app_localizations*.dart            # flutter gen-l10n 生成
│   │
│   ├── features/                              # ===== 业务模块（垂直拆分）=====
│   │   │
│   │   ├── auth/                              # 认证模块（标准样板）
│   │   │   ├── router.dart                    # shoAuthRoutes()
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── hos_auth_user.dart
│   │   │   │   │   └── hos_auth_session.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── hos_auth_repository.dart      # abstract interface
│   │   │   │   └── use_cases/                 # 可选：多步编排
│   │   │   │       ├── hos_login_use_case.dart
│   │   │   │       └── hos_logout_use_case.dart
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── remote/
│   │   │   │   │   │   └── hos_auth_remote_ds.dart     # 原 hos_auth_api.dart
│   │   │   │   │   └── local/
│   │   │   │   │       └── hos_auth_local_ds.dart      # Token 读写封装
│   │   │   │   ├── dto/                       # 可选：与 domain 实体分离时
│   │   │   │   │   └── hos_login_response_dto.dart
│   │   │   │   └── repositories/
│   │   │   │       └── hos_auth_repository_impl.dart
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       │   ├── hos_login_page.dart
│   │   │       │   └── hos_register_page.dart
│   │   │       ├── widgets/
│   │   │       │   └── hos_social_login_buttons.dart
│   │   │       └── state/
│   │   │           ├── hos_auth_providers.dart
│   │   │           └── hos_session_provider.dart
│   │   │
│   │   ├── home/                              # 首页（Tab 内，无独立 router）
│   │   │   ├── domain/
│   │   │   ├── data/
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       └── widgets/
│   │   │
│   │   ├── category/                          # 分类
│   │   ├── product/                           # 商品（可嵌套 review 子路由）
│   │   ├── cart/
│   │   ├── checkout/                          # 结账 / 支付（优先补齐 domain 接口）
│   │   ├── order/
│   │   ├── address/
│   │   ├── after_sale/
│   │   ├── coupon/
│   │   ├── community/
│   │   ├── message/
│   │   ├── profile/
│   │   ├── search/                            # 轻量模块可省略 domain/
│   │   ├── splash/
│   │   ├── toolbox/                           # 百宝箱（阅读 / 下载 / 原生组件入口）
│   │   │   └── presentation/
│   │   │       ├── music/
│   │   │       └── video/
│   │   └── study/                             # 面试学习（toolbox 子路由）
│   │
│   └── core/                                  # ===== 共享核心层 =====
│       │
│       ├── network/                           # 网络（原 infrastructure/network）
│       │   ├── hos_dio_client.dart
│       │   ├── hos_api_response.dart          # ★ 统一响应包装（按需）
│       │   ├── hos_network_info.dart            # ★ 连接状态（connectivity_plus）
│       │   ├── hos_mock_interceptor.dart
│       │   ├── hos_mock_route_registry.dart
│       │   └── interceptors/
│       │       ├── hos_auth_interceptor.dart
│       │       ├── hos_logging_interceptor.dart
│       │       ├── hos_error_interceptor.dart
│       │       └── hos_retry_interceptor.dart   # ★ 按需
│       │
│       ├── storage/
│       │   ├── key_value/
│       │   │   └── hos_local_storage.dart     # SharedPreferences
│       │   ├── secure/
│       │   │   └── hos_secure_storage.dart
│       │   ├── file/
│       │   │   └── hos_file_storage.dart      # ★ 按需
│       │   └── database/                      # ★ 上线离线能力时再建
│       │       └── hos_app_database.dart
│       │
│       ├── cache/
│       │   ├── hos_cache_cleanup_service.dart
│       │   └── hos_cache_policy.dart          # ★ TTL / LRU 策略（按需）
│       │
│       ├── platform/                          # 平台层（Channels + Hybrid）
│       │   ├── hos_platform.dart              # 桶导出
│       │   ├── bridge/                        # Method / Event / Message Channel
│       │   ├── business_event/                # 支付 / 下载 / 物流事件
│       │   ├── hybrid/                        # S活动 混合桥
│       │   └── native_components/             # 原生组件库
│       │
│       ├── widgets/                           # 共享 UI（原 shared_widgets）
│       │   ├── hos_widgets.dart               # 桶导出
│       │   ├── loading/
│       │   ├── error/
│       │   ├── empty/
│       │   ├── dialog/                        # 对应 hos_dialog.dart
│       │   ├── refresh/
│       │   ├── pager/                         # 分页列表壳
│       │   └── image/
│       │
│       ├── theme/
│       │   ├── hos_theme.dart
│       │   ├── hos_colors.dart
│       │   ├── hos_typography.dart
│       │   ├── hos_spacing.dart
│       │   ├── hos_theme_extension.dart
│       │   └── hos_theme_mode_provider.dart
│       │
│       ├── analytics/
│       ├── auth/                              # hos_auth_guard.dart
│       ├── config/                            # hos_config · hos_environment
│       ├── constants/
│       ├── debug/                             # Debug 面板（仅 Debug 构建）
│       ├── deeplink/
│       ├── errors/
│       ├── feedback/                          # Toast / 全局错误
│       ├── l10n/                              # hos_locale_provider.dart
│       ├── logging/
│       ├── marketing/
│       ├── media/
│       ├── models/
│       ├── navigation/
│       ├── pagination/
│       ├── permissions/
│       ├── pricing/
│       ├── share/
│       ├── update/
│       ├── utils/
│       └── extensions/                        # ★ 从 utils 拆出（按需）
│           ├── hos_context_extensions.dart
│           └── hos_string_extensions.dart
│
├── test/
│   ├── unit/
│   │   ├── core/
│   │   │   └── network/
│   │   │       └── hos_dio_client_test.dart
│   │   └── features/
│   │       └── auth/
│   │           ├── hos_auth_repository_impl_test.dart
│   │           └── hos_login_use_case_test.dart
│   ├── widget/
│   │   └── features/
│   │       └── auth/
│   │           └── hos_login_page_test.dart
│   └── integration/
│       └── hos_app_test.dart
│
├── assets/
│   ├── mock/                                  # Mock JSON 单一数据源
│   ├── brand/
│   ├── book/ · music/ · video/                # Toolbox 样例资源
│   └── images/
│
├── scripts/                                   # ★ 建议补齐
│   ├── codegen.sh                             # build_runner + gen-l10n
│   └── analyze.sh                             # flutter analyze + test
│
├── server/                                    # 可选 Node Mock API
├── docs/
├── pubspec.yaml
├── l10n.yaml
├── analysis_options.yaml
└── build.yaml                                 # build_runner 配置（可选）
```

> **图例**：`★` 表示相对当前仓库的**建议新增或重组**项；无标记项为已有或已等价存在。

---

## 三、依赖关系（依赖倒置）

```
┌─────────────────────────────────────────────────────────────────┐
│                        依赖方向 (由外向内)                         │
└─────────────────────────────────────────────────────────────────┘

                    ┌──────────────────┐
                    │   Presentation   │  ← 只依赖 State + Domain（接口）
                    │   pages/widgets  │
                    └────────┬─────────┘
                             │
                    ┌────────▼─────────┐
                    │  presentation/   │
                    │     state/       │  ← Riverpod Notifier / Controller
                    │  (*_provider)    │
                    └────────┬─────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
   ┌──────────▼──────────┐    │   ┌──────────▼──────────┐
   │      Domain         │    │   │    Use Cases        │
   │  entities +         │◄───┘   │  （可选，编排多步）   │
   │  repository 接口    │        └──────────┬──────────┘
   │  纯 Dart，零 Flutter │                   │
   └──────────▲──────────┘                   │
              │                              │
   ┌──────────┴──────────┐                   │
   │        Data         │◄──────────────────┘
   │  repository_impl    │
   │  datasources + dto  │
   └──────────┬──────────┘
              │
   ┌──────────▼──────────┐
   │       core/         │
   │  network · storage  │
   │  platform · theme   │
   └─────────────────────┘

横向规则：
  features/*  ──▶  core/*          ✅ 允许
  core/*      ──▶  features/*      ❌ 禁止
  feature A   ──▶  feature B       ❌ 禁止直接 import 页面/Repository
  feature A   ──▶  core/navigation  ✅ 跨模块流程用导航辅助或事件
```

### 3.1 跨 Feature 通信

| 场景 | 推荐方式 |
|------|----------|
| 登录后刷新购物车 | `ref.invalidate(cartControllerProvider)` 或 Session Provider 监听 |
| 支付成功跳订单 | `core/navigation/hos_payment_flow_navigation.dart` |
| 全局 Tab 角标 | `core/navigation/hos_tab_badge_provider.dart` |
| 原生回调 Flutter | `core/platform/hybrid/` |

---

## 四、模块注册约定

### 4.1 新 Feature 清单

新建 `features/<name>/` 时至少包含：

```
features/<name>/
├── router.dart                 # 必须（无路由的 Tab 页除外）
├── domain/entities/            # 有业务模型时必须
├── data/
│   ├── datasources/remote/     # API
│   └── repositories/           # impl + Provider
└── presentation/
    ├── pages/
    └── state/                  # Riverpod
```

### 4.2 路由注册

```dart
// features/foo/router.dart
List<RouteBase> shoFooRoutes({required GlobalKey<NavigatorState> rootKey}) => [
  GoRoute(path: SHOAppRoutes.foo, builder: (_, __) => const SHOFooPage()),
];

// app/router/hos_router.dart
routes: [
  ...shoFooRoutes(rootKey: rootNavigatorKey),
  ...shoShellRoutes(),
],
```

### 4.3 Provider 注册（替代 Service Locator）

```dart
// data/repositories/hos_foo_repository_impl.dart
final fooRepositoryProvider = Provider<SHOFooRepository>(
  (ref) => SHOFooRepositoryImpl(ref.watch(fooRemoteDsProvider)),
);

// presentation/state/hos_foo_controller.dart
final fooControllerProvider =
    AsyncNotifierProvider<SHOFooController, SHOFooState>(SHOFooController.new);
```

---

## 五、命名规范

| 类型 | 规则 | 示例 |
|------|------|------|
| 文件名 | `hos_<topic>_<role>.dart` | `hos_cart_page.dart` |
| 类名 | `SHO` + PascalCase | `SHOCartPage` |
| 路由工厂 | `sho<Feature>Routes` | `shoCartRoutes()` |
| 路径常量 | `SHOAppRoutes.<name>` | `SHOAppRoutes.cart` |
| Domain 接口 | `SHO<X>Repository` | `SHOAuthRepository` |
| Data 实现 | `SHO<X>RepositoryImpl` | `SHOAuthRepositoryImpl` |
| Provider | `<name>Provider` | `authRepositoryProvider` |
| 生成文件 | 不手改 | `*.freezed.dart` `*.g.dart` |

---

## 六、与当前仓库的迁移对照（渐进）

| 目标路径 | 当前路径 | 迁移策略 |
|----------|----------|----------|
| `domain/repositories/hos_auth_repository.dart`（接口） | `data/hos_auth_repository.dart`（具体类） | auth 模块先拆接口 + impl |
| `data/datasources/remote/hos_auth_remote_ds.dart` | `data/hos_auth_api.dart` | 重命名或 re-export，行为不变 |
| `presentation/state/hos_session_provider.dart` | `presentation/hos_session_provider.dart` | 移入 `state/` 子目录 |
| `app/router/guards/hos_auth_redirect.dart` | `hos_router_notifier.dart` 内联逻辑 | 抽纯函数，Notifier 只组合 |
| `core/widgets/loading/` | `core/widgets/hos_loading.dart` | 按类型分子目录（可选） |
| `test/unit/features/auth/` | `test/hos_phase*_test.dart` | 新测试用新结构，旧测试保留 |
| `scripts/codegen.sh` | 无 | 新增脚本 |

**不建议动刀的区域（稳定即可）**：

- `core/platform/hybrid/` — 混合桥已成型
- `core/network/hos_mock_*` — Mock 体系运行良好
- `l10n/*.arb` — 保持 gen-l10n 流程

---

## 七、分层职责速查

| 层 | 放什么 | 不放什么 |
|----|--------|----------|
| **app/** | Shell、Router 组装、Bootstrap | 业务页面、API、Repository |
| **features/domain** | Freezed 实体、Repository **接口**、纯函数 | `import 'package:flutter/`、`dio` |
| **features/data** | API、DTO、Repository **实现** | `BuildContext`、Widget |
| **features/presentation** | Page、Widget、Riverpod State | 直接 `Dio()` 实例化 |
| **core/** | 跨模块基建、平台桥、主题、网络 | 某一业务独有逻辑 |
| **l10n/** | ARB 与生成代码 | 业务字符串硬编码在 Dart |

---

## 八、推荐落地顺序

```
Phase A（规范新代码）
  └─ 新 Feature 按本文 §二 目录创建
  └─ 新测试放入 test/unit/features/<name>/

Phase B（高价值重构）
  └─ auth：domain 接口 + repository_impl
  └─ checkout/order：支付相关 UseCase（可选）
  └─ router/guards/ 拆分 redirect

Phase C（基建增强）
  └─ scripts/codegen.sh
  └─ core/network 拦截器细分
  └─ 离线能力：core/storage/database/

Phase D（测试与文档）
  └─ 核心路径 integration test
  └─ 各 feature README 或 功能清单.md（platform 已有范例）
```

---

## 九、相关文档

| 文档 | 说明 |
|------|------|
| [SHOO项目结构图.md](./SHOO项目结构图.md) | 当前实际结构 + 与模板差异分析 |
| [SHOO项目搭建框架技术方案.md](./SHOO项目搭建框架技术方案.md) | 基建与三方组件详案 |
| [Flutter电商项目基建技术方案.md](./Flutter电商项目基建技术方案.md) | 电商域能力说明 |

---

## 十、一句话

**在你提供的分层模板上，SHOO 目标框架保留 Clean Architecture 与依赖倒置，用 Riverpod 替代 Service Locator、用 `router.dart` 替代 `*_module.dart`、用 `core/platform` 整合平台能力，并以 `presentation/state/` 与 `use_cases/` 按需展开——既对齐业界标准，又避免过度设计。**
