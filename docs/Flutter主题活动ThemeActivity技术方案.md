# Flutter 主题活动 ThemeActivity 技术方案

> **版本**：v0.2（方案稿）  
> **日期**：2026-08-15  
> **状态**：待实现 · 方案已定稿，后续按分期落地  
> **模块规划**：`features/theme_activity/`  
> **入口规划**：常用工具箱 →「主题活动 ThemeActivity」  
> **关联**：  
> - `Flutter活动页WebView技术方案.md`  
> - `Flutter抢购活动技术方案.md`  
> - `lib/core/deeplink/DEEPLINK.md`（**页面跳转唯一事实来源**）  
> - `lib/features/toolbox/`、`docs/服务启动事项.md`

---

## 一、文档目的

将「配置驱动的通用主题活动页」落地为可实施的技术方案，明确：

1. 页面与模块分层、配置模型与校验规则；
2. 各模块能力边界与通用样式体系；
3. 底部商品唯一约束与上拉加载更多；
4. **所有「打开新页面」的跳转一律通过 App Link / Deep Link 配置与执行**（商品、广告、分类、活动、优惠券中心、抢购等）；
5. 与现有 WebView 活动 / S活动 / 抢购活动的边界；
6. 工具箱入口与 Mock 验收路径；
7. 分期实现顺序，便于后续迭代完善。

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
| Deep Link | `lib/core/deeplink/` | 已统一解析/鉴权/导航，活动配置尚未强制复用 |
| 工具箱 | 已有多活动入口 | 缺「配置驱动 Native 活动页」入口 |

### 2.2 目标

落地 **ThemeActivity** = 配置驱动的 Native 活动页引擎：

- 运营通过一份 JSON 配置驱动整页；
- 客户端按 `modules[]` 顺序渲染，样式可组合；
- 支持多种布局/营销模块；
- **底部商品区最多 1 个**，且支持上拉加载更多；
- **跳转统一**：凡配置侧「点一下打开另一个界面」的能力，只配置 Deep Link / App Link（或等价 in-app path），客户端只走 `SHODeepLinkNavigator` / `SHORouteNavigator.followLink`；
- 工具箱可进入预览 / Mock 调试。

### 2.3 非目标（本期不做）

- 运营可视化拖拽搭建器（P3 再议）；
- 完全替代 WebView 活动页（Web 仅作为模块之一）；
- 复杂规则引擎 / 实时库存秒杀（可 **Deep Link 跳转**抢购页）；
- 在配置里发明一套平行于 Deep Link 的 `route` / `productId` 跳转 DSL（**明确禁止**，见 §5.3）。

---

## 三、与现有活动边界

| 名称 | 位置 | 形态 | 与 ThemeActivity 关系 |
|------|------|------|----------------------|
| 营销弹窗 | `core/marketing/` | 首页弹窗 | CTA **用 Deep Link** 跳入 ThemeActivity / 其它页 |
| S活动 | Hybrid Bridge | 原生 Demo | 保留；正式能力由 ThemeActivity 承接 |
| WebView 活动页 | `features/activity_webview/` | 整页 H5 | **并行**；ThemeActivity 内可嵌 `web` 模块；H5 内跳转亦走 Bridge → Deep Link |
| 限时抢购 | `features/flash_sale/` | 垂直抢购页 | 通过 Deep Link（如 `https://shoo.app/flash-sale?...`）进入；不合并引擎 |
| Deep Link 基建 | `lib/core/deeplink/` | 解析 + 鉴权 + 导航 | **ThemeActivity 跳转唯一出口** |
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
5. **跳转唯一通道（硬约束）**：  
   - **打开新页面** → 只允许配置 `link`（App Link / Deep Link / in-app path），统一调用 Deep Link 导航。  
   - **页内行为**（不换页）→ 用独立字段/能力（如领券 API、倒计时结束隐藏），**禁止**伪装成页面跳转。  
   - 禁止在配置中写 `go_router` 私有实现细节、禁止写 `Navigator.push` 式伪协议。

