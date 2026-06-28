import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/activity_webview/presentation/state/hos_dialog_provider.dart';

class SHOLotteryDialog extends ConsumerStatefulWidget {
  const SHOLotteryDialog({super.key});

  @override
  ConsumerState<SHOLotteryDialog> createState() => _SHOLotteryDialogState();
}

class _SHOLotteryDialogState extends ConsumerState<SHOLotteryDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _spinning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _spin() async {
    if (_spinning) return;
    setState(() => _spinning = true);
    _controller.reset();
    await _controller.forward();
    if (!mounted) return;
    setState(() => _spinning = false);
    hideActivityDialog(ref);
    showActivityDialog(ref, 'prize');
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '幸运抽奖',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * pi * 8,
                  child: child,
                );
              },
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Color(0xFFFF6B6B),
                      Color(0xFFFFD93D),
                      Color(0xFF6BCB77),
                      Color(0xFF4D96FF),
                      Color(0xFF9B59B6),
                      Color(0xFFFF8C42),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'GO',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _spinning ? null : _spin,
              child: Text(_spinning ? '抽奖中...' : '开始抽奖'),
            ),
          ],
        ),
      ),
    );
  }
}
