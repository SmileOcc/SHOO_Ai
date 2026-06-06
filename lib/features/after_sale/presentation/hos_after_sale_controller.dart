import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/hos_after_sale_repository.dart';
import '../domain/hos_after_sale.dart';

final afterSalesProvider = FutureProvider<List<SHOAfterSaleRequest>>((ref) async {
  final repo = ref.watch(afterSaleRepositoryProvider);
  return repo.getRequests();
});
