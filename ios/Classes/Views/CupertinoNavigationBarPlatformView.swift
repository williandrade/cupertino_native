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

  // Added: default icon color from theme/style
  private var defaultIconColor: UIColor? = nil
  private var backgroundColor: UIColor? = nil
  private var isTranslucent: Bool = true
  private var preferredLargeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode = .automatic

  init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(
      name: "CupertinoNativeNavigationBar_\(viewId)", binaryMessenger: messenger)
    self.container = UIView(frame: frame)
    self.navigationBar = UINavigationBar()
    self.navigationItem = UINavigationItem()

    var isDark: Bool = false
    var tint: UIColor? = nil
    var title: String? = nil
    var height: CGFloat = 44.0
    var backgroundColor: UIColor? = nil
    var translucent: Bool = true
    var largeTitleDisplayMode: String = "automatic"

    if let dict = args as? [String: Any] {
      if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
      if let style = dict["style"] as? [String: Any], let n = style["tint"] as? NSNumber {
        tint = Self.colorFromARGB(n.intValue)
      }
      if let t = dict["title"] as? String { title = t }
      if let h = dict["height"] as? NSNumber { height = CGFloat(truncating: h) }
      if let bg = dict["backgroundColor"] as? NSNumber {
        backgroundColor = Self.colorFromARGB(bg.intValue)
      }
      if let t = dict["translucent"] as? NSNumber { translucent = t.boolValue }
      if let mode = dict["largeTitleDisplayMode"] as? String {
        largeTitleDisplayMode = mode
      }
      if let leading = dict["leadingGroups"] as? [[String: Any]] { self.leadingGroups = leading }
      if let center = dict["centerGroups"] as? [[String: Any]] { self.centerGroups = center }
      if let trailing = dict["trailingGroups"] as? [[String: Any]] {
        self.trailingGroups = trailing
      }
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
    if let bg = backgroundColor {
      navigationBar.barTintColor = bg
      self.backgroundColor = bg
    }
    navigationBar.isTranslucent = translucent
    self.isTranslucent = translucent

    // Configure appearance for iOS 13+
    if #available(iOS 13.0, *) {
      configureAppearance()
    }

    // Set large title display mode
    navigationItem.largeTitleDisplayMode = parseLargeTitleDisplayMode(largeTitleDisplayMode)

    if let t = title { navigationItem.title = t }

    // Add navigation item to bar
    navigationBar.setItems([navigationItem], animated: true)

    container.addSubview(navigationBar)
    NSLayoutConstraint.activate([
      navigationBar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      navigationBar.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      navigationBar.topAnchor.constraint(equalTo: container.topAnchor),
      navigationBar.heightAnchor.constraint(equalToConstant: height),
    ])

    rebuildButtonGroups()

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(nil)
        return
      }
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
        } else {
          result(FlutterError(code: "bad_args", message: "Missing title", details: nil))
        }
      case "setButtonGroups":
        if let args = call.arguments as? [String: Any] {
          DispatchQueue.main.async {
            if let leading = args["leadingGroups"] as? [[String: Any]] {
              self.leadingGroups = leading
            }
            if let center = args["centerGroups"] as? [[String: Any]] { self.centerGroups = center }
            if let trailing = args["trailingGroups"] as? [[String: Any]] {
              self.trailingGroups = trailing
            }
            self.rebuildButtonGroups()
            result(nil)
          }
        } else {
          result(FlutterError(code: "bad_args", message: "Missing button groups", details: nil))
        }
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
        } else {
          result(FlutterError(code: "bad_args", message: "Missing style", details: nil))
        }
      case "setBrightness":
        if let args = call.arguments as? [String: Any],
          let isDark = (args["isDark"] as? NSNumber)?.boolValue
        {
          DispatchQueue.main.async {
            if #available(iOS 13.0, *) {
              self.container.overrideUserInterfaceStyle = isDark ? .dark : .light
            }
            result(nil)
          }
        } else {
          result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil))
        }
      case "setBackgroundColor":
        if let args = call.arguments as? [String: Any],
          let colorValue = args["backgroundColor"] as? NSNumber
        {
          DispatchQueue.main.async {
            let color = Self.colorFromARGB(colorValue.intValue)
            self.navigationBar.barTintColor = color
            self.backgroundColor = color
            if #available(iOS 13.0, *) {
              self.configureAppearance()
            }
            result(nil)
          }
        } else {
          result(FlutterError(code: "bad_args", message: "Missing backgroundColor", details: nil))
        }
      case "setTranslucent":
        if let args = call.arguments as? [String: Any],
          let translucent = (args["translucent"] as? NSNumber)?.boolValue
        {
          DispatchQueue.main.async {
            self.navigationBar.isTranslucent = translucent
            self.isTranslucent = translucent
            result(nil)
          }
        } else {
          result(FlutterError(code: "bad_args", message: "Missing translucent", details: nil))
        }
      case "setLargeTitleDisplayMode":
        if let args = call.arguments as? [String: Any],
          let mode = args["largeTitleDisplayMode"] as? String
        {
          DispatchQueue.main.async {
            self.navigationItem.largeTitleDisplayMode = self.parseLargeTitleDisplayMode(mode)
            result(nil)
          }
        } else {
          result(
            FlutterError(code: "bad_args", message: "Missing largeTitleDisplayMode", details: nil))
        }
      case "setHeight":
        if let args = call.arguments as? [String: Any],
          let height = (args["height"] as? NSNumber)?.doubleValue
        {
          DispatchQueue.main.async {
            // Update the height constraint
            if let heightConstraint = self.container.constraints.first(where: {
              $0.firstAttribute == .height && $0.firstItem === self.navigationBar
            }) {
              heightConstraint.constant = CGFloat(height)
            }
            result(nil)
          }
        } else {
          result(FlutterError(code: "bad_args", message: "Missing height", details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func view() -> UIView { container }

  private func rebuildButtonGroups() {
    if #available(iOS 16.0, *) {
      // Use modern item groups API with smart updates
      navigationItem.leadingItemGroups = updateItemGroups(
        current: navigationItem.leadingItemGroups, 
        new: leadingGroups, 
        groupType: "leading"
      )
      navigationItem.centerItemGroups = updateItemGroups(
        current: navigationItem.centerItemGroups, 
        new: centerGroups, 
        groupType: "center"
      )
      navigationItem.trailingItemGroups = updateItemGroups(
        current: navigationItem.trailingItemGroups, 
        new: trailingGroups, 
        groupType: "trailing"
      )
    } else {
      // Fallback for older iOS versions with smart updates
      let newLeftItems = createNewBarButtonItems(from: leadingGroups, groupType: "leading")
      let newRightItems = createNewBarButtonItems(from: trailingGroups, groupType: "trailing")
      
      // Smart update for left items
      let updatedLeftItems = updateBarButtonItems(
        current: navigationItem.leftBarButtonItems ?? [], 
        new: newLeftItems
      )
      
      // Smart update for right items  
      let updatedRightItems = updateBarButtonItems(
        current: navigationItem.rightBarButtonItems ?? [], 
        new: newRightItems
      )

      navigationItem.setLeftBarButtonItems(updatedLeftItems.isEmpty ? nil : updatedLeftItems, animated: true)
      navigationItem.setRightBarButtonItems(updatedRightItems.isEmpty ? nil : updatedRightItems, animated: true)

      // Center groups fallback - use title view if there's only one center item
      updateCenterTitleView()
    }
  }
  
  private func createNewBarButtonItems(from groupsData: [[String: Any]], groupType: String) -> [UIBarButtonItem] {
    var items: [UIBarButtonItem] = []
    for (groupIndex, group) in groupsData.enumerated() {
      if let buttons = group["buttons"] as? [[String: Any]] {
        items.append(
          contentsOf: createBarButtonItems(
            from: buttons, groupIndex: groupIndex, groupType: groupType))
      }
    }
    return items
  }
  
  private func updateCenterTitleView() {
    if centerGroups.count == 1, let buttons = centerGroups[0]["buttons"] as? [[String: Any]],
      buttons.count == 1
    {
      let button = createBarButtonItems(from: buttons, groupIndex: 0, groupType: "center").first
      if let btn = button {
        let customView = UIButton(type: .system)
        customView.setTitle(btn.title, for: .normal)
        customView.setImage(btn.image, for: .normal)
        navigationItem.titleView = customView
      }
    } else {
      navigationItem.titleView = nil
    }
  }
  
  private func updateBarButtonItems(current: [UIBarButtonItem], new: [UIBarButtonItem]) -> [UIBarButtonItem] {
    // If new array is empty, return empty (clear all)
    if new.isEmpty {
      return []
    }
    
    // If current array is empty, return all new items
    if current.isEmpty {
      return new
    }
    
    var result: [UIBarButtonItem] = []
    
    // Compare items and reuse existing ones where possible
    for (index, newItem) in new.enumerated() {
      if index < current.count {
        let currentItem = current[index]
        
        // Check if we can reuse the existing item by updating its properties
        if canReuseBarButtonItem(current: currentItem, new: newItem) {
          updateBarButtonItem(current: currentItem, with: newItem)
          result.append(currentItem)
        } else {
          // Need to replace with new item
          result.append(newItem)
        }
      } else {
        // Adding new item beyond current array length
        result.append(newItem)
      }
    }
    
    return result
  }
  
  private func canReuseBarButtonItem(current: UIBarButtonItem, new: UIBarButtonItem) -> Bool {
    // We can reuse if the basic structure is the same (both have title or both have image)
    let currentHasTitle = current.title != nil && !current.title!.isEmpty
    let newHasTitle = new.title != nil && !new.title!.isEmpty
    let currentHasImage = current.image != nil
    let newHasImage = new.image != nil
    
    // Both should have the same type (title vs image)
    return (currentHasTitle == newHasTitle) && (currentHasImage == newHasImage)
  }
  
  private func updateBarButtonItem(current: UIBarButtonItem, with new: UIBarButtonItem) {
    // Update properties that can be changed without recreating the item
    current.title = new.title
    current.image = new.image
    current.isEnabled = new.isEnabled
    current.tag = new.tag
    current.target = new.target
    current.action = new.action
    current.style = new.style
  }

  @available(iOS 16.0, *)
  private func updateItemGroups(
    current: [UIBarButtonItemGroup], 
    new newGroupsData: [[String: Any]], 
    groupType: String
  ) -> [UIBarButtonItemGroup] {
    // If new data is empty, return empty array (clear all)
    if newGroupsData.isEmpty {
      return []
    }
    
    // If current is empty, create all new groups
    if current.isEmpty {
      return createItemGroups(from: newGroupsData, groupType: groupType)
    }
    
    var result: [UIBarButtonItemGroup] = []
    
    // Compare groups and reuse where possible
    for (index, groupData) in newGroupsData.enumerated() {
      guard let buttonsData = groupData["buttons"] as? [[String: Any]] else { continue }
      
      if index < current.count {
        let currentGroup = current[index]
        let newItems = createBarButtonItems(from: buttonsData, groupIndex: index, groupType: groupType)
        
        // Try to update existing group's items
        let updatedItems = updateBarButtonItems(current: currentGroup.barButtonItems, new: newItems)
        
        // Create new group with updated items, but try to preserve the representative item if possible
        let updatedGroup = UIBarButtonItemGroup(
          barButtonItems: updatedItems, 
          representativeItem: currentGroup.representativeItem
        )
        result.append(updatedGroup)
      } else {
        // Adding new group beyond current array length
        let newItems = createBarButtonItems(from: buttonsData, groupIndex: index, groupType: groupType)
        let newGroup = UIBarButtonItemGroup(barButtonItems: newItems, representativeItem: nil)
        result.append(newGroup)
      }
    }
    
    return result
  }

  @available(iOS 16.0, *)
  private func createItemGroups(from groupsData: [[String: Any]], groupType: String)
    -> [UIBarButtonItemGroup]
  {
    return groupsData.enumerated().compactMap { (groupIndex, groupData) in
      guard let buttonsData = groupData["buttons"] as? [[String: Any]] else { return nil }
      let items = createBarButtonItems(
        from: buttonsData, groupIndex: groupIndex, groupType: groupType)
      return UIBarButtonItemGroup(barButtonItems: items, representativeItem: nil)
    }
  }

  private func createBarButtonItems(
    from buttonsData: [[String: Any]], groupIndex: Int, groupType: String
  ) -> [UIBarButtonItem] {
    return buttonsData.enumerated().compactMap { (buttonIndex, buttonData) in
      guard let title = buttonData["title"] as? String else { return nil }

      var image: UIImage? = nil
      let tagOffset = groupType == "leading" ? 0 : (groupType == "center" ? 1000 : 2000)

      if let symbolName = buttonData["sfSymbol"] as? String, !symbolName.isEmpty {
        image = UIImage(systemName: symbolName)

        // Apply symbol styling
        if let size = buttonData["sfSymbolSize"] as? NSNumber {
          let config = UIImage.SymbolConfiguration(pointSize: CGFloat(truncating: size))
          image = image?.applyingSymbolConfiguration(config)
        }

        // Determine rendering mode and color
        let perItemColor: UIColor? = {
          if let colorArgb = buttonData["sfSymbolColor"] as? NSNumber {
            return Self.colorFromARGB(colorArgb.intValue)
          }
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
            if #available(iOS 15.0, *),
              let paletteColors = buttonData["sfSymbolPaletteColors"] as? [NSNumber]
            {
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
      }

      // Determine button style based on parameter
      let buttonStyle: UIBarButtonItem.Style = {
        if let buttonType = buttonData["buttonType"] as? String {
          if #available(iOS 26.0, *) {
            if buttonType == "prominent" {
              return .prominent
            }
          }
        }
        return .plain  // Default to plain
      }()

      var item: UIBarButtonItem
      if let image = image {
        item = UIBarButtonItem(
          image: image, style: buttonStyle, target: self, action: #selector(buttonTapped(_:)))
      } else {
        item = UIBarButtonItem(
          title: title, style: buttonStyle, target: self, action: #selector(buttonTapped(_:)))
      }

      // Store index information for callback with different ranges for different group types
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

    channel.invokeMethod(
      "buttonTapped",
      arguments: [
        "groupType": groupType,
        "groupIndex": groupIndex,
        "buttonIndex": buttonIndex,
      ])
  }

  private func parseLargeTitleDisplayMode(_ mode: String) -> UINavigationItem.LargeTitleDisplayMode
  {
    switch mode {
    case "automatic":
      return .automatic
    case "always":
      return .always
    case "never":
      return .never
    default:
      return .automatic
    }
  }

  @available(iOS 13.0, *)
  private func configureAppearance() {
    let appearance = UINavigationBarAppearance()

    // Configure background
    if let bgColor = backgroundColor {
      if #available(iOS 26.0, *) {
        appearance.backgroundEffect = UIBlurEffect(style: .systemMaterial)
      } else {
        appearance.backgroundColor = bgColor
      }
    }

    // Configure tint
    if let tintColor = navigationBar.tintColor {
      appearance.titleTextAttributes = [.foregroundColor: tintColor]
      appearance.largeTitleTextAttributes = [.foregroundColor: tintColor]
      appearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: tintColor]
    }

    // Apply appearance
    navigationBar.standardAppearance = appearance
    if #available(iOS 15.0, *) {
      navigationBar.scrollEdgeAppearance = appearance
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
      let navigationBarView = CupertinoNavigationBarPlatformView(
        frame: CGRect(x: 0, y: 0, width: 320, height: 100),
        viewId: 0,
        args: args,
        messenger: DummyTestMessenger()
      )

      return navigationBarView.view()
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
  }

  // The Preview provider that shows your button in the Xcode canvas
  @available(iOS 13.0, *)
  struct CupertinoNavigationBarPlatformView_Preview: PreviewProvider {
    static var previews: some View {
      // You can create multiple previews to see different styles
      Group {
        // Basic navigation bar with title only
        CupertinoNavigationBarPlatformViewPreview(args: [
          "title": "Basic Navigation",
          "height": 44,
          "interactive": true,
        ])
        .previewDisplayName("Basic")

        // Navigation bar with buttons
        CupertinoNavigationBarPlatformViewPreview(args: [
          "title": "With Buttons",
          "height": 50,
          "interactive": true,
          //          "style": ["tint": 0xFF00_7AFF],
          "leadingGroups": [
            [
              "buttons": [
                [
                  "title": "Back",
                  "enabled": true,
                  "sfSymbol": "chevron.left",
                ]
              ]
            ]
          ],
          "trailingGroups": [
            [
              "buttons": [
                [
                  "title": "Action",
                  "enabled": true,
                  "sfSymbol": "ellipsis",
                ]
              ]
            ]
          ],
        ])
        .previewDisplayName("With Buttons")

        // Disabled navigation bar
        CupertinoNavigationBarPlatformViewPreview(args: [
          "title": "Disabled",
          "height": 44,
          "interactive": false,
          "leadingGroups": [
            [
              "buttons": [
                [
                  "title": "Back",
                  "enabled": false,
                  "sfSymbol": "chevron.left",
                  "sfSymbolSize": 16,
                ]
              ]
            ]
          ],
          "trailingGroups": [
            [
              "buttons": [
                [
                  "title": "Action",
                  "enabled": false,
                  "sfSymbol": "ellipsis",
                  "sfSymbolSize": 16,
                ]
              ]
            ]
          ],
        ])
        .previewDisplayName("Disabled")

        // Dark mode navigation bar
        CupertinoNavigationBarPlatformViewPreview(args: [
          "isDark": true,
          "title": "Dark Mode",
          "height": 60,
          "interactive": true,
          "style": ["tint": 0xFFFF_9500],
          "leadingGroups": [
            [
              "buttons": [
                [
                  "title": "Cancel",
                  "enabled": true,
                  "sfSymbol": "xmark",
                  "sfSymbolSize": 18,
                  "sfSymbolColor": 0xFFFF_3B30,
                  "sfSymbolRenderingMode": "hierarchical",
                ]
              ]
            ]
          ],
          "trailingGroups": [
            [
              "buttons": [
                [
                  "title": "Action",
                  "enabled": true,
                  "sfSymbol": "ellipsis",
                  "sfSymbolSize": 16,
                ]
              ]
            ]
          ],
        ])
        .previewDisplayName("Dark Mode")

        // Complex navigation bar with multiple groups
        CupertinoNavigationBarPlatformViewPreview(args: [
          "title": "Complex Layout",
          "height": 70,
          "interactive": true,
          "style": ["tint": 0xFF58_56D6],
          "leadingGroups": [
            [
              "buttons": [
                [
                  "title": "Menu",
                  "enabled": true,
                  "sfSymbol": "line.horizontal.3",
                ]
                //                [
                //                    "title": "Back",
                //                    "enabled": true,
                //                    "sfSymbol": "chevron.left",
                //                ],
              ]
            ]
          ],
          "centerGroups": [
            [
              "buttons": [
                [
                  "title": "Center",
                  "enabled": true,
                  "sfSymbol": "star.fill",
                ]
              ]
            ]
          ],
          "trailingGroups": [
            [
              "buttons": [
                [
                  "title": "Share",
                  "enabled": true,
                  "sfSymbol": "square.and.arrow.up",
                ]
              ]
            ]
          ],
        ])
        .previewDisplayName("Complex Layout")

        // iOS 26 Glass Effect Navigation Bar
        if #available(iOS 26.0, *) {
          CupertinoNavigationBarPlatformViewPreview(args: [
            "title": "iOS 26 Glass",
            "height": 50,
            "interactive": true,
            "style": ["tint": 0xFF00_7AFF],
            "backgroundColor": 0x8000_7AFF,  // Semi-transparent blue
            "largeTitleDisplayMode": "always",
            "leadingGroups": [
              [
                "buttons": [
                  [
                    "title": "Back",
                    "enabled": true,
                    "sfSymbol": "chevron.left",
                    "sfSymbolSize": 16,
                  ]
                ]
              ]
            ],
            "trailingGroups": [
              [
                "buttons": [
                  [
                    "title": "Action",
                    "enabled": true,
                    "sfSymbol": "ellipsis",
                    "sfSymbolSize": 16,
                  ]
                ]
              ]
            ],
          ])
          .previewDisplayName("iOS 26 Glass")
        }

        // Prominent Style Buttons
        CupertinoNavigationBarPlatformViewPreview(args: [
          "title": "Prominent Buttons",
          "height": 44,
          "interactive": true,
          "style": ["tint": 0xFFFF_9500],
          "leadingGroups": [
            [
              "buttons": [
                [
                  "title": "Edit",
                  "enabled": true,
                  "sfSymbol": "pencil",
                  "sfSymbolSize": 18,
                ]
              ]
            ]
          ],
          "centerGroups": [
            [
              "buttons": [
                [
                  "title": "Center",
                  "enabled": true,
                  "sfSymbol": "star.fill",
                  "sfSymbolColor": 0xFF58_56D6,
                  "sfSymbolRenderingMode": "hierarchical",
                ]
              ]
            ]
          ],
          "trailingGroups": [
            [
              "buttons": [
                [
                  "title": "Save",
                  "enabled": true,
                  "sfSymbol": "square.and.arrow.down",
                  "sfSymbolSize": 18,
                ]
              ]
            ]
          ],
        ])
        .previewDisplayName("Prominent Buttons")

        // Large Title Navigation Bar
        CupertinoNavigationBarPlatformViewPreview(args: [
          "title": "Large Title Example",
          "height": 96,
          "interactive": true,
          "style": ["tint": 0xFF30_D158],
          "backgroundColor": 0xFF30_D158,
          "largeTitleDisplayMode": "always",
          "leadingGroups": [
            [
              "buttons": [
                [
                  "title": "",
                  "enabled": true,
                  "sfSymbol": "person.circle",
                  "sfSymbolSize": 20,
                ]
              ]
            ]
          ],
          "trailingGroups": [
            [
              "buttons": [
                [
                  "title": "Settings",
                  "enabled": true,
                  "sfSymbol": "gear",
                  "sfSymbolSize": 16,
                ]
              ]
            ]
          ],
        ])
        .previewDisplayName("Large Title")

      }
      .previewLayout(.fixed(width: 320, height: 100))
      .padding()
    }
  }
#endif
