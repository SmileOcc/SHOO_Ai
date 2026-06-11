import 'package:flutter/material.dart';

import '../../../../core/theme/hos_colors.dart';
import '../../../../core/theme/hos_spacing.dart';
import '../../../../l10n/app_localizations.dart';

/// 在线播放：输入视频 URL 后跳转播放详情。
abstract final class SHOVideoOnlinePlayDialog {
  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const _SHOVideoOnlinePlayDialogBody(),
    );
  }
}

class _SHOVideoOnlinePlayDialogBody extends StatefulWidget {
  const _SHOVideoOnlinePlayDialogBody();

  @override
  State<_SHOVideoOnlinePlayDialogBody> createState() =>
      _SHOVideoOnlinePlayDialogBodyState();
}

class _SHOVideoOnlinePlayDialogBodyState
    extends State<_SHOVideoOnlinePlayDialogBody> {
  final _controller = TextEditingController();
  var _errorText = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final url = _controller.text.trim();
    if (url.isEmpty) {
      setState(() => _errorText = AppLocalizations.of(context).videoLibraryInvalidUrl);
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !uri.hasScheme ||
        !{'http', 'https'}.contains(uri.scheme)) {
      setState(() => _errorText = AppLocalizations.of(context).videoLibraryInvalidUrl);
      return;
    }
    Navigator.of(context).pop(url);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: SHOAppSpacing.xxl),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SHOAppSpacing.xl,
          SHOAppSpacing.lg,
          SHOAppSpacing.xl,
          SHOAppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.videoLibraryOnlinePlayTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
            const SizedBox(height: SHOAppSpacing.md),
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.go,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: l10n.videoLibraryOnlinePlayHint,
                errorText: _errorText.isEmpty ? null : _errorText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: SHOAppSpacing.lg),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                backgroundColor: SHOAppColors.accent,
                padding: const EdgeInsets.symmetric(vertical: SHOAppSpacing.md),
              ),
              child: Text(l10n.videoLibraryOnlinePlayButton),
            ),
          ],
        ),
      ),
    );
  }
}
