import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/constants/hos_constants.dart';
import 'package:shoo/core/storage/key_value/hos_local_storage.dart';

class SHONotificationPrefs {
  const SHONotificationPrefs({
    this.orderUpdates = true,
    this.promotions = true,
    this.flashSaleReminders = true,
  });

  final bool orderUpdates;
  final bool promotions;
  final bool flashSaleReminders;

  SHONotificationPrefs copyWith({
    bool? orderUpdates,
    bool? promotions,
    bool? flashSaleReminders,
  }) {
    return SHONotificationPrefs(
      orderUpdates: orderUpdates ?? this.orderUpdates,
      promotions: promotions ?? this.promotions,
      flashSaleReminders: flashSaleReminders ?? this.flashSaleReminders,
    );
  }
}

final notificationPrefsProvider =
    NotifierProvider<SHONotificationPrefsNotifier, SHONotificationPrefs>(
  SHONotificationPrefsNotifier.new,
);

class SHONotificationPrefsNotifier extends Notifier<SHONotificationPrefs> {
  late final SHOLocalStorage _storage;

  @override
  SHONotificationPrefs build() {
    _storage = ref.read(localStorageProvider);
    return SHONotificationPrefs(
      orderUpdates:
          _storage.readSync<bool>(SHOAppConstants.notifyOrderUpdatesKey) ??
          true,
      promotions:
          _storage.readSync<bool>(SHOAppConstants.notifyPromotionsKey) ?? true,
      flashSaleReminders:
          _storage.readSync<bool>(SHOAppConstants.notifyFlashSaleKey) ?? true,
    );
  }

  Future<void> setOrderUpdates(bool value) async {
    state = state.copyWith(orderUpdates: value);
    await _storage.write(SHOAppConstants.notifyOrderUpdatesKey, value);
  }

  Future<void> setPromotions(bool value) async {
    state = state.copyWith(promotions: value);
    await _storage.write(SHOAppConstants.notifyPromotionsKey, value);
  }

  Future<void> setFlashSaleReminders(bool value) async {
    state = state.copyWith(flashSaleReminders: value);
    await _storage.write(SHOAppConstants.notifyFlashSaleKey, value);
  }
}
