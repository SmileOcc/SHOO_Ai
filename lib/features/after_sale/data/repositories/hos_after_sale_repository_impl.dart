import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/after_sale/domain/entities/hos_after_sale.dart';
import 'package:shoo/features/after_sale/data/datasources/remote/hos_after_sale_remote_ds.dart';

final afterSaleRepositoryProvider = Provider<SHOAfterSaleRepository>((ref) {
  return SHOAfterSaleRepository(ref.watch(afterSaleApiProvider));
});

class SHOAfterSaleRepository {
  SHOAfterSaleRepository(this._api);

  final SHOAfterSaleApi _api;

  Future<List<SHOAfterSaleRequest>> getRequests() => _api.fetchRequests();

  Future<SHOAfterSaleRequest> submit(SHOAfterSaleCreateRequest request) =>
      _api.createRequest(request);
}
