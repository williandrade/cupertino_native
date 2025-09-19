
import Flutter
import UIKit

class CupertinoNavigationBarPlatformView: NSObject, FlutterPlatformView {
  private let channel: FlutterMethodChannel
  private let container: UIView
  private let navigationBar: UINavigationBar
  private let navigationItem: UINavigationItem
  
  // Button group data
  private var leadingGroups: [[String: Any]] = []
  private var centerGroups: [[String: Any]] = []
  private var trailingGroups: [[String: Any]] = []
  
  // Added: default icon color from theme/style and interactivity flag
  private var defaultIconColor: UIColor? = nil
  private var isInteractive: Bool = true
  
  init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativeNavigationBar_\(viewId)", binaryMessenger: messenger)
    self.container = UIView(frame: frame)
    self.navigationBar = UINavigationBar()
    self.navigationItem = UINavigationItem()
    
    var isDark: Bool = false
    var tint: UIColor? = nil
    var title: String? = nil
    var height: CGFloat = 44.0
    var interactive: Bool = true
    
    if let dict = args as? [String: Any] {
      if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
      if let style = dict["style"] as? [String: Any], let n = style["tint"] as? NSNumber {
        tint = Self.colorFromARGB(n.intValue)
      }
      if let t = dict["title"] as? String { title = t }
      if let h = dict["height"] as? NSNumber { height = CGFloat(truncating: h) }
      if let leading = dict["leadingGroups"] as? [[String: Any]] { self.leadingGroups = leading }
      if let center = dict["centerGroups"] as? [[String: Any]] { self.centerGroups = center }
      if let trailing = dict["trailingGroups"] as? [[String: Any]] { self.trailingGroups = trailing }
      if let i = dict["interactive"] as? NSNumber { interactive = i.boolValue }
    }
    
    super.init()
    