### 4.3 目录规划（实现时）

```
lib/features/theme_activity/
├── domain/
│   ├── entities/          # PageConfig / Module / Style / Link / Product
│   └── validators/        # 配置校验（含 link 可解析性）
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
│   ├── navigation/        # 薄封装：点击 → followLink（禁止旁路路由）
│   └── style/             # ModuleStyle → Decorations / TextStyle
└── router.dart
```

注册表模式：`Map<ModuleType, ModuleBuilder>`，新模块只注册 builder，不改引擎核心。

导航层强制：

```text
用户点击（模块 item / 热区 / 商品卡 / 「去使用」等）
        │
        ▼
ThemeActivityLinkHandler.open(context, link)
        │
        ▼
SHORouteNavigator.followLink / SHODeepLinkNavigator.openLink
        │
        ▼
Resolver → Mapper → GoRouter（鉴权、Tab go / 全屏 push）
```

### 4.4 工具箱入口

在 `hos_toolbox_page.dart` 的「工具」分组新增：

| 项 | 说明 |
|----|------|
| 文案 | 主题活动 / ThemeActivity |
| 路由 | 如 `/toolbox/theme-activity` → 模板列表 → 活动页 |
| 能力 | Mock 模板列表；可切换读 Mock / 远程；调试展示配置 JSON；**可测各类 link 跳转** |

建议预置 3～5 套 Mock 模板，覆盖全部模块类型，且模板内跳转字段一律使用真实可解析的 Deep Link 示例。

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
| `share` | `{ title, image, url }` | 可选（系统分享，非页面跳转） |
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
| `defaultLink` | 模块级兜底 link（item 未配 link 时使用） |

### 5.3 跳转配置：只认 `link`（App Link / Deep Link）

#### 5.3.1 硬性约定

| 场景 | 配置方式 | 客户端行为 |
|------|----------|------------|
| 打开商品详情 | `link` → 商品 Deep Link | `followLink` |
| 打开分类 / 商品列表 | `link` → 分类 Deep Link | `followLink` |
| 打开广告落地页 / 其它活动 | `link` → 对应 Deep Link 或 WebView Deep Link | `followLink` |
| 打开优惠券中心 / 去使用 | `link` → 优惠券等 Deep Link | `followLink` |
| 打开抢购 / 搜索 / 个人中心等 | `link` → 已支持映射的路径 | `followLink` |
| 领券、倒计时结束隐藏、跑马灯暂停 | **非 link**（页内能力字段） | 调 API / 改本地 UI |
| 系统分享面板 | `share` 配置 | 调分享 SDK，不换路由栈 |

**禁止**在 ThemeActivity 配置中出现以下「平行跳转 DSL」（历史方案已废弃）：

```text
❌ type: product / category / route / url / webview / coupon / custom（作为页面跳转）
❌ value: 商品 id、路由 path、任意非统一协议字符串
❌ params 拼路由（应用内跳转细节应由 Deep Link Mapper 消化）
```

统一形态：

```text
LinkRef {
  link: string           // 必填（可点击项）
  // needLogin 一般不配：由 SHODeepLinkResolver 根据目标路由推导
  // 仅当运营要强制先登录再跳时，可显式 needLogin: true
  needLogin?: bool
}
```

JSON 示例：

```json
{
  "link": "https://shoo.app/product/c1-g1-l1-p1"
}
```

```json
{
  "link": "https://shoo.app/category/products?leafId=c1-g1-l1&title=%E6%98%A5%E5%AD%A3%E5%A5%B3%E8%A3%85"
}
```

```json
{
  "link": "/flash-sale?activityId=activity_flash_001"
}
```

```json
{
  "link": "shoo.app/coupons",
  "needLogin": true
}
```

#### 5.3.2 合法 `link` 形态（与 DEEPLINK.md 一致）

