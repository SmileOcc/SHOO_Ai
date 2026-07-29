# Flutter 主题活动 ThemeActivity 技术方案

> **版本**：v0.1（方案稿）  
> **日期**：2026-07-29  
> **状态**：待实现 · 方案已定稿，后续按分期落地  
> **模块规划**：`features/theme_activity/`  
> **入口规划**：常用工具箱 →「主题活动 ThemeActivity」  
> **关联**：`Flutter活动页WebView技术方案.md`、`Flutter抢购活动技术方案.md`、`lib/features/toolbox/`

---

## 一、文档目的

将「配置驱动的通用主题活动页」落地为可实施的技术方案，明确：

1. 页面与模块分层、配置模型与校验规则；
2. 各模块能力边界与通用样式体系；
3. 底部商品唯一约束与上拉加载更多；
4. 与现有 WebView 活动 / S活动 / 抢购活动的边界；
5. 工具箱入口与 Mock 验收路径；
6. 分期实现顺序，便于后续迭代完善。

**本文为方案文档，不包含实现代码。** 实现时以本文为单一事实来源，变更请先改文档再改代码。

---

## 二、背景与目标

### 2.1 背景

运营侧需要快速拼装不同视觉风格的营销活动页（大促长图、券+倒计时、九宫格入口、瀑布流商品等）。现有能力分散：

| 能力 | 现状 | 缺口 |
|------|------|------|
| WebView 活动 | `features/activity_webview/` | 偏 H5，Native 模块拼装弱 |
| S活动 | iOS Hybrid Demo | 非正式通用配置方案 |
| 抢购 | `features/flash_sale/` | 垂直场景，非通用活动引擎 |
| 工具箱 | 已有多活动入口 | 缺「配置驱动 Native 活动页」入口 |

### 2.2 目标

落地 **ThemeActivity** = 配置驱动的 Native 活动页引擎：

- 运营通过一份 JSON 配置驱动整页；
- 客户端按 `modules[]` 顺序渲染，样式可组合；
- 支持多种布局/营销模块；
- **底部商品区最多 1 个**，且支持上拉加载更多；
- 工具箱可进入预览 / Mock 调试。

### 2.3 非目标（本期不做）

- 运营可视化拖拽搭建器（P3 再议）；
- 完全替代 WebView 活动页（Web 仅作为模块之一）；
- 复杂规则引擎 / 实时库存秒杀（可跳转抢购页）。

---

## 三、与现有活动边界

| 名称 | 位置 | 形态 | 与 ThemeActivity 关系 |
|------|------|------|----------------------|
| 营销弹窗 | `core/marketing/` | 首页弹窗 | 可 deeplink 跳入 ThemeActivity |
| S活动 | Hybrid Bridge | 原生 Demo | 保留；正式能力由 ThemeActivity 承接 |
| WebView 活动页 | `features/activity_webview/` | 整页 H5 | **并行**；ThemeActivity 内可嵌 `web` 模块 |
| 限时抢购 | `features/flash_sale/` | 垂直抢购页 | Action 可跳转；不合并引擎 |
| **主题活动（本文）** | 新建 `features/theme_activity/` | Native 模块栈 + 可选底部商品 | **本文实施对象** |

---

## 四、总体架构

### 4.1 页面结构

```
┌─────────────────────────────┐
│  Page Shell（导航栏 / 整页背景）│
│  ┌───────────────────────┐  │
│  │ Module Stack（可多个）  │  │  ← 上方模块可重复、可排序
│  │  grid / banner / coupon │  │
│  │  countdown / marquee …  │  │
│  └───────────────────────┘  │
│  ┌───────────────────────┐  │
│  │ Footer Products（0~1）  │  │  ← 必须在最后；三选一布局
│  │  + 上拉加载更多         │  │
│  └───────────────────────┘  │
└─────────────────────────────┘
```

### 4.2 核心原则

1. **模块正交**：每个模块只做一件事，互不嵌套（除模块内部 item）。
2. **样式下沉**：页面级 `defaultStyle` + 模块级 `style` 覆盖。
3. **底部唯一**：`footer` 只能 0 或 1 个，且固定钉在 modules 之后。
4. **向前兼容**：未知 `type` 静默跳过；缺字段走默认值；单模块失败不白屏。

