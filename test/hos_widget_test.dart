import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoo/app/hos_shoo_app.dart';
import 'package:shoo/core/config/hos_config.dart';
import 'package:shoo/core/constants/hos_constants.dart';
import 'package:shoo/core/storage/hos_local_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await SHOAppConfig.init();
  });

  testWidgets('SHOO app boots with tab shell', (tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_seen': true,
      SHOAppConstants.localeKey: 'en',
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const SHOApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Shop'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Bag'), findsOneWidget);
    expect(find.text('Me'), findsOneWidget);
  });
}
