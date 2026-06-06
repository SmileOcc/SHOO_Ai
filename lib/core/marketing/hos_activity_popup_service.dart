import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../debug/hos_debug_override_gate.dart';
import '../debug/hos_debug_activity_config_provider.dart';
import '../debug/models/hos_debug_activity_config.dart';
import '../network/hos_dio_client.dart';

final activityPopupServiceProvider = Provider<SHOActivityPopupService>((ref) {
  return SHOActivityPopupService(ref.watch(dioProvider), ref);
});

class SHOActivityPopup {
  const SHOActivityPopup({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.link,
    required this.buttonText,
    this.delaySeconds = 0,
    this.startAt,
    this.endAt,
    this.prefetchEnabled = false,
    this.maxDailyShows = 1,
    this.cachedImagePath,
  });

  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String link;
  final String buttonText;
  final int delaySeconds;
  final DateTime? startAt;
  final DateTime? endAt;
  final bool prefetchEnabled;
  final int maxDailyShows;
  final String? cachedImagePath;

  SHOActivityPopup copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? link,
    String? buttonText,
    int? delaySeconds,
    DateTime? startAt,
    DateTime? endAt,
    bool? prefetchEnabled,
    int? maxDailyShows,
    String? cachedImagePath,
  }) {
    return SHOActivityPopup(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      link: link ?? this.link,
      buttonText: buttonText ?? this.buttonText,
      delaySeconds: delaySeconds ?? this.delaySeconds,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      prefetchEnabled: prefetchEnabled ?? this.prefetchEnabled,
      maxDailyShows: maxDailyShows ?? this.maxDailyShows,
      cachedImagePath: cachedImagePath ?? this.cachedImagePath,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'link': link,
        'buttonText': buttonText,
        'delaySeconds': delaySeconds,
        'startAt': startAt?.toIso8601String(),
        'endAt': endAt?.toIso8601String(),
        'prefetchEnabled': prefetchEnabled,
        'maxDailyShows': maxDailyShows,
      };

  factory SHOActivityPopup.fromJson(Map<String, dynamic> json) {
    return SHOActivityPopup(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String,
      link: json['link'] as String? ?? '',
      buttonText: json['buttonText'] as String? ?? 'Shop Now',
      delaySeconds: json['delaySeconds'] as int? ?? 0,
      startAt: _parseDate(json['startAt']),
      endAt: _parseDate(json['endAt']),
      prefetchEnabled: json['prefetchEnabled'] as bool? ?? false,
      maxDailyShows: json['maxDailyShows'] as int? ?? 1,
    );
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is! String || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}

extension SHODebugActivityConfigMapper on SHODebugActivityConfig {
  SHOActivityPopup toActivityPopup() {
    return SHOActivityPopup(
      id: id,
      title: title,
      description: description,
      imageUrl: imageUrl,
      link: link,
      buttonText: buttonText,
      delaySeconds: delaySeconds,
      startAt: startAt,
      endAt: endAt,
      prefetchEnabled: prefetchEnabled,
      maxDailyShows: maxDailyShows,
    );
  }
}

class SHOActivityPopupService {
  SHOActivityPopupService(this._dio, this._ref);

  final Dio _dio;
  final Ref _ref;

  Future<SHOActivityPopup?> fetchActive() async {
    if (SHODebugOverrideGate.isActivityOverrideActive(_ref)) {
      return _ref.read(debugActivityConfigProvider).toActivityPopup();
    }

    return _dio.getData<SHOActivityPopup?>(
      '/marketing/activity-popup',
      parser: (data) {
        if (data == null) return null;
        return SHOActivityPopup.fromJson(data as Map<String, dynamic>);
      },
    );
  }
}
