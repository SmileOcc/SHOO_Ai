// =============================================================================
// CI 失败演示 #3 — 静态分析 Warning（flutter analyze --fatal-warnings）
// =============================================================================
//
// 对应 CI 步骤：
//   flutter analyze --fatal-warnings --no-fatal-infos
//
// 触发条件：warning 在 --fatal-warnings 下等同失败
//
// 本文件故意包含的问题（覆盖 P2 常见规则）：
//   - unused_import          未使用的 import
//   - unused_element         未引用的私有方法
//   - unused_local_variable  未使用的局部变量
//   - inference_failure      List / Future 缺少类型参数
//   - strict_raw_type        裸泛型 Response / Map / List
//   - always_declare_return_types  公共方法缺少返回类型
//   - type_annotate_public_apis      公共 API 缺少类型注解
//   - avoid_print            使用 print（P1 lint）
//
// ⚠️ 默认被 analysis_options.yaml exclude，不会阻断 CI。
// =============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

/// 分析 Warning 示例。
class SHOCiAnalyzeWarningDemo {
  /// warning: type_annotate_public_apis + always_declare_return_types
  runPublicApi(untypedParam) {
    // warning: unused_local_variable
    final neverRead = 'ci-demo';

    // warning: inference_failure_on_collection_literal
    final items = [];

    // warning: inference_failure_on_instance_creation
    Future.delayed(const Duration(milliseconds: 1), () {});

    // warning: avoid_print
    print('CI warning demo: $untypedParam');

    return items;
  }

  /// warning: unused_element
  void _neverCalledHelper() {}

  /// warning: strict_raw_type
  void onResponse(Response response) {
    // warning: strict_raw_type
    Map rawMap = {'k': 1};

    // warning: strict_raw_type
    List rawList = [1, 2, 3];

    response.statusCode;
    rawMap['k'];
    rawList.first;
  }
}
