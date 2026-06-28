// =============================================================================
// CI 失败演示 #5 — 单元测试失败（flutter test）
// =============================================================================
//
// 对应 CI 步骤：
//   flutter test
//
// 触发条件：任意 test 断言失败
//
// 本文件故意包含的问题：
//   - expect(1, 2) 明显失败的断言
//
// ⚠️ 默认 skip: true，不会阻断 CI。
//    测试 CI 时将下方 skip 改为 false 或删除 skip 参数后提交 PR。
// =============================================================================

import 'package:flutter_test/flutter_test.dart';

/// 改为 false 可触发 flutter test 失败。
const _kCiFailureDemoEnabled = false;

void main() {
  test(
    'CI failure demo — intentional failing assertion',
    () {
      expect(1, 2, reason: 'CI 演示：此断言应失败');
    },
    skip: _kCiFailureDemoEnabled ? false : 'CI 演示：设 _kCiFailureDemoEnabled=true 启用',
  );

  test(
    'CI failure demo — another failing case',
    () {
      expect('main', 'master');
    },
    skip: _kCiFailureDemoEnabled ? false : 'CI 演示：设 _kCiFailureDemoEnabled=true 启用',
  );
}
