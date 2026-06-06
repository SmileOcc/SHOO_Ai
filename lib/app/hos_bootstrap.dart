import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/hos_config.dart';
import '../core/logging/hos_logger.dart';
import '../core/storage/hos_local_storage.dart';
import 'hos_shoo_app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SHOAppConfig.init();
  SHOAppLogger.info('Started with ${SHOAppConfig.instance}');

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const SHOApp(),
    ),
  );
}
