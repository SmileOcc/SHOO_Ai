import AVKit
import AuthenticationServices
import CoreBluetooth
import CoreNFC
import MapKit
import PhotosUI
import Security
import UIKit
import UserNotifications
import WebKit

/// 各原生组件 Demo 实现。
enum NativeComponentDemos {
  static func run(moduleId: String, presenter: UIViewController) {
    switch moduleId {
    case "map": showMap(presenter: presenter)
    case "video": showVideo(presenter: presenter)
    case "webView": showWebView(presenter: presenter)
    case "push": requestPush(presenter: presenter)
    case "payment": showPayment(presenter: presenter)
    case "socialLogin": showSocialLogin(presenter: presenter)
    case "analytics": trackAnalytics(presenter: presenter)
    case "photoLibrary": pickPhoto(presenter: presenter)
    case "keychain": demoKeychain(presenter: presenter)
    case "nfc": startNFC(presenter: presenter)
    case "bluetooth": showBluetooth(presenter: presenter)
    case "appBadge": setBadge(presenter: presenter)
    case "share": showShare(presenter: presenter)
    default:
      ncPresentAlert(presenter, title: "未知模块", message: moduleId)
    }
  }

  // MARK: - Map

  private static func showMap(presenter: UIViewController) {
    let vc = NCMapDemoViewController()
    presenter.navigationController?.pushViewController(vc, animated: true)
  }

  // MARK: - Video

  private static func showVideo(presenter: UIViewController) {
    guard let url = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") else { return }
    let player = AVPlayer(url: url)
    let vc = AVPlayerViewController()
    vc.player = player
    presenter.present(vc, animated: true) { player.play() }
  }

  // MARK: - WebView

  private static func showWebView(presenter: UIViewController) {
    let vc = NCWebDemoViewController()
    presenter.navigationController?.pushViewController(vc, animated: true)
  }

  // MARK: - Push

