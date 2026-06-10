import 'package:flutter_test/flutter_test.dart';
import 'package:shoo/features/toolbox/data/hos_reading_storage_keys.dart';

void main() {
  group('SHOReadingStorageKeys', () {
    test('preserves bookshelf, downloads, and reader progress keys', () {
      expect(
        SHOReadingStorageKeys.preserveOnPreferencesClear(
          SHOReadingStorageKeys.bookshelf,
        ),
        isTrue,
      );
      expect(
        SHOReadingStorageKeys.preserveOnPreferencesClear(
          SHOReadingStorageKeys.downloadTasks,
        ),
        isTrue,
      );
      expect(
        SHOReadingStorageKeys.preserveOnPreferencesClear(
          '${SHOReadingStorageKeys.progressPrefix}task_1',
        ),
        isTrue,
      );
    });

    test('does not preserve unrelated keys', () {
      expect(
        SHOReadingStorageKeys.preserveOnPreferencesClear('search_history_v1'),
        isFalse,
      );
    });
  });
}
