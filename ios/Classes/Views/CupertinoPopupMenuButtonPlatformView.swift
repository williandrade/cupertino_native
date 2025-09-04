import Flutter
import UIKit

class CupertinoPopupMenuButtonPlatformView: NSObject, FlutterPlatformView {
  private let channel: FlutterMethodChannel
  private let container: UIView
  private let button: UIButton
  private var isRoundButton: Bool = false
  private var labels: [String] = []
  private var symbols: [String] = []
  private var dividers: [Bool] = []
  private var enabled: [Bool] = []

  init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativePopupMenuButton_\(viewId)", binaryMessenger: messenger)
    self.container = UIView(frame: frame)
    self.button = UIButton(type: .system)

    var title: String? = nil
    var iconName: String? = nil
    var iconSize: CGFloat? = nil
    var iconColor: UIColor? = nil
    var makeRound: Bool = false
    var isDark: Bool = false
    var tint: UIColor? = nil
    var buttonStyle: String = "automatic"
    var labels: [String] = []
    var symbols: [String] = []
    var dividers: [NSNumber] = []
    var enabled: [NSNumber] = []
    var sizes: [NSNumber] = []
    var colors: [NSNumber] = []

    if let dict = args as? [String: Any] {
      if let t = dict["buttonTitle"] as? String { title = t }
      if let s = dict["buttonIconName"] as? String { iconName = s }
      if let s = dict["buttonIconSize"] as? NSNumber { iconSize = CGFloat(truncating: s) }
      if let c = dict["buttonIconColor"] as? NSNumber { iconColor = Self.colorFromARGB(c.intValue) }
      if let r = dict["round"] as? NSNumber { makeRound = r.boolValue }
      if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
      if let style = dict["style"] as? [String: Any], let n = style["tint"] as? NSNumber { tint = Self.colorFromARGB(n.intValue) }
      if let bs = dict["buttonStyle"] as? String { buttonStyle = bs }
      labels = (dict["labels"] as? [String]) ?? []
      symbols = (dict["sfSymbols"] as? [String]) ?? []
      dividers = (dict["isDivider"] as? [NSNumber]) ?? []
      enabled = (dict["enabled"] as? [NSNumber]) ?? []
      sizes = (dict["sfSymbolSizes"] as? [NSNumber]) ?? []
      colors = (dict["sfSymbolColors"] as? [NSNumber]) ?? []
    }

    super.init()

    container.backgroundColor = .clear
    if #available(iOS 13.0, *) { container.overrideUserInterfaceStyle = isDark ? .dark : .light }

    button.translatesAutoresizingMaskIntoConstraints = false
    // Choose a visible default tint if none provided
    if let t = tint { button.tintColor = t }
    else if #available(iOS 13.0, *) { button.tintColor = .label }

    // Add button and pin to container
    container.addSubview(button)
    NSLayoutConstraint.activate([
      button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      button.topAnchor.constraint(equalTo: container.topAnchor),
      button.bottomAnchor.constraint(equalTo: container.bottomAnchor),
    ])

    // Store
    self.labels = labels
    self.symbols = symbols
    self.dividers = dividers.map { $0.boolValue }
    self.enabled = enabled.map { $0.boolValue }

