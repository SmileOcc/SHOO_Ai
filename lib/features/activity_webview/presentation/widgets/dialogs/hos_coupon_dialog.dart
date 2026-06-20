import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/feedback/hos_toast.dart';
import 'package:shoo/features/activity_webview/domain/entities/hos_activity_config.dart';
import 'package:shoo/features/activity_webview/presentation/state/hos_dialog_provider.dart';

class SHOCouponDialog extends ConsumerWidget {
  const SHOCouponDialog({super.key, required this.coupon});

  final SHOActivityCoupon coupon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amount = coupon.amount ?? 0;
    final condition = coupon.condition ?? 0;
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF9A44), Color(0xFFFF4E50)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.card_giftcard, color: Colors.white, size: 48),
            const SizedBox(height: 12),
            Text(
              coupon.type,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '满$condition减$amount',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            if (coupon.expireAt != null) ...[
              const SizedBox(height: 8),
              Text(
                '有效期至 ${coupon.expireAt}',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFF4E50),
                ),
                onPressed: () {
                  hideActivityDialog(ref);
                  context.showToast('优惠券已发放到您的账户');
                },
                child: const Text('立即领取'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