### 4.3 目录规划（实现时）

```
lib/features/theme_activity/
├── domain/
│   ├── entities/          # PageConfig / Module / Style / Action / Product
│   └── validators/        # 配置校验
├── data/
│   ├── datasources/
│   │   ├── local/         # Mock JSON
│   │   └── remote/        # 远程配置 + 商品分页
│   └── repositories/
├── presentation/
│   ├── pages/             # ThemeActivityPage（CustomScrollView 引擎）
│   ├── state/             # 配置加载 / footer 分页
│   ├── modules/           # 每 type 一个 ModuleBuilder
│   ├── footer/            # 三种列表 + LoadMore
│   └── style/             # ModuleStyle → Decoration / TextStyle
└── router.dart
```

注册表模式：`Map<ModuleType, ModuleBuilder>`，新模块只注册 builder，不改引擎核心。

### 4.4 工具箱入口

在 `hos_toolbox_page.dart` 的「工具」分组新增：

| 项 | 说明 |
|----|------|
| 文案 | 主题活动 / ThemeActivity |
| 路由 | 如 `/toolbox/theme-activity` → 模板列表 → 活动页 |
| 能力 | Mock 模板列表；可切换读 Mock / 远程；调试展示配置 JSON |

建议预置 3～5 套 Mock 模板，覆盖全部模块类型。

---

## 五、配置分层

### 5.1 活动页级 Page Config

| 字段 | 说明 | 默认 |
|------|------|------|
| `activityId` | 活动唯一 ID | **必填** |
| `title` | 导航栏标题 | — |
| `status` | `draft` / `online` / `offline` | `draft` |
| `startAt` / `endAt` | 活动有效期 | — |
| `expiredBehavior` | `block`（拦截页）/ `browse`（仍可浏览） | `browse` |
| `navBar` | 导航栏样式 | 见下 |
| `pageBackground` | `{ color, image, fit }` | `#FFFFFF` |
| `safeArea` | 是否避开刘海/底部 | `true` |
| `share` | `{ title, image, url }` | 可选 |
| `defaultStyle` | 全局模块默认样式 | 见 §6 |
| `modules` | 上方模块数组 | `[]` |
| `footer` | 底部商品模块 | `null` 或 1 个对象 |
| `tracking` | `{ prefix, channel }` | 可选 |

**导航栏 `navBar`：**

| 字段 | 说明 |
|------|------|
| `style` | `solid` / `transparent` / `gradient` |
| `backgroundColor` | 背景色 |
| `titleColor` | 标题色 |
| `iconColor` | 返回/分享图标色 |
| `showShare` | 是否显示分享 |
| `immersive` | 沉浸式（内容顶到状态栏下） |

### 5.2 模块公共结构 ModuleBase

所有上方模块共用：

| 字段 | 说明 |
|------|------|
| `moduleId` | 唯一，埋点/刷新用 |
| `type` | 模块类型枚举 |
| `visible` | 是否展示（A/B、灰度） |
| `sort` | 排序权重（越小越靠上） |
| `style` | `ModuleStyle`，覆盖 `defaultStyle` |
| `margin` | `{ top, right, bottom, left }` 或统一 number |
| `padding` | 内边距，同上 |
| `height` | 可选固定高度；不设则自适应 |
| `minHeight` | 可选最小高度 |
| `dataSource` | 静态 / API / 商品查询 |
| `actionDefaults` | 模块内默认点击行为兜底 |

### 5.3 Action（点击行为）

```text
Action {
  type: none | product | category | url | webview | coupon | route | share | custom
  value: string          // id / url / route path
  params: map            // 额外参数
  needLogin: bool
}
```

### 5.4 DataSource

| 模式 | 用途 |
|------|------|
| `static` | 配置内直接带 `items[]` |
| `api` | `{ url, method, params, mapping }` |
| `productQuery` | `{ ids[] / categoryId / tag / sort / pageSize }` |

底部商品列表建议强制 `productQuery` 或 `api`，以支持分页。

---

## 六、通用样式 ModuleStyle

