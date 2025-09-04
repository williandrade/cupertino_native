import FlutterMacOS
import Cocoa

class CupertinoPopupMenuButtonNSView: NSView {
  private let channel: FlutterMethodChannel
  private let button: NSButton
  private var menu: NSMenu = NSMenu()
  private var labels: [String] = []
  private var symbols: [String] = []
  private var dividers: [Bool] = []
  private var enabled: [Bool] = []

  init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativePopupMenuButton_\(viewId)", binaryMessenger: messenger)
    self.button = NSButton(title: "Menu", target: nil, action: nil)
    super.init(frame: .zero)

    var title: String = "Menu"
    var isDark: Bool = false
    var tint: NSColor? = nil
    var labels: [String] = []
    var symbols: [String] = []
    var dividers: [NSNumber] = []
    var enabled: [NSNumber] = []

    if let dict = args as? [String: Any] {
      if let t = dict["buttonTitle"] as? String { title = t }
      if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
      if let style = dict["style"] as? [String: Any], let n = style["tint"] as? NSNumber { tint = Self.colorFromARGB(n.intValue) }
      labels = (dict["labels"] as? [String]) ?? []
      symbols = (dict["sfSymbols"] as? [String]) ?? []
      dividers = (dict["isDivider"] as? [NSNumber]) ?? []
      enabled = (dict["enabled"] as? [NSNumber]) ?? []
    }

    wantsLayer = true
    layer?.backgroundColor = NSColor.clear.cgColor
    appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)

    button.bezelStyle = .rounded
    button.setButtonType(.momentaryPushIn)
    button.title = title
    if #available(macOS 10.14, *), let c = tint { button.contentTintColor = c }

    addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      button.leadingAnchor.constraint(equalTo: leadingAnchor),
      button.trailingAnchor.constraint(equalTo: trailingAnchor),
      button.topAnchor.constraint(equalTo: topAnchor),
      button.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])

    self.labels = labels
    self.symbols = symbols
    self.dividers = dividers.map { $0.boolValue }
    self.enabled = enabled.map { $0.boolValue }
    rebuildMenu()

    button.target = self
    button.action = #selector(onButtonPressed(_:))

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "getIntrinsicSize":
        let s = self.button.intrinsicContentSize
        result(["width": Double(s.width), "height": Double(s.height)])
      case "setItems":
        if let args = call.arguments as? [String: Any] {
          self.labels = (args["labels"] as? [String]) ?? []
          self.symbols = (args["sfSymbols"] as? [String]) ?? []
          self.dividers = ((args["isDivider"] as? [NSNumber]) ?? []).map { $0.boolValue }
          self.enabled = ((args["enabled"] as? [NSNumber]) ?? []).map { $0.boolValue }
          self.rebuildMenu()
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing items", details: nil)) }
      case "setStyle":
        if let args = call.arguments as? [String: Any] {
          if #available(macOS 10.14, *), let n = args["tint"] as? NSNumber { self.button.contentTintColor = Self.colorFromARGB(n.intValue) }
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing style", details: nil)) }
      case "setBrightness":
        if let args = call.arguments as? [String: Any], let isDark = (args["isDark"] as? NSNumber)?.boolValue {
          self.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil)) }
      case "setButtonTitle":
        if let args = call.arguments as? [String: Any], let t = args["title"] as? String {
          self.button.title = t
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing title", details: nil)) }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  required init?(coder: NSCoder) { return nil }

  @objc private func onButtonPressed(_ sender: NSButton) {
    let location = NSPoint(x: 0, y: sender.bounds.height)
    menu.popUp(positioning: nil, at: location, in: sender)
  }

  private func rebuildMenu() {
    menu = NSMenu()
    let count = max(labels.count, max(symbols.count, dividers.count))
    for i in 0..<count {
      if i < dividers.count, dividers[i] {
        menu.addItem(.separator())
        continue
      }
      let title = i < labels.count ? labels[i] : ""
      let mi = NSMenuItem(title: title, action: #selector(onSelectMenuItem(_:)), keyEquivalent: "")
      mi.target = self
      mi.tag = i
      if i < enabled.count { mi.isEnabled = enabled[i] }
      if i < symbols.count, !symbols[i].isEmpty {
        if let img = NSImage(systemSymbolName: symbols[i], accessibilityDescription: nil) {
          mi.image = img
        }
      }
      menu.addItem(mi)
    }
  }

  @objc private func onSelectMenuItem(_ sender: NSMenuItem) {
    channel.invokeMethod("itemSelected", arguments: ["index": sender.tag])
  }

  private static func colorFromARGB(_ argb: Int) -> NSColor {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return NSColor(srgbRed: r, green: g, blue: b, alpha: a)
  }
}

