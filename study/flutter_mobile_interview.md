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

**优化要点 & 常见问题：**

### Q1：小组件刷新会影响大组件吗？

**答案：不会直接影响，但可能间接触发。**

- **Element 树复用机制**：Flutter 通过 Widget 的 `key` 和 `runtimeType` 判断是否复用 Element
- **局部刷新**：只有状态变化的 Widget 及其子树会 rebuild
- **潜在问题**：如果父组件的 `build()` 被触发，子组件即使状态没变也会 rebuild（除非使用 const 或 Consumer）

### Q2：如何减少不必要的刷新？

**核心原则**：让 `build()` 尽可能"纯净"，避免执行耗时操作。

**优化策略：**

| 策略 | 适用场景 | 示例 |
|------|---------|------|
| `const` Widget | 无状态、参数不变 | `const Text('Hello')` |
| `Consumer` / `Selector` (Riverpod) | 只监听必要状态 | `Consumer(builder: (_, ref, __) => Text(ref.watch(countProvider)))` |
| `StatefulWidget` 拆分 | 复杂页面拆分为独立状态组件 | 将列表项抽为独立 StatefulWidget |
| `AutomaticKeepAliveClientMixin` | Tab 切换保持状态 | 避免 Tab 切换时重复初始化 |
| `LayoutBuilder` / `Builder` | 隔离 context | 避免不必要的依赖引用 |

**示例对比：**

```dart
// ⚠️ 可优化：状态监听范围过大，导致不必要的 Widget 对象创建
class BadExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final count = ref.watch(countProvider); // 状态在顶层监听
    return Column(
      children: [
        Text('Count: $count'), // 需要状态
        Expanded(child: HugeList()), // Widget 对象会重新创建，但 Element 复用，build() 不执行
      ],
    );
  }
}

// ✅ 好：只在需要的地方监听状态
class GoodExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer(
          builder: (_, ref, __) => Text('Count: ${ref.watch(countProvider)}'),
        ),
        const Expanded(child: HugeList()), // const 避免 rebuild
      ],
    );
  }
}


====

// 方案 A：提取一个独立的小 Widget
class _CountText extends ConsumerWidget {
  const _CountText();
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(countProvider);
    return Text('Count: $count');
  }
}

// 使用
class GoodExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _CountText(),         // 重建仅限于这个小 Widget
        const Expanded(child: HugeList()), // 完全不重建
      ],
    );
  }
}

Widget 重建 ≠ 性能灾难

重要认知：Flutter 中 Widget 本身是非常轻量的，只是一份"配置描述"。真正消耗性能的是底层 Element 树的更新和 RenderObject 的重绘。const 能避免 Widget 重建，但即使没有 const，如果子树结构没变，Flutter 的 diff 算法也会跳过实际绘制。

所以 BadExample 的实际性能影响：

1. `HugeList()` Widget 对象会被重新创建（便宜操作，只是 new 一个对象）
2. 对应的 Element 会复用（通过 runtimeType + key diff 判断）
3. 如果 HugeList 内部不依赖变化的外部状态，其 build() **不会执行**
4. 真正的性能开销：如果 HugeList 内部有 `ref.watch()` 监听了变化的 Provider，则 build() 会执行

const 的好处：
- 连 Widget 对象创建都省了（更省一点内存）
- 明确告诉框架子树不会变，编译时优化
- 但即使没有 const，Element 复用机制也能避免大部分性能问题
```

**小组件 vs 大组件刷新影响：**

```
┌─────────────────────────────────────────────────────────────┐
│                      组件树示例                              │
└─────────────────────────────────────────────────────────────┘

                    ParentWidget (Stateful)
                    ├── build() → 创建新 Widget 对象
                    │
                    ├── ChildA (Stateless, const)
                    │       └── build() 不会执行（Element 复用）
                    │
                    └── ChildB (Consumer)
                            └── 只在监听的 Provider 变化时 rebuild

结论：ChildA 刷新不会影响 ParentWidget
      ParentWidget 刷新会触发 ChildA.build() 创建新 Widget，但 Element 复用
      使用 const/Consumer 可避免不必要的 rebuild
```

**实战技巧：**

