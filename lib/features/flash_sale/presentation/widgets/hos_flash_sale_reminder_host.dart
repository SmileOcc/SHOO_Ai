import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shoo/app/router/hos_router.dart';
import 'package:shoo/core/notifications/hos_flash_sale_reminder_analytics.dart';
import 'package:shoo/core/notifications/hos_flash_sale_reminder_nav.dart';
import 'package:shoo/core/notifications/hos_flash_sale_reminder_service.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/widgets/hos_button.dart';
import 'package:shoo/features/auth/presentation/state/hos_session_provider.dart';
import 'package:shoo/features/flash_sale/presentation/state/hos_flash_sale_follow_controller.dart';
import 'package:shoo/l10n/app_localizations.dart';

/// 监听关注列表，T-5min 在前台弹出抢购提醒卡片。
class SHOFlashSaleReminderHost extends ConsumerStatefulWidget {
  const SHOFlashSaleReminderHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SHOFlashSaleReminderHost> createState() =>
      _SHOFlashSaleReminderHostState();
}

class _SHOFlashSaleReminderHostState
    extends ConsumerState<SHOFlashSaleReminderHost> with WidgetsBindingObserver {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncForegroundFlag();

    Future.microtask(() async {
      final reminder = ref.read(flashSaleReminderServiceProvider);
      await reminder.initialize();
      reminder.flushPendingNavigation();
    });

    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _poll());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ref.read(appInForegroundProvider.notifier).state =
        state == AppLifecycleState.resumed;
    if (state == AppLifecycleState.resumed) {
      final reminder = ref.read(flashSaleReminderServiceProvider);
      reminder.processPendingNotificationTaps();
      reminder.flushPendingNavigation();
    }
  }

  void _syncForegroundFlag() {
    final state = WidgetsBinding.instance.lifecycleState;
    ref.read(appInForegroundProvider.notifier).state =
        state == null || state == AppLifecycleState.resumed;
  }

  void _poll() {
    if (!ref.read(appInForegroundProvider)) return;

    final follows = ref.read(flashSaleFollowControllerProvider).valueOrNull;
    if (follows == null || follows.isEmpty) return;
    final reminder = ref.read(flashSaleReminderServiceProvider);
    for (final follow in follows) {
      final payload = reminder.pollForegroundPopup(follow);
      if (payload != null) {
        reminder.showForegroundPopup(payload);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionProvider, (prev, next) {
      if (!prev!.isAuthenticated && next.isAuthenticated) {
        ref
            .read(flashSaleFollowControllerProvider.notifier)
            .pushLocalToServer();
      }
    });

    final popup = ref.watch(flashSaleReminderPopupProvider);
    return Stack(
      children: [
        widget.child,
        if (popup != null) _ReminderOverlay(payload: popup),
      ],
    );
  }
}

class _ReminderOverlay extends ConsumerWidget {
  const _ReminderOverlay({required this.payload});

  final SHOFlashSaleReminderPayload payload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final router = ref.read(routerProvider);

    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 300,
          margin: const EdgeInsets.all(SHOAppSpacing.xl),
          padding: const EdgeInsets.all(SHOAppSpacing.xl),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    SHOFlashSaleReminderAnalytics.trackPopupAction(
                      payload: payload,
                      action: 'dismiss',
                    );
                    ref.read(flashSaleReminderPopupProvider.notifier).state =
                        null;
                  },
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: CachedNetworkImage(
                  imageUrl: payload.imageUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: SHOAppSpacing.md),
              Text(
                l10n.flashSaleReminderTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: SHOAppSpacing.sm),
              Text(
                payload.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: SHOAppSpacing.lg),
              SHOAppButton(
                label: l10n.flashSaleReminderAction,
                isExpanded: true,
                onPressed: () {
                  SHOFlashSaleReminderAnalytics.trackPopupAction(
                    payload: payload,
                    action: 'go_flash_sale',
                  );
                  ref.read(flashSaleReminderPopupProvider.notifier).state =
                      null;
                  if (SHOFlashSaleReminderNav.isOnSameActivity(router, payload)) {
                    return;
                  }
                  SHOFlashSaleReminderNav.openActivity(router, payload);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
