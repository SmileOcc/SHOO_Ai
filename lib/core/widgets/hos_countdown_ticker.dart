import 'dart:async';

import 'package:flutter/material.dart';

enum SHOCountdownFormat { hms, ms, dhms }

/// 倒计时格式化工具。
String formatCountdownDuration(
  Duration duration, {
  SHOCountdownFormat format = SHOCountdownFormat.hms,
}) {
  switch (format) {
    case SHOCountdownFormat.ms:
      final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
      final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
      return '$m:$s';
    case SHOCountdownFormat.dhms:
      final days = duration.inDays;
      final h = duration.inHours.remainder(24).toString().padLeft(2, '0');
      final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
      final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
      if (days > 0) return '$days天 $h:$m:$s';
      return '$h:$m:$s';
    case SHOCountdownFormat.hms:
      final h = duration.inHours.remainder(24).toString().padLeft(2, '0');
      final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
      final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
      return '$h:$m:$s';
  }
}

/// 共享倒计时 Timer 逻辑，供闪购 / 主题活动等复用。
mixin SHOCountdownTickerMixin<T extends StatefulWidget> on State<T> {
  Timer? countdownTimer;
  Duration countdownRemaining = Duration.zero;
  bool countdownExpired = false;

  void startCountdown(
    DateTime? target, {
    VoidCallback? onComplete,
  }) {
    countdownTimer?.cancel();
    if (target == null) return;

    void tick() {
      final diff = target.difference(DateTime.now());
      if (!mounted) return;
      if (diff.isNegative) {
        countdownTimer?.cancel();
        setState(() {
          countdownRemaining = Duration.zero;
          countdownExpired = true;
        });
        onComplete?.call();
        return;
      }
      setState(() {
        countdownRemaining = diff;
        countdownExpired = false;
      });
    }

    tick();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  void disposeCountdownTicker() {
    countdownTimer?.cancel();
    countdownTimer = null;
  }
}