1. **使用 `flutter run --profile` 查看 rebuild 热点**
2. **用 `const` 修饰静态子组件**
3. **拆分大 StatefulWidget 为多个小组件**
4. **Riverpod 用户根据场景选择 `Consumer` 或 `ConsumerWidget`**
   - `ConsumerWidget`：适合整个 Widget 都依赖响应式状态的场景，代码更简洁
   - `Consumer`：适合只有部分 UI 需要响应式状态的场景，rebuild 范围更精确
5. 
// ========================================
// Flutter 三层树更新机制（正确版本）
// ========================================

// 1. Widget 重建（最轻量）
//    - Widget 对象重新创建（只是一份配置描述）
//    - Element 通常保持不变（复用）
//    - 开销：分配小对象的 CPU 时间

// 2. Element 重建（最重量）
//    - Element 对象重新创建
//    - State 对象重新创建（状态丢失！）
//    - RenderObject 可能重新创建
//    - 触发条件：Widget 类型/Key 改变、位置改变

// 3. 重绘（Paint）- 中等开销
//    - RenderObject 重新绘制（GPU 绘制命令）
//    - 通常由 Widget/Element 状态变化触发
//    - 开销取决于绘制复杂度

// 动画或频繁变化的部分用 RepaintBoundary 包裹
RepaintBoundary(
  child: AnimatedWidget(), // 内部重绘不影响外部
)
关键结论：

Widget 重建 ≠ 性能问题（Flutter 设计就是如此）
Element 重建才是需要避免的（导致 State 丢失）
RepaintBoundary 优化的不是"重建"，而是"重绘的传播范围"
记忆口诀：Widget 重建是常态，Element 重建才是灾，RepaintBoundary 管重绘，
---

Flutter 三棵树独立的生命周期：

Widget 树：配置的创建和销毁
   ↓ (通过 Element.updateChild)
Element 树：中间协调层，决定复用或重建
   ↓ (通过 Element.renderObject)
RenderObject 树：布局和绘制

关键认知：
- 三棵树的更新是**解耦的**
- Widget 可以快速重建（不影响 Element/RenderObject）
- 重绘只发生在 RenderObject 层
- 不能说"重绘时 Element 不变"，因为两件事可能同时发生

## 3. StatefulWidget 生命周期有哪些？dispose 里能做什么、不能做什么？

**参考答案：**

常见顺序：

// StatefulWidget 完整生命周期
1. constructor             // Widget 创建（可多次）
2. createState()          // 创建 State（只一次）
3. initState()            // 初始化（只一次）此时 context 不可用
4. didChangeDependencies() // 首次 build 前 + InheritedWidget 变化时
5. build()                // 可多次
6. didUpdateWidget()      // 父组件传入新配置
7. setState()             // 触发 rebuild
8. deactivate()           // 从树中移除（可能复用，如 PageView）
9. dispose()              // 永久销毁
10. mounted == false      // 销毁后立即为 false

// dispose 应该做：
- 取消 StreamSubscription / Timer / CancelableOperation
- 释放 AnimationController、TextEditingController、ScrollController 等
- 移除所有监听器（removeListener）
- 断开 FocusNode、GestureRecognizer
- 关闭 Isolate、文件流等重量资源
- 一定调用 super.dispose()（放最后）

// dispose 不应该做：
- ❌ 调用 setState（断言失败）
- ❌ 通过 context 访问 InheritedWidget 或 Navigator
- ❌ 更新全局状态（Provider/Bloc）
- ❌ 发起异步操作后不检查 mounted
- ❌ 在 super.dispose() 之后再访问 State 成员

// didChangeDependencies 不仅首次 build 前调用，后续也会
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  // ⚠️ 注意：
  // 1. 首次 build() 之前一定会调用（在 initState 之后）
  // 2. 之后只要依赖的 InheritedWidget 变化就会再次调用
  // 3. 这里可以安全使用 context
  final mediaQuery = MediaQuery.of(context); // ✅ 安全
}

// deactivate 之后可能再次 build（如果被重新插入树）
@override
void deactivate() {
  super.deactivate();
  // Element 被临时移除，但 State 未销毁
  // 如果之后被重新插入，会调用 build()（不是 initState）
}

super.dispose(); // 必须最后调用，不能忘！

@override
void dispose() {
  setState(() {}); // ❌ 断言失败：!mounted
  super.dispose();
}
修正：如果需要同步状态，在 deactivate 中做。

### didChangeDependencies 生命周期

