/// Mock 抢购关注内存态（客户端 Mock 与服务端需镜像逻辑）。
abstract final class SHOMockFlashSaleFollowStore {
  static final Map<String, Map<String, dynamic>> _follows = {};

  static String keyFor(String sessionId, String productId) =>
      '$sessionId:$productId';

  static void upsert(Map<String, dynamic> follow) {
    final sessionId = follow['sessionId']?.toString() ?? '';
    final productId = follow['productId']?.toString() ?? '';
    if (sessionId.isEmpty || productId.isEmpty) return;
    _follows[keyFor(sessionId, productId)] = Map<String, dynamic>.from(follow);
  }

  static void remove({required String sessionId, required String productId}) {
    _follows.remove(keyFor(sessionId, productId));
  }

  static List<Map<String, dynamic>> list() =>
      _follows.values.map((e) => Map<String, dynamic>.from(e)).toList()..sort(
        (a, b) => (a['sessionStartAt']?.toString() ?? '').compareTo(
          b['sessionStartAt']?.toString() ?? '',
        ),
      );

  static bool contains({
    required String sessionId,
    required String productId,
  }) => _follows.containsKey(keyFor(sessionId, productId));

  static void replaceAll(List<Map<String, dynamic>> follows) {
    _follows.clear();
    for (final follow in follows) {
      upsert(follow);
    }
  }

  static void clear() => _follows.clear();
}
