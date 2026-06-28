import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/analytics/hos_page_analytics.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/utils/hos_validators.dart';
import 'package:shoo/core/widgets/hos_button.dart';
import 'package:shoo/core/widgets/hos_text_field.dart';
import 'package:shoo/l10n/app_localizations.dart';
import 'package:shoo/features/auth/domain/entities/hos_auth_user.dart';
import 'package:shoo/features/auth/presentation/state/hos_session_provider.dart';

class SHOLoginPage extends ConsumerStatefulWidget {
  const SHOLoginPage({super.key, this.redirectTo});

  final String? redirectTo;

  @override
  ConsumerState<SHOLoginPage> createState() => _SHOLoginPageState();
}

class _SHOLoginPageState extends ConsumerState<SHOLoginPage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '13800138000');
  final _passwordController = TextEditingController(text: '123456');
  bool _isLoading = false;
  String? _error;

  @override
  String get pageName => 'login';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _exitIfAlreadyLoggedIn(),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(SHOAppRoutes.home);
  }

  void _exitIfAlreadyLoggedIn() {
    if (_isLoading || !mounted) return;
    final session = ref.read(sessionProvider);
    if (session.isAuthenticated && !session.isRestoring) {
      _navigateAfterAuth();
    }
  }

  void _navigateAfterAuth() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    final redirect = widget.redirectTo;
    if (redirect != null && redirect.isNotEmpty) {
      context.go(redirect);
    } else {
      context.go(SHOAppRoutes.home);
    }
  }

  Future<void> _submit() async {
    // 表单校验机制解析 自动聚焦到第一个错误字段，引导用户修正
    if (!SHOFormHelper.validateAndFocus(_formKey)) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final session = await ref
          .read(sessionProvider.notifier)
          .loginRequest(
            SHOLoginRequest(
              phone: _phoneController.text.trim(),
              password: _passwordController.text,
            ),
          );
      if (!mounted) return;
      _navigateAfterAuth();
      // 等 pop/go 完成后再提交会话，避免路由守卫在仍停留在登录页时触发跳转。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(sessionProvider.notifier).commitLogin(session);
        }
      });
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return buildTrackedPage(
      Scaffold(
        appBar: AppBar(
          title: Text(l10n.loginTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBack,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(SHOAppSpacing.xxxl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.loginMockHint,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
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
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
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
      ),
    );
  }
}
