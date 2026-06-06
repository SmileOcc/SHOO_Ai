import '../../../../l10n/app_localizations.dart';
import 'hos_debug_native_examples.dart';

extension SHONativeDebugL10n on AppLocalizations {
  String nativeCategoryTitle(SHONativeDebugCategory category) {
    return switch (category) {
      SHONativeDebugCategory.methodChannel => debugNativeCategoryMethod,
      SHONativeDebugCategory.messageChannel => debugNativeCategoryMessage,
      SHONativeDebugCategory.eventChannel => debugNativeCategoryEvent,
    };
  }

  String nativeExampleTitle(SHONativeDebugExampleId id) {
    return switch (id) {
      SHONativeDebugExampleId.ping => debugNativeExamplePingTitle,
      SHONativeDebugExampleId.platformVersion => debugNativeExampleVersionTitle,
      SHONativeDebugExampleId.messageEcho => debugNativeExampleMessageTitle,
      SHONativeDebugExampleId.eventTick => debugNativeExampleEventTitle,
    };
  }

  String nativeExampleDesc(SHONativeDebugExampleId id) {
    return switch (id) {
      SHONativeDebugExampleId.ping => debugNativeExamplePingDesc,
      SHONativeDebugExampleId.platformVersion => debugNativeExampleVersionDesc,
      SHONativeDebugExampleId.messageEcho => debugNativeExampleMessageDesc,
      SHONativeDebugExampleId.eventTick => debugNativeExampleEventDesc,
    };
  }
}