渲染优先级：**模块 style > 页面 defaultStyle > 客户端内置默认值**。

| 分组 | 字段 | 说明 |
|------|------|------|
| **背景** | `backgroundColor` | `#RRGGBB` / `#AARRGGBB` |
| | `backgroundImage` | 图片 URL |
| | `backgroundFit` | `cover` / `contain` / `fill` / `repeat` |
| | `backgroundOverlayColor` | 背景图蒙层色 |
| **圆角** | `borderRadius` | 统一圆角，或 `{ tl, tr, br, bl }` |
| | `clipContent` | 子内容是否裁剪到圆角内 |
| **边框** | `borderWidth` | `0` = 无边框 |
| | `borderColor` | 边框颜色 |
| | `borderStyle` | `solid`（一期） |
| **阴影** | `shadow` | `{ color, blur, offsetX, offsetY, spread }`，可关 |
| **间距** | `itemGap` | 模块内 item 间距 |
| | `rowGap` / `columnGap` | 网格行列间距 |
| **字体** | `titleColor` / `titleFontSize` / `titleFontWeight` | 主标题 |
| | `subtitleColor` / `subtitleFontSize` | 副标题 |
| | `bodyColor` / `bodyFontSize` | 正文 |
| | `priceColor` / `originPriceColor` | 价格 |
| | `highlightColor` | 强调色（倒计时数字、优惠金额） |
| **透明度** | `opacity` | 0～1 |

所有上方模块与 footer **均支持**背景色或背景图（通过 `style`）。

---

## 七、模块类型清单

### 7.1 类型总表

| type | 名称 | 说明 |
|------|------|------|
| `grid` | 网格 / 一行 N 个 / Menu | 含九宫格 preset |
| `unevenGrid` | 不均分布局 | 两行四格等 |
| `web` | Web 活动块 | 可配宽高 |
| `coupon` | 优惠券 | 领取/去使用 |
| `countdown` | 倒计时 | 多种格式与布局 |
| `marquee` | 跑马灯 | 横/竖滚动公告 |
| `bannerRow` | 一行广告图 | 单图 + 可选热区 |
| `bannerStack` | 多行广告图 | 拼接成长图效果 |
| `productScroll` | 横向商品列表 | 可横向滚动 |
| `menu` | 自定义行列菜单 | 可底层复用 grid |

Footer 独立字段，不进 `modules[]`（见 §8）。

---

### 7.2 `grid` — 一行 N 个 / 九宫格 / Menu

| 配置 | 说明 |
|------|------|
| `columns` | 列数 2～6 |
| `rows` | 可选；有则固定行数 |
| `preset` | 可选 `nineGrid`（运营模板，底层仍是 grid） |
| `itemStyle` | `iconText` / `imageOnly` / `imageTitle` / `imageTitleDesc` |
| `itemAspectRatio` | 如图 `1`、`0.75` |
| `imageCornerRadius` | item 图圆角 |
| `textAlign` | 文案对齐 |
| `items[]` | `{ image, title, subtitle, badge, action }` |

---

### 7.3 `unevenGrid` — 两行四格不均分

| 配置 | 说明 |
|------|------|
| `layoutPreset` | `leftBig_rightTwo` / `topBig_bottomThree` / `leftBig_rightThree` / `custom` |
| `slots[]` | 槽位：`spanRow` / `spanCol`、`image`、`action` |
| `aspectRatio` | 整块宽高比 |
| `gap` | 槽位间距 |

`custom`：总列 2 或 3，每 slot 声明 `row` / `col` / `rowSpan` / `colSpan`。

---

### 7.4 `web` — Web 活动模块

| 配置 | 说明 |
|------|------|
| `url` | H5 地址 |
| `width` | `match_parent` / 固定 dp / 百分比 |
| `height` | 固定高度（与 aspectRatio 二选一） |
| `aspectRatio` | 宽高比 |
| `scrollEnabled` | Web 内滚动；建议 `false`，整页统一滚 |
| `bridgeEnabled` | 是否注入活动 JS Bridge |
| `placeholderColor` | 加载占位色 |
| `fallbackImage` | 失败兜底图 + action |

可复用 `activity_webview` 的 bridge 能力子集。

