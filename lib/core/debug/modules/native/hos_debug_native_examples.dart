import 'package:flutter/material.dart';

/// 原生调试示例分类。
enum SHONativeDebugCategory {
  methodChannel,
  messageChannel,
  eventChannel,
}

/// 原生调试示例 ID（对应路由 `:id`）。
enum SHONativeDebugExampleId {
  ping,
  platformVersion,
  messageEcho,
  eventTick,
}

class SHONativeDebugExample {
  const SHONativeDebugExample({
    required this.id,
    required this.category,
    required this.icon,
  });

  final SHONativeDebugExampleId id;
  final SHONativeDebugCategory category;
  final IconData icon;

  String get routeId => id.name;
}

const kNativeDebugExamples = <SHONativeDebugExample>[
  SHONativeDebugExample(
    id: SHONativeDebugExampleId.ping,
    category: SHONativeDebugCategory.methodChannel,
    icon: Icons.wifi_tethering,
  ),
  SHONativeDebugExample(
    id: SHONativeDebugExampleId.platformVersion,
    category: SHONativeDebugCategory.methodChannel,
    icon: Icons.phone_iphone_outlined,
  ),
  SHONativeDebugExample(
    id: SHONativeDebugExampleId.messageEcho,
    category: SHONativeDebugCategory.messageChannel,
    icon: Icons.swap_horiz,
  ),
  SHONativeDebugExample(
    id: SHONativeDebugExampleId.eventTick,
    category: SHONativeDebugCategory.eventChannel,
    icon: Icons.stream,
  ),
];

SHONativeDebugExample? findNativeDebugExample(String routeId) {
  for (final example in kNativeDebugExamples) {
    if (example.routeId == routeId) return example;
  }
  return null;
}

List<SHONativeDebugExample> nativeDebugExamplesByCategory(
  SHONativeDebugCategory category,
) {
  return kNativeDebugExamples.where((e) => e.category == category).toList();
}
