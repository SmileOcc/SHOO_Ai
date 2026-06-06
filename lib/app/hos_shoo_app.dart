import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/deeplink/hos_deeplink_listener.dart';
import '../core/feedback/hos_toast.dart';
import '../core/l10n/hos_locale_provider.dart';
import '../core/theme/hos_theme.dart';
import '../core/theme/hos_theme_mode_provider.dart';
import '../core/widgets/hos_offline_banner.dart' show SHOAppShell;
import '../l10n/app_localizations.dart';
import 'router/hos_router.dart';

class SHOApp extends ConsumerWidget {
  const SHOApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    ref.watch(deepLinkListenerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: SHOAppTheme.light,
      darkTheme: SHOAppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) {
        return SHOAppShell(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
