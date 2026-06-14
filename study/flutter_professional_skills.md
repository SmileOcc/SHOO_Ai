# Flutter 面试专业技能项（基于 SHOO 项目）

> 对标 iOS 简历技能描述格式，结合 SHOO v0.4 实际技术栈整理，可直接用于简历「专业技能」或面试自我介绍提纲。

---

## 1、编程语言与开发基础

**Dart 3.x** | **Flutter 3.x Widget 体系** | **空安全 / sealed class / pattern matching**

- 熟练使用 Dart 面向对象、异步编程（`Future` / `Stream` / `async-await`）
- 熟悉 Flutter 声明式 UI：`StatelessWidget` / `StatefulWidget` / `ConsumerWidget`
- 掌握不可变数据建模：**freezed** + **json_serializable** 代码生成（订单、商品、优惠券等 Domain 模型）
- 熟悉泛型、扩展方法、抽象接口等 Dart 现代特性（如 `sealed class SHOAppException` 错误体系）

---

## 2、架构设计

**Clean Architecture（Feature-First）** | **MVVM 变体（Presentation + Controller）** | **go_router 声明式路由** | **组件化与模块化设计**

| 能力点 | SHOO 项目实践 |
|--------|---------------|
| 分层架构 | `features/{module}/domain · data · presentation`，单向依赖 `features → core` |
| 状态管理 | **flutter_riverpod**（`NotifierProvider` / `AsyncNotifier` / `ref.watch`） |
| 路由方案 | **go_router** + `StatefulShellRoute.indexedStack` 四 Tab 保栈 + `parentNavigatorKey` 全屏二级页 |
| 路由守卫 | `SHORouterNotifier.redirect` 登录态刷新 + `?redirect=` 回跳 |
| 模块化 | 各 feature 独立 `router.dart`，`hos_router.dart` 统一组装；`core/` 跨模块基建 |
| 依赖注入 | Riverpod Provider 替代 Service Locator，Debug 环境热切换 `ProviderScope` 重建 |
| Repository 模式 | `AuthRepository` / `OrderRepository` 等接口隔离数据源，Dio + Mock 可切换 |

---

## 3、原生交互与跨端通信

**Platform Channel 三通道** | **原生能力封装** | **深链 / Universal Link**

- **MethodChannel**：`SHONativeBridge` 统一泛型调用、类型转换、异常映射（`SHONativeBridgeException`）
- **EventChannel**：原生事件流订阅（传感器、推送状态等场景预留）
- **BasicMessageChannel**：`SHONativeMessageBridge` 高频小数据双向通信
- 权限与系统能力：`permission_handler` / `image_picker` / `share_plus` / `url_launcher`
- 深链：`app_links` 监听外部 URL → `go_router` 导航落地

---

## 4、网络、存储与数据层

**Dio 网络栈** | **多环境配置** | **本地持久化** | **Mock 驱动开发**

- **Dio 5.x**：拦截器链（Auth 头注入 / Mock 拦截 / 网络日志 / 统一错误映射 `mapDioError`）
- 多环境：Debug / Staging / Production API 切换，`SHOAppRestart` 无进程重启热切换
- 本地存储：`shared_preferences`（偏好设置）+ `flutter_secure_storage`（Token 加密）+ `path_provider`（沙盒路径）
- 图片缓存：`cached_network_image` + `flutter_cache_manager` 自定义 `SHOImageCacheManager`（只读 DB 自愈）
- 离线感知：`connectivity_plus` 驱动全局离线 Banner

---

## 5、底层机制与性能优化

**Flutter 渲染与生命周期** | **Zone / 全局错误捕获** | **启动优化** | **内存与缓存管理**

- 理解 Widget / Element / RenderObject 三棵树与 `build` / `setState` 触发机制
- App 生命周期：`WidgetsBindingObserver` / `SHOAppLifecycleBinder` 冷启动与前后台埋点
- 全局错误：`runZonedGuarded` + `FlutterError.onError` + `PlatformDispatcher.onError` 统一兜底
- 启动优化：`SHOAppStartupTimer` 分段计时（bootstrap → 首帧），异步预热图片缓存
- 列表性能：分页加载 `SHOPagedListState`、骨架屏 `SHOSkeletonBox`、图片懒加载
- 路由可见性：`RouteAware` + `RouteObserver` 页面级埋点，避免 Tab 切换误报

