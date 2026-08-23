import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/features/theme_activity/presentation/navigation/hos_theme_activity_link_handler.dart';
import 'package:shoo/features/theme_activity/presentation/style/hos_module_style.dart';

class SHOThemeCountdownModule extends StatefulWidget {
  const SHOThemeCountdownModule({
    super.key,
    required this.raw,
    required this.style,
  });

  final Map<String, dynamic> raw;
  final Map<String, dynamic> style;

  @override
  State<SHOThemeCountdownModule> createState() =>
      _SHOThemeCountdownModuleState();
}

class _SHOThemeCountdownModuleState extends State<SHOThemeCountdownModule> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _expired = false;
  bool _hidden = false;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  DateTime? get _target {
    final mode = widget.raw['mode'] as String? ?? 'toEnd';
    final raw = mode == 'toStart'
        ? widget.raw['startAt']
        : widget.raw['endAt'];
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString())?.toLocal();
  }

  void _tick() {
    final target = _target;
    if (target == null) return;
    final diff = target.difference(DateTime.now());
    if (!mounted) return;

    if (diff.isNegative) {
      _timer?.cancel();
      setState(() {
        _remaining = Duration.zero;
        _expired = true;
      });
      _handleExpire();
      return;
    }
    setState(() => _remaining = diff);
  }

  void _handleExpire() {
    if (!mounted) return;
    final onExpire = widget.raw['onExpire'] as String? ?? 'showText';
    if (onExpire == 'hide') {
      setState(() => _hidden = true);
      return;
    }
    final link = widget.raw['onExpireLink'] as String?;
    if (link != null && link.isNotEmpty) {
      SHOThemeActivityLinkHandler.open(
        context,
        link,
        moduleId: widget.raw['moduleId'] as String?,
      );
    }
  }

  String _formatDuration() {
    final format = widget.raw['format'] as String? ?? 'HMS';
    final d = _remaining;
    if (format == 'MS') {
      final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
      final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
      return '$m:$s';
    }
    if (format == 'DHMS') {
      final days = d.inDays;
      final h = d.inHours.remainder(24).toString().padLeft(2, '0');
      final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
      final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
      if (days > 0) return '$days天 $h:$m:$s';
      return '$h:$m:$s';
    }
    final h = d.inHours.remainder(24).toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_hidden) return const SizedBox.shrink();

    final highlight = parseThemeColor(
      widget.style['highlightColor'] as String?,
      fallback: SHOAppColors.accent,
    );
    final prefix = widget.raw['prefixText'] as String? ?? '';
    final suffix = widget.raw['suffixText'] as String? ?? '';
    final layout = widget.raw['layout'] as String? ?? 'inline';

    if (_expired) {
      final onExpire = widget.raw['onExpire'] as String? ?? 'showText';
      if (onExpire == 'hide') return const SizedBox.shrink();
      final text = widget.raw['expireText'] as String? ?? '';
      if (text.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: highlight,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final digits = _formatDuration();
    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (prefix.isNotEmpty)
          Text(prefix, style: TextStyle(color: highlight)),
        if (prefix.isNotEmpty) const SizedBox(width: 8),
        _DigitBlock(text: digits, color: highlight!),
        if (suffix.isNotEmpty) const SizedBox(width: 8),
        if (suffix.isNotEmpty)
          Text(suffix, style: TextStyle(color: highlight)),
      ],
    );

    if (layout == 'block') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Center(child: content),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: content,
    );
  }
}

class _DigitBlock extends StatelessWidget {
  const _DigitBlock({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 16,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
