import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoo/features/category/domain/hos_category.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('parses hierarchical categories from mock asset', () async {
    final raw = await rootBundle.loadString('assets/mock/categories.json');
    final envelope = jsonDecode(raw) as Map<String, dynamic>;
    final list = envelope['data'] as List<dynamic>;

    for (final e in list) {
      final item = SHOCategoryItem.fromJson(e as Map<String, dynamic>);
      expect(item.groups, isNotNull);
      expect(item.groups, isA<List<SHOCategoryGroup>>());
    }
  });

  test('parses flat legacy category without groups key', () {
    final item = parseCategoryItemFromJson({
      'id': 'c1',
      'name': 'Women',
      'icon': '👗',
    });
    expect(item.groups, isEmpty);
  });

  test('parses flat legacy category with null groups', () {
    final item = parseCategoryItemFromJson({
      'id': 'c1',
      'name': 'Women',
      'icon': '👗',
      'groups': null,
    });
    expect(item.groups, isEmpty);
  });
}
