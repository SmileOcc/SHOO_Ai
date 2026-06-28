import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/after_sale/data/repositories/hos_after_sale_repository_impl.dart';
import 'package:shoo/features/after_sale/domain/entities/hos_after_sale.dart';

final afterSalesProvider = FutureProvider<List<SHOAfterSaleRequest>>((
  ref,
) async {
  final repo = ref.watch(afterSaleRepositoryProvider);
  return repo.getRequests();
});