    container.backgroundColor = .clear
    if #available(iOS 13.0, *) {
      container.overrideUserInterfaceStyle = isDark ? .dark : .light
    }
    
    // Setup navigation bar
    navigationBar.translatesAutoresizingMaskIntoConstraints = false
    if let c = tint {
      navigationBar.tintColor = c
      self.defaultIconColor = c
    }
    navigationBar.isUserInteractionEnabled = interactive
    self.isInteractive = interactive
    if let t = title { navigationItem.title = t }
    
    // Add navigation item to bar
    navigationBar.setItems([navigationItem], animated: false)
    
    container.addSubview(navigationBar)
    NSLayoutConstraint.activate([
      navigationBar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      navigationBar.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      navigationBar.topAnchor.constraint(equalTo: container.topAnchor),
      navigationBar.heightAnchor.constraint(equalToConstant: height),
    ])
    
    rebuildButtonGroups()
    
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "getIntrinsicSize":
        let size = self.navigationBar.intrinsicContentSize
        result(["width": Double(size.width), "height": Double(size.height)])
      case "setTitle":
        if let args = call.arguments as? [String: Any], let title = args["title"] as? String {
          DispatchQueue.main.async {
            self.navigationItem.title = title
            result(nil)
          }
        } else { result(FlutterError(code: "bad_args", message: "Missing title", details: nil)) }
      case "setButtonGroups":
        if let args = call.arguments as? [String: Any] {
          DispatchQueue.main.async {
            if let leading = args["leadingGroups"] as? [[String: Any]] { self.leadingGroups = leading }
            if let center = args["centerGroups"] as? [[String: Any]] { self.centerGroups = center }
            if let trailing = args["trailingGroups"] as? [[String: Any]] { self.trailingGroups = trailing }
            self.rebuildButtonGroups()
            result(nil)
          }
        } else { result(FlutterError(code: "bad_args", message: "Missing button groups", details: nil)) }
      case "setStyle":
        if let args = call.arguments as? [String: Any] {
          DispatchQueue.main.async {
            if let n = args["tint"] as? NSNumber {
              let color = Self.colorFromARGB(n.intValue)
              self.navigationBar.tintColor = color
              self.defaultIconColor = color
              self.rebuildButtonGroups()
            }
            result(nil)
          }
        } else { result(FlutterError(code: "bad_args", message: "Missing style", details: nil)) }
      case "setBrightness":
        if let args = call.arguments as? [String: Any], let isDark = (args["isDark"] as? NSNumber)?.boolValue {
          DispatchQueue.main.async {
            if #available(iOS 13.0, *) {
              self.container.overrideUserInterfaceStyle = isDark ? .dark : .light
            }
            result(nil)
          }
        } else { result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil)) }
      case "setInteractive":
        if let args = call.arguments as? [String: Any], let interactive = (args["interactive"] as? NSNumber)?.boolValue {
          DispatchQueue.main.async {
            self.navigationBar.isUserInteractionEnabled = interactive
            result(nil)
          }
        } else { result(FlutterError(code: "bad_args", message: "Missing interactive", details: nil)) }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
  
  func view() -> UIView { container }
  
  private func rebuildButtonGroups() {
    if #available(iOS 16.0, *) {
      // Use modern item groups API
      navigationItem.leadingItemGroups = createItemGroups(from: leadingGroups, groupType: "leading")
      navigationItem.centerItemGroups = createItemGroups(from: centerGroups, groupType: "center")
      navigationItem.trailingItemGroups = createItemGroups(from: trailingGroups, groupType: "trailing")
    } else {
      // Fallback for older iOS versions
      var leftItems: [UIBarButtonItem] = []
      var rightItems: [UIBarButtonItem] = []
      
      // Combine leading groups into left items
      for (groupIndex, group) in leadingGroups.enumerated() {
        if let buttons = group["buttons"] as? [[String: Any]] {
          leftItems.append(contentsOf: createBarButtonItems(from: buttons, groupIndex: groupIndex, groupType: "leading"))
        }
      }
      
      // Combine trailing groups into right items
      for (groupIndex, group) in trailingGroups.enumerated() {
        if let buttons = group["buttons"] as? [[String: Any]] {
          rightItems.append(contentsOf: createBarButtonItems(from: buttons, groupIndex: groupIndex, groupType: "trailing"))
        }
      }
      
      navigationItem.leftBarButtonItems = leftItems.isEmpty ? nil : leftItems
      navigationItem.rightBarButtonItems = rightItems.isEmpty ? nil : rightItems
      
      // Center groups fallback - use title view if there's only one center item
      if centerGroups.count == 1, let buttons = centerGroups[0]["buttons"] as? [[String: Any]], buttons.count == 1 {
        let button = createBarButtonItems(from: buttons, groupIndex: 0, groupType: "center").first
        if let btn = button {
          let customView = UIButton(type: .system)
          customView.setTitle(btn.title, for: .normal)
          customView.setImage(btn.image, for: .normal)
          navigationItem.titleView = customView
        }
      }
    }
  }
  
  @available(iOS 16.0, *)
  private func createItemGroups(from groupsData: [[String: Any]], groupType: String) -> [UIBarButtonItemGroup] {
    return groupsData.enumerated().compactMap { (groupIndex, groupData) in
      guard let buttonsData = groupData["buttons"] as? [[String: Any]] else { return nil }
      let items = createBarButtonItems(from: buttonsData, groupIndex: groupIndex, groupType: groupType)
      return UIBarButtonItemGroup(barButtonItems: items, representativeItem: nil)
    }
  }
  
  private func createBarButtonItems(from buttonsData: [[String: Any]], groupIndex: Int, groupType: String) -> [UIBarButtonItem] {
    return buttonsData.enumerated().compactMap { (buttonIndex, buttonData) in
      guard let title = buttonData["title"] as? String else { return nil }
      
      var item: UIBarButtonItem
      var image: UIImage? = nil
      
      if let symbolName = buttonData["sfSymbol"] as? String, !symbolName.isEmpty {
        image = UIImage(systemName: symbolName)
        
        // Apply symbol styling
        if let size = buttonData["sfSymbolSize"] as? NSNumber {
          let config = UIImage.SymbolConfiguration(pointSize: CGFloat(truncating: size))
          image = image?.applyingSymbolConfiguration(config)
        }
        
        // Determine rendering mode and color
        let perItemColor: UIColor? = {
          if let colorArgb = buttonData["sfSymbolColor"] as? NSNumber { return Self.colorFromARGB(colorArgb.intValue) }
          return nil
        }()
        let renderMode = buttonData["sfSymbolRenderingMode"] as? String
        
        if let mode = renderMode {
          switch mode {
          case "hierarchical":
            if #available(iOS 15.0, *) {
              if let color = perItemColor ?? self.defaultIconColor {
                let cfg = UIImage.SymbolConfiguration(hierarchicalColor: color)
                image = image?.applyingSymbolConfiguration(cfg)
              }
            }
          case "palette":
            if #available(iOS 15.0, *), let paletteColors = buttonData["sfSymbolPaletteColors"] as? [NSNumber] {
              let colors = paletteColors.map { Self.colorFromARGB($0.intValue) }
              let config = UIImage.SymbolConfiguration(paletteColors: colors)
              image = image?.applyingSymbolConfiguration(config)
            }
          case "multicolor":
            if #available(iOS 15.0, *) {
              let config = UIImage.SymbolConfiguration.preferringMulticolor()
              image = image?.applyingSymbolConfiguration(config)
            }
          default:
            break
          }
        } else if let color = perItemColor ?? self.defaultIconColor {
          if #available(iOS 13.0, *) {
            image = image?.withTintColor(color, renderingMode: .alwaysOriginal)
          }
        }
        
        item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(buttonTapped(_:)))
      } else {
        item = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(buttonTapped(_:)))
      }
      
      // Store index information for callback with different ranges for different group types
      let tagOffset = groupType == "leading" ? 0 : (groupType == "center" ? 1000 : 2000)
      item.tag = tagOffset + groupIndex * 100 + buttonIndex
      
      if let enabled = buttonData["enabled"] as? NSNumber {
        item.isEnabled = enabled.boolValue
      }
      
      return item
    }
  }
  
  @objc private func buttonTapped(_ sender: UIBarButtonItem) {
    // Decode tag: offset + groupIndex * 100 + buttonIndex
    var groupType = "leading"
    var groupIndex = 0
    var buttonIndex = 0
    
    if sender.tag >= 2000 {
      groupType = "trailing"
      let adjustedTag = sender.tag - 2000
      groupIndex = adjustedTag / 100
      buttonIndex = adjustedTag % 100
    } else if sender.tag >= 1000 {
      groupType = "center"
      let adjustedTag = sender.tag - 1000
      groupIndex = adjustedTag / 100
      buttonIndex = adjustedTag % 100
    } else {
      groupType = "leading"
      groupIndex = sender.tag / 100
      buttonIndex = sender.tag % 100
    }
    
    channel.invokeMethod("buttonTapped", arguments: [
      "groupType": groupType,
      "groupIndex": groupIndex,
      "buttonIndex": buttonIndex
    ])
  }
  
  private static func colorFromARGB(_ argb: Int) -> UIColor {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return UIColor(red: r, green: g, blue: b, alpha: a)
  }
}