| 形态 | 示例 | 说明 |
|------|------|------|
| App Link / Universal Link | `https://shoo.app/product/p-1` | 推荐运营配置写法 |
| Host 简写 | `shoo.app/category/products?leafId=...` | 客户端归一为 https |
| Custom Scheme | `shoo://product/p-1` | 分享/唤起场景 |
| In-App Path | `/coupons`、`/activity`、`flash-sale?...` | 管理端可写短路径 |

解析与映射以 `lib/core/deeplink/` 为准；ThemeActivity **不得**私自 `context.push(rawPath)`。

#### 5.3.3 运营常用跳转对照表

| 业务意图 | 推荐 `link` |
|----------|-------------|
| 商品详情 | `https://shoo.app/product/{productId}` |
| 分类 Tab | `https://shoo.app/category` |
| 叶子类目商品列表 | `https://shoo.app/category/products?leafId={id}&title={name}` |
| 搜索 | `https://shoo.app/search?q={keyword}` |
| 抢购页 | `https://shoo.app/flash-sale?activityId={id}` |
| WebView 活动 / 外链 H5 | `https://shoo.app/webview?url={encodeURIComponent(h5)}&title=...` |
| 优惠券中心 | `https://shoo.app/coupons`（需登录） |
| 购物车 | `https://shoo.app/cart` |
| 个人中心 | `https://shoo.app/profile` |
| 订单列表 | `https://shoo.app/orders`（需登录） |
| 另一个主题活动 | `https://shoo.app/theme-activity/{activityId}`（实现期补 Mapper，见 §5.3.5） |
| 既有活动 Web 页 | `https://shoo.app/activity` 或具体 activity 路径（以现网 Mapper 为准） |

新增业务落地页时：**先扩展 Deep Link Mapper**，再在 ThemeActivity 配置里填新 link；禁止只在活动引擎里 hardcode 路由。

#### 5.3.4 页内行为 vs 页面跳转（勿混淆）

| 能力 | 是否换页 | 配置 |
|------|----------|------|
| 领取优惠券 | 否 | `claimable` + 调 `claimCoupon` API；成功后更新 status |
| 券「去使用」 | **是** | `link` → 商品列表 / 首页 / 指定落地 Deep Link |
| 商品卡点击 | **是** | `link` → 商品详情 Deep Link |
| 加购按钮 | 否（默认）或是 | 默认页内加购；若跳购物车则配 `cartLink` 为 Deep Link |
| 倒计时结束 | 否（或是） | `onExpire`：`hide` / `refresh` / `showText`；若要跳转用 `onExpireLink` |
| 跑马灯点击 | **是**（若配置） | item.`link` |
| Banner / 热区 | **是** | `link` / hotspot.`link` |
| 九宫格入口 | **是** | item.`link` |
| `web` 模块加载 URL | 否（内嵌） | 模块字段 `url`（嵌入用，不是页面跳转） |
| `web` 内 H5 点链 | **是** | Bridge → Deep Link（与 activity_webview 一致） |

#### 5.3.5 ThemeActivity 自身 Deep Link（实现期）

建议标准入口（需同步写入 `SHODeepLinkMapper` / `DEEPLINK.md`）：

```text
https://shoo.app/theme-activity/{activityId}
shoo://theme-activity/{activityId}
/theme-activity/{activityId}
```

可选 query：`?channel=xxx`（仅埋点，不改变路由）。

首页弹窗、Banner、其它活动互相跳转，均配置上述 link，而不是写死 `/toolbox/theme-activity`。

### 5.4 DataSource

| 模式 | 用途 |
|------|------|
| `static` | 配置内直接带 `items[]` |
| `api` | `{ url, method, params, mapping }` |
| `productQuery` | `{ ids[] / categoryId / tag / sort / pageSize }` |

