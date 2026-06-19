import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/message/data/datasources/remote/hos_message_remote_ds.dart';
import 'package:shoo/features/message/domain/entities/hos_message.dart';

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
