# 移动端 / Flutter 面试题与答案详解

> 面向 Flutter 客户端岗位，结合 SHOO 电商项目中的真实场景（Riverpod、GoRouter、Dio、下载、音乐播放等）整理。

---

## 1. StatelessWidget 和 StatefulWidget 有什么区别？什么时候用哪个？

**参考答案：**

| 类型 | 特点 | 适用场景 |
|------|------|----------|
| `StatelessWidget` | 配置不可变，只有 `build()` | 纯展示：图标、文本、静态卡片 |
| `StatefulWidget` | 有 `State` 对象，可 `setState` | 有内部交互状态：表单、动画、Tab 切换 |

**深入要点：**

- Widget 本身是不可变的（immutable），变的是 `Element` 树和 `State`。
- `StatefulWidget` 拆成两部分：Widget 只传配置，`State` 持有可变状态和 `BuildContext`。
- 能用 Stateless 就不用 Stateful，减少重建范围和状态管理复杂度。

**项目示例（SHOO）：**

- `SHOToolboxPage`：纯菜单展示 → Stateless。
- `SHOMusicPlayerPage`：播放进度、歌词切换 → Stateful + Riverpod。

**追问：setState 后发生了什么？**

`setState` → 标记 Element 为 dirty → 下一帧 `build()` 重建子树 → 对比新旧 Widget → 最小化 DOM/RenderObject 更新。

---

## 2. Flutter 中 Widget / Element / RenderObject 三层关系是什么？

**参考答案：**

```
Widget（配置）  →  Element（树节点）  →  RenderObject（布局/绘制）
   不可变              生命周期载体           真正干活的
```

- **Widget**：描述 UI 长什么样，轻量，可频繁创建。
- **Element**：Widget 在树上的实例，负责挂载、更新、卸载。
- **RenderObject**：负责布局（layout）、绘制（paint）、命中测试（hit test）。

**面试一句话：** Widget 是 recipe，Element 是实例，RenderObject 是引擎。

**常考坑：** 以为 Widget 就是 UI 本身——实际上频繁 `build()` 创建的是 Widget，Element 尽量复用。

---

## 3. StatefulWidget 生命周期有哪些？dispose 里能做什么、不能做什么？

**参考答案：**

常见顺序：

1. `constructor` → `createState()`
2. `initState()` — 只调用一次，适合订阅、初始化控制器
3. `didChangeDependencies()` — 依赖的 InheritedWidget 变化时
4. `build()` — 可多次调用
5. `didUpdateWidget()` — 父组件传入新配置
6. `deactivate()` — 从树中移除但可能复用
7. `dispose()` — 永久销毁，释放资源

**dispose 应该做：**

- 取消 `StreamSubscription` / `Timer`
- 释放 `AnimationController`、`TextEditingController`
- 移除监听器

**dispose 不应该做：**

- ❌ 调用 `setState`
- ❌ 用 `ref` / `context` 触发导航或更新全局 Provider（可能通知已销毁的 Element 重建，触发 `_lifecycleState != defunct` 断言）
- ❌ 发起新的异步 UI 操作而不检查 `mounted`

**项目踩坑（SHOO 音乐播放）：**

播放页在 `dispose()` 里写 `ref.read(musicOnPlayerPageProvider).state = false`，音乐播放中 Provider 持续推送进度，已销毁页面仍被通知重建 → 崩溃。正确做法：路由 Observer 同步页面状态，异步回调里检查 `mounted`。

---

## 4. BuildContext 是什么？为什么不能长期持有 context？

**参考答案：**

`BuildContext` 本质是 `Element` 的接口，代表当前 Widget 在树中的位置。

用途：

- 查 InheritedWidget（`Theme.of(context)`）
- 导航（`Navigator.of(context)` / `context.push`）
- 显示 `SnackBar`、`Dialog`

**不能长期持有的原因：**

