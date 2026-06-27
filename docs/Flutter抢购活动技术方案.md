# Flutter 抢购活动技术方案

> 版本：v1.0 · 模块：`features/flash_sale/` · 状态：已实现 Mock + 原生列表页

## 1. 背景与目标

SHOO 原有限时抢购入口（Banner `/flash-sale`、deeplink）跳转搜索页，缺少原生抢购能力。本方案落地：

- 原生 **限时抢购列表页**（活动日 / 场次 / 推广 / 领券 / 排序 / 商品分页）
- 统一 **`SHOPromoBadge`** 折扣/满减标识组件
- 商品详情 **`sessionId`** 活动态改造
- Mock 资产 + Node 本地 Server 双端 Mock

## 2. 模块结构

```
lib/features/flash_sale/
├── domain/entities/hos_flash_sale_models.dart   # freezed 模型
├── data/
│   ├── datasources/remote/hos_flash_sale_remote_ds.dart
│   └── repositories/hos_flash_sale_repository_impl.dart
├── presentation/
│   ├── pages/hos_flash_sale_page.dart
│   ├── state/hos_flash_sale_controller.dart
│   └── widgets/
│       ├── hos_flash_sale_product_card.dart
│       ├── hos_flash_sale_countdown.dart
│       └── hos_sku_chip_row.dart
└── router.dart

lib/core/widgets/hos_promo_badge.dart              # 全局促销标识
lib/core/network/hos_flash_sale_mock_dynamic.dart  # 客户端动态 Mock
server/src/flashSaleMock.js                        # Server 动态 Mock
```

## 3. 促销类型（后台可配置）

### 3.1 折扣类 `type`

| API 值 | 枚举 | 角标色 | 示例 |
|--------|------|--------|------|
| `discount_percent` | discountPercent | 黄 #FFB800 | 8.5折 |
| `discount_fixed` | discountFixed | 黄 | 减¥20 |
| `discount_flash` | discountFlash | 黄 | 限时闪购 |
| `discount_member` | discountMember | 黄 | 会员95折 |
| `discount_bundle` | discountBundle | 黄 | 2件8折 |

### 3.2 满减类 `type`

| API 值 | 枚举 | 角标色 | 示例 |
|--------|------|--------|------|
| `full_reduction_tier` | fullReductionTier | 红 #FF4657 | 满300减50 |
| `full_reduction_single` | fullReductionSingle | 红 | 单件减20 |
| `full_reduction_cross` | fullReductionCross | 红 | 跨店满减 |
| `full_reduction_category` | fullReductionCategory | 红 | 品类满减 |

JSON 示例：

```json
{
  "type": "full_reduction_tier",
  "label": "满300减50",
  "enabled": true
}
```

## 4. 时间窗口（三轴独立）

| 窗口 | 字段 | 说明 |
|------|------|------|
| 领券窗口 | `claimStartAt` ~ `claimEndAt` | 领券模块倒计时绑定此窗口 |
| 抢购窗口 | `startAt` ~ `endAt` | 控制购买按钮、商品状态 |
| 价格生效 | 默认 = 抢购窗口 | 未开始/已结束展示原价，进行中展示活动价 |

**规则**：领券倒计时结束仅将「未领取」券置为 `expired`；已领取券在抢购进行中仍可用于下单。

Mock 场次模板（`sessionTemplates`）：

- 10:00 / 14:00 / 20:00 三场
- 默认 `claimLeadMinutes: 30`，`claimTrailMinutes: 10`

