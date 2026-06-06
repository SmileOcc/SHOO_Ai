import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/platform/hos_native_business_event.dart';
import '../../../core/platform/hos_native_business_event_service.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/widgets/hos_loading_state.dart';
import '../../../core/widgets/hos_logistics_timeline.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/hos_order.dart';
import 'hos_order_controller.dart';

class SHOLogisticsPage extends ConsumerStatefulWidget {
  const SHOLogisticsPage({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<SHOLogisticsPage> createState() => _SHOLogisticsPageState();
}

class _SHOLogisticsPageState extends ConsumerState<SHOLogisticsPage> {
  final List<SHOLogisticsEvent> _liveEvents = [];
  StreamSubscription<SHONativeBusinessEvent>? _nativeSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nativeSub = ref
          .read(nativeBusinessEventServiceProvider)
          .watchLogistics(orderId: widget.orderId)
          .listen((event) {
        if (!mounted) return;
        setState(() {
          _liveEvents.insert(
            0,
            SHOLogisticsEvent(
              time: DateTime.now().toLocal().toString().substring(0, 16),
              status: event.trackingEvent ?? 'Update',
              description: event.message ?? '',
              isActive: true,
            ),
          );
        });
      });
    });
  }

  @override
  void dispose() {
    _nativeSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final trackAsync = ref.watch(orderLogisticsProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.logisticsTitle)),
      body: trackAsync.whenLoadingState(
        onRetry: () => ref.invalidate(orderLogisticsProvider(widget.orderId)),
        data: (track) {
          final events = [
            ..._liveEvents,
            ...track.events,
          ];

          return ListView(
            padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
            children: [
              if (_liveEvents.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: SHOAppSpacing.md),
                  child: Text(
                    l10n.logisticsLiveUpdates,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SHOAppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(SHOAppSpacing.lg),
                decoration: BoxDecoration(
                  color: SHOAppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(SHOAppSpacing.cardRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.logisticsCarrierLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      track.carrier,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: SHOAppSpacing.md),
                    Text(
                      l10n.logisticsTrackingNoLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            track.trackingNumber,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: track.trackingNumber),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.logisticsCopied)),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SHOAppSpacing.xl),
              Text(
                l10n.logisticsTimelineTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: SHOAppSpacing.lg),
              SHOLogisticsTimeline(events: events),
            ],
          );
        },
      ),
    );
  }
}