底部商品列表建议强制 `productQuery` 或 `api`，以支持分页。  
**注意**：DataSource 只负责「拉数据」，不负责「点了去哪」；商品卡仍须带 `link`（或由 `productId` **服务端/客户端规范生成**标准商品 Deep Link，见 §8.3）。

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
| `web` | Web 活动块 | 可配宽高（内嵌 URL，非跳转） |
| `coupon` | 优惠券 | 领取=页内；去使用=link |
| `countdown` | 倒计时 | 多种格式与布局 |
| `marquee` | 跑马灯 | 横/竖滚动公告 |
| `bannerRow` | 一行广告图 | 单图 + 可选热区 |
| `bannerStack` | 多行广告图 | 拼接成长图效果 |
| `productScroll` | 横向商品列表 | 可横向滚动 |
| `menu` | 自定义行列菜单 | 可底层复用 grid |

Footer 独立字段，不进 `modules[]`（见 §8）。

凡下表出现「点击打开页面」处，字段名统一为 **`link`**（热区同理）。

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
| `items[]` | `{ image, title, subtitle, badge, link }` |

---

### 7.3 `unevenGrid` — 两行四格不均分

| 配置 | 说明 |
|------|------|
| `layoutPreset` | `leftBig_rightTwo` / `topBig_bottomThree` / `leftBig_rightThree` / `custom` |
| `slots[]` | 槽位：`spanRow` / `spanCol`、`image`、`link` |
| `aspectRatio` | 整块宽高比 |
| `gap` | 槽位间距 |

`custom`：总列 2 或 3，每 slot 声明 `row` / `col` / `rowSpan` / `colSpan`。

---

### 7.4 `web` — Web 活动模块

| 配置 | 说明 |
|------|------|
| `url` | **内嵌** H5 地址（不是 App 页面跳转） |
| `width` | `match_parent` / 固定 dp / 百分比 |
| `height` | 固定高度（与 aspectRatio 二选一） |
| `aspectRatio` | 宽高比 |
| `scrollEnabled` | Web 内滚动；建议 `false`，整页统一滚 |
| `bridgeEnabled` | 是否注入活动 JS Bridge（H5 跳转走 Deep Link） |
| `placeholderColor` | 加载占位色 |
| `fallbackImage` | 失败兜底图 |
| `fallbackLink` | 兜底图点击 → Deep Link |

可复用 `activity_webview` 的 bridge 能力子集；**禁止** Web 模块用自定义 scheme 直达 Flutter 路由而不经 Deep Link。

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
`couponId, type(fullReduce/discount/gift), amount, condition, discount, title, desc, expireAt, status(claimable/claimed/soldOut/expired), buttonText, bgImage, amountColor, buttonColor`

**交互拆分：**

| status / 按钮 | 行为 |
|---------------|------|
| `claimable` | 调领取 API（页内），**不**走 link |
| `claimed` 且文案「去使用」 | 必须配置 `link`（Deep Link） |
| 运营配置整卡可点 | 同样只用 `link` |

领取失败 toast；成功更新本地 status。

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
| `onExpire` | `hide` / `refresh` / `showText` |
| `onExpireLink` | 可选；结束后若需打开新页，配 Deep Link |
| `expireText` | `showText` 时文案 |

可参考 `flash_sale` 倒计时组件实现经验。

---

### 7.7 `marquee` — 跑马灯

| 配置 | 说明 |
|------|------|
| `direction` | `horizontal` / `vertical` |
| `speed` | px/s 或 `slow` / `normal` / `fast` |
| `pauseOnTap` | 点击是否暂停（页内） |
| `loop` | 是否循环 |
| `icon` | 左侧公告图标 |
| `items[]` | `{ text, textColor, link? }` |
| `separator` | 条目分隔 |
| `height` | 条高度 |

有 `link` 则点击走 Deep Link；无 `link` 仅展示或暂停。

---

### 7.8 `bannerRow` — 一行广告图

| 配置 | 说明 |
|------|------|
| `image` | 单图 URL |
| `aspectRatio` / `height` | 二选一 |
| `link` | 整图点击 Deep Link |
| `hotspots[]` | `{ x%, y%, w%, h%, link }` 可选热区 |

---

### 7.9 `bannerStack` — 多行广告图（长图效果）

