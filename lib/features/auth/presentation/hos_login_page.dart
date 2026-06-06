import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/utils/hos_validators.dart';
import '../../../core/widgets/hos_button.dart';
import '../../../core/widgets/hos_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/hos_auth_user.dart';
import 'hos_session_provider.dart';

class SHOLoginPage extends ConsumerStatefulWidget {
  const SHOLoginPage({super.key, this.redirectTo});

  final String? redirectTo;

  @override
  ConsumerState<SHOLoginPage> createState() => _SHOLoginPageState();
}

class _SHOLoginPageState extends ConsumerState<SHOLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '13800138000');
  final _passwordController = TextEditingController(text: '123456');
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!SHOFormHelper.validateAndFocus(_formKey)) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(sessionProvider.notifier).login(
            SHOLoginRequest(
              phone: _phoneController.text.trim(),
              password: _passwordController.text,
            ),
          );
      if (!mounted) return;
      final redirect = widget.redirectTo;
      if (redirect != null && redirect.isNotEmpty) {
        context.go(redirect);
      } else {
        context.go('/');
      }
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.loginTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SHOAppSpacing.xxxl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.loginMockHint, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: SHOAppSpacing.xl),
              SHOAppTextField(
                label: l10n.loginPhoneHint,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: SHOValidators.compose([
                  SHOValidators.required(l10n),
                  SHOValidators.phone(l10n),
                ]),
              ),
              const SizedBox(height: SHOAppSpacing.lg),
              SHOAppTextField(
                label: l10n.loginPasswordHint,
                controller: _passwordController,
                obscureText: true,
                validator: SHOValidators.compose([
                  SHOValidators.required(l10n),
                  SHOValidators.minLength(l10n, 6),
                ]),
              ),
              if (_error != null) ...[
                const SizedBox(height: SHOAppSpacing.md),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: SHOAppSpacing.xxxl),
              SHOAppButton(
                label: l10n.loginSubmit,
                onPressed: _submit,
                isLoading: _isLoading,
                fullWidth: true,
                variant: SHOAppButtonVariant.accent,
              ),
              const SizedBox(height: SHOAppSpacing.lg),
              SHOAppButton(
                label: l10n.loginNoAccount,
                variant: SHOAppButtonVariant.text,
                onPressed: () => context.push(SHOAppRoutes.register),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
