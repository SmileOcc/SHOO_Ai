import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/hos_search_history_storage.dart';

final searchHistoryProvider =
    AsyncNotifierProvider<SearchHistoryNotifier, List<String>>(
  SearchHistoryNotifier.new,
);

class SearchHistoryNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() {
    return ref.read(searchHistoryStorageProvider).read();
  }

  Future<void> add(String keyword) async {
    await ref.read(searchHistoryStorageProvider).add(keyword);
    state = AsyncData(await ref.read(searchHistoryStorageProvider).read());
  }

  Future<void> clear() async {
    await ref.read(searchHistoryStorageProvider).clear();
    state = const AsyncData([]);
  }
}
