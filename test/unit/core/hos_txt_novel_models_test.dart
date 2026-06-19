import 'package:flutter_test/flutter_test.dart';
import 'package:shoo/features/toolbox/domain/entities/hos_txt_novel_models.dart';

void main() {
  group('clampListIndex', () {
    test('returns 0 for empty list', () {
      expect(clampListIndex(5, 0), 0);
      expect(clampListIndex(-1, 0), 0);
    });

    test('clamps to valid range', () {
      expect(clampListIndex(-2, 3), 0);
      expect(clampListIndex(0, 3), 0);
      expect(clampListIndex(2, 3), 2);
      expect(clampListIndex(5, 3), 2);
    });
  });
}
