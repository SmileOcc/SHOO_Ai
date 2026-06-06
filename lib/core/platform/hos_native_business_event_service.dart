import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'hos_native_business_event.dart';
import 'hos_native_event_bridge.dart';
import 'hos_native_event_kinds.dart';

final nativeBusinessEventServiceProvider =
    Provider<SHONativeBusinessEventService>((ref) {
  return const SHONativeBusinessEventService();
});

/// 订阅原生业务 EventChannel（支付结果 / 下载进度 / 物流推送）。
class SHONativeBusinessEventService {
  const SHONativeBusinessEventService();

  Stream<SHONativeBusinessEvent> watch(
    String kind, {
    Map<String, dynamic>? params,
  }) {
    final args = _encodeArgs(kind, params);
    return SHONativeEventBridge.broadcast<SHONativeBusinessEvent>(
      arguments: args,
      mapper: SHONativeBusinessEvent.fromDynamic,
    ).where((event) => event.kind == kind || event.kind.isEmpty);
  }

  Stream<SHONativeBusinessEvent> watchPayment({required String orderId}) {
    return watch(SHONativeEventKinds.payment, params: {'orderId': orderId});
  }

  Stream<SHONativeBusinessEvent> watchDownload({String? taskId}) {
    return watch(
      SHONativeEventKinds.download,
      params: taskId == null ? null : {'taskId': taskId},
    );
  }

  Stream<SHONativeBusinessEvent> watchLogistics({required String orderId}) {
    return watch(SHONativeEventKinds.logistics, params: {'orderId': orderId});
  }

  static String _encodeArgs(String kind, Map<String, dynamic>? params) {
    if (params == null || params.isEmpty) return kind;
    return '$kind:${params.entries.map((e) => '${e.key}=${e.value}').join(',')}';
  }
}
