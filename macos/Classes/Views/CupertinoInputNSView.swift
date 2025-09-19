import FlutterMacOS
import Cocoa

class CupertinoInputNSView: NSView, NSTextFieldDelegate {
  private let channel: FlutterMethodChannel
  private let textField: NSTextField
  private var isEnabled: Bool = true
  private var currentBorderStyle: String = "roundedRect"
  
  init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativeInput_\(viewId)", binaryMessenger: messenger)
    self.textField = NSTextField()
    super.init(frame: .zero)
    
    var placeholder: String? = nil
    var text: String? = nil
    var borderStyle: String = "roundedRect"
    var fontSize: CGFloat = 17.0
    var textColor: NSColor? = nil
    var backgroundColor: NSColor? = nil
    var isSecure: Bool = false
    var isDark: Bool = false
    var enabled: Bool = true
    
    if let dict = args as? [String: Any] {
      if let p = dict["placeholder"] as? String { placeholder = p }
      if let t = dict["text"] as? String { text = t }
      if let bs = dict["borderStyle"] as? String { borderStyle = bs }
      if let fs = dict["fontSize"] as? NSNumber { fontSize = CGFloat(truncating: fs) }
      if let tc = dict["textColor"] as? NSNumber { textColor = Self.colorFromARGB(tc.intValue) }
      if let bg = dict["backgroundColor"] as? NSNumber { backgroundColor = Self.colorFromARGB(bg.intValue) }
      if let secure = dict["isSecure"] as? NSNumber { isSecure = secure.boolValue }
      if let dark = dict["isDark"] as? NSNumber { isDark = dark.boolValue }
      if let e = dict["enabled"] as? NSNumber { enabled = e.boolValue }
    }
    
    wantsLayer = true
    layer?.backgroundColor = NSColor.clear.cgColor
    appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
    
    // Configure text field
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.placeholderString = placeholder
    textField.stringValue = text ?? ""
    textField.font = NSFont.systemFont(ofSize: fontSize)
    textField.isEnabled = enabled
    textField.delegate = self
    
    // Convert to secure field if needed
    if isSecure {
      // Create a secure text field
      let secureField = NSSecureTextField()
      secureField.translatesAutoresizingMaskIntoConstraints = false
      secureField.placeholderString = placeholder
      secureField.stringValue = text ?? ""
      secureField.font = NSFont.systemFont(ofSize: fontSize)
      secureField.isEnabled = enabled
      secureField.delegate = self
      
      // Replace the text field with secure field
      removeFromSuperview()
      addSubview(secureField)
      // Note: We'd need to refactor to handle this properly
    }
    
    // Apply border style
    switch borderStyle {
    case "none":
      textField.isBezeled = false
      textField.isBordered = false
    case "line":
      textField.isBezeled = false
      textField.isBordered = true
    case "bezel":
      textField.isBezeled = true
      textField.bezelStyle = .roundedBezel
    case "roundedRect":
      textField.isBezeled = true
      textField.bezelStyle = .roundedBezel
    default:
      textField.isBezeled = true
      textField.bezelStyle = .roundedBezel
    }
    currentBorderStyle = borderStyle
    
    // Apply colors
    if let tc = textColor {
      textField.textColor = tc
    } else {
      textField.textColor = .labelColor
    }
    
    if let bg = backgroundColor {
      textField.backgroundColor = bg
    } else {
      textField.backgroundColor = .textBackgroundColor
    }
    
    self.isEnabled = enabled
    
