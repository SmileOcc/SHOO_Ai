import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/features/activity_webview/presentation/state/hos_dialog_provider.dart';

class SHORulesDialog extends ConsumerWidget {
  const SHORulesDialog({super.key, required this.rules, this.activityId});

  final List<String> rules;
  final String? activityId;

  /// 规则列表区域最大高度（超出后内部滚动）。
  static const double maxContentHeightFactor = 0.42;

  static const double maxWidthFactor = 0.88;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxContentHeight =
        MediaQuery.sizeOf(context).height * maxContentHeightFactor;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * maxWidthFactor,
      ),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Icon(Icons.rule, color: Color(0xFF6A11CB)),
                  SizedBox(width: 8),
                  Text(
                    '活动规则',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxContentHeight),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < rules.length; i++) ...[
                        if (i > 0) const SizedBox(height: 8),
                        Text('${i + 1}. ${rules[i]}'),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (activityId != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '活动编号: $activityId',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => hideActivityDialog(ref),
                  child: const Text('我知道了'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
