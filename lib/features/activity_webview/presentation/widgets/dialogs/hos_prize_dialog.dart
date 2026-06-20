import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/activity_webview/presentation/state/hos_dialog_provider.dart';

class SHOPrizeDialog extends ConsumerWidget {
  const SHOPrizeDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            const Text(
              '恭喜中奖',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            const Icon(Icons.emoji_events, size: 72, color: Color(0xFFFFB300)),
            const SizedBox(height: 8),
            const Text('满200减100优惠券'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => hideActivityDialog(ref),
                    child: const Text('继续参与'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => hideActivityDialog(ref),
                    child: const Text('查看奖品'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
