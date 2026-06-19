# SHO Hybrid Bridge — Flutter ↔ Native 混合交互框架

## 1. 背景与目标

大型电商 App 常见 **Flutter 主业务 + 原生能力**（支付 SDK、系统分享、复杂动画、遗留模块）。  
SHOO 已在 `lib/core/platform/bridge/` 建立 Platform Channel 基础层；`hybrid/` 在其上统一 **导航、弹窗、能力调用** 三类混合场景，避免各业务散落 `MethodChannel` 字符串。

## 2. 通道选型（成熟主流方案）

| 通道 | 名称 | 方向 | 适用场景 |
|------|------|------|----------|
| **MethodChannel** | `native_bridge` | Flutter → Native | 打开原生页、读设备信息、同步能力、一次性调用 |
| **MethodChannel** | `native_host` | Native → Flutter | 原生唤起 Flutter 路由/弹窗、需要 `BuildContext` 的 UI |
| **BasicMessageChannel** | `native_message` | 双向 | 轻量 JSON、Echo、心跳、低延迟小数据 |
| **EventChannel** | `native_event` | Native → Flutter | 支付进度、下载、物流、传感器等 **流式** 事件 |

> **不采用** flutter_boost / Pigeon（当前阶段）：团队已有 go_router + 自研 Channel 层；Pigeon 可在协议稳定后 codegen 替换 hand-written 桩。

### 为何增加 `native_host`？

`native_bridge` 由 **原生注册 Handler**，供 Dart `invokeMethod`。  
原生 UI（如 S活动）需要 **反向调用 Flutter**（导航、弹窗），必须 Dart 端 `setMethodCallHandler` —— 独立通道职责清晰，避免双向同 Channel 互相覆盖。

## 3. 架构分层

```
┌─────────────────────────────────────────────────────────┐
│  Feature（百宝箱 S活动、Debug Native Hub）               │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│  SHOHybridBridge（门面：openSActivity / 协议常量）       │
│  SHONativeHostBridge（native_host 注册与分发）             │
│  SHONativeHostActions（navigate / showDialog / demos）    │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│  SHONativeBridge / MessageBridge / EventBridge（已有）     │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│  iOS: HybridBridgeCoordinator + ViewControllers           │
│  Android: NativeBridgeHandler（桩，可扩展 Activity）        │
└─────────────────────────────────────────────────────────┘
```

## 4. 协议约定

### 4.1 Flutter → Native（`native_bridge`）

| method | args | returns |
|--------|------|---------|
| `ping` | — | `{ok, platform}` |
| `getPlatformVersion` | — | `String` |
| `sActivity/open` | — | `{ok: true}` 打开 S活动原生页 |
| `sActivity/openDialogLab` | — | `{ok: true}` 打开 S弹弹窗实验页 |

### 4.2 Native → Flutter（`native_host`）

| method | args | returns |
|--------|------|---------|
| `navigate` | `{route: String, args?: Map}` | `{ok: true}` |
| `showDialog` | `{kind, title, message?, ...}` | `{action, kind, ...}` |
| `runMethodChannelDemo` | — | ping 结果 Map |
| `runMessageChannelDemo` | `{text?: String}` | echo Map |
| `runEventChannelDemo` | `{ticks?: int}` | 最后一条 event Map |

### 4.3 导航约定

- 原生打开 Flutter 页面前 **dismiss 当前原生 Modal**，保证 go_router 栈可见。
- 路由使用 `SHOAppRoutes` 常量，禁止硬编码散落。

## 5. S活动功能地图

| 区块 | 类型 | 行为 |
|------|------|------|
| 交换学习 ×3 | 原生 UI | 调用 `native_host` 演示三种 Channel |
| F商品列表 | Flutter | `/category/products?leafId=c1-g1-l1&title=...` |
| F购物车 | Flutter | `/cart/view` → 可继续结算/支付 |
| S弹弹窗 | 原生 UI | 按钮触发 Flutter `SHOAppDialog`，结果回显原生列表 |

## 6. 扩展指南

1. 新增 **Flutter→Native** 能力：在 `NativeBridgeHandler` 增加 case + Dart `SHOHybridBridge` 封装方法。
2. 新增 **Native→Flutter** UI：在 `SHONativeHostActions` 增加分支 + iOS `HybridBridgeCoordinator.invokeFlutter`。
3. 流式场景：优先 `EventChannel`，在 `SHONativeEventKinds` 登记 kind。
4. 大型二进制：使用预留的 `native_binary` + `StandardMessageCodec` Uint8List。

## 7. 参考

- Debug 面板：`/debug/native` — 最小 Channel 示例  
- S活动：`百宝箱 → S活动` — 端到端混合导航 + 弹窗 + 学习示例
