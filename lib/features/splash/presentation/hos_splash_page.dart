import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/hos_routes.dart';
import '../../../core/constants/hos_constants.dart';
import '../../../core/storage/hos_local_storage.dart';
import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../l10n/app_localizations.dart';

const _onboardingSeenKey = 'onboarding_seen';

/// 启动闪屏页：品牌展示 + 路由到引导页或首页。
class SHOSplashPage extends ConsumerStatefulWidget {
  const SHOSplashPage({super.key});

  @override
  ConsumerState<SHOSplashPage> createState() => _SHOSplashPageState();
}

class _SHOSplashPageState extends ConsumerState<SHOSplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final storage = ref.read(localStorageProvider);
    final seen = await storage.read<bool>(_onboardingSeenKey) ?? false;

    if (!seen) {
      context.go(SHOAppRoutes.onboarding);
    } else {
      context.go(SHOAppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: SHOAppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.appName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: SHOAppSpacing.lg),
            Text(
              l10n.splashTagline,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: SHOAppSpacing.xxxl),
            const CircularProgressIndicator(color: SHOAppColors.accent, strokeWidth: 2),
            const SizedBox(height: SHOAppSpacing.md),
            Text(
              '${SHOAppConstants.appVersion}',
              style: const TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