  private static func requestPush(presenter: UIViewController) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
      DispatchQueue.main.async {
        if let error {
          ncPresentAlert(presenter, title: "推送", message: error.localizedDescription)
          return
        }
        guard granted else {
          ncPresentAlert(presenter, title: "推送", message: "用户未授权通知权限")
          return
        }
        let content = UNMutableNotificationContent()
        content.title = "SHOO 原生推送 Demo"
        content.body = "这是一条本地通知（3 秒后触发）"
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: "shoo.native.push.demo", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { err in
          DispatchQueue.main.async {
            if let err {
              ncPresentAlert(presenter, title: "推送", message: err.localizedDescription)
            } else {
              ncPresentAlert(presenter, title: "推送", message: "已调度本地通知，请切到后台或等待横幅")
            }
          }
        }
      }
    }
  }

  // MARK: - Payment

  private static func showPayment(presenter: UIViewController) {
    let sheet = UIAlertController(title: "原生支付桩", message: "选择模拟支付方式", preferredStyle: .actionSheet)
    sheet.addAction(UIAlertAction(title: "Apple Pay（桩）", style: .default) { _ in
      ncPresentAlert(presenter, title: "支付成功", message: "mock_apple_pay_tx_\(Int(Date().timeIntervalSince1970))")
    })
    sheet.addAction(UIAlertAction(title: "微信 / 支付宝（桩）", style: .default) { _ in
      ncPresentAlert(presenter, title: "支付成功", message: "mock_wallet_tx_\(Int(Date().timeIntervalSince1970))")
    })
    sheet.addAction(UIAlertAction(title: "取消", style: .cancel))
    if let pop = sheet.popoverPresentationController {
      pop.sourceView = presenter.view
      pop.sourceRect = CGRect(x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 1, height: 1)
    }
    presenter.present(sheet, animated: true)
  }

  // MARK: - Social Login

  private static func showSocialLogin(presenter: UIViewController) {
    let sheet = UIAlertController(title: "社交登录", message: "选择登录方式", preferredStyle: .actionSheet)
    sheet.addAction(UIAlertAction(title: "Sign in with Apple", style: .default) { _ in
      let provider = ASAuthorizationAppleIDProvider()
      let request = provider.createRequest()
      request.requestedScopes = [.fullName, .email]
      let controller = ASAuthorizationController(authorizationRequests: [request])
      let delegate = AppleSignInDelegate(presenter: presenter)
      objc_setAssociatedObject(controller, &AppleSignInDelegate.assocKey, delegate, .OBJC_ASSOCIATION_RETAIN)
      controller.delegate = delegate
      controller.presentationContextProvider = delegate
      controller.performRequests()
    })
    sheet.addAction(UIAlertAction(title: "微信登录（桩）", style: .default) { _ in
      ncPresentAlert(presenter, title: "微信登录", message: "mock_wechat_openid_wx_\(Int.random(in: 1000...9999))")
    })
    sheet.addAction(UIAlertAction(title: "QQ 登录（桩）", style: .default) { _ in
      ncPresentAlert(presenter, title: "QQ 登录", message: "mock_qq_openid_qq_\(Int.random(in: 1000...9999))")
    })
    sheet.addAction(UIAlertAction(title: "取消", style: .cancel))
    if let pop = sheet.popoverPresentationController {
      pop.sourceView = presenter.view
      pop.sourceRect = CGRect(x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 1, height: 1)
    }
    presenter.present(sheet, animated: true)
  }

  // MARK: - Analytics

  private static func trackAnalytics(presenter: UIViewController) {
    HybridBridgeCoordinator.shared.invokeFlutter(
      method: "trackNativeAnalytics",
      arguments: [
        "eventKey": "native_component_demo",
        "params": [
          "module": "analytics",
          "source": "ios_native_hub",
          "timestamp": Int(Date().timeIntervalSince1970 * 1000),
        ],
      ]
    ) { result in
      DispatchQueue.main.async {
        let text: String
        if let dict = result as? [String: Any] {
          text = String(describing: dict)
        } else {
          text = String(describing: result ?? "nil")
        }
        ncPresentAlert(presenter, title: "原生埋点", message: text)
      }
    }
  }

  // MARK: - Photo Library

  private static func pickPhoto(presenter: UIViewController) {
    var config = PHPickerConfiguration()
    config.selectionLimit = 1
    config.filter = .images
    let picker = PHPickerViewController(configuration: config)
    let delegate = PhotoPickerDelegate(presenter: presenter)
    objc_setAssociatedObject(picker, &PhotoPickerDelegate.assocKey, delegate, .OBJC_ASSOCIATION_RETAIN)
    picker.delegate = delegate
    presenter.present(picker, animated: true)
  }

  // MARK: - Keychain

  private static func demoKeychain(presenter: UIViewController) {
    let key = "com.shoo.native.demo.token"
    let value = "shoo_keychain_\(Int(Date().timeIntervalSince1970))"
    let saved = KeychainHelper.save(key: key, value: value)
    let read = KeychainHelper.read(key: key) ?? "nil"
    ncPresentAlert(presenter, title: "Keychain", message: "写入: \(saved ? "成功" : "失败")\n读取: \(read)")
  }

  // MARK: - NFC

  private static func startNFC(presenter: UIViewController) {
    guard NFCNDEFReaderSession.readingAvailable else {
      ncPresentAlert(presenter, title: "NFC", message: "当前设备不支持 NFC 读取")
      return
    }
    let delegate = NFCDemoDelegate(presenter: presenter)
    let session = NFCNDEFReaderSession(delegate: delegate, queue: nil, invalidateAfterFirstRead: true)
    objc_setAssociatedObject(session as Any, &NFCDemoDelegate.assocKey, delegate, .OBJC_ASSOCIATION_RETAIN)
    session.alertMessage = "将 NFC 标签靠近手机顶部"
    session.begin()
  }

  // MARK: - Bluetooth

  private static func showBluetooth(presenter: UIViewController) {
    let vc = NCBluetoothDemoViewController()
    presenter.navigationController?.pushViewController(vc, animated: true)
  }

  // MARK: - Badge

  private static func setBadge(presenter: UIViewController) {
    if #available(iOS 17.0, *) {
      UNUserNotificationCenter.current().setBadgeCount(3) { error in
        DispatchQueue.main.async {
          if let error {
            ncPresentAlert(presenter, title: "角标", message: error.localizedDescription)
          } else {
            ncPresentAlert(presenter, title: "角标", message: "已设置桌面角标为 3")
          }
        }
      }
    } else {
      UIApplication.shared.applicationIconBadgeNumber = 3
      ncPresentAlert(presenter, title: "角标", message: "已设置桌面角标为 3")
    }
  }

  // MARK: - Share

  private static func showShare(presenter: UIViewController) {
    let text = "SHOO 原生分享 Demo — https://shoo.app"
    let vc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
    if let pop = vc.popoverPresentationController {
      pop.sourceView = presenter.view
      pop.sourceRect = CGRect(x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 1, height: 1)
    }
    presenter.present(vc, animated: true)
  }

}

private func ncPresentAlert(_ presenter: UIViewController, title: String, message: String) {
  let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
  a.addAction(UIAlertAction(title: "OK", style: .default))
  presenter.present(a, animated: true)
}

// MARK: - Map VC

