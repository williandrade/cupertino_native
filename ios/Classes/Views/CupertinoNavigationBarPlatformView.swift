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

  // Cache bar button items for smooth updates
  private var cachedBarButtonItems: [String: UIBarButtonItem] = [:]

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

    if let t = title {
      navigationItem.title = t
    }

    // Add navigation item to bar
    navigationBar.setItems([navigationItem], animated: true)

    container.addSubview(navigationBar)
    NSLayoutConstraint.activate([
      navigationBar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      navigationBar.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      navigationBar.topAnchor.constraint(equalTo: container.topAnchor),
      navigationBar.heightAnchor.constraint(equalToConstant: height),
    ])

    rebuildButtonGroups(animated: false)

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
            self.rebuildButtonGroups(animated: true)
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
              self.rebuildButtonGroups(animated: true)
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

  private func rebuildButtonGroups(animated: Bool = true) {
    let navItem = navigationBar.topItem ?? navigationItem

    var usedKeys: Set<String> = []

    let leadingGroupItems = buildGroupItems(
      from: leadingGroups,
      groupType: "leading",
      usedKeys: &usedKeys
    )
    let centerGroupItems = buildGroupItems(
      from: centerGroups,
      groupType: "center",
      usedKeys: &usedKeys
    )
    let trailingGroupItems = buildGroupItems(
      from: trailingGroups,
      groupType: "trailing",
      usedKeys: &usedKeys
    )

    if #available(iOS 16.0, *) {
      navItem.leadingItemGroups = leadingGroupItems.map {
        UIBarButtonItemGroup(barButtonItems: $0, representativeItem: nil)
      }
      navItem.centerItemGroups = centerGroupItems.map {
        UIBarButtonItemGroup(barButtonItems: $0, representativeItem: nil)
      }
      navItem.trailingItemGroups = trailingGroupItems.map {
        UIBarButtonItemGroup(barButtonItems: $0, representativeItem: nil)
      }
    }

    let flatLeadingItems = leadingGroupItems.flatMap { $0 }
    applyLeftBarButtonItems(flatLeadingItems, to: navItem, animated: animated)

    let flatTrailingItems = trailingGroupItems.flatMap { $0 }
    applyRightBarButtonItems(flatTrailingItems, to: navItem, animated: animated)

    updateCenterTitleView(on: navItem, using: centerGroupItems)

    cleanupCachedBarButtonItems(keeping: usedKeys)

    navigationBar.setNeedsLayout()
    navigationBar.layoutIfNeeded()
  }

  private func buildGroupItems(
    from groupsData: [[String: Any]],
    groupType: String,
    usedKeys: inout Set<String>
  ) -> [[UIBarButtonItem]] {
    return groupsData.enumerated().compactMap { (groupIndex, groupData) in
      guard let buttons = groupData["buttons"] as? [[String: Any]] else { return nil }

      let items = buttons.enumerated().compactMap { (buttonIndex, buttonData) -> UIBarButtonItem? in
        makeBarButtonItem(
          groupType: groupType,
          groupIndex: groupIndex,
          buttonIndex: buttonIndex,
          buttonData: buttonData,
          usedKeys: &usedKeys
        )
      }

      return items.isEmpty ? nil : items
    }
  }

  private func makeBarButtonItem(
    groupType: String,
    groupIndex: Int,
    buttonIndex: Int,
    buttonData: [String: Any],
    usedKeys: inout Set<String>
  ) -> UIBarButtonItem? {
    guard let title = buttonData["title"] as? String else { return nil }

    let key = barButtonItemKey(
      from: buttonData,
      groupType: groupType,
      groupIndex: groupIndex,
      buttonIndex: buttonIndex
    )

    usedKeys.insert(key)

    let item: UIBarButtonItem
    if let cached = cachedBarButtonItems[key] {
      item = cached
    } else {
      item = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(buttonTapped(_:)))
      cachedBarButtonItems[key] = item
    }

    configureBarButtonItem(
      item,
      with: buttonData,
      title: title,
      groupType: groupType,
      groupIndex: groupIndex,
      buttonIndex: buttonIndex
    )

    return item
  }

  private func barButtonItemKey(
    from buttonData: [String: Any],
    groupType: String,
    groupIndex: Int,
    buttonIndex: Int
  ) -> String {
    if let identifier = buttonData["identifier"] as? String, !identifier.isEmpty {
      return "\(groupType)::\(identifier)"
    }
    return "\(groupType)#\(groupIndex)#\(buttonIndex)"
  }

  private func configureBarButtonItem(
    _ item: UIBarButtonItem,
    with buttonData: [String: Any],
    title: String,
    groupType: String,
    groupIndex: Int,
    buttonIndex: Int
  ) {
    item.target = self
    item.action = #selector(buttonTapped(_:))
    var shouldImageFollowTint = true;

    if #available(iOS 26.0, *) {
      item.style = resolveButtonStyle(from: buttonData)
      shouldImageFollowTint = item.style != .prominent
    } else if let buttonType = buttonData["buttonType"] as? String, buttonType == "done" {
      item.style = .done
    } else if let buttonType = buttonData["buttonType"] as? String, buttonType == "plain" {
      item.style = .plain
    } else {
      item.style = .plain
    }

    item.tag = tagOffsetFor(groupType: groupType, groupIndex: groupIndex, buttonIndex: buttonIndex)

    if let identifier = buttonData["identifier"] as? String, !identifier.isEmpty {
      item.accessibilityIdentifier = identifier
    } else {
      item.accessibilityIdentifier = nil
    }

    item.title = title

    let resolvedTint: UIColor? = {
      if let colorValue = buttonData["sfSymbolColor"] as? NSNumber {
        return Self.colorFromARGB(colorValue.intValue)
      }
      return defaultIconColor ?? navigationBar.tintColor
    }()

    item.tintColor = resolvedTint

    
    var image: UIImage? = nil
    if (shouldImageFollowTint) {
      image = makeSymbolImage(from: buttonData, fallbackTint: resolvedTint)
    } else {
      image = makeSymbolImage(from: buttonData, fallbackTint: nil)
    }

    item.image = image
    if image == nil {
      item.title = title
    }

    if let enabled = buttonData["enabled"] as? NSNumber {
      item.isEnabled = enabled.boolValue
    } else {
      item.isEnabled = true
    }

    if #available(iOS 16.0, *) {
      if let hiddenValue = buttonData["hidden"] as? NSNumber {
        item.isHidden = hiddenValue.boolValue
      } else {
        item.isHidden = false
      }
    }
  }

  private func resolveButtonStyle(from buttonData: [String: Any]) -> UIBarButtonItem.Style {
    if let buttonType = buttonData["buttonType"] as? String {
      if #available(iOS 26.0, *), buttonType == "prominent" {
        return .prominent
      }
    }
    return .plain
  }

  private func makeSymbolImage(from buttonData: [String: Any], fallbackTint: UIColor?) -> UIImage? {
    guard let symbolName = buttonData["sfSymbol"] as? String, !symbolName.isEmpty else {
      return nil
    }

    var image = UIImage(systemName: symbolName)

    if let size = buttonData["sfSymbolSize"] as? NSNumber {
      let config = UIImage.SymbolConfiguration(pointSize: CGFloat(truncating: size))
      image = image?.applyingSymbolConfiguration(config)
    }

    if let renderMode = buttonData["sfSymbolRenderingMode"] as? String {
      switch renderMode {
      case "hierarchical":
        if #available(iOS 15.0, *) {
          if let color = fallbackTint ?? defaultIconColor ?? navigationBar.tintColor {
            let config = UIImage.SymbolConfiguration(hierarchicalColor: color)
            image = image?.applyingSymbolConfiguration(config)
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
    } else if let tint = fallbackTint ?? defaultIconColor ?? navigationBar.tintColor {
      if #available(iOS 13.0, *) {
        image = image?.withTintColor(tint, renderingMode: .alwaysOriginal)
      }
    }

    return image
  }

  private func tagOffsetForGroupType(_ groupType: String) -> Int {
    switch groupType {
    case "center":
      return 1000
    case "trailing":
      return 2000
    default:
      return 0
    }
  }

  private func tagOffsetFor(
    groupType: String,
    groupIndex: Int,
    buttonIndex: Int
  ) -> Int {
    return tagOffsetForGroupType(groupType) + groupIndex * 100 + buttonIndex
  }

  private func applyRightBarButtonItems(
    _ items: [UIBarButtonItem],
    to navItem: UINavigationItem,
    animated: Bool
  ) {
    let currentItems = navItem.rightBarButtonItems ?? []
    let newItems = items

    let itemsChanged = currentItems.count != newItems.count
      || zip(currentItems, newItems).contains(where: { $0.0 !== $0.1 })

    guard itemsChanged else { return }

    if animated {
      navItem.setRightBarButtonItems(nil, animated: true)
      navItem.setRightBarButtonItems(newItems, animated: true)
    } else {
      navItem.setRightBarButtonItems(newItems.isEmpty ? nil : newItems, animated: false)
    }
  }

  private func applyLeftBarButtonItems(
    _ items: [UIBarButtonItem],
    to navItem: UINavigationItem,
    animated: Bool
  ) {
    let currentItems = navItem.leftBarButtonItems ?? []
    let newItems = items

    let itemsChanged = currentItems.count != newItems.count
      || zip(currentItems, newItems).contains(where: { $0.0 !== $0.1 })

    guard itemsChanged else { return }

    navItem.setLeftBarButtonItems(newItems.isEmpty ? nil : newItems, animated: animated)
  }

  private func updateCenterTitleView(
    on navItem: UINavigationItem,
    using centerGroupItems: [[UIBarButtonItem]]
  ) {
    if centerGroupItems.count == 1, let firstItem = centerGroupItems.first?.first {
      let displayButton = UIButton(type: .system)
      displayButton.setTitle(firstItem.title, for: .normal)
      displayButton.setImage(firstItem.image, for: .normal)
      displayButton.tintColor = firstItem.tintColor
      displayButton.isUserInteractionEnabled = false
      navItem.titleView = displayButton
    } else {
      navItem.titleView = nil
    }
  }

  private func cleanupCachedBarButtonItems(keeping usedKeys: Set<String>) {
    cachedBarButtonItems = cachedBarButtonItems.filter { usedKeys.contains($0.key) }
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
          "translucent": true,
        ])
        .background(Color(.red))
        .previewDisplayName("Basic")

        // Navigation bar with buttons
        CupertinoNavigationBarPlatformViewPreview(args: [
          "title": "With Buttons",
          "height": 50,
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
          "style": ["tint": 0xFF30_D158],
          "translucent": true,
          //          "backgroundColor": 0xFF30_D158,
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
