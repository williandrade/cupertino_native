import FlutterMacOS
import Cocoa
import SwiftUI

class CupertinoButtonNSView: NSView {
  private let channel: FlutterMethodChannel
  private let hostingController: NSHostingController<CupertinoButtonView>

  init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativeButton_\(viewId)", binaryMessenger: messenger)

    var title: String = ""
    var enabled: Bool = true
    if let dict = args as? [String: Any] {
      if let t = dict["title"] as? String { title = t }
      if let v = dict["enabled"] as? NSNumber { enabled = v.boolValue }
    }

    var channelRef: FlutterMethodChannel? = nil
    let model = ButtonModel(title: title, enabled: enabled) {
      channelRef?.invokeMethod("pressed", arguments: nil)
    }
    self.hostingController = NSHostingController(rootView: CupertinoButtonView(model: model))
    super.init(frame: .zero)

    channelRef = self.channel

    hostingController.view.wantsLayer = true
    hostingController.view.layer?.backgroundColor = NSColor.clear.cgColor

    addSubview(hostingController.view)
    hostingController.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
      hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
      hostingController.view.topAnchor.constraint(equalTo: topAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])

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

  required init?(coder: NSCoder) { return nil }
}

