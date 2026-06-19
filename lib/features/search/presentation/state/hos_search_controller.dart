import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/home/domain/entities/hos_product.dart';
import 'package:shoo/features/search/data/repositories/hos_search_repository_impl.dart';

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
