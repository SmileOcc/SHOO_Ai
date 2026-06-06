/// Design Token — 间距 / 圆角规范。
///
/// 参考文章第一步：统一管理 xs~xxl 间距，Shein 风格偏紧凑。
///
/// ```dart
/// Padding(padding: EdgeInsets.all(SHOAppSpacing.pagePadding))
/// SizedBox(height: SHOAppSpacing.lg)
/// BorderRadius.circular(SHOAppSpacing.cardRadius)
/// ```
abstract final class SHOAppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 20;
  static const double xxxl = 24;

  static const double pagePadding = 10;
  static const double gridGap = 6;
  static const double cardRadius = 2;
  static const double buttonRadius = 2;
  static const double tagRadius = 2;
}