1. 首次 build 前调用（在 initState 之后）
2. 之后只要依赖的 InheritedWidget 变化就会再次调用
3. 这里可以安全使用 context
```dart
@override
  void initState() {
    super.initState();
    // ❌ 此时 context 还不能安全使用 MediaQuery
    // _screenWidth = MediaQuery.of(context).size.width;
    // ❌ 不能使用 InheritedWidget
    // final width = MediaQuery.of(context).size.width; // 错误
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ 这里安全，获取屏幕宽度
    _screenWidth = MediaQuery.of(context).size.width;
    
    // 屏幕旋转、窗口大小变化时也会被调用
    print('屏幕宽度变为: $_screenWidth');
    // ❌ 但不能调用 setState 而不检查 mounted
    // setState(() {}); // 可能导致错误

    // ❌ 危险：如果 updateTheme 触发 build → didChangeDependencies
    // 可能导致无限循环
    // context.read<ThemeProvider>().updateTheme(newTheme);
    // ✅ 安全：只读取，不修改
    final theme = context.read<ThemeProvider>().theme;
  }
```

2. Mixin 的 dispose 顺序

class _MyWidgetState extends State<MyWidget> 
    with TickerProviderStateMixin, WidgetsBindingObserver {
  
  @override
  void dispose() {
    // ✅ 先移除观察者
    WidgetsBinding.instance.removeObserver(this);
    
    // ✅ 再释放自己的资源
    _controller.dispose();
    
    // ✅ 最后 super.dispose()（会处理 mixin 的资源）
    super.dispose();
  }
}


## 4. BuildContext 是什么？为什么不能长期持有 context？

**参考答案：**

`BuildContext` 本质是 `Element` 的接口，代表当前 Widget 在树中的位置。

用途：

- 查 InheritedWidget（`Theme.of(context)`）
- 导航（`Navigator.of(context)` / `context.push`）
- 显示 `SnackBar`、`Dialog`

**不能长期持有的原因：**

- 1. Element 销毁后 context 失效（defunct 状态）
- 2. 异步操作完成时，原始 context 可能已销毁
- 3. 持有 context 导致内存泄漏（context 持有整棵子树引用）
- 4. 多个页面持有同一 context 会导致混乱

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

维度	Provider	Riverpod
编译安全	运行时类型检查	编译时类型安全
Context 依赖	必须 BuildContext	不依赖，全局可用
自动依赖	手动维护	ref.watch 自动追踪
生命周期	手动 dispose	autoDispose 自动管理
测试	需要 WidgetTester	ProviderContainer 独立测试
参数化	不支持	family 支持
代码生成	无官方方案	riverpod_generator 可选
学习曲线	低	中-高
适用项目	简单-中等	中-大型
维护状态	维护模式	活跃开发

特性	Provider	Riverpod
代码生成	不内置（社区有 provider_generator）	可选（riverpod_generator）
使用复杂度	简单，直接手写	可手写，也可用代码生成简化

// Riverpod 自动管理生命周期
```dart
final userProvider = FutureProvider.autoDispose<User>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.fetchUser();
});
// 当没有任何 Widget 监听 userProvider 时，自动释放资源
// Provider 需要手动管理 dispose
```


- 1. Riverpod 不依赖 BuildContext 读取状态，提供者本身是全局变量，结合 lint 规则可以在编译时检查类型安全和 provider 存在性。
- 2. Provider 的读取依赖运行时查找 InheritedWidget，类型不匹配或未提供时只会在运行时报错。



// Provider 的问题：运行时才发现错误
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ❌ 编译通过，运行时抛 ProviderNotFoundException
    final user = context.read<UserViewModel>();
    return Text(user.name);
  }
}

// Riverpod：编译时就能发现问题
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ❌ 如果 provider 没在 ProviderScope 注册，lint 能警告
    final user = ref.watch(userViewModelProvider);
    return Text(user.name);
  }
}

**Riverpod 核心概念：**

- `Provider`：只读、自动缓存
- `StateProvider`：简单可变状态
- `StateNotifierProvider`：复杂业务状态（如播放器）
- `FutureProvider` / `StreamProvider`：异步数据

## 为什么选 Riverpod？
// 选择 Riverpod 的核心原因（按重要性排序）

1. **编译时安全**
   - Provider 的运行时错误在生产环境是隐患
   - Riverpod 的全局声明 + lint 规则更早发现问题