---

## 6、工程化与质量保障

**日志体系** | **业务埋点** | **国际化** | **主题体系** | **Debug 基建**

- 生产级 Logger：`dart:developer.log()` 封装，多级别 / 模块化前缀 `[SHOO][LEVEL][Module]`，Sink 可扩展（控制台 / 文件 / Sentry）
- 业务上报：`SHOAnalyticsManager` 多通道分发（Console / LogCache / MockRemote / Remote），事件注册表字段校验
- 页面埋点：`page_enter/exit/cover/resume` + `tab_switch` + Navigator 栈级 `route_push/pop`
- 国际化：`flutter gen-l10n` + ARB 双语资源 + `localeProvider` 运行时切换
- 主题：`ThemeData` 亮暗模式 + `SHOAppTheme` Design Token（间距 / 色板 / 圆角）
- Debug 面板：环境切换、网络日志、Analytics 试发、全局 Loading/Error 调试、Native Channel 测试

---

## 7、多媒体与业务能力

**音视频播放** | **文件处理** | **电商业务全链路**

| 领域 | 技术栈 / 实现 |
|------|---------------|
| 音频播放 | **just_audio** 音乐播放器（播放列表 / 歌词 / 迷你播放器 / 路由同步） |
| 视频播放 | **video_player** 视频库与评论互动 |
| 文档阅读 | **pdfx** PDF 预览、TXT 小说阅读器（章节 / 书签 / 进度持久化） |
| 文件下载 | 下载队列管理、ZIP 解压（**archive**）、音乐包导入曲库 |
| 电商核心 | 商品浏览 → 购物车 → 结算 → 支付（Mock）→ 订单 / 物流 / 售后 |
| 营销能力 | 活动弹窗预加载、优惠券、Banner 轮播、分享卡片 |

---

## 8、可写在简历上的一行版（参考 iOS 格式）

```
1、编程语言：Dart 3.x、Flutter Widget 体系、freezed 不可变建模
2、架构设计：Clean Architecture / Feature-First | Riverpod 状态管理 | go_router 声明式路由 | 组件化模块化
3、原生交互：MethodChannel / EventChannel / BasicMessageChannel | 深链 app_links | 权限与系统能力封装
4、网络与存储：Dio 拦截器链 | 多环境热切换 | Secure Storage | 图片缓存与离线策略
5、底层与性能：三棵树与生命周期 | Zone 全局错误捕获 | 启动分段计时 | 分页列表与缓存优化
6、工程化：生产级 Logger + 业务埋点体系 | i18n 双语 | 亮暗主题 | Debug 调试基建
7、多媒体与业务：just_audio 音乐 / video_player 视频 / 下载解压 / 电商全链路 Mock 可演示
```

---

## 9、面试可展开的项目亮点（话术参考）

1. **为什么选 go_router 而不是 auto_route？**  
   四 Tab 需 `StatefulShellRoute` 保栈，登录守卫 + 深链是刚需；团队已有 Riverpod，go_router 无额外代码生成成本。

2. **Riverpod 和 Provider / Bloc 的区别？**  
   编译期安全、无 `BuildContext` 依赖、`Notifier` 统一同步/异步状态；`ProviderScope` 重建支持 Debug 环境热切换。

3. **如何做页面级埋点？**  
   方案 B：`RouteObserver` + `RouteAware` mixin 区分 enter/exit/cover/resume；Tab 切换单独 `tab_switch`；NavigatorObserver 补栈级事件。

4. **全局错误怎么处理？**  
   `SHOGlobalErrorListener` 内联弹层（避免 builder 层无 Navigator）；bootstrap 三层 Zone 兜底；`messageFromAny` 统一用户文案。

5. **Mock 如何支撑前后端并行？**  
   Dio `SHOMockInterceptor` 拦截 + 可选 Node.js 本地 Server，同一套路由表与 JSON 资产。

---

*文档版本：2026-06-06 · 对应 SHOO v0.4.0+1*
