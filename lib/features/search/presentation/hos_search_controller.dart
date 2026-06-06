import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/domain/hos_product.dart';
import '../data/hos_search_repository.dart';

final searchHotKeywordsProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(searchRepositoryProvider);
  return repo.getHotKeywords();
});

final searchResultsProvider =
    FutureProvider.family<List<SHOProduct>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  final repo = ref.watch(searchRepositoryProvider);
  return repo.search(query);
});