---

### 7.5 `coupon` — 优惠券

| 配置 | 说明 |
|------|------|
| `layout` | `horizontalScroll` / `grid` / `single` |
| `columns` | grid 时列数 |
| `cardStyle` | `ticket` / `rect` / `image` |
| `showProgress` | 是否显示「已抢 xx%」 |
| `items[]` | 见下 |

**单券字段：**  
`couponId, type(fullReduce/discount/gift), amount, condition, discount, title, desc, expireAt, status(claimable/claimed/soldOut/expired), buttonText, action, bgImage, amountColor, buttonColor`

领取走统一 `claimCoupon`；失败 toast；成功更新本地 status。

---

### 7.6 `countdown` — 倒计时

| 配置 | 说明 |
|------|------|
| `mode` | `toEnd` / `toStart` / `daily` |
| `endAt` / `startAt` | ISO 时间 |
| `dailyWindow` | `{ start: "10:00", end: "22:00" }` |
| `format` | `DHMS` / `HMS` / `MS` |
| `layout` | `inline` / `block` / `flip` |
| `prefixText` / `suffixText` | 前后文案 |
| `digitStyle` | 数字块背景色、字色、圆角、字号 |
| `separatorStyle` | 分隔符/单位标签色 |
| `onExpireAction` | 结束后：隐藏 / 刷新 / 跳转 / 展示文案 |

可参考 `flash_sale` 倒计时组件实现经验。

---

### 7.7 `marquee` — 跑马灯

| 配置 | 说明 |
|------|------|
| `direction` | `horizontal` / `vertical` |
| `speed` | px/s 或 `slow` / `normal` / `fast` |
| `pauseOnTap` | 点击是否暂停 |
| `loop` | 是否循环 |
| `icon` | 左侧公告图标 |
| `items[]` | `{ text, textColor, action }` |
| `separator` | 条目分隔 |
| `height` | 条高度 |

---

### 7.8 `bannerRow` — 一行广告图

| 配置 | 说明 |
|------|------|
| `image` | 单图 URL |
| `aspectRatio` / `height` | 二选一 |
| `action` | 点击 |
| `hotspots[]` | `{ x%, y%, w%, h%, action }` 可选热区 |

---

### 7.9 `bannerStack` — 多行广告图（长图效果）

| 配置 | 说明 |
|------|------|
| `items[]` | `{ image, width, height|aspectRatio, action, hotspots[] }` |
| `gap` | 图间距，默认 `0`（无缝） |
| `lazyLoad` | 按可视区域加载 |
| `fullBleed` | 是否左右顶满 |

---

### 7.10 `productScroll` — 横向商品列表

| 配置 | 说明 |
|------|------|
| `cardWidth` | 卡片宽 |
| `imageAspectRatio` | 图比例 |
| `showCartButton` | 是否加购 |
| `showOriginPrice` | 划线价 |
| `showTitleLines` | 标题行数 1/2 |
| `items` / `dataSource` | 商品数据 |
| `edgeFade` | 边缘渐隐提示可滑 |

---

### 7.11 `menu` — 自定义行列 Menu

运营心智上可与 grid 区分；**底层可复用 grid 渲染器**：

| 额外字段 | 说明 |
|----------|------|
| `showTitleBar` | 模块标题栏 |
| `titleBar` | `{ title, moreText, moreAction }` |
| `indicator` | 多页指示点 |
| `pageSize` | 每页个数 = rows × columns |
| `rows` / `columns` | 行列数 |

---

## 八、底部商品模块 footer（唯一约束）

### 8.1 强制规则

1. 整页最多 **1** 个 footer。  
2. 若存在，固定在所有 `modules` 之后（客户端忽略其 sort，钉底）。  
3. `type` 只能是以下之一：

| type | 布局 | 加载更多 |
|------|------|----------|
| `productListSingle` | 一行一列 | 上拉分页 |
| `productListDouble` | 一行两列 | 上拉分页 |
| `productWaterfall` | 多列瀑布流 | 上拉分页 |

### 8.2 Footer 公共配置

