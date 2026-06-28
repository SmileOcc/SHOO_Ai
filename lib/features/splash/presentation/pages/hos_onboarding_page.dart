import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shoo/core/analytics/hos_page_analytics.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/app/router/hos_routes.dart';
import 'package:shoo/core/storage/key_value/hos_local_storage.dart';
import 'package:shoo/core/theme/hos_colors.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/widgets/hos_button.dart';
import 'package:shoo/l10n/app_localizations.dart';

const _onboardingSeenKey = 'onboarding_seen';

/// 首次启动引导页（3 屏滑动）。
class SHOOnboardingPage extends ConsumerStatefulWidget {
  const SHOOnboardingPage({super.key});

  @override
  ConsumerState<SHOOnboardingPage> createState() => _SHOOnboardingPageState();
}

class _SHOOnboardingPageState extends ConsumerState<SHOOnboardingPage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  final _controller = PageController();
  int _index = 0;

  @override
  String get pageName => 'onboarding';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(localStorageProvider).write(_onboardingSeenKey, true);
    if (!mounted) return;
    context.replace(SHOAppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final slides = [
      (l10n.onboardingTitle1, l10n.onboardingDesc1, Icons.style),
      (
        l10n.onboardingTitle2,
        l10n.onboardingDesc2,
        Icons.local_shipping_outlined,
      ),
      (l10n.onboardingTitle3, l10n.onboardingDesc3, Icons.savings_outlined),
    ];

    return buildTrackedPage(
      Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: Text(l10n.onboardingSkip),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: slides.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final slide = slides[i];
                    return Padding(
                      padding: const EdgeInsets.all(SHOAppSpacing.xxxl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(slide.$3, size: 80, color: SHOAppColors.accent),
                          const SizedBox(height: SHOAppSpacing.xxxl),
                          Text(
                            slide.$1,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: SHOAppSpacing.lg),
                          Text(
                            slide.$2,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(slides.length, (i) {
                  return Container(
                    width: i == _index ? 16 : 6,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i == _index
                          ? SHOAppColors.primary
                          : SHOAppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.all(SHOAppSpacing.xxxl),
                child: SHOAppButton(
                  label: _index == slides.length - 1
                      ? l10n.onboardingStart
                      : l10n.onboardingNext,
                  isExpanded: true,
                  variant: SHOAppButtonVariant.accent,
                  onPressed: () {
                    if (_index < slides.length - 1) {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    } else {
                      _finish();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
