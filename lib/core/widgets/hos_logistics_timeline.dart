import 'package:flutter/material.dart';

import '../../features/order/domain/hos_order.dart';
import '../theme/hos_colors.dart';
import '../theme/hos_spacing.dart';

/// 物流轨迹时间轴组件。
class SHOLogisticsTimeline extends StatelessWidget {
  const SHOLogisticsTimeline({
    super.key,
    required this.events,
  });

  final List<SHOLogisticsEvent> events;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < events.length; i++)
          _SHOLogisticsTimelineItem(
            event: events[i],
            isLast: i == events.length - 1,
          ),
      ],
    );
  }
}

class _SHOLogisticsTimelineItem extends StatelessWidget {
  const _SHOLogisticsTimelineItem({
    required this.event,
    required this.isLast,
  });

  final SHOLogisticsEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final active = event.isActive;
    final dotColor = active ? SHOAppColors.primary : SHOAppColors.border;
    final lineColor = active ? SHOAppColors.primary : SHOAppColors.border;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: active ? SHOAppColors.primary : SHOAppColors.surface,
                    border: Border.all(color: dotColor, width: 2),
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: lineColor,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : SHOAppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.status,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                          color: active
                              ? SHOAppColors.textPrimary
                              : SHOAppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: SHOAppSpacing.xxs),
                  Text(
                    event.time,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: SHOAppSpacing.xs),
                  Text(
                    event.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: SHOAppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