private final class NCMapDemoViewController: UIViewController {
  private let mapView = MKMapView()

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "地图"
    view.backgroundColor = .systemBackground
    mapView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(mapView)
    NSLayoutConstraint.activate([
      mapView.topAnchor.constraint(equalTo: view.topAnchor),
      mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
    let coord = CLLocationCoordinate2D(latitude: 31.2304, longitude: 121.4737)
    let region = MKCoordinateRegion(center: coord, latitudinalMeters: 8000, longitudinalMeters: 8000)
    mapView.setRegion(region, animated: false)
    let pin = MKPointAnnotation()
    pin.coordinate = coord
    pin.title = "SHOO Demo"
    pin.subtitle = "上海 · 原生 MKMapView"
    mapView.addAnnotation(pin)
  }
}

// MARK: - WebView VC

private final class NCWebDemoViewController: UIViewController, WKNavigationDelegate {
  private let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "WebView"
    webView.navigationDelegate = self
    webView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(webView)
    NSLayoutConstraint.activate([
      webView.topAnchor.constraint(equalTo: view.topAnchor),
      webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
    if let url = URL(string: "https://flutter.dev") {
      webView.load(URLRequest(url: url))
    }
  }
}

// MARK: - Bluetooth VC

private final class NCBluetoothDemoViewController: UIViewController, UITableViewDataSource, CBCentralManagerDelegate {
  private var central: CBCentralManager!
  private var devices: [String] = []
  private let table = UITableView(frame: .zero, style: .plain)

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "蓝牙扫描"
    table.dataSource = self
    table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    table.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(table)
    NSLayoutConstraint.activate([
      table.topAnchor.constraint(equalTo: view.topAnchor),
      table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      table.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
    central = CBCentralManager(delegate: self, queue: nil)
  }

  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    guard central.state == .poweredOn else { return }
    central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
  }

  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
    let name = peripheral.name ?? "Unknown"
    let line = "\(name) · \(peripheral.identifier.uuidString.prefix(8))"
    guard !devices.contains(line) else { return }
    devices.append(line)
    if devices.count > 30 { central.stopScan() }
    table.reloadData()
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    max(devices.count, 1)
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    if devices.isEmpty {
      cell.textLabel?.text = "扫描中… 请开启蓝牙"
    } else {
      cell.textLabel?.text = devices[indexPath.row]
    }
    return cell
  }
}

// MARK: - Helpers

private enum KeychainHelper {
  static func save(key: String, value: String) -> Bool {
    guard let data = value.data(using: .utf8) else { return false }
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key,
      kSecAttrService as String: "com.shoo.shoo.native",
    ]
    SecItemDelete(query as CFDictionary)
    var add = query
    add[kSecValueData as String] = data
    return SecItemAdd(add as CFDictionary, nil) == errSecSuccess
  }

  static func read(key: String) -> String? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key,
      kSecAttrService as String: "com.shoo.shoo.native",
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne,
    ]
    var item: CFTypeRef?
    guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
          let data = item as? Data,
          let text = String(data: data, encoding: .utf8) else { return nil }
    return text
  }
}

private final class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
  static var assocKey: UInt8 = 0
  private weak var presenter: UIViewController?
  init(presenter: UIViewController) { self.presenter = presenter }

  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    presenter?.view.window ?? UIWindow()
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
    let id = credential.user
    DispatchQueue.main.async {
      guard let presenter = self.presenter else { return }
      ncPresentAlert(presenter, title: "Apple 登录", message: "user: \(id)")
    }
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    DispatchQueue.main.async {
      guard let presenter = self.presenter else { return }
      ncPresentAlert(presenter, title: "Apple 登录失败", message: error.localizedDescription)
    }
  }
}

private final class PhotoPickerDelegate: NSObject, PHPickerViewControllerDelegate {
  static var assocKey: UInt8 = 0
  private weak var presenter: UIViewController?
  init(presenter: UIViewController) { self.presenter = presenter }

  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    picker.dismiss(animated: true)
    let count = results.count
    DispatchQueue.main.async {
      guard let presenter = self.presenter else { return }
      ncPresentAlert(presenter, title: "相册", message: "已选择 \(count) 张图片")
    }
  }
}

private final class NFCDemoDelegate: NSObject, NFCNDEFReaderSessionDelegate {
  static var assocKey: UInt8 = 0
  private weak var presenter: UIViewController?
  init(presenter: UIViewController) { self.presenter = presenter }

  func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
    let texts = messages.flatMap { $0.records.compactMap { $0.wellKnownTypeTextPayload().0 } }
    DispatchQueue.main.async {
      guard let presenter = self.presenter else { return }
      ncPresentAlert(presenter, title: "NFC", message: texts.joined(separator: "\n"))
    }
  }

  func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
    if (error as NSError).code == 200 { return }
    DispatchQueue.main.async {
      guard let presenter = self.presenter else { return }
      ncPresentAlert(presenter, title: "NFC", message: error.localizedDescription)
    }
  }
}
