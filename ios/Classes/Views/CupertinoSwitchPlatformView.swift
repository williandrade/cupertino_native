import Flutter
import UIKit
import SwiftUI

class CupertinoSwitchPlatformView: NSObject, FlutterPlatformView {
  private let channel: FlutterMethodChannel
  private let hostingController: UIHostingController<CupertinoSwitchView>

  init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "CupertinoNativeSwitch_\(viewId)", binaryMessenger: messenger)
    self.channel = channel

    var initialValue: Bool = false
    var enabled: Bool = true
    if let dict = args as? [String: Any] {
      if let v = dict["value"] as? NSNumber { initialValue = v.boolValue }
      if let v = dict["enabled"] as? NSNumber { enabled = v.boolValue }
    }

    let model = SwitchModel(value: initialValue, enabled: enabled) { newValue in
      channel.invokeMethod("valueChanged", arguments: ["value": newValue])
    }
    self.hostingController = UIHostingController(rootView: CupertinoSwitchView(model: model))
    self.hostingController.view.backgroundColor = .clear
    self.hostingController.view.isOpaque = false
    super.init()

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "setValue":
        if let args = call.arguments as? [String: Any], let value = (args["value"] as? NSNumber)?.boolValue {
          model.value = value
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing value", details: nil)) }
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

