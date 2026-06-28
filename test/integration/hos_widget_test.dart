import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoo/app/root/hos_shoo_app.dart';
import 'package:shoo/core/config/hos_config.dart';
import 'package:shoo/core/constants/hos_constants.dart';
import 'package:shoo/core/notifications/hos_flash_sale_reminder_bootstrap.dart';
import 'package:shoo/core/storage/key_value/hos_local_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await SHOAppConfig.init();
    // Mock 通知插件初始化，跳过原生平台调用
    SHOFlashSaleReminderBootstrap.setTestMode();
  });

  testWidgets('SHOO app boots with tab shell', (tester) async {
    final errorWidgetBuilderBeforeTest = ErrorWidget.builder;
    SharedPreferences.setMockInitialValues({
      'onboarding_seen': true,
      SHOAppConstants.localeKey: 'en',
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const SHOApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Shop'), findsWidgets);
    expect(find.text('Category'), findsWidgets);
    expect(find.text('Bag'), findsWidgets);
    expect(find.text('Me'), findsWidgets);

    ErrorWidget.builder = errorWidgetBuilderBeforeTest;
  });
}
