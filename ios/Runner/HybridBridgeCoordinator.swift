import Flutter
import UIKit

/// Hybrid Bridge 协调器：原生 UI 与 Flutter 宿主通道的统一入口。
final class HybridBridgeCoordinator {
  static let shared = HybridBridgeCoordinator()

  private weak var flutterViewController: FlutterViewController?
  private weak var sActivityNavigationController: UINavigationController?
  private weak var hybridShellViewController: HybridNativeShellViewController?
  private var hostChannel: FlutterMethodChannel?

  private init() {}

  func attach(flutterViewController: FlutterViewController) {
    self.flutterViewController = flutterViewController
    hostChannel = FlutterMethodChannel(
      name: "com.shoo.shoo/native_host",
      binaryMessenger: flutterViewController.binaryMessenger
    )
  }

  var rootPresenter: UIViewController? {
    flutterViewController
  }

  func invokeFlutter(
    method: String,
    arguments: Any? = nil,
    completion: @escaping (Any?) -> Void = { _ in }
  ) {
    guard let hostChannel else {
      completion(["ok": false, "error": "host channel not ready"])
      return
    }
    hostChannel.invokeMethod(method, arguments: arguments) { result in
      if let error = result as? FlutterError {
        completion([
          "ok": false,
          "error": error.message ?? error.code,
        ])
        return
      }
      completion(result)
    }
  }

  /// Push 动画打开 S活动。
  func presentSActivity(from presenter: UIViewController? = nil) {
    let host = presenter ?? rootPresenter
    guard let host else { return }
    let vc = SActivityViewController()
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .fullScreen
    sActivityNavigationController = nav
    presentWithPushTransition(nav, on: host)
  }

  func presentDialogLab(from presenter: UIViewController? = nil) {
    let host = presenter ?? rootPresenter
    guard let host else { return }
    let vc = SDialogLabViewController()
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .fullScreen
    presentWithPushTransition(nav, on: host)
  }

  /// 打开 Flutter 嵌入页：根 Engine go 路由 + 透明原生顶栏（不创建第二个 FlutterViewController）。
  func openFlutterRoute(
    _ route: String,
    from viewController: UIViewController,
    completion: @escaping (Any?) -> Void
  ) {
    guard let sActivityNav = viewController.navigationController else {
      completion(["ok": false, "error": "navigationController missing"])
      return
    }
    guard let host = rootPresenter else {
      completion(["ok": false, "error": "root presenter missing"])
      return
    }

    sActivityNavigationController = sActivityNav
    let title = HybridNativeShellViewController.resolveTitle(from: route)

    navigateEmbeddedRoute(route) { [weak self] _ in
      DispatchQueue.main.async {
        guard let self else { return }
        self.dismissWithPopTransition(sActivityNav) {
          let shell = HybridNativeShellViewController(title: title)
          shell.modalPresentationStyle = .overFullScreen
          shell.modalTransitionStyle = .coverVertical
          self.hybridShellViewController = shell
          host.present(shell, animated: true) {
            completion(["ok": true, "route": route, "embedded": true])
          }
        }
      }
    }
  }

  func navigateEmbeddedRoute(
    _ route: String,
    completion: @escaping (Any?) -> Void = { _ in }
  ) {
    invokeFlutter(
      method: "navigate",
      arguments: ["route": route, "embedded": true],
      completion: completion
    )
  }

  /// 原生顶栏返回 / Dart 请求退出嵌入：关闭壳层并恢复 S活动。
  func restoreToSActivityFromEmbedded() {
    onHybridFlutterPagePoppedByUser()
    popHybridShellAndRestoreSActivity()
  }

  func onHybridFlutterPagePoppedByUser() {
    invokeFlutter(method: "onHybridFlutterPopped", arguments: nil)
  }

  func popHybridFlutterPage() {
    popHybridShellAndRestoreSActivity()
  }

  private func popHybridShellAndRestoreSActivity() {
    guard let shell = hybridShellViewController else { return }
    shell.dismiss(animated: true) { [weak self] in
      guard let self else { return }
      self.hybridShellViewController = nil
      guard let sActivityNav = self.sActivityNavigationController,
            let host = self.rootPresenter else { return }
      self.presentWithPushTransition(sActivityNav, on: host)
    }
  }

  func clearOverlayReference() {
    hybridShellViewController = nil
    sActivityNavigationController = nil
  }

  func dismissSActivity(from viewController: UIViewController) {
    invokeFlutter(method: "abandonNativeOverlaySession", arguments: nil)
    clearOverlayReference()

    if let nav = viewController.navigationController,
       nav.viewControllers.count > 1,
       nav.viewControllers.last === viewController {
      nav.popViewController(animated: true)
      return
    }

    guard let nav = viewController.navigationController else {
      viewController.dismiss(animated: true)
      return
    }
    dismissWithPopTransition(nav)
  }

  func showFlutterDialog(
    kind: String,
    title: String,
    message: String?,
    from viewController: UIViewController,
    onResult: @escaping (Any?) -> Void
  ) {
    let savedResults = (viewController as? SDialogLabViewController)?.exportResults() ?? []
    let navStack = viewController.navigationController

    dismissWithPopTransition(navStack ?? viewController) { [weak self] in
      guard let self else { return }
      var args: [String: Any] = ["kind": kind, "title": title]
      if let message { args["message"] = message }

      self.invokeFlutter(method: "showDialog", arguments: args) { result in
        DispatchQueue.main.async {
          let lab = SDialogLabViewController(initialResults: savedResults)
          lab.appendResult(kind: kind, payload: result)
          let sActivity = SActivityViewController()
          let newNav = UINavigationController()
          newNav.setViewControllers([sActivity, lab], animated: false)
          newNav.modalPresentationStyle = .fullScreen
          self.sActivityNavigationController = newNav
          if let host = self.rootPresenter {
            self.presentWithPushTransition(newNav, on: host)
          }
          onResult(result)
        }
      }
    }
  }

  private func presentWithPushTransition(_ viewController: UIViewController, on host: UIViewController) {
    let transition = CATransition()
    transition.duration = 0.32
    transition.type = .push
    transition.subtype = .fromRight
    transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    host.view.window?.layer.add(transition, forKey: kCATransition)
    host.present(viewController, animated: false)
  }

  private func dismissWithPopTransition(
    _ viewController: UIViewController,
    completion: (() -> Void)? = nil
  ) {
    guard viewController.presentingViewController != nil else {
      viewController.dismiss(animated: true, completion: completion)
      return
    }
    let transition = CATransition()
    transition.duration = 0.32
    transition.type = .push
    transition.subtype = .fromLeft
    transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    viewController.view.window?.layer.add(transition, forKey: kCATransition)
    viewController.dismiss(animated: false, completion: completion)
  }
}
