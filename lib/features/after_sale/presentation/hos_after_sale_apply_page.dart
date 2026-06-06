import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/widgets/hos_button.dart';
import '../../../core/widgets/hos_image_picker_field.dart';
import '../../../core/widgets/hos_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../order/presentation/hos_order_controller.dart';
import '../domain/hos_after_sale.dart';
import '../data/hos_after_sale_repository.dart';
import 'hos_after_sale_controller.dart';
import 'hos_after_sale_status_label.dart';

class SHOAfterSaleApplyPage extends ConsumerStatefulWidget {
  const SHOAfterSaleApplyPage({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<SHOAfterSaleApplyPage> createState() =>
      _SHOAfterSaleApplyPageState();
}

class _SHOAfterSaleApplyPageState extends ConsumerState<SHOAfterSaleApplyPage> {
  SHOAfterSaleType _type = SHOAfterSaleType.refund;
  final _reasonController = TextEditingController();
  final List<XFile> _evidenceImages = [];
  bool _submitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.afterSaleReasonRequired)),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(afterSaleRepositoryProvider).submit(
            SHOAfterSaleCreateRequest(
              orderId: widget.orderId,
              type: _type,
              reason: reason,
              imageUrls: _evidenceImages.map((f) => f.name).toList(),
            ),
          );
      ref.invalidate(afterSalesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.afterSaleSubmitSuccess)),
        );
        context.go(SHOAppRoutes.afterSales);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final orderAsync = ref.watch(orderDetailProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.afterSaleApplyTitle)),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (order) => ListView(
          padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
          children: [
            Text(
              order.orderNo,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: SHOAppSpacing.xl),
            Text(
              l10n.afterSaleTypeLabel,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: SHOAppSpacing.md),
            ...SHOAfterSaleType.values.map(
              (type) => RadioListTile<SHOAfterSaleType>(
                title: Text(shoAfterSaleTypeLabel(context, type)),
                value: type,
                groupValue: _type,
                onChanged: (v) => setState(() => _type = v!),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
            const SizedBox(height: SHOAppSpacing.xl),
            SHOAppTextField(
              controller: _reasonController,
              label: l10n.afterSaleReasonLabel,
              hint: l10n.afterSaleReasonHint,
              maxLines: 4,
            ),
            const SizedBox(height: SHOAppSpacing.xl),
            SHOImagePickerField(
              label: l10n.afterSaleEvidenceLabel,
              images: _evidenceImages,
              maxCount: 4,
              onChanged: (next) => setState(() {
                _evidenceImages
                  ..clear()
                  ..addAll(next);
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
          child: SHOAppButton(
            label: l10n.afterSaleSubmit,
            isExpanded: true,
            isLoading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
        ),
      ),
    );
  }
}
