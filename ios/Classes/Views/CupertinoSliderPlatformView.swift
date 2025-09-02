import Flutter
import UIKit
import SwiftUI

class CupertinoSliderPlatformView: NSObject, FlutterPlatformView {
  private let channel: FlutterMethodChannel
  private let hostingController: UIHostingController<CupertinoSliderView>

  init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "CupertinoNativeSlider_\(viewId)", binaryMessenger: messenger)
    self.channel = channel

    var initialValue: Double = 0
    var minValue: Double = 0
    var maxValue: Double = 1
    var enabled: Bool = true
    if let dict = args as? [String: Any] {
      if let v = dict["value"] as? NSNumber { initialValue = v.doubleValue }
      if let v = dict["min"] as? NSNumber { minValue = v.doubleValue }
      if let v = dict["max"] as? NSNumber { maxValue = v.doubleValue }
      if let v = dict["enabled"] as? NSNumber { enabled = v.boolValue }
    }

    let model = SliderModel(value: initialValue, min: minValue, max: maxValue, enabled: enabled) { newValue in
      channel.invokeMethod("valueChanged", arguments: ["value": newValue])
    }
    self.hostingController = UIHostingController(rootView: CupertinoSliderView(model: model))
    self.hostingController.view.backgroundColor = .clear
    self.hostingController.view.isOpaque = false
    super.init()

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "setValue":
        if let args = call.arguments as? [String: Any], let value = (args["value"] as? NSNumber)?.doubleValue {
          model.value = value
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing value", details: nil)) }
      case "setRange":
        if let args = call.arguments as? [String: Any],
           let min = (args["min"] as? NSNumber)?.doubleValue,
           let max = (args["max"] as? NSNumber)?.doubleValue {
          model.min = min; model.max = max
          if model.value < min { model.value = min }
          if model.value > max { model.value = max }
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing min/max", details: nil)) }
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

