import 'dart:async';

/// EventChannel 流订阅基类，强制在 [dispose] 时 cancel，避免内存泄漏。
///
/// ```dart
/// class BatteryStreamService extends SHONativeStreamService<Map<String, dynamic>> {
///   @override
///   Stream<Map<String, dynamic>> get stream => SHONativeEventBridge.broadcast(...);
/// }
/// ```
abstract class SHONativeStreamService<T> {
  StreamSubscription<T>? _subscription;

  Stream<T> get stream;

  bool get isListening => _subscription != null;

  void listen(
    void Function(T event) onData, {
    Function? onError,
    void Function()? onDone,
  }) {
    cancel();
    _subscription = stream.listen(onData, onError: onError, onDone: onDone);
  }

  void cancel() {
    _subscription?.cancel();
    _subscription = null;
  }

  void dispose() => cancel();
}
