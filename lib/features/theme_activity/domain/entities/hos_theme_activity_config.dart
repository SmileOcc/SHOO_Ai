class SHOThemeActivityTracking {
  const SHOThemeActivityTracking({this.prefix, this.channel});

  final String? prefix;
  final String? channel;

  factory SHOThemeActivityTracking.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SHOThemeActivityTracking();
    return SHOThemeActivityTracking(
      prefix: json['prefix'] as String?,
      channel: json['channel'] as String?,
    );
  }
}

class SHOThemeActivityNavBar {
  const SHOThemeActivityNavBar({
    this.style = 'solid',
    this.backgroundColor,
    this.titleColor,
    this.iconColor,
    this.showShare = false,
    this.immersive = false,
  });

  final String style;
  final String? backgroundColor;
  final String? titleColor;
  final String? iconColor;
  final bool showShare;
  final bool immersive;

  factory SHOThemeActivityNavBar.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SHOThemeActivityNavBar();
    return SHOThemeActivityNavBar(
      style: json['style'] as String? ?? 'solid',
      backgroundColor: json['backgroundColor'] as String?,
      titleColor: json['titleColor'] as String?,
      iconColor: json['iconColor'] as String?,
      showShare: json['showShare'] as bool? ?? false,
      immersive: json['immersive'] as bool? ?? false,
    );
  }
}

class SHOThemeActivityPageBackground {
  const SHOThemeActivityPageBackground({this.color, this.image, this.fit});

  final String? color;
  final String? image;
  final String? fit;

  factory SHOThemeActivityPageBackground.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SHOThemeActivityPageBackground();
    return SHOThemeActivityPageBackground(
      color: json['color'] as String?,
      image: json['image'] as String?,
      fit: json['fit'] as String?,
    );
  }
}

class SHOThemeActivityModule {
  const SHOThemeActivityModule({
    required this.moduleId,
    required this.type,
    required this.raw,
    this.visible = true,
    this.sort = 0,
  });

  final String moduleId;
  final String type;
  final Map<String, dynamic> raw;
  final bool visible;
  final int sort;

  factory SHOThemeActivityModule.fromJson(Map<String, dynamic> json) {
    return SHOThemeActivityModule(
      moduleId: json['moduleId'] as String? ?? '',
      type: json['type'] as String? ?? '',
      raw: Map<String, dynamic>.from(json),
      visible: json['visible'] as bool? ?? true,
      sort: json['sort'] as int? ?? 0,
    );
  }
}

class SHOThemeActivityFooter {
  const SHOThemeActivityFooter({
    required this.type,
    required this.raw,
    this.pageSize = 10,
    this.columns = 2,
  });

  final String type;
  final Map<String, dynamic> raw;
  final int pageSize;
  final int columns;

  factory SHOThemeActivityFooter.fromJson(Map<String, dynamic> json) {
    return SHOThemeActivityFooter(
      type: json['type'] as String? ?? '',
      raw: Map<String, dynamic>.from(json),
      pageSize: json['pageSize'] as int? ?? 10,
      columns: json['columns'] as int? ?? 2,
    );
  }
}

class SHOThemeActivityAccess {
  const SHOThemeActivityAccess({
    required this.allowed,
    this.expired = false,
    this.reason = 'ok',
  });

  final bool allowed;
  final bool expired;
  final String reason;

  factory SHOThemeActivityAccess.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const SHOThemeActivityAccess(allowed: true);
    }
    return SHOThemeActivityAccess(
      allowed: json['allowed'] as bool? ?? true,
      expired: json['expired'] as bool? ?? false,
      reason: json['reason'] as String? ?? 'ok',
    );
  }
}

class SHOThemeActivityConfig {
  const SHOThemeActivityConfig({
    required this.activityId,
    required this.title,
    this.status = 'draft',
    this.expiredBehavior = 'browse',
    this.navBar = const SHOThemeActivityNavBar(),
    this.pageBackground = const SHOThemeActivityPageBackground(),
    this.defaultStyle = const {},
    this.modules = const [],
    this.footer,
    this.access = const SHOThemeActivityAccess(allowed: true),
    this.tracking = const SHOThemeActivityTracking(),
  });

