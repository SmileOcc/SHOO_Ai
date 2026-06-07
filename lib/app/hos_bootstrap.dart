import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/analytics/hos_app_startup_timer.dart';
import '../core/config/hos_config.dart';
import '../core/debug/core/hos_app_restart.dart';
import '../core/logging/hos_log_manager.dart';
import '../core/storage/hos_image_cache_manager.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  SHOAppStartupTimer.markProcessStart();

  await SHOAppConfig.init();
  await SHOAppLogManager.instance.init();
  await SHOImageCacheManager.ensureReady();
  CachedNetworkImageProvider.defaultCacheManager = SHOImageCacheManager.instance;

  final previousPlatformErrorHandler = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (error, stack) {
    if (SHOImageCacheManager.isReadonlyDbError(error)) {
      unawaited(
        SHOImageCacheManager.recoverFromReadonlyError(error: error),
      );
      return true;
    }
    return previousPlatformErrorHandler?.call(error, stack) ?? false;
  };

  final sharedPreferences = await SharedPreferences.getInstance();
  await prepareRuntimeAfterEnvChange(sharedPreferences);
  SHOAppStartupTimer.markBootstrapEnd();

  runApp(SHOAppRestart(sharedPreferences: sharedPreferences));
}