#if DEBUG
  import SwiftUI

  // A dummy class to satisfy the initializer of CupertinoNavigationBarPlatformView
  // which requires a FlutterBinaryMessenger. This won't be used in the preview.
  private class DummyTestMessenger: NSObject, FlutterBinaryMessenger {
    func send(onChannel channel: String, message: Data?) {}
    func send(
      onChannel channel: String, message: Data?, binaryReply reply: FlutterBinaryReply? = nil
    ) {}
    func setMessageHandlerOnChannel(
      _ channel: String, binaryMessageHandler handler: FlutterBinaryMessageHandler? = nil
    ) -> FlutterBinaryMessengerConnection {
      return 0
    }
    func cleanUpConnection(_ connection: FlutterBinaryMessengerConnection) {}
  }

  private struct CupertinoNavigationBarPlatformViewPreview: UIViewRepresentable {
    let args: [String: Any]
    
    func makeUIView(context: Context) -> UIView {
      let messenger = DummyTestMessenger()
      let view = CupertinoNavigationBarPlatformView(
        frame: CGRect(x: 0, y: 0, width: 300, height: 60),
        viewId: 0,
        args: [
          "title": "Demo Bar",
          "height": 60,
          "leadingGroups": [
            [
              "buttons": [
                ["title": "Edit", "sfSymbol": "pencil", "enabled": true],
                ["title": "Add", "sfSymbol": "plus", "enabled": true]
              ]
            ]
          ],
          "centerGroups": [
            [
              "buttons": [
                ["title": "Search", "sfSymbol": "magnifyingglass", "enabled": true],
                ["title": "Filter", "sfSymbol": "line.3.horizontal.decrease.circle", "enabled": true]
              ]
            ]
          ],
          "trailingGroups": [
            [
              "buttons": [
                ["title": "Done", "sfSymbol": "checkmark", "enabled": true]
              ]
            ]
          ]
        ],
        messenger: messenger
      )
      return view.view()
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
  }

  // The Preview provider that shows your button in the Xcode canvas
  @available(iOS 13.0, *)
  struct CupertinoNavigationBarPlatformView_Preview: PreviewProvider {
    static var previews: some View {
      // You can create multiple previews to see different styles
      Group {
          CupertinoNavigationBarPlatformViewPreview(args: [:])
        .previewDisplayName("Button Group")

      }
      .previewLayout(.fixed(width: 250, height: 70))
      .padding()
    }
  }
#endif
