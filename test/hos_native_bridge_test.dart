import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shoo/core/platform/hos_native_type_caster.dart';

void main() {
  group('SHONativeTypeCaster', () {
    test('casts primitives', () {
      expect(SHONativeTypeCaster.cast<int>(42), 42);
      expect(SHONativeTypeCaster.cast<int>(42.9), 42);
      expect(SHONativeTypeCaster.cast<double>(3.14), 3.14);
      expect(SHONativeTypeCaster.cast<String>('ok'), 'ok');
      expect(SHONativeTypeCaster.cast<bool>(true), isTrue);
      expect(SHONativeTypeCaster.cast<bool>(1), isFalse);
    });

    test('casts collections', () {
      final map = SHONativeTypeCaster.cast<Map<String, dynamic>>({
        'level': 80,
        'charging': true,
      });
      expect(map['level'], 80);
      expect(map['charging'], isTrue);

      final list = SHONativeTypeCaster.cast<List<int>>([1, 2, 3]);
      expect(list, [1, 2, 3]);
    });

    test('casts bytes', () {
      final bytes = SHONativeTypeCaster.cast<Uint8List>([1, 2, 3]);
      expect(bytes, Uint8List.fromList([1, 2, 3]));
    });
  });
}
