import Flutter
import UIKit

class CupertinoTabBarPlatformView: NSObject, FlutterPlatformView, UITabBarDelegate {
  private let channel: FlutterMethodChannel
  private let container: UIView
  private let tabBar: UITabBar

  init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativeTabBar_\(viewId)", binaryMessenger: messenger)
    self.container = UIView(frame: frame)
    self.tabBar = UITabBar(frame: .zero)

    var labels: [String] = []
    var symbols: [String] = []
    var sizes: [NSNumber] = [] // ignored; use system metrics
    var colors: [NSNumber] = [] // ignored; use tintColor
    var selectedIndex: Int = 0
    var isDark: Bool = false
    var tint: UIColor? = nil
    var bg: UIColor? = nil

    if let dict = args as? [String: Any] {
      labels = (dict["labels"] as? [String]) ?? []
      symbols = (dict["sfSymbols"] as? [String]) ?? []
      sizes = (dict["sfSymbolSizes"] as? [NSNumber]) ?? []
      colors = (dict["sfSymbolColors"] as? [NSNumber]) ?? []
      if let v = dict["selectedIndex"] as? NSNumber { selectedIndex = v.intValue }
      if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
      if let style = dict["style"] as? [String: Any] {
        if let n = style["tint"] as? NSNumber { tint = Self.colorFromARGB(n.intValue) }
        if let n = style["backgroundColor"] as? NSNumber { bg = Self.colorFromARGB(n.intValue) }
      }
    }

    super.init()

    container.backgroundColor = .clear
    if #available(iOS 13.0, *) { container.overrideUserInterfaceStyle = isDark ? .dark : .light }

    tabBar.delegate = self
    tabBar.translatesAutoresizingMaskIntoConstraints = false
    // Adjust layout so icons sit above titles (avoid overlap)
    // Use default system layout (no manual offsets) for robust icon/title positioning.
    if #available(iOS 13.0, *) {
      let appearance = UITabBarAppearance()
      appearance.configureWithDefaultBackground()
      tabBar.standardAppearance = appearance
      if #available(iOS 15.0, *) { tabBar.scrollEdgeAppearance = appearance }
    }
    if let bg = bg { tabBar.barTintColor = bg }
    if #available(iOS 10.0, *), let tint = tint { tabBar.tintColor = tint }

    var items: [UITabBarItem] = []
    let count = max(labels.count, symbols.count)
    for i in 0..<count {
      var image: UIImage? = nil
      if i < symbols.count {
        image = UIImage(systemName: symbols[i])
        // Leave images as template to let UITabBar manage tinting and sizing.
      }
      let title = (i < labels.count) ? labels[i] : nil
      let item = UITabBarItem(title: title, image: image, selectedImage: image)
      // No manual insets; system positions icon/title appropriately.
      items.append(item)
    }
    tabBar.items = items
    if selectedIndex >= 0 && selectedIndex < items.count { tabBar.selectedItem = items[selectedIndex] }

    container.addSubview(tabBar)
    NSLayoutConstraint.activate([
      tabBar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      tabBar.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      tabBar.topAnchor.constraint(equalTo: container.topAnchor),
      tabBar.bottomAnchor.constraint(equalTo: container.bottomAnchor),
    ])

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "getIntrinsicSize":
        let size = self.tabBar.sizeThatFits(.zero)
        result(["width": Double(size.width), "height": Double(size.height)])
      case "setSelectedIndex":
        if let args = call.arguments as? [String: Any], let idx = (args["index"] as? NSNumber)?.intValue, let items = self.tabBar.items, idx >= 0, idx < items.count {
          self.tabBar.selectedItem = items[idx]
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing index", details: nil)) }
      case "setStyle":
        if let args = call.arguments as? [String: Any] {
          if let n = args["tint"] as? NSNumber { self.tabBar.tintColor = Self.colorFromARGB(n.intValue) }
          if let n = args["backgroundColor"] as? NSNumber { self.tabBar.barTintColor = Self.colorFromARGB(n.intValue) }
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing style", details: nil)) }
      case "setBrightness":
        if let args = call.arguments as? [String: Any], let isDark = (args["isDark"] as? NSNumber)?.boolValue {
          if #available(iOS 13.0, *) { self.container.overrideUserInterfaceStyle = isDark ? .dark : .light }
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil)) }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func view() -> UIView { container }

  func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    if let items = tabBar.items, let idx = items.firstIndex(of: item) {
      channel.invokeMethod("valueChanged", arguments: ["index": idx])
    }
  }

  private static func colorFromARGB(_ argb: Int) -> UIColor {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return UIColor(red: r, green: g, blue: b, alpha: a)
  }
}