    addSubview(textField)
    NSLayoutConstraint.activate([
      textField.leadingAnchor.constraint(equalTo: leadingAnchor),
      textField.trailingAnchor.constraint(equalTo: trailingAnchor),
      textField.topAnchor.constraint(equalTo: topAnchor),
      textField.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
    
    // Set up target for text changes
    textField.target = self
    textField.action = #selector(textFieldChanged)
    
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(nil)
        return
      }
      switch call.method {
      case "setText":
        if let args = call.arguments as? [String: Any], let text = args["text"] as? String {
          self.textField.stringValue = text
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing text", details: nil))
        }
      case "getText":
        result(self.textField.stringValue)
      case "setPlaceholder":
        if let args = call.arguments as? [String: Any], let placeholder = args["placeholder"] as? String {
          self.textField.placeholderString = placeholder
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing placeholder", details: nil))
        }
      case "setEnabled":
        if let args = call.arguments as? [String: Any], let enabled = args["enabled"] as? NSNumber {
          self.isEnabled = enabled.boolValue
          self.textField.isEnabled = self.isEnabled
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing enabled", details: nil))
        }
      case "focus":
        DispatchQueue.main.async {
          self.window?.makeFirstResponder(self.textField)
        }
        result(nil)
      case "unfocus":
        DispatchQueue.main.async {
          self.window?.makeFirstResponder(nil)
        }
        result(nil)
      case "setBorderStyle":
        if let args = call.arguments as? [String: Any], let style = args["borderStyle"] as? String {
          switch style {
          case "none":
            self.textField.isBezeled = false
            self.textField.isBordered = false
          case "line":
            self.textField.isBezeled = false
            self.textField.isBordered = true
          case "bezel":
            self.textField.isBezeled = true
            self.textField.bezelStyle = .roundedBezel
          case "roundedRect":
            self.textField.isBezeled = true
            self.textField.bezelStyle = .roundedBezel
          default:
            self.textField.isBezeled = true
            self.textField.bezelStyle = .roundedBezel
          }
          self.currentBorderStyle = style
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing borderStyle", details: nil))
        }
      case "setBrightness":
        if let args = call.arguments as? [String: Any],
          let isDark = (args["isDark"] as? NSNumber)?.boolValue
        {
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
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc private func textFieldChanged() {
    guard isEnabled else { return }
    channel.invokeMethod("textChanged", arguments: ["text": textField.stringValue])
  }
  
  // MARK: - NSTextFieldDelegate
  
  func controlTextDidBeginEditing(_ obj: Notification) {
    channel.invokeMethod("focusChanged", arguments: ["focused": true])
  }
  
  func controlTextDidEndEditing(_ obj: Notification) {
    channel.invokeMethod("focusChanged", arguments: ["focused": false])
    // Handle submit on Enter key
    if let textField = obj.object as? NSTextField {
      channel.invokeMethod("submitted", arguments: ["text": textField.stringValue])
    }
  }
  
  // MARK: - Helper Methods
  
  private static func colorFromARGB(_ argb: Int) -> NSColor {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return NSColor(red: r, green: g, blue: b, alpha: a)
  }
}


#if DEBUG
  import SwiftUI

  // A dummy class to satisfy the initializer of CupertinoInputNSView
  // which requires a FlutterBinaryMessenger. This won't be used in the preview.
  private class DummyBinaryMessenger: NSObject, FlutterBinaryMessenger {
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

  @available(macOS 10.15, *)
  private struct CupertinoInputNSView_Preview: NSViewRepresentable {
    let args: [String: Any]
    
    func makeNSView(context: Context) -> NSView {
      let containerView = NSView()
      containerView.wantsLayer = true
      containerView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor

      let cupertinoInputNSView = CupertinoInputNSView(
        viewId: 0,
        args: args,
        messenger: DummyBinaryMessenger()
      )
      
      containerView.addSubview(cupertinoInputNSView)
      
      // Set up constraints
      cupertinoInputNSView.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        cupertinoInputNSView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
        cupertinoInputNSView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
        cupertinoInputNSView.widthAnchor.constraint(equalToConstant: 300),
        cupertinoInputNSView.heightAnchor.constraint(equalToConstant: 24),
      ])
      
      return containerView
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
  }

  // The Preview provider that shows your input field in the Xcode canvas
  @available(macOS 10.15, *)
  struct CupertinoInputNSPreview: PreviewProvider {
    static var previews: some View {
      // You can create multiple previews to see different styles
      Group {
        CupertinoInputNSView_Preview(args: [
          "placeholder": "Enter your name",
          "borderStyle": "roundedRect",
          "fontSize": 14,
        ])
        .previewDisplayName("Default Input")

        CupertinoInputNSView_Preview(args: [
          "placeholder": "Search...",
          "borderStyle": "roundedRect",
        ])
        .previewDisplayName("Search Input")

        CupertinoInputNSView_Preview(args: [
          "placeholder": "Enter password",
          "borderStyle": "roundedRect",
          "isSecure": true,
        ])
        .previewDisplayName("Password Input")

        CupertinoInputNSView_Preview(args: [
          "text": "Disabled input field",
          "enabled": false,
          "borderStyle": "bezel",
        ])
        .previewDisplayName("Disabled Input")

        CupertinoInputNSView_Preview(args: [
          "placeholder": "No border input",
          "borderStyle": "none",
          "fontSize": 16,
        ])
        .previewDisplayName("No Border Input")
      }
      .frame(width: 350, height: 50)
      .padding()
    }
  }
#endif
