import FlutterMacOS
import Cocoa

class CupertinoGlassEffectContainerNSView: NSView {
  private let channel: FlutterMethodChannel
  private let visualEffectView: NSVisualEffectView
  private let contentView: NSView
  private var currentMaterial: NSVisualEffectView.Material = .sidebar
  private var currentBlendingMode: NSVisualEffectView.BlendingMode = .behindWindow
  private var tintColor: NSColor?
  private var isInteractive: Bool = false
  
  init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativeGlassEffectContainer_\(viewId)", binaryMessenger: messenger)
    self.visualEffectView = NSVisualEffectView()
    self.contentView = NSView()
    
    var material: NSVisualEffectView.Material = .sidebar
    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
    var tint: NSColor? = nil
    var interactive: Bool = false
    var isDark: Bool = false
    var cornerRadius: CGFloat = 0
    
    if let dict = args as? [String: Any] {
      if let materialName = dict["material"] as? String {
        material = Self.materialFromString(materialName)
      }
      if let blendingName = dict["blending"] as? String {
        blendingMode = Self.blendingModeFromString(blendingName)
      }
      if let tintArgb = dict["tint"] as? NSNumber {
        tint = Self.colorFromARGB(tintArgb.intValue)
      }
      if let i = dict["interactive"] as? NSNumber {
        interactive = i.boolValue
      }
      if let v = dict["isDark"] as? NSNumber {
        isDark = v.boolValue
      }
      if let r = dict["cornerRadius"] as? NSNumber {
        cornerRadius = CGFloat(truncating: r)
      }
    }
    
    super.init(frame: .zero)
    
    // Store current values
    self.currentMaterial = material
    self.currentBlendingMode = blendingMode
    self.tintColor = tint
    self.isInteractive = interactive
    
    wantsLayer = true
    layer?.backgroundColor = NSColor.clear.cgColor
    appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
    
    // Set up visual effect view
    visualEffectView.material = material
    visualEffectView.blendingMode = blendingMode
    visualEffectView.state = .active
    visualEffectView.translatesAutoresizingMaskIntoConstraints = false
    visualEffectView.wantsLayer = true
    visualEffectView.layer?.cornerRadius = cornerRadius
    
    // Set up content view
    contentView.wantsLayer = true
    contentView.layer?.backgroundColor = NSColor.clear.cgColor
    contentView.translatesAutoresizingMaskIntoConstraints = false
    
    // Add tint color if specified
    if let tint = tint {
      contentView.layer?.backgroundColor = tint.withAlphaComponent(0.1).cgColor
    }
    
    // Build view hierarchy
    addSubview(visualEffectView)
    visualEffectView.addSubview(contentView)
    
    // Set up constraints
    NSLayoutConstraint.activate([
      visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
      visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
      visualEffectView.topAnchor.constraint(equalTo: topAnchor),
      visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
      
      contentView.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor),
      contentView.topAnchor.constraint(equalTo: visualEffectView.topAnchor),
      contentView.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor),
    ])
    
    // Add interaction if requested
    if interactive {
      let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick))
      addGestureRecognizer(clickGesture)
    }
    
    // Set up method channel handlers
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "getIntrinsicSize":
        let size = self.intrinsicContentSize
        result(["width": Double(size.width), "height": Double(size.height)])
      case "setMaterial":
        if let args = call.arguments as? [String: Any] {
          if let materialName = args["material"] as? String {
            let material = Self.materialFromString(materialName)
            self.currentMaterial = material
            self.visualEffectView.material = material
          }
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing material", details: nil))
        }
      case "setBlending":
        if let args = call.arguments as? [String: Any] {
          if let blendingName = args["blending"] as? String {
            let blendingMode = Self.blendingModeFromString(blendingName)
            self.currentBlendingMode = blendingMode
            self.visualEffectView.blendingMode = blendingMode
          }
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing blending mode", details: nil))
        }
      case "setTint":
        if let args = call.arguments as? [String: Any] {
          if let tintArgb = args["tint"] as? NSNumber {
            let tint = Self.colorFromARGB(tintArgb.intValue)
            self.tintColor = tint
            self.contentView.layer?.backgroundColor = tint.withAlphaComponent(0.1).cgColor
          }
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing tint", details: nil))
        }
      case "setCornerRadius":
        if let args = call.arguments as? [String: Any] {
          if let radiusNumber = args["cornerRadius"] as? NSNumber {
            let radius = CGFloat(truncating: radiusNumber)
            self.visualEffectView.layer?.cornerRadius = radius
          }
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing corner radius", details: nil))
        }
      case "setBrightness":
        if let args = call.arguments as? [String: Any], let isDark = (args["isDark"] as? NSNumber)?.boolValue {
          self.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
  
  required init?(coder: NSCoder) { return nil }
  
  @objc private func handleClick() {
    channel.invokeMethod("onTap", arguments: nil)
  }
  
  // MARK: - Helper Methods
  
  private static func materialFromString(_ materialName: String) -> NSVisualEffectView.Material {
    switch materialName {
    case "titlebar": return .titlebar
    case "selection": return .selection
    case "menu": return .menu
    case "popover": return .popover
    case "sidebar": return .sidebar
    case "headerView": 
      if #available(macOS 10.14, *) { return .headerView }
      return .titlebar
    case "sheet":
      if #available(macOS 10.14, *) { return .sheet }
      return .menu
    case "windowBackground":
      if #available(macOS 10.14, *) { return .windowBackground }
      return .sidebar
    case "hudWindow":
      if #available(macOS 10.14, *) { return .hudWindow }
      return .popover
    case "fullScreenUI":
      if #available(macOS 10.14, *) { return .fullScreenUI }
      return .sidebar
    case "toolTip":
      if #available(macOS 10.14, *) { return .toolTip }
      return .popover
    case "contentBackground":
      if #available(macOS 10.14, *) { return .contentBackground }
      return .sidebar
    case "underWindowBackground":
      if #available(macOS 10.14, *) { return .underWindowBackground }
      return .sidebar
    case "underPageBackground":
      if #available(macOS 10.14, *) { return .underPageBackground }
      return .sidebar
    default: return .sidebar
    }
  }
  
  private static func blendingModeFromString(_ blendingName: String) -> NSVisualEffectView.BlendingMode {
    switch blendingName {
    case "behindWindow": return .behindWindow
    case "withinWindow": return .withinWindow
    default: return .behindWindow
    }
  }
  
  private static func colorFromARGB(_ argb: Int) -> NSColor {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return NSColor(srgbRed: r, green: g, blue: b, alpha: a)
  }
}

extension CupertinoGlassEffectContainerNSView: FlutterPlatformView {
  func view() -> NSView {
    return self
  }
}