| 配置 | 说明 |
|------|------|
| `items[]` | `{ image, width, height|aspectRatio, link, hotspots[] }` |
| `gap` | 图间距，默认 `0`（无缝） |
| `lazyLoad` | 按可视区域加载 |
| `fullBleed` | 是否左右顶满 |

---

### 7.10 `productScroll` — 横向商品列表

| 配置 | 说明 |
|------|------|
| `cardWidth` | 卡片宽 |
| `imageAspectRatio` | 图比例 |
| `showCartButton` | 是否加购（页内） |
| `showOriginPrice` | 划线价 |
| `showTitleLines` | 标题行数 1/2 |
| `items` / `dataSource` | 商品数据（卡片含 `link` 或可推导） |
| `edgeFade` | 边缘渐隐提示可滑 |

---

### 7.11 `menu` — 自定义行列 Menu

运营心智上可与 grid 区分；**底层可复用 grid 渲染器**：

| 额外字段 | 说明 |
|----------|------|
| `showTitleBar` | 模块标题栏 |
| `titleBar` | `{ title, moreText, moreLink }`（更多 → Deep Link） |
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
link,                 // 点击进详情：Deep Link（推荐显式下发）
cartAction            // addToCart | 无；若跳转购物车则改用 cartLink
cartLink?             // 可选 Deep Link，如 https://shoo.app/cart
```

**`link` 生成规则（二选一，实现时写死优先级）：**

1. 配置/接口已带 `link` → 原样走 Deep Link；  
2. 仅有 `productId` → 客户端规范生成 `https://shoo.app/product/{productId}`（与 Mapper 一致）。

