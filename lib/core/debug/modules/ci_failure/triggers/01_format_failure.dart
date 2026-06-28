// =============================================================================
// CI 失败演示 #1 — 代码格式（dart format）
// =============================================================================
//
// 对应 CI 步骤：
//   dart format --output=none --set-exit-if-changed .
//
// 使用方法：
//   cp lib/core/debug/modules/ci_failure/triggers/01_format_failure.sample \
//      lib/core/debug/modules/ci_failure/triggers/01_format_failure.dart
//   然后提交 PR，format 步骤会失败。
//
// 验证完成后删除 01_format_failure.dart 即可。
//
// 本 sample 故意包含的问题：
//   - prefer_single_quotes：双引号
//   - require_trailing_commas：缺少尾逗号
//   - 缩进/空格不规范
// =============================================================================
//sample
import "dart:math";

class SHOCiFormatFailureDemo {
  SHOCiFormatFailureDemo({this.label="format-bad",this.count=0});

  final String label;
  final int count;

  Map<String,dynamic> toJson( ) {
    return {"label": label,"count": count,"ok": true};
  }

  List<int> buildList( ) {
    return [1,2,3,4,5];
  }
}
