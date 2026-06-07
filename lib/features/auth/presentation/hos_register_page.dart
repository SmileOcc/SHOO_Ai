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

class SHORegisterPage extends ConsumerStatefulWidget {
  const SHORegisterPage({super.key});

  @override
  ConsumerState<SHORegisterPage> createState() => _SHORegisterPageState();
}

class _SHORegisterPageState extends ConsumerState<SHORegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!SHOFormHelper.validateAndFocus(_formKey)) return;
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).registerPasswordMismatch)),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final session = await ref.read(sessionProvider.notifier).loginRequest(
            SHOLoginRequest(
              phone: _phoneController.text.trim(),
              password: _passwordController.text,
            ),
          );
      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(SHOAppRoutes.home);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(sessionProvider.notifier).commitLogin(session);
        }
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.registerTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(SHOAppRoutes.home);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SHOAppSpacing.xxxl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.registerMockHint, style: Theme.of(context).textTheme.bodySmall),
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
              const SizedBox(height: SHOAppSpacing.lg),
              SHOAppTextField(
                label: l10n.registerConfirmPassword,
                controller: _confirmController,
                obscureText: true,
                validator: SHOValidators.required(l10n),
              ),
              const SizedBox(height: SHOAppSpacing.xxxl),
              SHOAppButton(
                label: l10n.registerSubmit,
                onPressed: _submit,
                isLoading: _isLoading,
                fullWidth: true,
                variant: SHOAppButtonVariant.accent,
              ),
              const SizedBox(height: SHOAppSpacing.lg),
              SHOAppButton(
                label: l10n.registerHasAccount,
                variant: SHOAppButtonVariant.text,
                onPressed: () => context.push(SHOAppRoutes.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
