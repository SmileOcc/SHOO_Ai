// =============================================================================
// CI 失败演示 #4 — 静态分析 Info（默认不阻断 CI）
// =============================================================================
//
// 对应 CI 步骤：
//   flutter analyze --fatal-warnings --no-fatal-infos
//
// 触发条件：info 级别；因 CI 使用 --no-fatal-infos，**单独启用本文件不会失败**
//
// 本文件故意包含的问题：
//   - avoid_redundant_argument_values  参数值与默认值相同
//   - prefer_const_constructors        可用 const 却未用
//
// 用途：验证 CI 配置是否按预期「只 fatal warning、不 fatal info」。
// 若将来去掉 --no-fatal-infos，本文件会导致 analyze 失败。
//
// ⚠️ 默认被 analysis_options.yaml exclude，不会阻断 CI。
// =============================================================================

import 'package:flutter/material.dart';

/// Info 级别 lint 示例（当前 CI 不阻断）。
class SHOCiAnalyzeInfoDemo {
  Widget buildBadge() {
    // info: avoid_redundant_argument_values (growable 默认为 false)
    final buffer = List<String>.empty(growable: false);

    // info: prefer_const_constructors
    return Container(
      padding: EdgeInsets.all(8),
      child: Text('CI info demo: ${buffer.length}'),
    );
  }
}
