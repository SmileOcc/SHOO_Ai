import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/hos_config.dart';
import '../core/logging/hos_logger.dart';
import '../core/storage/hos_image_cache_manager.dart';
import '../core/storage/hos_local_storage.dart';
import 'hos_shoo_app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SHOAppConfig.init();
  await SHOImageCacheManager.ensureReady();
  CachedNetworkImageProvider.defaultCacheManager = SHOImageCacheManager.instance;

  final previousPlatformErrorHandler = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (error, stack) {
    if (SHOImageCacheManager.isReadonlyDbError(error)) {
      SHOAppLogger.warn('Image cache DB readonly, resetting cache: $error');
      SHOImageCacheManager.recoverFromReadonlyError();
      return true;
    }
    return previousPlatformErrorHandler?.call(error, stack) ?? false;
  };

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
