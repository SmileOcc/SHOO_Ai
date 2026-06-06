import Cocoa
import FlutterMacOS

/// SHOO Platform Channel 原生桩 — 与 Dart `SHONativeBridge` 对应。
enum NativeBridgeHandler {
  private static let methodChannel = "com.shoo.shoo/native_bridge"
  private static let messageChannel = "com.shoo.shoo/native_message"
  private static let eventChannel = "com.shoo.shoo/native_event"

  static func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: methodChannel, binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "ping":
        result([
          "ok": true,
          "platform": "macos",
        ])
      case "getPlatformVersion":
        let version = ProcessInfo.processInfo.operatingSystemVersion
        result("\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)")
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    let message = FlutterBasicMessageChannel(
      name: messageChannel,
      binaryMessenger: messenger,
      codec: FlutterStandardMessageCodec.sharedInstance()
    )
    message.setMessageHandler { message, reply in
      reply([
        "echo": message ?? NSNull(),
        "platform": "macos",
      ])
    }

    let events = FlutterEventChannel(name: eventChannel, binaryMessenger: messenger)
    events.setStreamHandler(DebugTickStreamHandler())
  }
}

private final class DebugTickStreamHandler: NSObject, FlutterStreamHandler {
  private var timer: Timer?
  private var tick = 0
  private var kind = "debug_tick"

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    tick = 0
    if let args = arguments as? String {
      kind = args
    }
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      guard let self else { return }
      self.tick += 1
      events([
        "kind": self.kind,
        "tick": self.tick,
        "platform": "macos",
        "timestamp": Int(Date().timeIntervalSince1970 * 1000),
      ])
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    timer?.invalidate()
    timer = nil
    return nil
  }
}