- 页面 pop 后 Element 销毁，context 失效。
- 异步回调里直接用旧 context → `mounted == false` 或更严重的 defunct 错误。

**正确写法：**

```dart
Future<void> load() async {
  final data = await api.fetch();
  if (!context.mounted) return;
  context.push('/detail');
}
```

---

## 5. Riverpod 和 Provider 有什么区别？你在项目里为什么选 Riverpod？

**参考答案：**

| 维度 | Provider | Riverpod |
|------|----------|----------|
| 编译安全 | 较弱 | 更强，不依赖 BuildContext 读 Provider |
| 依赖关系 | 手动 | `ref.watch` 自动建立依赖图 |
| 测试 | 一般 | 更易覆盖、可 override |
| 代码生成 | 无 | 可配合 codegen |

**Riverpod 核心概念：**

- `Provider`：只读、自动缓存
- `StateProvider`：简单可变状态
- `StateNotifierProvider`：复杂业务状态（如播放器）
- `FutureProvider` / `StreamProvider`：异步数据

**项目示例（SHOO）：**

```dart
final musicPlayerProvider =
    StateNotifierProvider<SHOMusicPlayerNotifier, SHOMusicPlayerState>((ref) {
  return SHOMusicPlayerNotifier(...);
});
```

下载列表状态、音乐库列表、路由守卫都用 `ref.watch` / `ref.read` 分离读写。

**追问：ref.watch 和 ref.read 区别？**

- `watch`：建立依赖，值变会重建当前 Widget。
- `read`：一次性读取，用于事件回调（onTap、init），不应在 `build` 里滥用 `read` 代替 `watch`。

---

## 6. GoRouter 和 Navigator 1.0 相比有什么优势？路由守卫怎么做？

**参考答案：**

**GoRouter 优势：**

- 声明式路由表，支持深链接、Web URL
- `redirect` 统一鉴权（登录拦截）
- `StatefulShellRoute` 做底部 Tab 保活
- `parentNavigatorKey` 控制全屏页叠在 Tab 之上

**SHOO 项目结构：**

- Tab 页：`StatefulShellRoute`（首页、分类、购物车、我的）
- 全屏功能页：`parentNavigatorKey: rootKey`（商品详情、播放器、下载列表）

**路由守卫示例：**

```dart
redirect: (context, state) {
  if (!session.isAuthenticated && requiresAuth(state.matchedLocation)) {
    return '${SHOAppRoutes.login}?redirect=...';
  }
  return null;
}
```

**常考题：push 和 go 区别？**

- `push`：入栈，可 `pop` 返回
- `go`：替换当前路径（类似清栈跳转），适合 Tab 切换

---

## 7. Future、async/await、Stream 怎么选？什么是 Event Loop？

**参考答案：**

| 类型 | 含义 | 场景 |
|------|------|------|
| `Future` | 单次异步结果 | 网络请求、读文件 |
| `Stream` | 多次异步事件 | 播放进度、WebSocket、下载进度 |
| `async/await` | 异步语法糖 | 串行异步逻辑 |

**Event Loop 简版：**

1. 执行同步代码
2. 处理 Microtask Queue（`Future.microtask`）
3. 处理 Event Queue（IO、Timer、手势）
4. 重复

**面试常问输出题：**

```dart
print('A');
Future(() => print('B'));
Future.microtask(() => print('C'));
print('D');
// 输出：A D C B
```

**项目注意：**

- 不要在 `dispose` 后 `await` 完再 `setState`
- 长耗时解压放后台，UI 用 `overlayLoading` 提示

---

## 8. 如何优化 Flutter 列表和长页面性能？

**参考答案：**

**列表：**

- 用 `ListView.builder` / `SliverList`，懒加载子项
- 给 item 加 `Key`（`ValueKey(id)`）帮助 diff
- 避免在 item `build` 里做重计算

**重建：**

- 尽量 `const` 构造函数
- 用 `Consumer` / `select` 缩小监听范围，不要整个页面 `watch` 大 Provider
- 播放进度高频更新时，进度条局部 `watch`，列表不要 watch 整个 `playerState`

