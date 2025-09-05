import Flutter
import UIKit

class CupertinoButtonPlatformView: NSObject, FlutterPlatformView {
  private let channel: FlutterMethodChannel
  private let container: UIView
  private let button: UIButton
  private var isEnabled: Bool = true

  init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativeButton_\(viewId)", binaryMessenger: messenger)
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
    var enabled: Bool = true

    if let dict = args as? [String: Any] {
      if let t = dict["buttonTitle"] as? String { title = t }
      if let s = dict["buttonIconName"] as? String { iconName = s }
      if let s = dict["buttonIconSize"] as? NSNumber { iconSize = CGFloat(truncating: s) }
      if let c = dict["buttonIconColor"] as? NSNumber { iconColor = Self.colorFromARGB(c.intValue) }
      if let r = dict["round"] as? NSNumber { makeRound = r.boolValue }
      if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
      if let style = dict["style"] as? [String: Any], let n = style["tint"] as? NSNumber { tint = Self.colorFromARGB(n.intValue) }
      if let bs = dict["buttonStyle"] as? String { buttonStyle = bs }
      if let e = dict["enabled"] as? NSNumber { enabled = e.boolValue }
    }

    super.init()

    container.backgroundColor = .clear
    if #available(iOS 13.0, *) { container.overrideUserInterfaceStyle = isDark ? .dark : .light }

    button.translatesAutoresizingMaskIntoConstraints = false
    if let t = tint { button.tintColor = t }
    else if #available(iOS 13.0, *) { button.tintColor = .label }

    container.addSubview(button)
    NSLayoutConstraint.activate([
      button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      button.topAnchor.constraint(equalTo: container.topAnchor),
      button.bottomAnchor.constraint(equalTo: container.bottomAnchor),
    ])

    applyButtonStyle(buttonStyle: buttonStyle, round: makeRound)
    button.isEnabled = enabled
    isEnabled = enabled

    var finalImage: UIImage? = nil
    if let name = iconName, var image = UIImage(systemName: name) {
      if let sz = iconSize { image = image.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: sz)) ?? image }
      if let col = iconColor, #available(iOS 13.0, *) { image = image.withTintColor(col, renderingMode: .alwaysOriginal) }
      finalImage = image
    }
    setButtonContent(title: title, image: finalImage, iconOnly: (title == nil))

    // Default system highlight/pressed behavior
    button.addTarget(self, action: #selector(onPressed(_:)), for: .touchUpInside)
    button.adjustsImageWhenHighlighted = true

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "getIntrinsicSize":
        let size = self.button.intrinsicContentSize
        result(["width": Double(size.width), "height": Double(size.height)])
      case "setStyle":
        if let args = call.arguments as? [String: Any] {
          if let n = args["tint"] as? NSNumber { self.button.tintColor = Self.colorFromARGB(n.intValue) }
          if let bs = args["buttonStyle"] as? String { self.applyButtonStyle(buttonStyle: bs, round: makeRound) }
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing style", details: nil)) }
      case "setEnabled":
        if let args = call.arguments as? [String: Any], let e = args["enabled"] as? NSNumber {
          self.isEnabled = e.boolValue
          self.button.isEnabled = self.isEnabled
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing enabled", details: nil)) }
      case "setPressed":
        if let args = call.arguments as? [String: Any], let p = args["pressed"] as? NSNumber {
          self.button.isHighlighted = p.boolValue
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing pressed", details: nil)) }
      case "setButtonTitle":
        if let args = call.arguments as? [String: Any], let t = args["title"] as? String {
          self.setButtonContent(title: t, image: nil, iconOnly: false)
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing title", details: nil)) }
      case "setButtonIcon":
        if let args = call.arguments as? [String: Any] {
          var image: UIImage? = nil
          if let name = args["buttonIconName"] as? String { image = UIImage(systemName: name) }
          if let s = args["buttonIconSize"] as? NSNumber, let img = image {
            image = img.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: CGFloat(truncating: s))) ?? img
          }
          if let c = args["buttonIconColor"] as? NSNumber, let img = image, #available(iOS 13.0, *) {
            image = img.withTintColor(Self.colorFromARGB(c.intValue), renderingMode: .alwaysOriginal)
          }
          self.setButtonContent(title: nil, image: image, iconOnly: true)
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing icon args", details: nil)) }
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

  @objc private func onPressed(_ sender: UIButton) {
    guard isEnabled else { return }
    channel.invokeMethod("pressed", arguments: nil)
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
      case "accessoryBar":
        config = .gray()
      case "accessoryBarAction": config = .tinted()
      case "bordered": config = .bordered()
      case "borderedProminent": config = .borderedProminent()
      case "glass":
        config = .plain()
        if #available(iOS 26, *) {
          config = .glass()
        }
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
      // Default background to preserve pressed/highlight behavior; custom glass handled above for iOS15+
      button.backgroundColor = .clear
      button.layer.borderWidth = 0
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
