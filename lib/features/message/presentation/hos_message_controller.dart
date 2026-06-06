import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/hos_message_api.dart';
import '../domain/hos_message.dart';

final messagesProvider = FutureProvider<List<SHOAppMessage>>((ref) async {
  return ref.watch(messageApiProvider).fetchMessages();
});

final unreadMessageCountProvider = Provider<int>((ref) {
  final async = ref.watch(messagesProvider);
  return async.maybeWhen(
    data: (list) => list.where((m) => !m.isRead).length,
    orElse: () => 0,
  );
});
