import UIKit

private struct SActivitySection {
  let title: String
  let subtitle: String?
  let items: [SActivityItem]
}

private struct SActivityItem {
  let title: String
  let subtitle: String
  let badge: String
  let tint: UIColor
  let action: () -> Void
}

/// S活动 — 原生瀑布流功能区块（Channel 学习 + Flutter 业务 + 原生实验）。
final class SActivityViewController: UIViewController {
  private var sections: [SActivitySection] = []
  private let tableView = UITableView(frame: .zero, style: SHOUIKitCompat.groupedTableStyle)

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "S活动"
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
      SActivitySection(
        title: "交换学习",
        subtitle: "三种 Platform Channel 典型用法",
        items: [
          SActivityItem(
            title: "MethodChannel",
            subtitle: "Flutter → Native ping / 平台版本",
            badge: "Demo",
            tint: SHOUIKitCompat.accentBlue,
            action: { [weak self] in self?.runMethodChannelDemo() }
          ),
          SActivityItem(
            title: "BasicMessageChannel",
            subtitle: "双向 Echo 小数据",
            badge: "Demo",
            tint: SHOUIKitCompat.accentTeal,
            action: { [weak self] in self?.runMessageChannelDemo() }
          ),
          SActivityItem(
            title: "EventChannel",
            subtitle: "原生推送 tick 流（3 条）",
            badge: "Demo",
            tint: SHOUIKitCompat.accentIndigo,
            action: { [weak self] in self?.runEventChannelDemo() }
          ),
        ]
      ),
      SActivitySection(
        title: "Flutter 业务",
        subtitle: "从原生进入现有 Flutter 页面",
        items: [
          SActivityItem(
            title: "F商品列表",
            subtitle: "分类商品瀑布流（T-Shirts）",
            badge: "Flutter",
            tint: SHOUIKitCompat.accentOrange,
            action: { [weak self] in
              self?.openFlutterRoute("/category/products?leafId=c1-g1-l1&title=T-Shirts")
            }
          ),
          SActivityItem(
            title: "F购物车",
            subtitle: "购物车 → 结算 → 支付（现有流程）",
            badge: "Flutter",
            tint: SHOUIKitCompat.accentPink,
            action: { [weak self] in
              self?.openFlutterRoute("/cart/view")
            }
          ),
        ]
      ),
      SActivitySection(
        title: "原生实验",
        subtitle: "原生 UI 触发 Flutter 弹窗并回显结果",
        items: [
          SActivityItem(
            title: "S弹弹窗",
            subtitle: "Alert / Confirm / BottomSheet / ActionSheet",
            badge: "Native",
            tint: SHOUIKitCompat.accentPurple,
            action: { [weak self] in self?.openDialogLab() }
          ),
        ]
      ),
    ]
  }

  private func setupTableView() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(SActivityCardCell.self, forCellReuseIdentifier: SActivityCardCell.reuseId)
    tableView.register(SActivitySectionHeader.self, forHeaderFooterViewReuseIdentifier: SActivitySectionHeader.reuseId)
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
    HybridBridgeCoordinator.shared.dismissSActivity(from: self)
  }

    private func openFlutterRoute(_ route: String) {
    HybridBridgeCoordinator.shared.openFlutterRoute(route, from: self) { _ in }
  }

  private func openDialogLab() {
    let lab = SDialogLabViewController()
    navigationController?.pushViewController(lab, animated: true)
  }

  private func runMethodChannelDemo() {
    HybridBridgeCoordinator.shared.invokeFlutter(method: "runMethodChannelDemo") { [weak self] result in
      self?.showResultAlert(title: "MethodChannel", result: result)
    }
  }

  private func runMessageChannelDemo() {
    HybridBridgeCoordinator.shared.invokeFlutter(
      method: "runMessageChannelDemo",
      arguments: ["text": "hello from SActivity"]
    ) { [weak self] result in
      self?.showResultAlert(title: "BasicMessageChannel", result: result)
    }
  }

  private func runEventChannelDemo() {
    HybridBridgeCoordinator.shared.invokeFlutter(
      method: "runEventChannelDemo",
      arguments: ["ticks": 3]
    ) { [weak self] result in
      self?.showResultAlert(title: "EventChannel", result: result)
    }
  }

  private func showResultAlert(title: String, result: Any?) {
    let text: String
    if let dict = result as? [String: Any],
       let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted]),
       let json = String(data: data, encoding: .utf8) {
      text = json
    } else {
      text = String(describing: result ?? "nil")
    }
    let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
  }
}

extension SActivityViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int { sections.count }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    sections[section].items.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: SActivityCardCell.reuseId, for: indexPath) as! SActivityCardCell
    let item = sections[indexPath.section].items[indexPath.row]
    cell.configure(with: item)
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    sections[indexPath.section].items[indexPath.row].action()
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SActivitySectionHeader.reuseId) as! SActivitySectionHeader
    let sec = sections[section]
    header.configure(title: sec.title, subtitle: sec.subtitle)
    return header
  }
}

// MARK: - Cells

private final class SActivityCardCell: UITableViewCell {
  static let reuseId = "SActivityCardCell"

  private let card = UIView()
  private let titleLabel = UILabel()
  private let subtitleLabel = UILabel()
  private let badgeLabel = UILabel()
  private let iconView = UIView()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    selectionStyle = .none
    backgroundColor = .clear
    contentView.backgroundColor = .clear

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

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  func configure(with item: SActivityItem) {
    titleLabel.text = item.title
    subtitleLabel.text = item.subtitle
    badgeLabel.text = "  \(item.badge)  "
    badgeLabel.backgroundColor = item.tint.withAlphaComponent(0.15)
    badgeLabel.textColor = item.tint
    iconView.backgroundColor = item.tint.withAlphaComponent(0.2)
  }
}

private final class SActivitySectionHeader: UITableViewHeaderFooterView {
  static let reuseId = "SActivitySectionHeader"

  private let titleLabel = UILabel()
  private let subtitleLabel = UILabel()

  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
    subtitleLabel.font = .systemFont(ofSize: 13)
    subtitleLabel.textColor = SHOUIKitCompat.secondaryText
    subtitleLabel.numberOfLines = 0

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

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  func configure(title: String, subtitle: String?) {
    titleLabel.text = title
    subtitleLabel.text = subtitle
    subtitleLabel.isHidden = subtitle == nil
  }
}
