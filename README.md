# SHOO

Shein-style Flutter e-commerce app — **Phase 0.5 complete**.

## Confirmed decisions

| 项 | 选型 |
|---|---|
| 视觉风格 | 偏 Shein（视觉密、促销标签、双列瀑布商品流） |
| 后端 | 纯 Mock（本地 JSON + Dio 拦截器，可 `--dart-define` 关闭） |
| 支付 | 首期模拟支付（Phase 1 接入） |

## Tech stack

- Flutter 3.x + Dart 3
- Riverpod（状态管理 / DI）
- go_router（声明式路由 + Tab Shell + 路由守卫）
- Dio + MockRouteRegistry + AuthInterceptor
- freezed + json_serializable（代码生成）
- flutter_secure_storage（Token 安全存储）
- shared_preferences（主题 / 语言偏好）
- flutter_localizations + ARB（中英国际化）
- connectivity_plus（离线检测）

## Run

```bash
cd SHOO
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # 首次或模型变更后
flutter run
```

### 环境变量

```bash
# 默认：dev + Mock API
flutter run

# 指定环境 / 关闭 Mock
flutter run \
  --dart-define=ENV=staging \
  --dart-define=USE_MOCK_API=false \
  --dart-define=API_BASE_URL=https://api.example.com/v1
```

## Phase 0.5 deliverables

- [x] **AppConfig** — 环境 / Mock 开关 / API BaseURL
- [x] **freezed** — Product / Banner / Category / AuthUser / PageResult
- [x] **Session** — SecureStorage Token + 登录/恢复/登出 + 路由守卫
- [x] **Mock 扩展** — 注册表 + auth / product detail / cart 接口
- [x] **Validators** — 表单校验器（required / phone / email / minLength）
- [x] **暗黑模式** — ThemeMode 持久化 + 设置页切换
- [x] **国际化** — 中英 ARB + Locale 持久化 + 设置页切换
- [x] **离线检测** — 顶部离线提示条
- [x] **AppLogger** — 分级日志

## Project structure

```
lib/
├── app/              # 入口、路由、Tab Shell
├── core/
│   ├── config/       # AppConfig / AppEnvironment
│   ├── l10n/         # Locale Provider
│   ├── logging/      # AppLogger
│   ├── models/       # PageResult (freezed)
│   ├── network/      # Dio / Mock / Auth / Connectivity
│   ├── storage/      # Local + Secure Storage
│   ├── theme/        # Token + ThemeMode Provider
│   ├── utils/        # Validators / Debouncer / Price
│   └── widgets/      # 组件库
├── features/
│   ├── auth/         # 登录 / Session
│   ├── home/
│   ├── category/
│   ├── cart/
│   └── profile/      # 个人中心 + Settings
└── l10n/             # app_en.arb / app_zh.arb
```

## Docs

- [项目方案报告](docs/项目方案报告.md)
- [Flutter 电商项目基建技术方案](docs/Flutter电商项目基建技术方案.md) — 可复刻到其他项目的完整基建文档

## Cursor Skill（一键搭建）

个人 Skill：`~/.cursor/skills/flutter-ecommerce-scaffold/`

对 Agent 说：**「用 flutter-ecommerce-scaffold skill 搭建 Flutter 电商基建，项目名 XXX」**

项目内副本：`.cursor/skills/flutter-ecommerce-scaffold/`

## Next: Phase 1

MVP 交易闭环 — 商品详情、购物车、确认订单、模拟支付、订单列表。
# SHOO_Ai