2. **不依赖 BuildContext**
   - 业务逻辑可以脱离 Widget 树存在
   - ViewModel 中可以直接读取其他 Provider
   - 测试不需要构建 Widget 树

3. **自动资源管理**
   - autoDispose 防止内存泄漏
   - keepAlive 控制生命周期
   - 比 Provider 手动管理更可靠

4. **测试友好**
   - ProviderContainer 可以完全控制依赖
   - override 机制灵活
   - 不依赖 Widget 测试框架

5. **依赖自动追踪**
   - Provider A 变化 → 依赖 A 的 Provider B 自动重建
   - Provider 需要手动协调

6. **社区活跃度**
   - Remi Rousselet 持续维护（Provider 作者创建）
   - Provider 已进入维护模式，新功能优先 Riverpod

// 不选 Riverpod 的场景
- 团队不熟悉，学习成本高
- 项目已有成熟 Provider 架构
- 简单应用（Provider 足够）


**追问：ref.watch 和 ref.read 区别？**

- `watch`：建立依赖，值变会重建当前 Widget。
- `read`：一次性读取，用于事件回调（onTap、init），不应在 `build` 里滥用 `read` 代替 `watch`。

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ❌ 错误：用 read 读取状态值
    final count = ref.read(counterProvider); // 不会响应变化
    
    // ✅ 正确：用 read 获取 notifier 调用方法（只读方法引用）
    final notifier = ref.read(counterProvider.notifier);
    
    // ✅ 也可以：在回调中直接用 read
    return ElevatedButton(
      onPressed: () {
        ref.read(counterProvider.notifier).increment(); // ✅
      },
      child: Text('Increment'),
    );
  }
}
```

2. watch 和 read 的生命周期限制

```dart
// ✅ 可以在任何地方用 read
void initState() {
  super.initState();
  // ✅ initState 中只能用 read
  ref.read(userProvider.notifier).loadUser();
}

// ❌ 不能在这些地方用 watch
void initState() {
  // ❌ 编译错误：initState 中不能 watch
  final user = ref.watch(userProvider);
}

// ✅ watch 只能在 build 方法或 provider 的 create 回调中
@override
Widget build(BuildContext context, WidgetRef ref) {
  final user = ref.watch(userProvider); // ✅
  return Text(user.name);
}
```

3. watch 的细粒度优化：select

```dart
// ❌ user 对象的任何字段变化都会触发 rebuild
final user = ref.watch(userProvider);

// ✅ 只在 name 变化时 rebuild
final name = ref.watch(userProvider.select((user) => user.name));

// ✅ 只在 isLoggedIn 变化时 rebuild
final isLoggedIn = ref.watch(userProvider.select((user) => user.isLoggedIn));
```

4. read 在 provider 内部的危险用法

```dart
// ❌ 危险：provider 内部用 read 读取依赖
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  // ❌ read 不会建立依赖关系
  final api = ref.read(apiServiceProvider);
  return UserNotifier(api);
});

// 问题：apiServiceProvider 被替换后，userProvider 不会更新

// ✅ 正确：用 watch 建立依赖
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final api = ref.watch(apiServiceProvider); // 自动追踪
  return UserNotifier(api);
});
```

## 使用决策树
```dart
需要读取 Provider 的值：
├── 在 build() 中
│   ├── 需要响应变化 → ref.watch(provider)
│   │   └── 可选：.select() 优化粒度
│   ├── 只需读取方法 → ref.read(provider.notifier)
│   └── 需要副作用回调 → ref.listen(provider, callback)
│
├── 在回调中（onTap, onChanged）
│   └── 永远用 ref.read(provider)
│       ├── ref.read(provider) 读取当前值
│       └── ref.read(provider.notifier).method() 调用方法
│
├── 在生命周期中（initState, dispose）
│   └── 永远用 ref.read(provider)
│
└── 在另一个 Provider 的 create 回调中
    └── 用 ref.watch 建立依赖关系
```
---

## 6. GoRouter 和 Navigator 2.0 相比有什么优势？路由守卫怎么做？

```dart
GoRouter 相比 Navigator 2.0 的优势：

1. **零模板声明式路由** - Navigator 2.0 需手动实现 RouterDelegate、
   RouteInformationParser 等 5-6 个类，GoRouter 一个实例搞定
   
