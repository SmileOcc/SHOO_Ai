import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/constants/hos_constants.dart';
import 'package:shoo/core/storage/key_value/hos_local_storage.dart';
import 'package:shoo/features/checkout/domain/entities/hos_payment_method.dart';

final paymentPrefsProvider =
    NotifierProvider<SHOPaymentPrefsNotifier, SHOPaymentPrefs>(
  SHOPaymentPrefsNotifier.new,
);

class SHOPaymentPrefs {
  const SHOPaymentPrefs({this.defaultMethod = SHOPaymentMethod.wechat});

  final SHOPaymentMethod defaultMethod;

  SHOPaymentPrefs copyWith({SHOPaymentMethod? defaultMethod}) {
    return SHOPaymentPrefs(defaultMethod: defaultMethod ?? this.defaultMethod);
  }
}

class SHOPaymentPrefsNotifier extends Notifier<SHOPaymentPrefs> {
  late final SHOLocalStorage _storage;

  @override
  SHOPaymentPrefs build() {
    _storage = ref.read(localStorageProvider);
    final saved = _storage.readSync<String>(SHOAppConstants.defaultPaymentMethodKey);
    return SHOPaymentPrefs(
      defaultMethod: _parseMethod(saved) ?? SHOPaymentMethod.wechat,
    );
  }

  SHOPaymentMethod? _parseMethod(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final method in SHOPaymentMethod.values) {
      if (method.name == raw) return method;
    }
    return null;
  }

  Future<void> setDefaultMethod(SHOPaymentMethod method) async {
    state = state.copyWith(defaultMethod: method);
    await _storage.write(SHOAppConstants.defaultPaymentMethodKey, method.name);
  }
}
