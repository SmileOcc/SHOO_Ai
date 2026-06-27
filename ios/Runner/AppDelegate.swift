import Flutter
import UIKit
import UserNotifications
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  /// 全应用共享 FlutterEngine，根页面与 S活动 内嵌 Flutter 页共用。
  private(set) lazy var flutterEngine: FlutterEngine = {
    let engine = FlutterEngine(name: "shoo.main")
    engine.run()
    GeneratedPluginRegistrant.register(with: engine)
    return engine
  }()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate

    _ = flutterEngine

    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    let flutterVC = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
    window?.rootViewController = flutterVC
    window?.makeKeyAndVisible()

    NativeBridgeHandler.register(
      messenger: flutterEngine.binaryMessenger,
      flutterViewController: flutterVC
    )
    HybridBridgeCoordinator.shared.attach(flutterViewController: flutterVC)
    return result
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
  }
}