  final String activityId;
  final String title;
  final String status;
  final String expiredBehavior;
  final SHOThemeActivityNavBar navBar;
  final SHOThemeActivityPageBackground pageBackground;
  final Map<String, dynamic> defaultStyle;
  final List<SHOThemeActivityModule> modules;
  final SHOThemeActivityFooter? footer;
  final SHOThemeActivityAccess access;
  final SHOThemeActivityTracking tracking;

  List<SHOThemeActivityModule> get visibleModules => modules
      .where((m) => m.visible && m.moduleId.isNotEmpty && m.type.isNotEmpty)
      .toList()
    ..sort((a, b) => a.sort.compareTo(b.sort));

  /// 页面内 coupon 模块出现的所有 couponId。
  Set<String> get couponIds {
    final ids = <String>{};
    for (final module in modules) {
      if (module.type != 'coupon') continue;
      final items = module.raw['items'];
      if (items is! List) continue;
      for (final item in items) {
        if (item is! Map<String, dynamic>) continue;
        final id = item['couponId'] as String? ?? '';
        if (id.isNotEmpty) ids.add(id);
      }
    }
    return ids;
  }

  factory SHOThemeActivityConfig.fromJson(Map<String, dynamic> json) {
    final modulesRaw = json['modules'];
    final modules = modulesRaw is List
        ? modulesRaw
            .whereType<Map<String, dynamic>>()
            .map(SHOThemeActivityModule.fromJson)
            .toList()
        : <SHOThemeActivityModule>[];

    final footerRaw = json['footer'];
    final footer = footerRaw is Map<String, dynamic>
        ? SHOThemeActivityFooter.fromJson(footerRaw)
        : null;

    final defaultStyleRaw = json['defaultStyle'];
    final defaultStyle = defaultStyleRaw is Map<String, dynamic>
        ? Map<String, dynamic>.from(defaultStyleRaw)
        : <String, dynamic>{};

    return SHOThemeActivityConfig(
      activityId: json['activityId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? 'draft',
      expiredBehavior: json['expiredBehavior'] as String? ?? 'browse',
      navBar: SHOThemeActivityNavBar.fromJson(
        json['navBar'] as Map<String, dynamic>?,
      ),
      pageBackground: SHOThemeActivityPageBackground.fromJson(
        json['pageBackground'] as Map<String, dynamic>?,
      ),
      defaultStyle: defaultStyle,
      modules: modules,
      footer: footer,
      access: SHOThemeActivityAccess.fromJson(
        json['_access'] as Map<String, dynamic>?,
      ),
      tracking: SHOThemeActivityTracking.fromJson(
        json['tracking'] as Map<String, dynamic>?,
      ),
    );
  }
}

/// 工具箱预置模板元数据（本地）。
class SHOThemeActivityTemplate {
  const SHOThemeActivityTemplate({
    required this.activityId,
    required this.title,
    required this.description,
  });

  final String activityId;
  final String title;
  final String description;

  static const presets = [
    SHOThemeActivityTemplate(
      activityId: 'demo_long_banner',
      title: '长图大促',
      description: 'bannerStack + marquee + 双列商品',
    ),
    SHOThemeActivityTemplate(
      activityId: 'demo_coupon_rush',
      title: '券+倒计时',
      description: 'countdown + coupon + grid + 单列商品',
    ),
    SHOThemeActivityTemplate(
      activityId: 'demo_nine_waterfall',
      title: '九宫格+瀑布流',
      description: 'grid + unevenGrid + productScroll',
    ),
    SHOThemeActivityTemplate(
      activityId: 'demo_all_modules',
      title: '全模块组件展示',
      description: '10 种模块 + 各模块不同背景色（后台/远程配置）',
    ),
  ];
}
