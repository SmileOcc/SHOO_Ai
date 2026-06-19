import UIKit

private struct NativeComponentSection {
  let title: String
  let subtitle: String?
  let items: [NativeComponentItem]
}

private struct NativeComponentItem {
  let moduleId: String
  let title: String
  let subtitle: String
  let badge: String
  let tint: UIColor
}

/// 原生组件库 Hub — 地图 / WebView / 支付等瀑布流入口。
final class NativeComponentsHubViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  private var sections: [NativeComponentSection] = []
  private let tableView = UITableView(frame: .zero, style: SHOUIKitCompat.groupedTableStyle)

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "原生组件"
    view.backgroundColor = SHOUIKitCompat.groupedBackground
    navigationItem.leftBarButtonItem = SHOUIKitCompat.makeCloseBarButtonItem(
      target: self,
      action: #selector(closeTapped)
    )
    rebuildSections()
    setupTableView()
  }

  private func rebuildSections() {
    sections = [
      NativeComponentSection(
        title: "媒体与展示",
        subtitle: "原生 UI 组件",
        items: [
          item("map", "地图", "MKMapView 标注演示", "Map", SHOUIKitCompat.accentTeal),
          item("video", "视频播放", "AVPlayer 系统播放器", "Media", SHOUIKitCompat.accentOrange),
          item("webView", "WebView", "WKWebView 加载网页", "Web", SHOUIKitCompat.accentBlue),
        ]
      ),
      NativeComponentSection(
        title: "系统能力",
        subtitle: "通知 / 支付 / 分享",
        items: [
          item("push", "推送", "本地通知权限与调度", "APNs", SHOUIKitCompat.accentIndigo),
          item("payment", "支付", "原生支付流程桩", "Pay", SHOUIKitCompat.accentPink),
          item("appBadge", "应用角标", "设置桌面角标数字", "Badge", .systemRed),
          item("share", "原生分享", "UIActivityViewController", "Share", SHOUIKitCompat.accentPurple),
        ]
      ),
      NativeComponentSection(
        title: "账号与数据",
        subtitle: "登录 / 埋点 / 存储",
        items: [
          item("socialLogin", "社交登录", "Apple / 微信 / QQ", "Auth", SHOUIKitCompat.accentBlue),
          item("analytics", "原生埋点", "调用 Flutter 埋点通道", "Track", .systemGreen),
          item("photoLibrary", "相册读写", "PHPicker 选择图片", "Photo", .systemYellow),
          item("keychain", "Keychain", "安全存储读写演示", "Secure", .systemGray),
        ]
      ),
      NativeComponentSection(
        title: "硬件",
        subtitle: "NFC / 蓝牙",
        items: [
          item("nfc", "NFC", "CoreNFC 读卡会话", "NFC", SHOUIKitCompat.accentTeal),
          item("bluetooth", "蓝牙", "CoreBluetooth 扫描", "BLE", SHOUIKitCompat.accentIndigo),
        ]
      ),
    ]
  }

  private func item(_ id: String, _ title: String, _ subtitle: String, _ badge: String, _ tint: UIColor) -> NativeComponentItem {
    NativeComponentItem(moduleId: id, title: title, subtitle: subtitle, badge: badge, tint: tint)
  }

  private func setupTableView() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(NativeComponentCardCell.self, forCellReuseIdentifier: NativeComponentCardCell.reuseId)
    tableView.register(NativeComponentSectionHeader.self, forHeaderFooterViewReuseIdentifier: NativeComponentSectionHeader.reuseId)
    tableView.separatorStyle = .none
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 88
    view.addSubview(tableView)
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }

  @objc private func closeTapped() {
    NativeComponentsCoordinator.shared.dismissHub(from: self)
  }

  func numberOfSections(in tableView: UITableView) -> Int { sections.count }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    sections[section].items.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: NativeComponentCardCell.reuseId, for: indexPath) as! NativeComponentCardCell
    cell.configure(with: sections[indexPath.section].items[indexPath.row])
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let item = sections[indexPath.section].items[indexPath.row]
    NativeComponentsCoordinator.shared.runModule(item.moduleId, from: self)
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NativeComponentSectionHeader.reuseId) as! NativeComponentSectionHeader
    let sec = sections[section]
    header.configure(title: sec.title, subtitle: sec.subtitle)
    return header
  }
}

// MARK: - Cells（复用 S活动 卡片样式）

private final class NativeComponentCardCell: UITableViewCell {
  static let reuseId = "NativeComponentCardCell"

  private let card = UIView()
  private let titleLabel = UILabel()
  private let subtitleLabel = UILabel()
  private let badgeLabel = UILabel()
  private let iconView = UIView()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    selectionStyle = .none
    backgroundColor = .clear
    card.backgroundColor = SHOUIKitCompat.cardBackground
    card.layer.cornerRadius = 14
    card.translatesAutoresizingMaskIntoConstraints = false
    iconView.layer.cornerRadius = 10
    iconView.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
    subtitleLabel.font = .systemFont(ofSize: 13)
    subtitleLabel.textColor = SHOUIKitCompat.secondaryText
    subtitleLabel.numberOfLines = 2
    badgeLabel.font = .systemFont(ofSize: 11, weight: .bold)
    badgeLabel.textAlignment = .center
    badgeLabel.layer.cornerRadius = 8
    badgeLabel.clipsToBounds = true

    let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
    textStack.axis = .vertical
    textStack.spacing = 4
    textStack.translatesAutoresizingMaskIntoConstraints = false
    let row = UIStackView(arrangedSubviews: [iconView, textStack, badgeLabel])
    row.axis = .horizontal
    row.alignment = .center
    row.spacing = 12
    row.translatesAutoresizingMaskIntoConstraints = false
    card.addSubview(row)
    contentView.addSubview(card)
    NSLayoutConstraint.activate([
      iconView.widthAnchor.constraint(equalToConstant: 44),
      iconView.heightAnchor.constraint(equalToConstant: 44),
      badgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 52),
      badgeLabel.heightAnchor.constraint(equalToConstant: 24),
      row.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
      row.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
      row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
      row.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
      card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
      card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
    ])
  }

  required init?(coder: NSCoder) { fatalError() }

  func configure(with item: NativeComponentItem) {
    titleLabel.text = item.title
    subtitleLabel.text = item.subtitle
    badgeLabel.text = "  \(item.badge)  "
    badgeLabel.backgroundColor = item.tint.withAlphaComponent(0.15)
    badgeLabel.textColor = item.tint
    iconView.backgroundColor = item.tint.withAlphaComponent(0.2)
  }
}

private final class NativeComponentSectionHeader: UITableViewHeaderFooterView {
  static let reuseId = "NativeComponentSectionHeader"
  private let titleLabel = UILabel()
  private let subtitleLabel = UILabel()

  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
    subtitleLabel.font = .systemFont(ofSize: 13)
    subtitleLabel.textColor = SHOUIKitCompat.secondaryText
    let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
    stack.axis = .vertical
    stack.spacing = 4
    stack.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(stack)
    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
      stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
      stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
    ])
  }

  required init?(coder: NSCoder) { fatalError() }

  func configure(title: String, subtitle: String?) {
    titleLabel.text = title
    subtitleLabel.text = subtitle
    subtitleLabel.isHidden = subtitle == nil
  }
}
