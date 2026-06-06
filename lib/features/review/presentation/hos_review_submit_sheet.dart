import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/feedback/hos_toast.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/widgets/hos_button.dart';
import '../../../core/widgets/hos_dialog.dart';
import '../../../core/widgets/hos_image_picker_field.dart';
import '../../../core/widgets/hos_text_field.dart';
import '../../../l10n/app_localizations.dart';

/// 评价晒图提交（Mock：本地选图 + Toast 反馈）。
abstract final class SHOReviewSubmitSheet {
  static Future<void> show(
    BuildContext context, {
    required String productId,
  }) {
    return SHOAppDialog.showBottomSheet<void>(
      context,
      isScrollControlled: true,
      child: SingleChildScrollView(
        child: _SHOReviewSubmitSheetBody(productId: productId),
      ),
    );
  }
}

class _SHOReviewSubmitSheetBody extends ConsumerStatefulWidget {
  const _SHOReviewSubmitSheetBody({required this.productId});

  final String productId;

  @override
  ConsumerState<_SHOReviewSubmitSheetBody> createState() =>
      _SHOReviewSubmitSheetBodyState();
}

class _SHOReviewSubmitSheetBodyState
    extends ConsumerState<_SHOReviewSubmitSheetBody> {
  final _contentController = TextEditingController();
  final List<XFile> _images = [];
  bool _submitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      SHOAppToast.error(l10n.reviewSubmitContentRequired);
      return;
    }

    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _submitting = false);
    Navigator.pop(context);
    SHOAppToast.success(
      l10n.reviewSubmitSuccess(_images.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: SHOAppSpacing.pagePadding,
        right: SHOAppSpacing.pagePadding,
        top: SHOAppSpacing.xl,
        bottom: MediaQuery.viewInsetsOf(context).bottom + SHOAppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.reviewSubmitTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: SHOAppSpacing.lg),
          SHOAppTextField(
            controller: _contentController,
            label: l10n.reviewSubmitContentLabel,
            hint: l10n.reviewSubmitContentHint,
            maxLines: 4,
          ),
          const SizedBox(height: SHOAppSpacing.xl),
          SHOImagePickerField(
            label: l10n.reviewSubmitPhotosLabel,
            images: _images,
            maxCount: 6,
            onChanged: (next) => setState(() {
              _images
                ..clear()
                ..addAll(next);
            }),
          ),
          const SizedBox(height: SHOAppSpacing.xl),
          SHOAppButton(
            label: l10n.reviewSubmitAction,
            isExpanded: true,
            isLoading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }
}
