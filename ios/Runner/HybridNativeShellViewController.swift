import UIKit

/// 嵌入 Flutter 页顶部的原生导航栏（毛玻璃，非纯白底）。
final class SHOHybridTopBar: UIView {
  var onBack: (() -> Void)?

  private let blurView: UIVisualEffectView
  private let titleLabel = UILabel()
  private let backButton = UIButton(type: .system)
  private let bottomLine = UIView()

  init(title: String) {
    blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    blurView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(blurView)

    backButton.translatesAutoresizingMaskIntoConstraints = false
    backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
    backButton.tintColor = SHOUIKitCompat.primaryText
    backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.text = title
    titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
    titleLabel.textColor = SHOUIKitCompat.primaryText
    titleLabel.textAlignment = .center

    bottomLine.translatesAutoresizingMaskIntoConstraints = false
    bottomLine.backgroundColor = UIColor.separator.withAlphaComponent(0.35)

    addSubview(backButton)
    addSubview(titleLabel)
    addSubview(bottomLine)

    NSLayoutConstraint.activate([
      blurView.topAnchor.constraint(equalTo: topAnchor),
      blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
      blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
      blurView.bottomAnchor.constraint(equalTo: bottomAnchor),

      backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
      backButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
      backButton.widthAnchor.constraint(equalToConstant: 44),
      backButton.heightAnchor.constraint(equalToConstant: 44),

      titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
      titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
      titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 8),
      titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -52),

      bottomLine.leadingAnchor.constraint(equalTo: leadingAnchor),
      bottomLine.trailingAnchor.constraint(equalTo: trailingAnchor),
      bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor),
      bottomLine.heightAnchor.constraint(equalToConstant: 0.5),
    ])
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  @objc private func backTapped() {
    onBack?()
  }
}

/// 透明穿透视图：仅顶栏区域响应触摸，其余事件交给下层 Flutter。
private final class SHOHybridPassthroughView: UIView {
  weak var topBar: SHOHybridTopBar?

  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    guard let topBar else { return nil }
    let barPoint = topBar.convert(point, from: self)
    if topBar.bounds.contains(barPoint) {
      return topBar.hitTest(barPoint, with: event)
    }
    return nil
  }
}

/// 透明壳层：不占用第二份 FlutterEngine，仅叠加原生顶栏，底下显示根 FlutterViewController。
final class HybridNativeShellViewController: UIViewController {
  private let topBar: SHOHybridTopBar
  private var topBarHeightConstraint: NSLayoutConstraint?
  private var passthroughView: SHOHybridPassthroughView {
    view as! SHOHybridPassthroughView
  }

  init(title: String) {
    topBar = SHOHybridTopBar(title: title)
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func loadView() {
    let root = SHOHybridPassthroughView()
    root.backgroundColor = .clear
    root.isOpaque = false
    root.topBar = topBar
    view = root
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    topBar.onBack = { [weak self] in
      self?.handleBack()
    }
    passthroughView.addSubview(topBar)

    let height = topBar.heightAnchor.constraint(equalToConstant: 88)
    topBarHeightConstraint = height
    NSLayoutConstraint.activate([
      topBar.topAnchor.constraint(equalTo: passthroughView.topAnchor),
      topBar.leadingAnchor.constraint(equalTo: passthroughView.leadingAnchor),
      topBar.trailingAnchor.constraint(equalTo: passthroughView.trailingAnchor),
      height,
    ])
  }

  override func viewSafeAreaInsetsDidChange() {
    super.viewSafeAreaInsetsDidChange()
    topBarHeightConstraint?.constant = view.safeAreaInsets.top + 44
  }

  private func handleBack() {
    HybridBridgeCoordinator.shared.restoreToSActivityFromEmbedded()
  }

  static func resolveTitle(from route: String) -> String {
    if route.hasPrefix("/cart") { return "购物车" }
    if route.hasPrefix("/category/products"),
       let title = queryValue(named: "title", in: route),
       !title.isEmpty {
      return title
    }
    return "详情"
  }

  private static func queryValue(named name: String, in route: String) -> String? {
    guard let queryIndex = route.firstIndex(of: "?") else { return nil }
    let query = String(route[route.index(after: queryIndex)...])
    for pair in query.split(separator: "&") {
      let parts = pair.split(separator: "=", maxSplits: 1).map(String.init)
      guard parts.count == 2, parts[0] == name else { continue }
      return parts[1].removingPercentEncoding ?? parts[1]
    }
    return nil
  }
}
