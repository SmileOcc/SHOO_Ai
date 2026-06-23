// ----------------------------------------------------------
// Mixin 线性化链 / 同名方法冲突 / 业务聚合 Demo
// ----------------------------------------------------------

// --- 演示一：线性化链（super 链式调用）---

abstract class SHODebugAnimal {
  String describe() => 'Animal';
}

mixin SHODebugWalkable on SHODebugAnimal {
  @override
  String describe() => '${super.describe()} → Walkable';
}

mixin SHODebugSwimmable on SHODebugAnimal {
  @override
  String describe() => '${super.describe()} → Swimmable';
}

mixin SHODebugFlyable on SHODebugAnimal {
  @override
  String describe() => '${super.describe()} → Flyable';
}

/// with Walkable, Swimmable, Flyable
/// 最右 Flyable 链头，super 向左：Swimmable → Walkable → Animal
class SHODebugDuck extends SHODebugAnimal
    with SHODebugWalkable, SHODebugSwimmable, SHODebugFlyable {}

/// 交换 with 顺序
class SHODebugDuckReversed extends SHODebugAnimal
    with SHODebugFlyable, SHODebugSwimmable, SHODebugWalkable {}

// --- 演示二：多个 Mixin 同名方法冲突 ---

mixin SHODebugLoggerA {
  String log() => 'LoggerA: logging from mixin A';
}

mixin SHODebugLoggerB {
  String log() => 'LoggerB: logging from mixin B';
}

mixin SHODebugLoggerC {
  String log() => 'LoggerC: logging from mixin C';
}

/// 最右侧 C 覆盖 A、B
class SHODebugService extends Object
    with SHODebugLoggerA, SHODebugLoggerB, SHODebugLoggerC {}

/// 调换顺序：A 覆盖 B、C
class SHODebugServiceReversed extends Object
    with SHODebugLoggerC, SHODebugLoggerB, SHODebugLoggerA {}

// --- 演示三：业务 Form Mixin 聚合 ---

mixin SHODebugValidatable {
  List<String> validate(Map<String, String> fields) {
    final errors = <String>[];
    for (final entry in fields.entries) {
      if (entry.value.trim().isEmpty) {
        errors.add('${entry.key} 不能为空');
      }
    }
    return errors;
  }
}

mixin SHODebugLoadable {
  bool _loading = false;
  bool get isLoading => _loading;
  void setLoading(bool v) {
    _loading = v;
  }
}

mixin SHODebugTraceable {
  final List<String> _trace = [];
  List<String> get trace => List.unmodifiable(_trace);
  void addTrace(String step) {
    _trace.add('[${DateTime.now().toIso8601String().substring(11, 23)}] $step');
  }
}

class SHODebugBizForm
    with SHODebugValidatable, SHODebugLoadable, SHODebugTraceable {
  String submit({required String username, required String password}) {
    addTrace('submit 开始');
    final errors = validate({'username': username, 'password': password});
    if (errors.isNotEmpty) {
      addTrace('校验失败: ${errors.join(", ")}');
      return '校验失败: ${errors.join(", ")}';
    }
    setLoading(true);
    addTrace('loading=true');
    setLoading(false);
    addTrace('loading=false, 提交成功');
    return '提交成功: $username';
  }
}
