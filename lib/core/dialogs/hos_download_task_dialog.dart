import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/hos_spacing.dart';
import '../utils/hos_validators.dart';
import '../widgets/hos_button.dart';
import '../widgets/hos_text_field.dart';
import 'hos_card_dialog_shell.dart';

class SHODownloadTaskDialogResult {
  const SHODownloadTaskDialogResult({
    required this.url,
    this.fileName,
    this.priority = false,
  });

  final String url;
  final String? fileName;
  final bool priority;
}

class SHODownloadTaskDialog extends StatefulWidget {
  const SHODownloadTaskDialog({super.key});

  static Future<SHODownloadTaskDialogResult?> show(BuildContext context) {
    return showDialog<SHODownloadTaskDialogResult>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const SHODownloadTaskDialog(),
    );
  }

  @override
  State<SHODownloadTaskDialog> createState() => _SHODownloadTaskDialogState();
}

class _SHODownloadTaskDialogState extends State<SHODownloadTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _urlCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  var _priority = false;

  @override
  void dispose() {
    _urlCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!SHOFormHelper.validateAndFocus(_formKey)) return;
    Navigator.of(context).pop(
      SHODownloadTaskDialogResult(
        url: _urlCtrl.text.trim(),
        fileName: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
        priority: _priority,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SHOCardDialogShell(
      onClose: () => Navigator.of(context).pop(),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SHOAppSpacing.xxl,
                ),
                child: Text(
                  l10n.downloadTaskDialogTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ),
            const SizedBox(height: SHOAppSpacing.lg),
            SHOAppTextField(
              label: l10n.downloadUrlLabel,
              controller: _urlCtrl,
              keyboardType: TextInputType.url,
              validator: SHOValidators.required(l10n),
            ),
            const SizedBox(height: SHOAppSpacing.lg),
            SHOAppTextField(
              label: l10n.downloadFileNameLabel,
              hint: l10n.downloadFileNameHint,
              controller: _nameCtrl,
            ),
            const SizedBox(height: SHOAppSpacing.sm),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.downloadPriorityLabel),
              value: _priority,
              onChanged: (value) => setState(() => _priority = value),
            ),
            const SizedBox(height: SHOAppSpacing.lg),
            SHOAppButton(
              label: l10n.downloadConfirmStart,
              fullWidth: true,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
