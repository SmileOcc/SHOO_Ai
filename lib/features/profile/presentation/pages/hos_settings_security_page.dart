import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/feedback/hos_toast.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/theme/hos_theme_extension.dart';
import 'package:shoo/core/utils/hos_validators.dart';
import 'package:shoo/core/widgets/hos_button.dart';
import 'package:shoo/core/widgets/hos_dialog.dart';
import 'package:shoo/features/auth/presentation/state/hos_session_provider.dart';
import 'package:shoo/features/profile/presentation/state/hos_security_prefs_provider.dart';
import 'package:shoo/features/profile/presentation/widgets/hos_settings_group.dart';
import 'package:shoo/l10n/app_localizations.dart';

class SHOSettingsSecurityPage extends ConsumerStatefulWidget {
  const SHOSettingsSecurityPage({super.key});

  @override
  ConsumerState<SHOSettingsSecurityPage> createState() =>
      _SHOSettingsSecurityPageState();
}

class _SHOSettingsSecurityPageState extends ConsumerState<SHOSettingsSecurityPage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _deletePasswordCtrl = TextEditingController();
  var _saving = false;
  var _deleting = false;
  var _obscureCurrent = true;
  var _obscureNew = true;
  var _obscureConfirm = true;

  @override
  String get pageName => 'settings_security';

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    _deletePasswordCtrl.dispose();
    super.dispose();
  }

  String? _validateConfirm(AppLocalizations l10n, String? value) {
    if (value == null || value.isEmpty) {
      return l10n.settingsSecurityConfirmRequired;
    }
    if (value != _newCtrl.text) {
      return l10n.settingsSecurityConfirmMismatch;
    }
    return null;
  }

  Future<void> _submit() async {
    if (!SHOFormHelper.validateAndFocus(_formKey)) return;
    if (!ref.read(sessionProvider).isAuthenticated) return;

    setState(() => _saving = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      SHOAppToast.success(AppLocalizations.of(context).settingsSecuritySaved);
      _currentCtrl.clear();
      _newCtrl.clear();
      _confirmCtrl.clear();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteAccount() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await SHOAppDialog.confirm(
      context,
      title: l10n.settingsDeleteAccountTitle,
      message: l10n.settingsDeleteAccountMessage,
      confirmLabel: l10n.settingsDeleteAccountConfirm,
      cancelLabel: l10n.dialogCancel,
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;

    final password = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.settingsDeleteAccountVerifyTitle),
          content: TextField(
            controller: _deletePasswordCtrl,
            obscureText: true,
            decoration: InputDecoration(
              labelText: l10n.loginPasswordHint,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.dialogCancel),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, _deletePasswordCtrl.text.trim()),
              child: Text(l10n.dialogConfirm),
            ),
          ],
        );
      },
    );
    _deletePasswordCtrl.clear();
    if (password == null || password.isEmpty || !mounted) return;

    setState(() => _deleting = true);
    try {
      await ref.read(sessionProvider.notifier).deleteAccount();
      if (!mounted) return;
      SHOAppToast.success(l10n.settingsDeleteAccountDone);
      context.go(SHOAppRoutes.home);
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    final securityPrefs = ref.watch(securityPrefsProvider);

    if (!session.isAuthenticated) {
      return buildTrackedPage(
        Scaffold(
          appBar: AppBar(title: Text(l10n.settingsSecurityTitle)),
          body: Center(child: Text(l10n.settingsProfileLoginRequired)),
        ),
      );
    }

    return buildTrackedPage(
      Scaffold(
        appBar: AppBar(title: Text(l10n.settingsSecurityTitle)),
        body: ListView(
          padding: const EdgeInsets.only(bottom: SHOAppSpacing.xxxl),
          children: [
            Padding(
              padding: const EdgeInsets.all(SHOAppSpacing.pagePadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.settingsSecurityHint,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.shoTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: SHOAppSpacing.xl),
                    TextFormField(
                      controller: _currentCtrl,
                      obscureText: _obscureCurrent,
                      decoration: InputDecoration(
                        labelText: l10n.settingsSecurityCurrentPassword,
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscureCurrent = !_obscureCurrent,
                          ),
                          icon: Icon(
                            _obscureCurrent
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: SHOValidators.required(l10n),
                    ),
                    const SizedBox(height: SHOAppSpacing.lg),
                    TextFormField(
                      controller: _newCtrl,
                      obscureText: _obscureNew,
                      decoration: InputDecoration(
                        labelText: l10n.settingsSecurityNewPassword,
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscureNew = !_obscureNew),
                          icon: Icon(
                            _obscureNew
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: SHOValidators.compose([
                        SHOValidators.required(l10n),
                        (value) {
                          if (value != null && value.length < 6) {
                            return l10n.settingsSecurityPasswordTooShort;
                          }
                          return null;
                        },
                      ]),
                    ),
                    const SizedBox(height: SHOAppSpacing.lg),
                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: l10n.settingsSecurityConfirmPassword,
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) => _validateConfirm(l10n, value),
                    ),
                    const SizedBox(height: SHOAppSpacing.xxxl),
                    SHOAppButton(
                      label: l10n.settingsSecuritySubmit,
                      onPressed: _submit,
                      isLoading: _saving,
                      fullWidth: true,
                    ),
                  ],
                ),
              ),
            ),
            SHOSettingsGroup(
              title: l10n.settingsSecurityLoginGroup,
              children: [
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: SHOAppSpacing.lg,
                  ),
                  title: Text(l10n.settingsBiometricLogin),
                  subtitle: Text(l10n.settingsBiometricLoginHint),
                  value: securityPrefs.biometricLoginEnabled,
                  onChanged: (value) => ref
                      .read(securityPrefsProvider.notifier)
                      .setBiometricLoginEnabled(value),
                ),
              ],
            ),
            const SizedBox(height: SHOAppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SHOAppSpacing.pagePadding,
              ),
              child: SHOAppButton(
                label: l10n.settingsDeleteAccount,
                onPressed: _deleting ? null : _deleteAccount,
                isLoading: _deleting,
                fullWidth: true,
                variant: SHOAppButtonVariant.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