| 字段 | 说明 |
|------|------|
| `columns` | waterfall 列数，默认 `2`（可为 2/3） |
| `pageSize` | 每页条数 |
| `dataSource` | **必填**，支持 `page` / `pageSize` |
| `cardStyle` | 卡片样式变体 |
| `emptyText` / `emptyImage` | 空态 |
| `errorRetry` | 失败可重试 |
| `loadMoreThreshold` | 距底部多少 px 触发 |
| `style` | 同 ModuleStyle（背景色/图、圆角、边框等） |
| `header` | 可选标题条（footer 内部，非独立模块） |

### 8.3 商品卡片 ProductCard

```text
productId, image, title, subtitle,
price, originPrice, currency,
tags[], salesText, rank,
badge,
action, cartAction
```

瀑布流：高度由图比例 + 文案行数自适应。

### 8.4 分页协议

```text
Request:  { activityId, moduleId, page, pageSize, extra }
Response: { list: ProductCard[], page, pageSize, hasMore, total? }
```

### 8.5 滚动容器

整页一个 `CustomScrollView`（或等价）：

- 上方 modules → slivers；
- footer → `SliverList` / `SliverGrid` / 瀑布流 sliver；
- 底部 loading / noMore 指示。

注意横向 `productScroll` / 跑马灯与外层竖滑的手势冲突（横向区域抢水平手势）。

---

## 九、配置 JSON 骨架

```json
{
  "activityId": "theme_spring_2026",
  "title": "春季大促",
  "status": "online",
  "navBar": {
    "style": "transparent",
    "titleColor": "#FFFFFF",
    "showShare": true,
    "immersive": true
  },
  "pageBackground": {
    "color": "#FFF5F0",
    "image": null
  },
  "defaultStyle": {
    "borderRadius": 12,
    "borderWidth": 0,
    "titleColor": "#222222",
    "priceColor": "#E53935"
  },
  "modules": [
    {
      "moduleId": "m_banner",
      "type": "bannerStack",
      "sort": 10,
      "style": {},
      "items": []
    },
    {
      "moduleId": "m_countdown",
      "type": "countdown",
      "sort": 20,
      "endAt": "2026-08-01T23:59:59+08:00",
      "format": "DHMS",
      "layout": "block"
    },
    {
      "moduleId": "m_coupon",
      "type": "coupon",
      "sort": 30,
      "layout": "horizontalScroll",
      "items": []
    },
    {
      "moduleId": "m_marquee",
      "type": "marquee",
      "sort": 40,
      "direction": "horizontal",
      "items": []
    },
    {
      "moduleId": "m_grid",
      "type": "grid",
      "sort": 50,
      "columns": 4,
      "items": []
    },
    {
      "moduleId": "m_uneven",
      "type": "unevenGrid",
      "sort": 60,
      "layoutPreset": "leftBig_rightTwo",
      "slots": []
    },
    {
      "moduleId": "m_scroll",
      "type": "productScroll",
      "sort": 70,
      "cardWidth": 120,
      "dataSource": { "mode": "static", "items": [] }
    },
    {
      "moduleId": "m_web",
      "type": "web",
      "sort": 80,
      "url": "https://example.com/promo",
      "aspectRatio": 1.2
    }
  ],
  "footer": {
    "type": "productWaterfall",
    "columns": 2,
    "pageSize": 10,
    "dataSource": {
      "mode": "productQuery",
      "tag": "spring"
    },
    "style": {
      "backgroundColor": "#FFFFFF"
    }
  }
}
```

正式实现前建议再收敛为 **JSON Schema**（另文或本文附录演进）。

---

## 十、配置校验规则

| 规则 | 级别 |
|------|------|
| `activityId`、`title` 必填 | error |
| `footer` 超过 1 个 | error |
| `footer.type` 不在三选一 | error |
| footer 存在但缺 `dataSource` | error |
| `grid.columns` ∉ [1, 6] | warn / clamp |
| `unevenGrid.slots` 与 preset 不符 | error |
| `web` 缺 `height` 且缺 `aspectRatio` | error |
| `countdown` 缺必要时间字段 | error |
| 未知 module `type` | warn + skip |
| 颜色非法 | warn + 回退默认 |
| 活动未开始/已结束 | 按 `expiredBehavior` |

