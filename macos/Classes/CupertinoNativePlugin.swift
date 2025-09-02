import Cocoa
import FlutterMacOS
import SwiftUI
// Combine no longer needed when targeting macOS 11+ (using .onChange)

public class CupertinoNativePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "cupertino_native", binaryMessenger: registrar.messenger)
    let instance = CupertinoNativePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    let sliderFactory = CupertinoSliderViewFactory(messenger: registrar.messenger)
    registrar.register(sliderFactory, withId: "CupertinoNativeSlider")

    let switchFactory = CupertinoSwitchViewFactory(messenger: registrar.messenger)
    registrar.register(switchFactory, withId: "CupertinoNativeSwitch")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

class CupertinoSliderViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func createArgsCodec() -> (FlutterMessageCodec & NSObjectProtocol)? {
    return FlutterStandardMessageCodec.sharedInstance()
  }

  func create(withViewIdentifier viewId: Int64, arguments args: Any?) -> NSView {
    return CupertinoSliderNSView(viewId: viewId, args: args, messenger: messenger)
  }
}

class CupertinoSliderNSView: NSView {
  private let channel: FlutterMethodChannel
  private let hostingController: NSHostingController<CupertinoSliderView>

  init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativeSlider_\(viewId)", binaryMessenger: messenger)

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

    var channelRef: FlutterMethodChannel? = nil
    let model = SliderModel(value: initialValue, min: minValue, max: maxValue, enabled: enabled) { newValue in
      channelRef?.invokeMethod("valueChanged", arguments: ["value": newValue])
    }
    self.hostingController = NSHostingController(rootView: CupertinoSliderView(model: model))
    super.init(frame: .zero)

    channelRef = self.channel

    // Transparent background to match Flutter's default
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

  required init?(coder: NSCoder) {
    return nil
  }
}

// Shared SwiftUI view and model used on Apple platforms
struct CupertinoSliderView: View {
  @ObservedObject var model: SliderModel

  var body: some View {
    Slider(value: $model.value, in: model.min...model.max)
      .disabled(!model.enabled)
      .onChange(of: model.value) { newValue in
        model.onChange(newValue)
      }
  }
}

class SliderModel: ObservableObject {
  @Published var value: Double
  @Published var min: Double
  @Published var max: Double
  @Published var enabled: Bool
  var onChange: (Double) -> Void

  init(value: Double, min: Double, max: Double, enabled: Bool, onChange: @escaping (Double) -> Void) {
    self.value = value
    self.min = min
    self.max = max
    self.enabled = enabled
    self.onChange = onChange
  }
}

// MARK: - Switch (Toggle)

class CupertinoSwitchViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func createArgsCodec() -> (FlutterMessageCodec & NSObjectProtocol)? {
    return FlutterStandardMessageCodec.sharedInstance()
  }

  func create(withViewIdentifier viewId: Int64, arguments args: Any?) -> NSView {
    return CupertinoSwitchNSView(viewId: viewId, args: args, messenger: messenger)
  }
}

class CupertinoSwitchNSView: NSView {
  private let channel: FlutterMethodChannel
  private let hostingController: NSHostingController<CupertinoSwitchView>

  init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativeSwitch_\(viewId)", binaryMessenger: messenger)

    var initialValue: Bool = false
    var enabled: Bool = true
    if let dict = args as? [String: Any] {
      if let v = dict["value"] as? NSNumber { initialValue = v.boolValue }
      if let v = dict["enabled"] as? NSNumber { enabled = v.boolValue }
    }

    var channelRef: FlutterMethodChannel? = nil
    let model = SwitchModel(value: initialValue, enabled: enabled) { newValue in
      channelRef?.invokeMethod("valueChanged", arguments: ["value": newValue])
    }
    self.hostingController = NSHostingController(rootView: CupertinoSwitchView(model: model))
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

  required init?(coder: NSCoder) {
    return nil
  }
}

struct CupertinoSwitchView: View {
  @ObservedObject var model: SwitchModel

  var body: some View {
    Toggle("", isOn: $model.value)
      .labelsHidden()
      .disabled(!model.enabled)
      .onChange(of: model.value) { newValue in
        model.onChange(newValue)
      }
  }
}

class SwitchModel: ObservableObject {
  @Published var value: Bool
  @Published var enabled: Bool
  var onChange: (Bool) -> Void

  init(value: Bool, enabled: Bool, onChange: @escaping (Bool) -> Void) {
    self.value = value
    self.enabled = enabled
    self.onChange = onChange
  }
}