**图片：**

- 网络图用 `cached_network_image`
- 指定 `memCacheWidth` 降内存

**项目示例：**

音乐库列表只 `watch` 需要的字段；下载列表用 `FutureProvider.family` 按 taskId 查状态，避免全局刷新。

---

## 9. Platform Channel 通信流程是什么？和 FFI 怎么选？

**参考答案：**

**MethodChannel 流程：**

```
Dart invokeMethod → BinaryMessenger → 原生 MethodChannel Handler → 结果回传 Future
```

**适用：** 调用系统 API（相册、蓝牙、推送）、已有原生 SDK。

**FFI（Foreign Function Interface）：**

- Dart 直接调用 C/C++ 动态库
- 适用高性能计算、音视频编解码

**面试追问：Channel 在主线程吗？**

- 默认 MethodChannel 回调在平台主线程，耗时操作要切后台线程，否则卡 UI。

---

## 10. 本地存储方案怎么选？SharedPreferences、文件、SQLite 区别？

**参考答案：**

| 方案 | 特点 | SHOO 场景 |
|------|------|-----------|
| SharedPreferences | 键值对，轻量 | 音乐包已添加标记、迷你播放器位置 |
| 文件 IO | 大文件、结构化弱 | 下载 zip/txt 落盘 `Documents/shoo_downloads/` |
| SQLite/Drift | 关系型、查询强 | 订单、购物车（若扩展） |
| secure_storage | 加密 | Token、敏感凭证 |

**原则：**

- 小配置 → SP
- 大媒体 → 文件 + 路径索引
- 复杂查询 → SQLite

**面试加分：** 说清「不持久化绝对路径」，用 taskId 拼接文件名，避免 iOS 容器路径变化导致找不到文件。

---

## 11. Dio 网络层你会怎么封装？拦截器能做什么？

**参考答案：**

**推荐分层：**

```
API Client (Dio)
  → Interceptors（鉴权、日志、重试、错误映射）
    → Repository
      → Provider / Controller
        → UI
```

**拦截器常见用途：**

1. **Auth**：自动带 Token，401 刷新或跳登录
2. **Log**：Debug 面板打印请求响应
3. **Retry**：弱网重试（指数退避）
4. **Error**：统一 `DioException` → 业务 `AppException`

**Mock 方案（SHOO）：**

本地 Mock Server + Dio `BaseOptions.baseUrl` 按环境切换，面试可讲「一套 UI 联调 Mock/预发/生产」。

---

## 12. 说说你项目里遇到的一个难点和解决过程（STAR 法则）

**参考答案模板：**

- **S**：音乐下载包点击后，音频能播但进不了播放页，偶发双播放器。
- **T**：保证下载列表 → 播放页跳转稳定，且不与悬浮迷你播放器冲突。
- **A**：
  1. 定位 `context.push` 在 `setPlaylist` 后 context 失效
  2. 统一 `router.push` 打开播放页，播放页 bootstrap 再拉播放列表
  3. 路由 Observer 同步 `musicOnPlayerPageProvider`，避免迷你播放器遮挡
  4. 移除 `dispose` 里更新 Provider，修复 defunct 崩溃
- **R**：首次点击稳定进播放页，无重复路由，崩溃消失。

---

## 附录：Flutter 移动端高频关键词速记

- **三棵树**：Widget / Element / RenderObject
- **状态管理**：Riverpod watch vs read
- **路由**：GoRouter redirect + parentNavigatorKey
- **异步**：Future / Stream / mounted 检查
- **性能**：builder 列表、const、缩小 watch 范围
- **存储**：SP + 文件 + 不存绝对路径
- **网络**：Dio 拦截器分层
- **生命周期**：dispose 不 setState、不 ref 更新全局状态

---

*文档路径：`study/flutter_mobile_interview.md` · 百宝箱 → 学习入口*
