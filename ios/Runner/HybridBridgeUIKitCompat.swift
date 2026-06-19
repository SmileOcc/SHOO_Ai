import UIKit

/// iOS 12 兼容的颜色与 UITableView 样式封装。
enum SHOUIKitCompat {
  static var groupedTableStyle: UITableView.Style {
    if #available(iOS 13.0, *) {
      return .insetGrouped
    }
    return .grouped
  }

  static var groupedBackground: UIColor {
    if #available(iOS 13.0, *) {
      return .systemGroupedBackground
    }
    return .groupTableViewBackground
  }

  static var cardBackground: UIColor {
    if #available(iOS 13.0, *) {
      return .secondarySystemGroupedBackground
    }
    return .white
  }

  static var primaryBackground: UIColor {
    if #available(iOS 13.0, *) {
      return .systemBackground
    }
    return .white
  }

  static var secondaryBackground: UIColor {
    if #available(iOS 13.0, *) {
      return .secondarySystemBackground
    }
    return UIColor(white: 0.95, alpha: 1)
  }

  static var secondaryText: UIColor {
    if #available(iOS 13.0, *) {
      return .secondaryLabel
    }
    return .gray
  }

  static var primaryText: UIColor {
    if #available(iOS 13.0, *) {
      return .label
    }
    return .black
  }

  static func makeCloseBarButtonItem(target: Any?, action: Selector) -> UIBarButtonItem {
    if #available(iOS 13.0, *) {
      return UIBarButtonItem(barButtonSystemItem: .close, target: target, action: action)
    }
    return UIBarButtonItem(title: "关闭", style: .plain, target: target, action: action)
  }

  static var accentBlue: UIColor {
    if #available(iOS 13.0, *) { return .systemBlue }
    return rgb(0, 122, 255)
  }

  static var accentTeal: UIColor {
    if #available(iOS 13.0, *) { return .systemTeal }
    return rgb(48, 176, 199)
  }

  static var accentIndigo: UIColor {
    if #available(iOS 13.0, *) { return .systemIndigo }
    return rgb(88, 86, 214)
  }

  static var accentOrange: UIColor {
    if #available(iOS 13.0, *) { return .systemOrange }
    return rgb(255, 149, 0)
  }

  static var accentPink: UIColor {
    if #available(iOS 13.0, *) { return .systemPink }
    return rgb(255, 45, 85)
  }

  static var accentPurple: UIColor {
    if #available(iOS 13.0, *) { return .systemPurple }
    return rgb(175, 82, 222)
  }

  private static func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
    UIColor(red: r / 255, green: g / 255, blue: b / 255, alpha: 1)
  }
}