## 5. API 契约

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/flash-sale/calendar` | 昨天起 7 天活动日 + 聚合状态 |
| GET | `/flash-sale/page` | `date`, `sessionId`, `sort`, `page`, `pageSize` |
| GET | `/flash-sale/product-activity` | `productId`, `sessionId` — 详情活动上下文 |
| GET | `/flash-sale/follows` | 抢购关注列表 |
| POST | `/flash-sale/follow` | `{ sessionId, productId }` |
| POST | `/flash-sale/coupons/{id}/claim` | 领券 |

`sort`：`hot` | `price_asc` | `price_desc` | `newest`

## 6. SHOPromoBadge 预设

| Preset | 场景 |
|--------|------|
| `cornerOnImage` | 商品图左上角折扣/满减角标 |
| `wrapTag` | 列表活动标签 Wrap（最多 6 个） |
| `priceInline` | 详情价格行旁标识 |
| `overlayBanner` | 详情图底部半透明活动状态条 |

## 7. 页面交互

### 7.1 抢购列表页 `/flash-sale`

1. **活动日 Tab**：7 天，标识未开始/进行中/已结束
2. **场次 Chip**：10:00 / 14:00 / 20:00
3. **推广入口**：deeplink 配置驱动（首页 Banner 第一个、`SHODeepLinkNavigator`）
4. **领券模块**：按 `claimPhase` 显示未开始 / 倒计时 / 已失效
5. **排序栏**：热门 / 价格（升序切换降序）/ 最新 — 切换保留选中态并刷新商品
6. **商品列表**：下拉刷新 + 上拉加载；排序切换重置 page=1

### 7.2 商品卡片

- 左图 96×96 + 角标；右文标题 2 行 + SKU 单行省略展开 + 活动标签 Wrap + 价格/库存 + 按钮
- 未开始：关注 + 置灰购买；进行中：库存 + 购买；结束/售罄：置灰购买

### 7.3 商品详情

路由：`/product/:id?sessionId=fs-2025-06-24-10`

- 未开始：原价 + 图底部 overlay + 灰态 Badge
- 进行中：活动价 + 划线原价 + 高亮 Badge
- 已结束/售罄：原价 + 结束 overlay

## 8. Mock 数据

| 文件 | 用途 |
|------|------|
| `assets/mock/flash_sale_catalog.json` | 主数据（商品、券、场次模板、推广入口） |
| `assets/mock/flash_sale_follows.json` | 关注列表 |
| `assets/mock/flash_sale_follow_ok.json` | 关注 POST |
| `assets/mock/flash_sale_claim_ok.json` | 领券 POST |

客户端：`hos_flash_sale_mock_dynamic.dart` 按 `DateTime.now()` 动态计算 7 天日历、场次状态、券态、商品态、排序分页。

服务端：`server/src/flashSaleMock.js` 镜像相同逻辑；数据文件同步至 `server/data/mock/`。

注册位置：

- `lib/core/network/hos_mock_route_registry.dart`
- `server/src/routeRegistry.js`

## 9. 入口

| 入口 | 路径 |
|------|------|
| 首页 Banner 第一项 | `/flash-sale` → `SHOAppRoutes.flashSale` |
| 百宝箱 | 「限时抢购」→ `/flash-sale` |
| Deeplink | `shoo://flash-sale` / `https://shoo.app/flash-sale` |

## 10. 状态机摘要

### 商品状态

```
now < startAt           → not_started  → 原价、可关注
startAt ≤ now < endAt   → ongoing      → 活动价（stock>0）
now ≥ endAt / stock=0   → ended/sold_out → 原价、置灰购买
```

### 券状态 × 领券阶段

| claimPhase | 未领券 | 已领券 |
|------------|--------|--------|
| before_claim | not_started | claimed |
| claiming | claimable | claimed |
| after_claim | expired | claimed（抢购中仍可用） |

## 11. 已实现扩展（Phase 2）

- [x] Profile「活动通知」+ 抢购关注列表页（`/profile/flash-sale-follows`）
- [x] T-5min 前台弹窗 + 本地通知 + Push Mock 注册（FCM/APNs 接入点见 `SHOPushNotificationService`）
- [x] Checkout 活动价 / 满减阶梯校验（`checkoutActivityLinesProvider` + Mock `POST /orders` 校验）
- [x] 关注数据持久化与服务端同步（SharedPreferences + `GET/POST /flash-sale/follow*`）

## 12. 本地验证

```bash
# 客户端 Mock（默认）
flutter run

# Node Mock Server
cd server && npm start
# AppConfig: USE_MOCK_API=false, API_BASE_URL=http://localhost:3000/api/v1
```

验证路径：首页 Banner → 抢购页；百宝箱 → 限时抢购；点击商品 → 详情带活动 overlay。
