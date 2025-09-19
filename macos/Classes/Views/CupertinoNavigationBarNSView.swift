import FlutterMacOS
import Cocoa

class CupertinoNavigationBarNSView: NSView {
  private let channel: FlutterMethodChannel
  private let stackView: NSStackView
  private let titleLabel: NSTextField
  
  // Button group data
  private var leadingGroups: [[String: Any]] = []
  private var centerGroups: [[String: Any]] = []
  private var trailingGroups: [[String: Any]] = []
  
  // UI components
  private var leadingStackView: NSStackView!
  private var centerStackView: NSStackView!
  private var trailingStackView: NSStackView!
  
  init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativeNavigationBar_\(viewId)", binaryMessenger: messenger)
    self.stackView = NSStackView()
    self.titleLabel = NSTextField()
    
    var isDark: Bool = false
    var title: String = ""
    var height: CGFloat = 44.0
    
    if let dict = args as? [String: Any] {
      if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
      if let t = dict["title"] as? String { title = t }
      if let h = dict["height"] as? NSNumber { height = CGFloat(truncating: h) }
      if let leading = dict["leadingGroups"] as? [[String: Any]] { self.leadingGroups = leading }
      if let center = dict["centerGroups"] as? [[String: Any]] { self.centerGroups = center }
      if let trailing = dict["trailingGroups"] as? [[String: Any]] { self.trailingGroups = trailing }
    }
    
    super.init(frame: .zero)
    
    wantsLayer = true
    layer?.backgroundColor = NSColor.clear.cgColor
    appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
    
    setupUI(title: title, height: height)
    rebuildButtonGroups()
    
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "getIntrinsicSize":
        let size = self.intrinsicContentSize
        result(["width": Double(size.width), "height": Double(size.height)])
      case "setTitle":
        if let args = call.arguments as? [String: Any], let title = args["title"] as? String {
          self.titleLabel.stringValue = title
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing title", details: nil)) }
      case "setButtonGroups":
        if let args = call.arguments as? [String: Any] {
          if let leading = args["leadingGroups"] as? [[String: Any]] { self.leadingGroups = leading }
          if let center = args["centerGroups"] as? [[String: Any]] { self.centerGroups = center }
          if let trailing = args["trailingGroups"] as? [[String: Any]] { self.trailingGroups = trailing }
          self.rebuildButtonGroups()
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing button groups", details: nil)) }
      case "setStyle":
        // Handle style changes if needed
        result(nil)
      case "setBrightness":
        if let args = call.arguments as? [String: Any], let isDark = (args["isDark"] as? NSNumber)?.boolValue {
          self.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil)) }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
  
  required init?(coder: NSCoder) { return nil }
  
  private func setupUI(title: String, height: CGFloat) {
    // Create main horizontal stack view
    stackView.orientation = .horizontal
    stackView.alignment = .centerY
    stackView.distribution = .fill
    stackView.spacing = 8
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    // Setup title label
    titleLabel.stringValue = title
    titleLabel.isEditable = false
    titleLabel.isBordered = false
    titleLabel.backgroundColor = .clear
    titleLabel.font = NSFont.systemFont(ofSize: 17, weight: .semibold)
    titleLabel.alignment = .center
    titleLabel.setContentHuggingPriority(NSLayoutConstraint.Priority(250), for: .horizontal)
    
    // Create section stack views
    leadingStackView = NSStackView()
    leadingStackView.orientation = .horizontal
    leadingStackView.alignment = .centerY
    leadingStackView.spacing = 4
    leadingStackView.setContentHuggingPriority(NSLayoutConstraint.Priority(252), for: .horizontal)
    
    centerStackView = NSStackView()
    centerStackView.orientation = .horizontal
    centerStackView.alignment = .centerY
    centerStackView.spacing = 4
    centerStackView.setContentHuggingPriority(NSLayoutConstraint.Priority(251), for: .horizontal)
    
    trailingStackView = NSStackView()
    trailingStackView.orientation = .horizontal
    trailingStackView.alignment = .centerY
    trailingStackView.spacing = 4
    trailingStackView.setContentHuggingPriority(NSLayoutConstraint.Priority(252), for: .horizontal)
    
    // Add to main stack
    stackView.addArrangedSubview(leadingStackView)
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(centerStackView)
    stackView.addArrangedSubview(trailingStackView)
    
    addSubview(stackView)
    
    NSLayoutConstraint.activate([
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
      stackView.topAnchor.constraint(equalTo: topAnchor),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
      heightAnchor.constraint(equalToConstant: height)
    ])
  }
  
