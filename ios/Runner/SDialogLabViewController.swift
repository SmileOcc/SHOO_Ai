import UIKit

struct SDialogLabResult: Codable {
  let id: String
  let kind: String
  let timestamp: TimeInterval
  let summary: String
}

/// S弹弹窗 — 原生按钮触发 Flutter 弹窗，结果回显在原生列表。
final class SDialogLabViewController: UIViewController {
  private var results: [SDialogLabResult] = []
  private let tableView = UITableView(frame: .zero, style: .plain)
  private let buttonsStack = UIStackView()
  private var dialogDemos: [(String, String, String?)] = []

  init(initialResults: [SDialogLabResult] = []) {
    self.results = initialResults
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  func exportResults() -> [SDialogLabResult] { results }

  func appendResult(kind: String, payload: Any?) {
    let summary = Self.formatPayload(payload)
    let entry = SDialogLabResult(
      id: UUID().uuidString,
      kind: kind,
      timestamp: Date().timeIntervalSince1970,
      summary: summary
    )
    results.insert(entry, at: 0)
    if isViewLoaded {
      tableView.reloadData()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "S弹弹窗"
    view.backgroundColor = SHOUIKitCompat.primaryBackground
    navigationItem.leftBarButtonItem = SHOUIKitCompat.makeCloseBarButtonItem(
      target: self,
      action: #selector(closeTapped)
    )

    setupButtons()
    setupTableView()
  }

  private func setupButtons() {
    buttonsStack.axis = .vertical
    buttonsStack.spacing = 10
    buttonsStack.translatesAutoresizingMaskIntoConstraints = false

    dialogDemos = [
      ("alert", "Alert 提示", "这是 Flutter SHOAppDialog.alert"),
      ("confirm", "Confirm 确认", "确定要执行此操作吗？"),
      ("bottomSheet", "BottomSheet 底部面板", "选择分享或举报"),
      ("actionSheet", "ActionSheet 操作表", "请选择一个选项"),
    ]

    for (index, demo) in dialogDemos.enumerated() {
      let (kind, title, message) = demo
      let button = UIButton(type: .system)
      button.setTitle(title, for: .normal)
      button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
      button.backgroundColor = SHOUIKitCompat.secondaryBackground
      button.layer.cornerRadius = 12
      button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
      button.tag = index
      button.addTarget(self, action: #selector(dialogButtonTapped(_:)), for: .touchUpInside)
      buttonsStack.addArrangedSubview(button)
    }

    view.addSubview(buttonsStack)
    NSLayoutConstraint.activate([
      buttonsStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
      buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
    ])
  }

  private func setupTableView() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.dataSource = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    tableView.tableFooterView = UIView()
    view.addSubview(tableView)
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: buttonsStack.bottomAnchor, constant: 16),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }

  @objc private func dialogButtonTapped(_ sender: UIButton) {
    let index = sender.tag
    guard index >= 0, index < dialogDemos.count else { return }
    let (kind, title, message) = dialogDemos[index]
    triggerDialog(kind: kind, title: title, message: message)
  }

  @objc private func closeTapped() {
    if let nav = navigationController,
       nav.viewControllers.count > 1,
       nav.viewControllers.last === self {
      nav.popViewController(animated: true)
      return
    }
    HybridBridgeCoordinator.shared.dismissSActivity(from: self)
  }

  private func triggerDialog(kind: String, title: String, message: String?) {
    HybridBridgeCoordinator.shared.showFlutterDialog(
      kind: kind,
      title: title,
      message: message,
      from: self
    ) { _ in }
  }

  private static func formatPayload(_ payload: Any?) -> String {
    if let dict = payload as? [String: Any],
       let data = try? JSONSerialization.data(withJSONObject: dict, options: [.sortedKeys]),
       let json = String(data: data, encoding: .utf8) {
      return json
    }
    return String(describing: payload ?? "nil")
  }
}

extension SDialogLabViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    max(results.count, 1)
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.selectionStyle = .none
    cell.textLabel?.numberOfLines = 0
    if results.isEmpty {
      cell.textLabel?.text = "点击下方按钮，Flutter 弹窗结果将显示在这里"
      cell.textLabel?.textColor = SHOUIKitCompat.secondaryText
      cell.detailTextLabel?.text = nil
    } else {
      let item = results[indexPath.row]
      cell.textLabel?.text = "[\(item.kind)] \(item.summary)"
      cell.textLabel?.textColor = SHOUIKitCompat.primaryText
      let date = Date(timeIntervalSince1970: item.timestamp)
      cell.detailTextLabel?.text = DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .medium)
    }
    return cell
  }
}
