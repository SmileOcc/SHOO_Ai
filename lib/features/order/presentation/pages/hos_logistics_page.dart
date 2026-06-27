import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/platform/business_event/hos_native_business_event.dart';
import 'package:shoo/core/platform/business_event/hos_native_business_event_service.dart';
import 'package:shoo/core/platform/bridge/hos_native_event_bridge.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/widgets/hos_logistics_timeline.dart';
import 'package:shoo/l10n/app_localizations.dart';
import 'package:shoo/features/order/domain/entities/hos_order.dart';
import 'package:shoo/features/order/presentation/state/hos_order_controller.dart';

class SHOLogisticsPage extends SHODataPage<SHOLogisticsTrack> {
  const SHOLogisticsPage({super.key, required this.orderId});

  final String orderId;

  @override
  SHODataPageState<SHOLogisticsTrack, SHOLogisticsPage> createState() =>
      _SHOLogisticsPageState();
}

class _SHOLogisticsPageState
    extends SHODataPageState<SHOLogisticsTrack, SHOLogisticsPage> {
  final List<SHOLogisticsEvent> _liveEvents = [];
  StreamSubscription<SHONativeBusinessEvent>? _nativeSub;

  @override
  ProviderListenable<AsyncValue<SHOLogisticsTrack>> get dataProvider =>
      orderLogisticsProvider(widget.orderId);

  @override
  void invalidateData(WidgetRef ref) =>
      ref.invalidate(orderLogisticsProvider(widget.orderId));

  @override
  String get pageName => 'order_logistics';

  @override
  Map<String, Object?> get pageAnalyticsExtra => {'order_id': widget.orderId};

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
    SHONativeEventBridge.cancelSafely(_nativeSub);
    super.dispose();
  }

  @override
  PreferredSizeWidget? buildPageAppBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppBar(title: Text(l10n.logisticsTitle));
  }

  @override
  Widget buildContent(
    BuildContext context,
    WidgetRef ref,
    SHOLogisticsTrack track,
  ) {
    final l10n = AppLocalizations.of(context);
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
  }
}