  private func rebuildButtonGroups() {
    // Clear existing views
    leadingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    centerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    trailingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    
    // Add leading groups
    for (groupIndex, groupData) in leadingGroups.enumerated() {
      if let buttonsData = groupData["buttons"] as? [[String: Any]] {
        let groupStackView = createGroupStackView()
        for (buttonIndex, buttonData) in buttonsData.enumerated() {
          if let button = createButton(from: buttonData, groupIndex: groupIndex, buttonIndex: buttonIndex, groupType: "leading") {
            groupStackView.addArrangedSubview(button)
          }
        }
        leadingStackView.addArrangedSubview(groupStackView)
      }
    }
    
    // Add center groups
    for (groupIndex, groupData) in centerGroups.enumerated() {
      if let buttonsData = groupData["buttons"] as? [[String: Any]] {
        let groupStackView = createGroupStackView()
        for (buttonIndex, buttonData) in buttonsData.enumerated() {
          if let button = createButton(from: buttonData, groupIndex: groupIndex, buttonIndex: buttonIndex, groupType: "center") {
            groupStackView.addArrangedSubview(button)
          }
        }
        centerStackView.addArrangedSubview(groupStackView)
      }
    }
    
    // Add trailing groups
    for (groupIndex, groupData) in trailingGroups.enumerated() {
      if let buttonsData = groupData["buttons"] as? [[String: Any]] {
        let groupStackView = createGroupStackView()
        for (buttonIndex, buttonData) in buttonsData.enumerated() {
          if let button = createButton(from: buttonData, groupIndex: groupIndex, buttonIndex: buttonIndex, groupType: "trailing") {
            groupStackView.addArrangedSubview(button)
          }
        }
        trailingStackView.addArrangedSubview(groupStackView)
      }
    }
  }
  
  private func createGroupStackView() -> NSStackView {
    let stackView = NSStackView()
    stackView.orientation = .horizontal
    stackView.alignment = .centerY
    stackView.spacing = 2
    return stackView
  }
  
  private func createButton(from buttonData: [String: Any], groupIndex: Int, buttonIndex: Int, groupType: String) -> NSButton? {
    guard let title = buttonData["title"] as? String else { return nil }
    
    let button = NSButton()
    button.title = title
    button.bezelStyle = .rounded
    button.target = self
    button.action = #selector(buttonTapped(_:))
    
    // Store index information for callback
    button.tag = groupIndex * 1000 + buttonIndex
    
    // Handle SF Symbol
    if let symbolName = buttonData["sfSymbol"] as? String, !symbolName.isEmpty {
      if #available(macOS 11.0, *), var image = NSImage(systemSymbolName: symbolName, accessibilityDescription: title) {
        
        // Apply symbol styling
        if let size = buttonData["sfSymbolSize"] as? NSNumber {
          if #available(macOS 12.0, *) {
            let config = NSImage.SymbolConfiguration(pointSize: CGFloat(truncating: size), weight: .regular)
            image = image.withSymbolConfiguration(config) ?? image
          }
        }
        
        if let colorArgb = buttonData["sfSymbolColor"] as? NSNumber {
          let color = Self.colorFromARGB(colorArgb.intValue)
          // macOS doesn't have direct tinting like iOS, but we can set content tint color
          button.contentTintColor = color
        }
        
        if let mode = buttonData["sfSymbolRenderingMode"] as? String {
          switch mode {
          case "multicolor":
            if #available(macOS 12.0, *) {
              let config = NSImage.SymbolConfiguration.preferringMulticolor()
              image = image.withSymbolConfiguration(config) ?? image
            }
          default:
            break
          }
        }
        
        button.image = image
        if title.isEmpty {
          button.title = ""
        }
      }
    }
    
    if let enabled = buttonData["enabled"] as? NSNumber {
      button.isEnabled = enabled.boolValue
    }
    
    // Store group type in identifier for callback
    button.identifier = NSUserInterfaceItemIdentifier("\(groupType)_\(groupIndex)_\(buttonIndex)")
    
    return button
  }
  
  @objc private func buttonTapped(_ sender: NSButton) {
    let groupIndex = sender.tag / 1000
    let buttonIndex = sender.tag % 1000
    
    // Extract group type from identifier
    let parts = sender.identifier?.rawValue.split(separator: "_")
    let groupType = parts?.first.map(String.init) ?? "leading"
    
    channel.invokeMethod("buttonTapped", arguments: [
      "groupType": groupType,
      "groupIndex": groupIndex,
      "buttonIndex": buttonIndex
    ])
  }
  
  private static func colorFromARGB(_ argb: Int) -> NSColor {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return NSColor(srgbRed: r, green: g, blue: b, alpha: a)
  }
}

extension CupertinoNavigationBarNSView: FlutterPlatformView {
  func view() -> NSView {
    return self
  }
}
