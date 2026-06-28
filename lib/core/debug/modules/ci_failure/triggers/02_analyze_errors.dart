// =============================================================================
// CI 失败演示 #2 — 静态分析 Error（flutter analyze --fatal-warnings）
// =============================================================================
//
// 对应 CI 步骤：
//   flutter analyze --fatal-warnings --no-fatal-infos
//
// 触发条件：analyzer 报 error（任何 error 都会使 analyze 退出码非 0）
//
// 本文件故意包含的问题：
//   - 返回类型不匹配（String 赋值给 int getter）
//   - 调用未定义的方法/符号
//   - strict-casts：不安全的 dynamic 强转
//
// ⚠️ 默认被 analysis_options.yaml exclude，不会阻断 CI。
// =============================================================================

/// 分析 Error 示例：编译期/type 检查失败。
class SHOCiAnalyzeErrorDemo {
  /// error: A value of type 'String' can't be returned from the function 'value'.
  int get value => 'not-an-int';

  void run(dynamic input) {
    // error: The method 'undefinedCiFailureHelper' isn't defined.
    undefinedCiFailureHelper(input);

    // error: strict cast — Map 不能 cast 成 int
    final broken = input as int;
    broken.isEven;
  }
}
