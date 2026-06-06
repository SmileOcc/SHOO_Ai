# SHOO

Shein-style Flutter e-commerce app — **Phase 3 complete** (v0.4.0).

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

### 本地 Mock API Server（可选）

Mock 数据也可通过本地 HTTP 服务提供，便于 Postman/curl 调试，并可 Docker 部署到云端。

```bash
# 终端 1：启动 API（读取 assets/mock/*.json）
cd server && npm install && npm run dev

# 终端 2：Flutter 连接本地 Server（iOS 模拟器 / macOS）
flutter run --dart-define=ENV=local --dart-define=USE_MOCK_API=false

# Android 模拟器
flutter run --dart-define=ENV=local --dart-define=USE_MOCK_API=false \
  --dart-define=API_BASE_URL=http://10.0.2.2:3847/api/v1
```

详见 [server/README.md](server/README.md)。

### 环境变量

```bash
# 默认：dev + 内置 Mock 拦截器（读 assets，无需 Server）
flutter run

# 本地 HTTP Mock Server
flutter run --dart-define=ENV=local --dart-define=USE_MOCK_API=false

# 指定远程 API
flutter run \
  --dart-define=ENV=staging \
  --dart-define=USE_MOCK_API=false \
  --dart-define=API_BASE_URL=https://api.example.com/v1
```

## Phase 1 deliverables (v0.3)

- [x] **购物车 CRUD** — 本地持久化 + Tab 角标 + 全选/结算 (`features/cart/`)
- [x] **SKU 面板** — 尺码 + 数量 + 加入购物袋
- [x] **地址管理** — Mock 地址列表 + 默认选中 (`features/address/`)
- [x] **确认订单** — 地址 + 商品清单 + 提交 (`/checkout`)
- [x] **模拟支付** — 2s 模拟收银台 + 支付成功页 (`/payment/:id`)
- [x] **Mock 接口** — `POST /orders`、`POST /orders/{id}/pay`、`GET /addresses`

## Phase 2 (v0.2)

搜索、商品详情、评价、订单列表、物流轨迹 — 见 `features/search|product|review|order/`

## Phase 3 deliverables (v0.4)

- [x] **价格计算 Domain** — `SHOPriceCalculator` 纯函数 + 单元测试 (`core/pricing/`)
- [x] **优惠券** — 列表 + 结算页选券抵扣 (`features/coupon/`, `/coupons`)
- [x] **售后** — 申请 + 列表 + 订单详情入口 (`features/after_sale/`, `/after-sales`)
- [x] **价格明细 UI** — `HOSPriceBreakdown` 组件 (`core/widgets/hos_price_breakdown.dart`)
- [x] **Mock 接口** — `GET /coupons`、`GET|POST /after-sales`

## Project structure

```
lib/
├── app/              # 入口、路由、Tab Shell
├── core/             # config / network / theme / widgets ...
├── features/
│   ├── auth/ home/ category/ cart/ profile/
│   ├── pricing/      # Phase 3 (core/pricing)
│   ├── search/       # Phase 2
│   ├── product/      # Phase 2
│   ├── review/       # Phase 2
│   ├── order/        # Phase 2
│   ├── checkout/     # Phase 1
│   ├── address/      # Phase 1
│   ├── coupon/       # Phase 3
│   └── after_sale/   # Phase 3
├── l10n/
server/               # 本地 Mock API（可选）
assets/mock/          # Mock JSON 单一数据源
```

## Docs

- [项目方案报告](docs/项目方案报告.md)
- [Flutter 电商项目基建技术方案](docs/Flutter电商项目基建技术方案.md) — 可复刻到其他项目的完整基建文档

## Cursor Skill（一键搭建）

个人 Skill：`~/.cursor/skills/flutter-ecommerce-scaffold/`

对 Agent 说：**「用 flutter-ecommerce-scaffold skill 搭建 Flutter 电商基建，项目名 XXX」**

项目内副本：`.cursor/skills/flutter-ecommerce-scaffold/`

## Next: Phase 4

Sentry 监控、真支付接入、CI 打包、AppConfig flavors。