禁止 `context.push('/product/$id')` 绕过 Deep Link（以免鉴权、埋点、Tab/全屏策略不一致）。

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
      "items": [
        {
          "image": "https://cdn.example/banner1.png",
          "aspectRatio": 2.5,
          "link": "https://shoo.app/flash-sale?activityId=activity_flash_001"
        }
      ]
    },
    {
      "moduleId": "m_countdown",
      "type": "countdown",
      "sort": 20,
      "endAt": "2026-08-01T23:59:59+08:00",
      "format": "DHMS",
      "layout": "block",
      "onExpire": "showText",
      "expireText": "本场已结束",
      "onExpireLink": "https://shoo.app/category"
    },
    {
      "moduleId": "m_coupon",
      "type": "coupon",
      "sort": 30,
      "layout": "horizontalScroll",
      "items": [
        {
          "couponId": "c_spring_10",
          "type": "fullReduce",
          "amount": 10,
          "condition": "满100可用",
          "title": "春日券",
          "status": "claimed",
          "buttonText": "去使用",
          "link": "https://shoo.app/category/products?leafId=c1-g1-l1&title=%E6%98%A5%E6%97%A5%E4%B8%93%E5%8C%BA"
        }
      ]
    },
    {
      "moduleId": "m_marquee",
      "type": "marquee",
      "sort": 40,
      "direction": "horizontal",
      "items": [
        {
          "text": "全场包邮，点击查看规则",
          "link": "https://shoo.app/webview?url=https%3A%2F%2Fexample.com%2Frules&title=%E6%B4%BB%E5%8A%A8%E8%A7%84%E5%88%99"
        }
      ]
    },
    {
      "moduleId": "m_grid",
      "type": "grid",
      "sort": 50,
      "columns": 4,
      "items": [
        {
          "image": "https://cdn.example/icon_cat.png",
          "title": "女装",
          "link": "https://shoo.app/category/products?leafId=c1-g1-l1&title=%E5%A5%B3%E8%A3%85"
        },
        {
          "image": "https://cdn.example/icon_coupon.png",
          "title": "领券",
          "link": "https://shoo.app/coupons"
        }
      ]
    },
    {
      "moduleId": "m_uneven",
      "type": "unevenGrid",
      "sort": 60,
      "layoutPreset": "leftBig_rightTwo",
      "slots": [
        {
          "image": "https://cdn.example/slot1.png",
          "link": "https://shoo.app/product/c1-g1-l1-p1"
        }
      ]
    },
    {
      "moduleId": "m_scroll",
      "type": "productScroll",
      "sort": 70,
      "cardWidth": 120,
      "dataSource": {
        "mode": "static",
        "items": [
          {
            "productId": "c1-g1-l1-p1",
            "title": "示例商品",
            "price": 99,
            "image": "https://cdn.example/p1.png",
            "link": "https://shoo.app/product/c1-g1-l1-p1"
          }
        ]
      }
    },
    {
      "moduleId": "m_web",
      "type": "web",
      "sort": 80,
      "url": "https://example.com/promo-embed",
      "aspectRatio": 1.2,
      "bridgeEnabled": true,
      "fallbackLink": "https://shoo.app/activity"
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

正式实现前建议再收敛为 **JSON Schema**（另文或本文附录演进），Schema 中对所有可点击节点约束：`link` 为 string，且通过 Deep Link 试解析。

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
| 可点击项缺少 `link`（且无 `defaultLink` / 不可由 productId 推导） | warn：不可点或仅展示 |
| `link` 无法被 `SHODeepLinkResolver` 解析 | error（后台）/ warn+禁用点击（端上） |
| 配置中出现废弃字段 `action.type=product|route|...` | error（后台拒收） |
| `claimed` 券「去使用」无 `link` | error |

后台与客户端 **双端校验**；客户端校验失败模块降级隐藏，页级 error 可展示错误态。  
后台校验建议直接调用与 App 同源的路径规则表（或共享 JSON 白名单），避免运营配了端上打不开的 link。

---

## 十一、渲染与交互规范

1. **单滚动容器**，避免多嵌套滚动冲突。  
2. **可选下拉刷新**：重拉配置 + footer 重置 `page=1`。  
3. **模块显隐**：`visible=false` 或倒计时结束后按策略移除并折叠空白。  
4. **图片**：统一占位、失败兜底、长图懒加载。  
5. **登录**：Deep Link 目标若 `requiresAuth`，由 `SHODeepLinkNavigator` 统一切登录页并带 `redirect`；配置侧 `needLogin: true` 仅作强制加强。  
6. **跳转**：所有打开新页面的点击 → `ThemeActivityLinkHandler` → `followLink`；**禁止**模块内直接 `context.push/go`。  
7. **埋点**：`activityId + moduleId + itemId + link + resolvedActionType`；曝光按可见比例。  
8. **性能**：modules 懒构建；`bannerStack` 按屏预加载；列表卡片复用。  
9. **错误隔离**：单模块解析/渲染失败只隐藏该模块；单条非法 link 只禁用该点击。

---

## 十二、分期落地计划

| 期次 | 范围 | 验收要点 |
|------|------|----------|
| **P0** | 目录骨架 + PageShell + ModuleStyle + `bannerRow` / `bannerStack` + `grid` + footer 三选一 + 上拉加载 + **LinkHandler（全走 Deep Link）** + 工具箱入口 + 2～3 套 Mock（含商品/分类/抢购 link） | 能打开活动页；点 Banner/宫格/商品卡正确进详情/分类/抢购；底部可加载更多 |
| **P1** | `coupon`（领券页内 + 去使用 link）+ `countdown` + `marquee` + `productScroll` + `unevenGrid` + `menu` | 大促常用模块齐全；券去使用走 Deep Link |
| **P2** | `web` 模块 + 热区 + 分享 + 下拉刷新 + 远程配置 + 埋点 + **Mapper 增加 `theme-activity/{id}`** | 可对接真实运营配置；活动互跳 |
| **P3** | 运营可视化搭建（搭建器内 link 选择器/校验）、A/B、`visible` 规则、更多 layoutPreset | 提效运营且防止配错路由 |

### P0 建议实现顺序

1. Domain 模型 + 校验器 + Mock JSON（**一律使用 link 字段**）  
2. `ThemeActivityLinkHandler` 对接 `SHORouteNavigator.followLink`  
3. ThemeActivityPage 引擎（CustomScrollView + Module 注册表）  
4. ModuleStyle → BoxDecoration / TextStyle  
5. bannerRow / bannerStack / grid（点击走 link）  
6. footer：单列 / 双列 / 瀑布流 + LoadMore（商品卡 link）  
7. 工具箱入口 + 模板列表页  
8. 路由 / i18n / 基础埋点占位  

---

## 十三、建议预置 Mock 模板

| 模板 ID | 场景 | 模块组合 | Footer | 跳转验收 |
|---------|------|----------|--------|----------|
| `demo_long_banner` | 长图大促 | bannerStack + marquee | `productListDouble` | Banner→抢购；商品→详情 |
| `demo_coupon_rush` | 券+倒计时 | countdown + coupon + grid | `productListSingle` | 去使用→类目列表；宫格→分类/领券中心 |
| `demo_nine_waterfall` | 九宫格+瀑布流 | grid(nineGrid) + unevenGrid + productScroll | `productWaterfall` | 九宫格→商品/搜索；瀑布流→详情 |
| `demo_web_embed`（P2） | 内嵌 H5 | bannerRow + web | `productListDouble` | H5 Bridge→Deep Link；fallbackLink |

---

## 十四、风险与注意点

| 风险 | 应对 |
|------|------|
| Web 模块与整页滚动冲突 | 默认关闭 Web 内滚动，固定高度 |
| 瀑布流高度跳动 | 图尺寸已知或占位比固定 |
| 配置膨胀难维护 | 模板 + Schema 校验 + 模块正交 |
| 与 activity_webview 职责重叠 | 文档边界清晰；bridge 复用子集 |
| 横向列表手势 | 使用明确的横向手势竞技场 |
| 运营乱配路由 / 私有 path | **只认 Deep Link**；后台试解析；未知 link 禁用点击 |
| 模块内旁路 `push` | Code Review + LinkHandler 单测；规范写入 Cursor/团队规则 |
| Deep Link 未覆盖新业务页 | 先扩 Mapper / DEEPLINK.md，再上配置 |
| `shoo.app/...` 无 scheme | 与现网一致：归一为 `https://` 再解析 |

---

## 十五、后续文档演进

实现过程中可追加：

1. **附录 A**：完整 JSON Schema（含 `link` pattern / 试解析钩子）；  
2. **附录 B**：字段默认值全表；  
3. **附录 C**：埋点事件字典（含 `link` / `resolvedType`）；  
4. **附录 D**：与 `activity_webview` bridge 复用清单；  
5. **附录 E**：ThemeActivity 专用 Deep Link 与运营配置手册（可摘自本文 §5.3）。

变更流程：先更新本文版本号与变更记录，再提交代码。Deep Link 映射变更须同步 `lib/core/deeplink/DEEPLINK.md`。

### 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v0.1 | 2026-07-29 | 初稿：总体架构、模块清单、样式、footer 约束、分期与工具箱入口 |
| v0.2 | 2026-08-15 | **跳转契约**：打开新页面一律 App Link / Deep Link（`link` 字段）；废弃 action DSL；补充对照表、校验、LinkHandler、自身入口与分期验收 |

---

## 十六、结论

ThemeActivity 以 **配置驱动 + 模块注册表 + 底部唯一商品区 + Deep Link 统一跳转** 为核心，覆盖一行 N / 九宫格 / 不均分 / Web / 券 / 倒计时 / 跑马灯 / 广告图 / 横向商品 / Menu / 底部三种商品流，并统一背景、圆角、边框、字体色等样式能力。

**跳转结论（务必遵守）：** 商品、广告、分类、活动、优惠券中心、抢购等一切「进入新界面」的配置，只写 App Link / Deep Link（或等价 in-app path）；客户端只经 `SHODeepLinkNavigator` 执行。页内领券、加购、倒计时 UI 等不换页行为除外。

**下一步**：按 **P0** 在 `features/theme_activity/` 开工；实现前先定 Mock 中的 link 样例，并与 `DEEPLINK.md` 对齐；需要时补 JSON Schema 后再写代码。
