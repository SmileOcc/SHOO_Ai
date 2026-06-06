/// 原生 EventChannel 业务事件模型。
class SHONativeBusinessEvent {
  const SHONativeBusinessEvent({
    required this.kind,
    required this.payload,
  });

  final String kind;
  final Map<String, dynamic> payload;

  factory SHONativeBusinessEvent.fromDynamic(dynamic raw) {
    final map = Map<String, dynamic>.from(raw as Map);
    final kind = map.remove('kind')?.toString() ?? '';
    return SHONativeBusinessEvent(kind: kind, payload: map);
  }

  String? get orderId => payload['orderId']?.toString();

  String? get status => payload['status']?.toString();

  double? get progress {
    final value = payload['progress'];
    if (value is num) return value.toDouble();
    return null;
  }

  String? get message => payload['message']?.toString();

  String? get trackingEvent => payload['event']?.toString();
}
