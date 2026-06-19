import 'package:flutter_test/flutter_test.dart';
import 'package:shoo/core/utils/hos_version_utils.dart';

void main() {
  test('toNumericCode pads segments and concatenates', () {
    expect(SHOVersionUtils.toNumericCode('0.1.0'), 100);
    expect(SHOVersionUtils.toNumericCode('0.2.0'), 200);
    expect(SHOVersionUtils.toNumericCode('1.2.3'), 10203);
  });

  test('hasUpdate compares numeric codes', () {
    expect(SHOVersionUtils.hasUpdate('0.1.0', '0.2.0'), isTrue);
    expect(SHOVersionUtils.hasUpdate('0.1.0', '0.1.0'), isFalse);
    expect(SHOVersionUtils.hasUpdate('0.2.0', '0.1.0'), isFalse);
  });

  test('parseSegments strips v prefix', () {
    expect(SHOVersionUtils.parseSegments('v0.3.0'), [0, 3, 0]);
  });
}
