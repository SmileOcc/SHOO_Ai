import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/hos_after_sale.dart';
import 'hos_after_sale_api.dart';

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
