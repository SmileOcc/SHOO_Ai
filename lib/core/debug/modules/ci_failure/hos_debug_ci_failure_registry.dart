/// CI 失败演示条目（纯数据，不 import triggers 目录下的问题代码）。
class SHOCiFailureDemoItem {
  const SHOCiFailureDemoItem({
    required this.id,
    required this.title,
    required this.ciStep,
    required this.filePath,
    required this.severity,
    required this.summary,
    required this.issues,
    required this.activationHint,
  });

  final String id;
  final String title;
  final String ciStep;
  final String filePath;
  final String severity;
  final String summary;
  final List<String> issues;
  final String activationHint;
}

/// 全部 CI 演示条目，供 Debug 页展示。
abstract final class SHOCiFailureDemoRegistry {
  static const activationSteps = [
    '打开 analysis_options.yaml，删除 ci_failure/triggers 的 exclude 行',
    '（format）cp triggers/01_format_failure.sample → 01_format_failure.dart',
    '（test）将 05_test_failure_test.dart 的 _kCiFailureDemoEnabled 改为 true',
    '提交并 Push，向 main/master 创建 PR',
    '观察 GitHub Actions CI 各步骤失败情况',
    '验证完成后恢复 exclude / 删除临时 .dart / 改回 false，勿合并到 main',
  ];

  static const items = <SHOCiFailureDemoItem>[
    SHOCiFailureDemoItem(
      id: '01',
      title: '代码格式 format',
      ciStep: 'dart format --output=none --set-exit-if-changed .',
      filePath:
          'lib/core/debug/modules/ci_failure/triggers/01_format_failure.sample',
      severity: '失败（exit 1）',
      summary: '未格式化的 .dart 文件；sample 需复制为 .dart 后才会被 format 检查。',
      issues: [
        '双引号（违反 prefer_single_quotes）',
        '缺少 trailing comma（违反 require_trailing_commas）',
        '缩进/空格不规范',
      ],
      activationHint:
          'cp triggers/01_format_failure.sample triggers/01_format_failure.dart 后提交。',
    ),
    SHOCiFailureDemoItem(
      id: '02',
      title: 'Analyze Error',
      ciStep: 'flutter analyze --fatal-warnings --no-fatal-infos',
      filePath: 'lib/core/debug/modules/ci_failure/triggers/02_analyze_errors.dart',
      severity: '失败（error）',
      summary: '类型错误、未定义符号等 analyzer error。',
      issues: [
        'int getter 返回 String',
        '调用 undefinedCiFailureHelper',
        'strict-casts 不安全 cast',
      ],
      activationHint: '取消 exclude 后 analyze 报 error，--fatal-warnings 下必失败。',
    ),
    SHOCiFailureDemoItem(
      id: '03',
      title: 'Analyze Warning',
      ciStep: 'flutter analyze --fatal-warnings --no-fatal-infos',
      filePath: 'lib/core/debug/modules/ci_failure/triggers/03_analyze_warnings.dart',
      severity: '失败（warning + fatal-warnings）',
      summary: 'P2 常见 warning：未使用代码、类型推断失败、裸泛型等。',
      issues: [
        'unused_import / unused_element / unused_local_variable',
        'inference_failure（List、Future.delayed）',
        'strict_raw_type（Response、Map、List）',
        'type_annotate_public_apis / always_declare_return_types',
        'avoid_print',
      ],
      activationHint: 'CI 已开启 --fatal-warnings，任一 warning 导致失败。',
    ),
    SHOCiFailureDemoItem(
      id: '04',
      title: 'Analyze Info（对照组）',
      ciStep: 'flutter analyze --fatal-warnings --no-fatal-infos',
      filePath: 'lib/core/debug/modules/ci_failure/triggers/04_analyze_infos.dart',
      severity: '不失败（info + no-fatal-infos）',
      summary: 'info 级 lint；当前 CI 配置下不应阻断合并。',
      issues: [
        'avoid_redundant_argument_values',
        'prefer_const_constructors',
      ],
      activationHint: '用于确认 --no-fatal-infos 生效；单独启用不应红 CI。',
    ),
    SHOCiFailureDemoItem(
      id: '05',
      title: '单元测试 test',
      ciStep: 'flutter test',
      filePath: 'test/debug/ci_failure_triggers/05_test_failure_test.dart',
      severity: '失败（test 断言）',
      summary: '故意写错的 expect，flutter test 退出码非 0。',
      issues: [
        'expect(1, 2)',
        'expect("main", "master")',
      ],
      activationHint: '将 05_test_failure_test.dart 中 _kCiFailureDemoEnabled 改为 true。',
    ),
  ];
}
