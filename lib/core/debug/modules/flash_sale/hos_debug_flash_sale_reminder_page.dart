import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/feedback/hos_toast.dart';
import 'package:shoo/core/notifications/hos_flash_sale_reminder_service.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/widgets/hos_button.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/features/flash_sale/domain/hos_flash_sale_activities.dart';

/// Debug：抢购活动通知弹窗与延时通知调试。
class SHODebugFlashSaleReminderPage extends ConsumerStatefulWidget {
  const SHODebugFlashSaleReminderPage({super.key});

  @override
  ConsumerState<SHODebugFlashSaleReminderPage> createState() =>
      _SHODebugFlashSaleReminderPageState();
}

class _SHODebugFlashSaleReminderPageState
    extends ConsumerState<SHODebugFlashSaleReminderPage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  @override
  String get pageName => 'debug_flash_sale_reminder';

  late final TextEditingController _activityIdCtrl;

  @override
  void initState() {
    super.initState();
    _activityIdCtrl = TextEditingController(text: SHOFlashSaleActivities.flash);
  }

  @override
  void dispose() {
    _activityIdCtrl.dispose();
    super.dispose();
  }

  SHOFlashSaleReminderPayload _samplePayload() {
    final activityId = _activityIdCtrl.text.trim();
    return SHOFlashSaleReminderPayload(
      sessionId: 'fs-debug-session',
      productId: 'fs-p4',
      title: 'Wireless Earbuds X200 — 限时闪购',
      imageUrl: 'https://picsum.photos/seed/fs-p4/400/500',
      sessionStartAt: DateTime.now()
          .add(const Duration(minutes: 8))
          .toUtc()
          .toIso8601String(),
      activityId: activityId.isEmpty ? null : activityId,
    );
  }

  Future<void> _previewPopup() async {
    await ref.read(flashSaleReminderServiceProvider).initialize();
    ref.read(flashSaleReminderServiceProvider).showDebugPopup(_samplePayload());
  }

  Future<void> _scheduleDelayed() async {
    await ref
        .read(flashSaleReminderServiceProvider)
        .scheduleDebugReminder(
          payload: _samplePayload(),
          delay: const Duration(seconds: 8),
        );
    if (mounted) {
      context.showToast('8 秒后将触发抢购活动通知');
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildTrackedPage(
      Scaffold(
        appBar: AppBar(title: const Text('抢购活动通知调试')),
        body: ListView(
          padding: const EdgeInsets.all(SHOAppSpacing.xl),
          children: [
            Text(
              '预览抢购提醒弹窗，或延时 8 秒触发本地通知与前台弹窗。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: SHOAppSpacing.xl),
            TextField(
              controller: _activityIdCtrl,
              decoration: const InputDecoration(
                labelText: '抢购活动 ID',
                hintText: 'activity_flash_001',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: SHOAppSpacing.md),
            Wrap(
              spacing: SHOAppSpacing.sm,
              runSpacing: SHOAppSpacing.sm,
              children: [
                ActionChip(
                  label: const Text('抢购 activity_flash_001'),
                  onPressed: () =>
                      _activityIdCtrl.text = SHOFlashSaleActivities.flash,
                ),
                ActionChip(
                  label: const Text('折扣 activity_discount_001'),
                  onPressed: () =>
                      _activityIdCtrl.text = SHOFlashSaleActivities.discount,
                ),
                ActionChip(
                  label: const Text('通用 activity_common_000'),
                  onPressed: () =>
                      _activityIdCtrl.text = SHOFlashSaleActivities.common,
                ),
              ],
            ),
            const SizedBox(height: SHOAppSpacing.xxxl),
            SHOAppButton(
              label: '立即预览抢购弹窗',
              isExpanded: true,
              onPressed: _previewPopup,
            ),
            const SizedBox(height: SHOAppSpacing.md),
            SHOAppButton(
              label: '延时 8 秒通知',
              variant: SHOAppButtonVariant.outline,
              isExpanded: true,
              onPressed: _scheduleDelayed,
            ),
            const SizedBox(height: SHOAppSpacing.xxxl),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('打开对应抢购活动页'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                final id = _activityIdCtrl.text.trim();
                if (id.isEmpty) return;
                context.push(SHOAppRoutes.flashSaleFor(activityId: id));
              },
            ),
          ],
        ),
      ),
    );
  }
}