    self.isRoundButton = makeRound
    applyButtonStyle(buttonStyle: buttonStyle, round: makeRound)
    // Now set content (title/image) using configuration when available
    var finalImage: UIImage? = nil
    if let name = iconName, var image = UIImage(systemName: name) {
      if let sz = iconSize { image = image.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: sz)) ?? image }
      if let col = iconColor, #available(iOS 13.0, *) { image = image.withTintColor(col, renderingMode: .alwaysOriginal) }
      finalImage = image
    }
    setButtonContent(title: title, image: finalImage, iconOnly: (title == nil))

    rebuildMenu(defaultSizes: sizes, defaultColors: colors)
    if #available(iOS 14.0, *) {
      button.showsMenuAsPrimaryAction = true
    } else {
      button.addTarget(self, action: #selector(onButtonPressedLegacy(_:)), for: .touchUpInside)
    }

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "getIntrinsicSize":
        let size = self.button.intrinsicContentSize
        result(["width": Double(size.width), "height": Double(size.height)])
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
          if let n = args["tint"] as? NSNumber { self.button.tintColor = Self.colorFromARGB(n.intValue) }
          if let bs = args["buttonStyle"] as? String { self.applyButtonStyle(buttonStyle: bs, round: self.isRoundButton) }
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing style", details: nil)) }
      case "setButtonIcon":
        if let args = call.arguments as? [String: Any] {
          var finalImage: UIImage? = nil
          if let name = args["buttonIconName"] as? String, var image = UIImage(systemName: name) {
            if let sz = args["buttonIconSize"] as? NSNumber { image = image.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: CGFloat(truncating: sz))) ?? image }
            if let c = args["buttonIconColor"] as? NSNumber, #available(iOS 13.0, *) {
              image = image.withTintColor(Self.colorFromARGB(c.intValue), renderingMode: .alwaysOriginal)
            }
            finalImage = image
          }
          if let r = args["round"] as? NSNumber { self.isRoundButton = r.boolValue }
          self.applyButtonStyle(buttonStyle: "tinted", round: self.isRoundButton)
          self.setButtonContent(title: nil, image: finalImage, iconOnly: true)
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing icon args", details: nil)) }
      case "setBrightness":
        if let args = call.arguments as? [String: Any], let isDark = (args["isDark"] as? NSNumber)?.boolValue {
          if #available(iOS 13.0, *) { self.container.overrideUserInterfaceStyle = isDark ? .dark : .light }
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil)) }
      case "setButtonTitle":
        if let args = call.arguments as? [String: Any], let t = args["title"] as? String {
          self.button.setTitle(t, for: .normal)
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing title", details: nil)) }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func view() -> UIView { container }

  private func rebuildMenu(defaultSizes: [NSNumber]? = nil, defaultColors: [NSNumber]? = nil) {
    // iOS 14+ native menu
    if #available(iOS 14.0, *) {
      // Build grouped actions; inline groups render with native separators.
      var groups: [[UIMenuElement]] = []
      var current: [UIMenuElement] = []
      let count = max(labels.count, max(symbols.count, dividers.count))
      let flushGroup: () -> Void = {
        if !current.isEmpty { groups.append(current); current = [] }
      }
      for i in 0..<count {
        let isDiv = i < dividers.count ? dividers[i] : false
        if isDiv { flushGroup(); continue }
        let title = i < labels.count ? labels[i] : ""
        var image: UIImage? = nil
        if i < symbols.count, !symbols[i].isEmpty { image = UIImage(systemName: symbols[i]) }
        if let sizes = defaultSizes, i < sizes.count {
          let s = CGFloat(truncating: sizes[i])
          if s > 0, let img = image { image = img.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: s)) }
        }
        if let colors = defaultColors, i < colors.count {
          let c = Self.colorFromARGB(colors[i].intValue)
          if let img = image, #available(iOS 13.0, *) {
            image = img.withTintColor(c, renderingMode: .alwaysOriginal)
          }
        }
        let isEnabled = i < enabled.count ? enabled[i] : true
        let action = UIAction(title: title, image: image, attributes: isEnabled ? [] : [.disabled]) { [weak self] _ in
          self?.channel.invokeMethod("itemSelected", arguments: ["index": i])
        }
        current.append(action)
      }
      flushGroup()
      let children: [UIMenuElement] = groups.map { group in
        UIMenu(title: "", options: .displayInline, children: group)
      }
      button.menu = UIMenu(title: "", children: children)
    }
  }

  @objc private func onButtonPressedLegacy(_ sender: UIButton) {
    // iOS 13 fallback: use action sheet
    let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let count = max(labels.count, max(symbols.count, dividers.count))
    for i in 0..<count {
      if i < dividers.count, dividers[i] {
        // Simulate separator with disabled action
        let fake = UIAlertAction(title: "—", style: .default, handler: nil)
        fake.isEnabled = false
        ac.addAction(fake)
        continue
      }
      let title = i < labels.count ? labels[i] : ""
      let action = UIAlertAction(title: title, style: .default) { [weak self] _ in
        self?.channel.invokeMethod("itemSelected", arguments: ["index": i])
      }
      if i < enabled.count { action.isEnabled = enabled[i] }
      // Optional: set image where supported (iOS 13 has `image` on UIAlertAction)
      if i < symbols.count, !symbols[i].isEmpty, let img = UIImage(systemName: symbols[i]) {
        if #available(iOS 13.0, *) { action.setValue(img, forKey: "image") }
      }
      ac.addAction(action)
    }
    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

    if let pop = ac.popoverPresentationController {
      pop.sourceView = sender
      pop.sourceRect = sender.bounds
    }
    parentViewController(for: container)?.present(ac, animated: true, completion: nil)
  }

  private func parentViewController(for view: UIView) -> UIViewController? {
    var responder: UIResponder? = view
    while let r = responder {
      if let vc = r as? UIViewController { return vc }
      responder = r.next
    }
    return nil
  }

  private static func colorFromARGB(_ argb: Int) -> UIColor {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return UIColor(red: r, green: g, blue: b, alpha: a)
  }

  private func applyButtonStyle(buttonStyle: String, round: Bool) {
    if #available(iOS 15.0, *) {
      var config: UIButton.Configuration
      switch buttonStyle {
      case "automatic": config = .plain()
      case "accessoryBar": config = .gray()
      case "accessoryBarAction": config = .tinted()
      case "bordered": config = .bordered()
      case "borderedProminent": config = .borderedProminent()
      case "glass":
        config = .plain()
        var bg = UIBackgroundConfiguration.clear()
        bg.visualEffect = UIBlurEffect(style: .systemChromeMaterial)
        bg.cornerRadius = round ? 999 : 12
        bg.strokeColor = UIColor.separator.withAlphaComponent(0.45)
        bg.strokeWidth = 1.0 / UIScreen.main.scale
        config.background = bg
      case "borderless": config = .plain()
      case "card": config = .plain()
      case "link": config = .plain()
      case "plain": config = .plain()
      default: config = .plain()
      }
      config.cornerStyle = round ? .capsule : .dynamic
      button.configuration = config
    } else {
      button.layer.cornerRadius = round ? 999 : 8
      button.clipsToBounds = true
      if buttonStyle == "glass" {
        button.backgroundColor = UIColor(white: 1.0, alpha: 0.22)
        button.layer.borderColor = UIColor.separator.withAlphaComponent(0.45).cgColor
        button.layer.borderWidth = 1.0 / UIScreen.main.scale
      } else {
        button.backgroundColor = .clear
        button.layer.borderWidth = 0
      }
    }
  }

  private func setButtonContent(title: String?, image: UIImage?, iconOnly: Bool) {
    if #available(iOS 15.0, *) {
      var cfg = button.configuration ?? .plain()
      cfg.title = title
      cfg.image = image
      button.configuration = cfg
    } else {
      button.setTitle(title, for: .normal)
      button.setImage(image, for: .normal)
      if iconOnly {
        button.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
      }
    }
  }
}