2. **内置路由守卫** - redirect 统一鉴权，支持组合守卫模式，比 Navigator 2.0 
   中在 RouterDelegate 写 if-else 更清晰

3. **StatefulShellRoute** - 内置 Tab 保活 + 独立导航栈，Navigator 2.0 实现
   相同功能代码量 5-10 倍

4. **深度链接零配置** - 自动处理 Android App Links / iOS Universal Links，
   Web URL 直接对应路由路径

5. **嵌套导航控制** - parentNavigatorKey 灵活控制全屏页面层级

6. **测试友好** - GoRouter 可在测试中直接操作，不需要 WidgetTester

路由守卫实战：
- 基础：redirect 统一鉴权
- 进阶：角色权限、参数保留、多守卫组合
- 生产级：分离 Guard 类，链式调用
```


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

```dart
1、很多人以为 Future 和 async/await 是并列的选项，这其实是个误区。
async/await 并不是和 Future、Stream 并列的第三种异步方案，它是基于 Future 的语法糖。

当你用 await 等待一个表达式时，Dart 会：

检查该表达式的类型：如果是 Future<T>，就“暂停”并等待其完成，解包出 T；如果是 Stream<T>，你需要用 await for，它等待的是流的关闭或下一个元素（注意有区别）。
在底层，async 函数会被编译器转换成一个状态机，await 就是状态机里的 yield 点。它会自动将后续代码包装成 Future.then() 的回调。
所以正确的分类是：

数据源/结果类型：Future（单值） vs Stream（多值）
代码风格：then/catchError（链式） vs async/await（同步风格）

2、Event Loop 的深度解析：
1. 两个队列的优先级与清空机制

Microtask Queue (微任务)：优先级更高。Event Loop 在每次准备处理下一个 Event 之前，必须先清空 Microtask Queue。
Event Queue (事件)：只有等 Microtask Queue 完全空了，才会从 Event Queue 里取一个事件来处理。处理完后，又会立刻回到检查 Microtask Queue 的逻辑。
这意味着，如果你在微任务里不断产生新的微任务，主线程会永远卡在微任务阶段，Event Queue 里的 UI 绘制、点击事件将永远得不到响应，导致应用假死。

2. 任务分发（什么会进入哪个队列？）

### 进入 Microtask Queue 的“贵宾通道”：

>scheduleMicrotask() 显式调度。
>Future.microtask() 构造函数。
>Completer.complete()：如果你在一个 Future 的 then 回调中调用了另一个 Completer 的 complete，并希望它的监听者立即执行，可以传入微任务（但一般 complete 默认是同步通知，后续监听才进微任务，这里需要细说）。更准确说：Future.then 的回调，如果这个 Future 已经完成，它会在微任务阶段被调用。
>StreamController.add() 的同步订阅：流数据的传递本身可以是同步的，但某些异步订阅的回调也可能进入微任务。

### 进入 Event Queue 的“普通通道”：

>所有 IO 操作（网络、文件）。
>Timer（Timer.run， Future.delayed 内部用 Timer）。
>手势、绘图等 UI 事件。
>通过 ReceivePort 发送的消息。



###总结：
Future 代表未来的单值，Stream 代表未来的一段数据流，而 async/await 是处理和组合 Future 的语法糖，让异步代码看起来像同步。
核心：Event Loop：概念：单线程，两个队列，微任务优先级高且会阻塞事件队列
Isolate，说明它的多线程模型和独立事件循环，是突破单线程性能瓶颈的关键

```

**面试常问输出题：**

```dart
print('A');
Future(() => print('B'));
Future.microtask(() => print('C'));
print('D');
// 输出：A D C B

void main() {
  print('1');
  Future(() => print('2')); // 此 Future 构造函数: Future() -> Event Queue
  Future.microtask(() => print('3')); // -> Microtask Queue
  scheduleMicrotask(() => print('4')); // -> Microtask Queue
  print('5');
}
答案是：1, 5, 3, 4, 2

推演过程：
先同步执行 main 里的代码：打印 1，将 2 加入事件队列，将 3 和 4 加入微任务队列，最后打印 5。
main 函数结束，同步代码执行完毕。
事件循环检查微任务队列：不为空，先执行 3，再执行 4。
微任务队列清空，从事件队列取出一个任务 2，执行它。
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
