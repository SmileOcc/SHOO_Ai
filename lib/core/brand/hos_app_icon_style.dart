/// SHOO 品牌 App Icon 视觉风格（可在 Debug 品牌页切换预览）。
enum SHOAppIconStyle {
  /// 深色圆角方块 + 白色 SHOO 字样
  classic,

  /// 品牌红圆形徽章 + 白色 SHOO
  accentBadge,

  /// 购物袋造型 + 红色提手
  fashionBag,

  /// 大号 S 字母 + 红点
  monogram,

  /// 描边圆环 + 居中 SHOO
  outlineRing,
}

extension SHOAppIconStyleX on SHOAppIconStyle {
  String get label => switch (this) {
        SHOAppIconStyle.classic => 'Classic',
        SHOAppIconStyle.accentBadge => 'Accent Badge',
        SHOAppIconStyle.fashionBag => 'Fashion Bag',
        SHOAppIconStyle.monogram => 'Monogram S',
        SHOAppIconStyle.outlineRing => 'Outline Ring',
      };

  String get labelZh => switch (this) {
        SHOAppIconStyle.classic => '经典方块',
        SHOAppIconStyle.accentBadge => '红色徽章',
        SHOAppIconStyle.fashionBag => '时尚购物袋',
        SHOAppIconStyle.monogram => '字母 S',
        SHOAppIconStyle.outlineRing => '描边圆环',
      };

}

SHOAppIconStyle? shoAppIconStyleFromName(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  for (final style in SHOAppIconStyle.values) {
    if (style.name == raw) return style;
  }
  return null;
}
