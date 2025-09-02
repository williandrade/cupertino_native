import Flutter
import UIKit
import SwiftUI

class CupertinoButtonPlatformView: NSObject, FlutterPlatformView {
  private let channel: FlutterMethodChannel
  private let hostingController: UIHostingController<CupertinoButtonView>

  init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "CupertinoNativeButton_\(viewId)", binaryMessenger: messenger)
    self.channel = channel

    var title: String = ""
    var enabled: Bool = true
    if let dict = args as? [String: Any] {
      if let t = dict["title"] as? String { title = t }
      if let v = dict["enabled"] as? NSNumber { enabled = v.boolValue }
    }

    var channelRef: FlutterMethodChannel? = channel
    let model = ButtonModel(title: title, enabled: enabled) {
      channelRef?.invokeMethod("pressed", arguments: nil)
    }
    self.hostingController = UIHostingController(rootView: CupertinoButtonView(model: model))
    self.hostingController.view.backgroundColor = .clear
    self.hostingController.view.isOpaque = false
    super.init()

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "setTitle":
        if let args = call.arguments as? [String: Any], let title = args["title"] as? String {
          model.title = title
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing title", details: nil)) }
      case "setEnabled":
        if let args = call.arguments as? [String: Any], let enabled = (args["enabled"] as? NSNumber)?.boolValue {
          model.enabled = enabled
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing enabled", details: nil)) }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func view() -> UIView {
    return hostingController.view
  }
}

