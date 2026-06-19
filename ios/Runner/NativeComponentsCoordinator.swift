import UIKit

/// 原生组件库入口协调器。
final class NativeComponentsCoordinator {
  static let shared = NativeComponentsCoordinator()

  private weak var presenter: UIViewController?

  private init() {}

  func attach(flutterViewController: FlutterViewController) {
    presenter = flutterViewController
  }

  var rootPresenter: UIViewController? { presenter }

  func presentHub() {
    guard let host = rootPresenter else { return }
    let hub = NativeComponentsHubViewController()
    let nav = UINavigationController(rootViewController: hub)
    nav.modalPresentationStyle = .fullScreen
    presentWithPushTransition(nav, on: host)
  }

  func runModule(_ moduleId: String, from viewController: UIViewController? = nil) {
    let base = viewController ?? topPresenter()
    guard let host = base else { return }
    NativeComponentDemos.run(moduleId: moduleId, presenter: host)
  }

  func dismissHub(from viewController: UIViewController) {
    guard let nav = viewController.navigationController else {
      viewController.dismiss(animated: true)
      return
    }
    dismissWithPopTransition(nav)
  }

  private func topPresenter() -> UIViewController? {
    guard var top = presenter else { return nil }
    while let presented = top.presentedViewController {
      top = presented
    }
    return top
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

  private func dismissWithPopTransition(_ viewController: UIViewController) {
    guard viewController.presentingViewController != nil else {
      viewController.dismiss(animated: true)
      return
    }
    let transition = CATransition()
    transition.duration = 0.32
    transition.type = .push
    transition.subtype = .fromLeft
    transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    viewController.view.window?.layer.add(transition, forKey: kCATransition)
    viewController.dismiss(animated: false)
  }
}
