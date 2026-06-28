import 'package:shoo/features/activity_webview/domain/entities/hos_activity_promo.dart';

class SHOActivityModule {
  const SHOActivityModule({
    required this.id,
    required this.icon,
    required this.title,
    required this.desc,
    required this.type,
    required this.action,
    this.params = const {},
  });

  final String id;
  final String icon;
  final String title;
  final String desc;
  final String type;
  final String action;
  final Map<String, dynamic> params;

  factory SHOActivityModule.fromJson(Map<String, dynamic> json) {
    return SHOActivityModule(
      id: json['id'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      title: json['title'] as String? ?? '',
      desc: json['desc'] as String? ?? '',
      type: json['type'] as String? ?? '',
      action: json['action'] as String? ?? '',
      params: Map<String, dynamic>.from(json['params'] as Map? ?? const {}),
    );
  }
}

class SHOActivityImage {
  const SHOActivityImage({
    required this.url,
    required this.title,
    this.width,
    this.height,
  });

  final String url;
  final String title;
  final int? width;
  final int? height;

  factory SHOActivityImage.fromJson(Map<String, dynamic> json) {
    return SHOActivityImage(
      url: json['url'] as String? ?? '',
      title: json['title'] as String? ?? '',
      width: json['width'] as int?,
      height: json['height'] as int?,
    );
  }
}

class SHOActivityCoupon {
  const SHOActivityCoupon({
    required this.type,
    this.amount,
    this.condition,
    this.discount,
    this.desc,
    this.expireAt,
  });

  final String type;
  final int? amount;
  final int? condition;
  final double? discount;
  final String? desc;
  final String? expireAt;

  factory SHOActivityCoupon.fromJson(Map<String, dynamic> json) {
    return SHOActivityCoupon(
      type: json['type'] as String? ?? '',
      amount: json['amount'] as int?,
      condition: json['condition'] as int?,
      discount: (json['discount'] as num?)?.toDouble(),
      desc: json['desc'] as String?,
      expireAt: json['expireAt'] as String?,
    );
  }
}

class SHOActivityConfig {
  const SHOActivityConfig({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.shareTitle,
    required this.shareDesc,
    required this.shareUrl,
    required this.modules,
    required this.images,
    required this.coupons,
    required this.rules,
    this.promoBlocks = const [],
    this.navigation,
    this.paymentTestUrl,
    this.startTime,
    this.endTime,
  });

  final String id;
  final String title;
  final String subtitle;
  final String shareTitle;
  final String shareDesc;
  final String shareUrl;
  final List<SHOActivityModule> modules;
  final List<SHOActivityImage> images;
  final List<SHOActivityCoupon> coupons;
  final List<String> rules;
  final List<SHOActivityPromoBlock> promoBlocks;
  final SHOActivityNavigation? navigation;
  final String? paymentTestUrl;
  final String? startTime;
  final String? endTime;

  factory SHOActivityConfig.fromJson(Map<String, dynamic> json) {
    return SHOActivityConfig(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      shareTitle: json['shareTitle'] as String? ?? '',
      shareDesc: json['shareDesc'] as String? ?? '',
      shareUrl: json['shareUrl'] as String? ?? '',
      modules: (json['modules'] as List<dynamic>? ?? const [])
          .map(
            (e) =>
                SHOActivityModule.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      images: (json['images'] as List<dynamic>? ?? const [])
          .map(
            (e) =>
                SHOActivityImage.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      coupons: (json['coupons'] as List<dynamic>? ?? const [])
          .map(
            (e) =>
                SHOActivityCoupon.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      rules: (json['rules'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      promoBlocks: (json['promoBlocks'] as List<dynamic>? ?? const [])
          .map(
            (e) => SHOActivityPromoBlock.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
      navigation: json['navigation'] == null
          ? null
          : SHOActivityNavigation.fromJson(
              Map<String, dynamic>.from(json['navigation'] as Map),
            ),
      paymentTestUrl: json['paymentTestUrl'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
    );
  }
}

class SHOActivityUserStatus {
  const SHOActivityUserStatus({
    required this.loggedIn,
    required this.nickname,
    this.avatar,
    this.level,
    this.coupons = 0,
    this.points = 0,
  });

  final bool loggedIn;
  final String nickname;
  final String? avatar;
  final String? level;
  final int coupons;
  final int points;

  factory SHOActivityUserStatus.fromJson(Map<String, dynamic> json) {
    return SHOActivityUserStatus(
      loggedIn: json['loggedIn'] as bool? ?? false,
      nickname: json['nickname'] as String? ?? '',
      avatar: json['avatar'] as String?,
      level: json['level'] as String?,
      coupons: json['coupons'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
    );
  }
}
