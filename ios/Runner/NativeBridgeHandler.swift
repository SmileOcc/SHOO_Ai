import Flutter
import UIKit

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
          "platform": "ios",
        ])
      case "getPlatformVersion":
        result(UIDevice.current.systemVersion)
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
        "platform": "ios",
      ])
    }

    let events = FlutterEventChannel(name: eventChannel, binaryMessenger: messenger)
    events.setStreamHandler(BusinessEventStreamHandler())
  }
}

private struct EventArgs {
  let kind: String
  let params: [String: String]
}

private func parseArgs(_ arguments: Any?) -> EventArgs {
  let raw = (arguments as? String) ?? "debug_tick"
  let parts = raw.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
  let kind = String(parts.first ?? "debug_tick")
  var params: [String: String] = [:]
  if parts.count == 2 {
    for pair in parts[1].split(separator: ",") {
      let kv = pair.split(separator: "=", maxSplits: 1)
      if kv.count == 2 {
        params[String(kv[0]).trimmingCharacters(in: .whitespaces)] =
          String(kv[1]).trimmingCharacters(in: .whitespaces)
      }
    }
  }
  return EventArgs(kind: kind, params: params)
}

private final class BusinessEventStreamHandler: NSObject, FlutterStreamHandler {
  private var timer: Timer?
  private var tick = 0
  private var downloadProgress = 0.0
  private var args = EventArgs(kind: "debug_tick", params: [:])

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    tick = 0
    downloadProgress = 0.0
    args = parseArgs(arguments)
    scheduleNext(after: interval(), events: events)
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    timer?.invalidate()
    timer = nil
    return nil
  }

  private func interval() -> TimeInterval {
    switch args.kind {
    case "payment": return 2.0
    case "download": return 0.4
    case "logistics": return 5.0
    default: return 1.0
    }
  }

  private func scheduleNext(after: TimeInterval, events: @escaping FlutterEventSink) {
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: after, repeats: false) { [weak self] _ in
      guard let self else { return }
      self.tick += 1
      events(self.payload())
      let next = self.interval()
      if self.shouldContinue() {
        self.scheduleNext(after: next, events: events)
      }
    }
  }

  private func shouldContinue() -> Bool {
    switch args.kind {
    case "payment": return tick < 3
    case "download": return downloadProgress < 1.0
    case "logistics": return true
    default: return true
    }
  }

  private func payload() -> [String: Any] {
    let ts = Int(Date().timeIntervalSince1970 * 1000)
    switch args.kind {
    case "payment":
      let orderId = args.params["orderId"] ?? ""
      if tick >= 3 {
        return [
          "kind": "payment",
          "orderId": orderId,
          "status": "success",
          "transactionId": "mock_tx_\(ts)",
          "platform": "ios",
          "timestamp": ts,
        ]
      }
      return [
        "kind": "payment",
        "orderId": orderId,
        "status": "processing",
        "message": "Confirming payment...",
        "platform": "ios",
        "timestamp": ts,
      ]
    case "download":
      downloadProgress = min(1.0, Double(tick) * 0.12)
      let taskId = args.params["taskId"] ?? "mock_download"
      return [
        "kind": "download",
        "taskId": taskId,
        "progress": downloadProgress,
        "status": downloadProgress >= 1.0 ? "completed" : "running",
        "platform": "ios",
        "timestamp": ts,
      ]
    case "logistics":
      let orderId = args.params["orderId"] ?? ""
      let events = ["Package picked up", "In transit to hub", "Out for delivery", "Delivered"]
      let event = events[(tick - 1) % events.count]
      return [
        "kind": "logistics",
        "orderId": orderId,
        "event": event,
        "message": "Logistics update #\(tick)",
        "platform": "ios",
        "timestamp": ts,
      ]
    default:
      return [
        "kind": "debug_tick",
        "tick": tick,
        "platform": "ios",
        "timestamp": ts,
      ]
    }
  }
}
