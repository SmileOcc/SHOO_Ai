import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/toolbox/data/datasources/remote/hos_contact_remote_ds.dart';
import 'package:shoo/features/toolbox/domain/entities/hos_contact.dart';

/// 按关键字拉取联系人；空串表示全量。页面级防抖后传入，离开页面即释放。
final contactListProvider = FutureProvider.autoDispose
    .family<List<SHOContact>, String>((ref, query) async {
  final api = ref.watch(contactApiProvider);
  final q = query.trim();
  return api.fetchContacts(query: q.isEmpty ? null : q);
});