后台与客户端 **双端校验**；客户端校验失败模块降级隐藏，页级 error 可展示错误态。

---

## 十一、渲染与交互规范

1. **单滚动容器**，避免多嵌套滚动冲突。  
2. **可选下拉刷新**：重拉配置 + footer 重置 `page=1`。  
3. **模块显隐**：`visible=false` 或倒计时结束后按策略移除并折叠空白。  
4. **图片**：统一占位、失败兜底、长图懒加载。  
5. **登录**：`needLogin` 先登录再续跳。  
6. **埋点**：`activityId + moduleId + itemId + actionType`；曝光按可见比例。  
7. **性能**：modules 懒构建；`bannerStack` 按屏预加载；列表卡片复用。  
8. **错误隔离**：单模块解析/渲染失败只隐藏该模块。

---

## 十二、分期落地计划

| 期次 | 范围 | 验收要点 |
|------|------|----------|
| **P0** | 目录骨架 + PageShell + ModuleStyle 解析 + `bannerRow` / `bannerStack` + `grid` + footer 三选一 + 上拉加载 + 工具箱入口 + 2～3 套 Mock | 能打开活动页，底部可加载更多，样式背景/圆角/边框生效 |
| **P1** | `coupon` + `countdown` + `marquee` + `productScroll` + `unevenGrid` + `menu` | 大促常用模块齐全 |
| **P2** | `web` 模块 + 热区 + 分享 + 下拉刷新 + 远程配置 + 埋点 | 可对接真实运营配置 |
| **P3** | 运营可视化搭建、A/B、`visible` 规则、更多 layoutPreset | 提效运营 |

### P0 建议实现顺序

1. Domain 模型 + 校验器 + Mock JSON  
2. ThemeActivityPage 引擎（CustomScrollView + Module 注册表）  
3. ModuleStyle → BoxDecoration / TextStyle  
4. bannerRow / bannerStack / grid  
5. footer：单列 / 双列 / 瀑布流 + LoadMore  
6. 工具箱入口 + 模板列表页  
7. 路由 / i18n / 基础埋点占位  

---

## 十三、建议预置 Mock 模板

| 模板 ID | 场景 | 模块组合 | Footer |
|---------|------|----------|--------|
| `demo_long_banner` | 长图大促 | bannerStack + marquee | `productListDouble` |
| `demo_coupon_rush` | 券+倒计时 | countdown + coupon + grid | `productListSingle` |
| `demo_nine_waterfall` | 九宫格+瀑布流 | grid(nineGrid) + unevenGrid + productScroll | `productWaterfall` |
| `demo_web_embed`（P2） | 内嵌 H5 | bannerRow + web | `productListDouble` |

---

## 十四、风险与注意点

| 风险 | 应对 |
|------|------|
| Web 模块与整页滚动冲突 | 默认关闭 Web 内滚动，固定高度 |
| 瀑布流高度跳动 | 图尺寸已知或占位比固定 |
| 配置膨胀难维护 | 模板 + Schema 校验 + 模块正交 |
| 与 activity_webview 职责重叠 | 文档边界清晰；bridge 复用子集 |
| 横向列表手势 | 使用明确的横向手势竞技场 |

---

## 十五、后续文档演进

实现过程中可追加：

1. **附录 A**：完整 JSON Schema；  
2. **附录 B**：字段默认值全表；  
3. **附录 C**：埋点事件字典；  
4. **附录 D**：与 `activity_webview` bridge 复用清单。

变更流程：先更新本文版本号与变更记录，再提交代码。

### 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v0.1 | 2026-07-29 | 初稿：总体架构、模块清单、样式、footer 约束、分期与工具箱入口 |

---

## 十六、结论

ThemeActivity 以 **配置驱动 + 模块注册表 + 底部唯一商品区** 为核心，覆盖一行 N / 九宫格 / 不均分 / Web / 券 / 倒计时 / 跑马灯 / 广告图 / 横向商品 / Menu / 底部三种商品流，并统一背景、圆角、边框、字体色等样式能力。

**下一步**：按 **P0** 在 `features/theme_activity/` 开工；需要时先补 JSON Schema 或 Mock 模板细节，再写代码。
