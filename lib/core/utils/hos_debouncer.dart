import 'dart:async';

import '../constants/hos_constants.dart';

class SHODebouncer {
  SHODebouncer({Duration? duration})
      : _duration = duration ?? SHOAppConstants.debounceDuration;

  final Duration _duration;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(_duration, action);
  }

  void dispose() => _timer?.cancel();
}
