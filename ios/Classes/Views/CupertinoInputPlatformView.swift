import Flutter
import UIKit

class CupertinoInputPlatformView: NSObject, FlutterPlatformView, UITextFieldDelegate {
  private let channel: FlutterMethodChannel
  private let container: UIView
  private let textField: UITextField
  private var isEnabled: Bool = true
  private var currentBorderStyle: UITextField.BorderStyle = .roundedRect
  
  init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(
      name: "CupertinoNativeInput_\(viewId)", binaryMessenger: messenger)
    self.container = UIView(frame: frame)
    self.textField = UITextField()
    
    var placeholder: String? = nil
    var text: String? = nil
    var borderStyle: String = "roundedRect"
    var fontSize: CGFloat = 17.0
    var textColor: UIColor? = nil
    var backgroundColor: UIColor? = nil
    var isSecure: Bool = false
    var keyboardType: String = "default"
    var returnKeyType: String = "default"
    var autocorrectionType: String = "default"
    var textContentType: String? = nil
    var isDark: Bool = false
    var enabled: Bool = true
    var clearButtonMode: String = "never"
    
    if let dict = args as? [String: Any] {
      if let p = dict["placeholder"] as? String { placeholder = p }
      if let t = dict["text"] as? String { text = t }
      if let bs = dict["borderStyle"] as? String { borderStyle = bs }
      if let fs = dict["fontSize"] as? NSNumber { fontSize = CGFloat(truncating: fs) }
      if let tc = dict["textColor"] as? NSNumber { textColor = Self.colorFromARGB(tc.intValue) }
      if let bg = dict["backgroundColor"] as? NSNumber { backgroundColor = Self.colorFromARGB(bg.intValue) }
      if let secure = dict["isSecure"] as? NSNumber { isSecure = secure.boolValue }
      if let kt = dict["keyboardType"] as? String { keyboardType = kt }
      if let rt = dict["returnKeyType"] as? String { returnKeyType = rt }
      if let ac = dict["autocorrectionType"] as? String { autocorrectionType = ac }
      if let tct = dict["textContentType"] as? String { textContentType = tct }
      if let dark = dict["isDark"] as? NSNumber { isDark = dark.boolValue }
      if let e = dict["enabled"] as? NSNumber { enabled = e.boolValue }
      if let cbm = dict["clearButtonMode"] as? String { clearButtonMode = cbm }
    }
    
    super.init()
    
    container.backgroundColor = .clear
    if #available(iOS 13.0, *) {
      container.overrideUserInterfaceStyle = isDark ? .dark : .light
    }
    
    // Configure text field
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.placeholder = placeholder
    textField.text = text
    textField.font = UIFont.systemFont(ofSize: fontSize)
    textField.isSecureTextEntry = isSecure
    textField.isEnabled = enabled
    textField.delegate = self
    
    // Apply border style
    switch borderStyle {
    case "none":
      textField.borderStyle = .none
    case "line":
      textField.borderStyle = .line
    case "bezel":
      textField.borderStyle = .bezel
    case "roundedRect":
      textField.borderStyle = .roundedRect
    default:
      textField.borderStyle = .roundedRect
    }
    currentBorderStyle = textField.borderStyle
    
    // Apply colors
    if let tc = textColor {
      textField.textColor = tc
    } else if #available(iOS 13.0, *) {
      textField.textColor = .label
    }
    
    if let bg = backgroundColor {
      textField.backgroundColor = bg
    } else if #available(iOS 13.0, *) {
      textField.backgroundColor = .systemBackground
    }
    
    // Configure keyboard
    textField.keyboardType = Self.keyboardTypeFromString(keyboardType)
    textField.returnKeyType = Self.returnKeyTypeFromString(returnKeyType)
    textField.autocorrectionType = Self.autocorrectionTypeFromString(autocorrectionType)
    textField.clearButtonMode = Self.clearButtonModeFromString(clearButtonMode)
    
    // Set text content type if available
    if #available(iOS 10.0, *), let tct = textContentType {
      textField.textContentType = Self.textContentTypeFromString(tct)
    }
    
    self.isEnabled = enabled
    
    container.addSubview(textField)
    NSLayoutConstraint.activate([
      textField.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      textField.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      textField.topAnchor.constraint(equalTo: container.topAnchor),
      textField.bottomAnchor.constraint(equalTo: container.bottomAnchor),
    ])
    
    // Add target for text changes
    textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(nil)
        return
      }
      switch call.method {
      case "setText":
        if let args = call.arguments as? [String: Any], let text = args["text"] as? String {
          self.textField.text = text
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing text", details: nil))
        }
      case "getText":
        result(self.textField.text ?? "")
      case "setPlaceholder":
        if let args = call.arguments as? [String: Any], let placeholder = args["placeholder"] as? String {
          self.textField.placeholder = placeholder
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
          self.textField.becomeFirstResponder()
        }
        result(nil)
      case "unfocus":
        DispatchQueue.main.async {
          self.textField.resignFirstResponder()
        }
        result(nil)
      case "setBorderStyle":
        if let args = call.arguments as? [String: Any], let style = args["borderStyle"] as? String {
          switch style {
          case "none":
            self.textField.borderStyle = .none
          case "line":
            self.textField.borderStyle = .line
          case "bezel":
            self.textField.borderStyle = .bezel
          case "roundedRect":
            self.textField.borderStyle = .roundedRect
          default:
            self.textField.borderStyle = .roundedRect
          }
          self.currentBorderStyle = self.textField.borderStyle
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing borderStyle", details: nil))
        }
      case "setSecure":
        if let args = call.arguments as? [String: Any], let secure = args["isSecure"] as? NSNumber {
          self.textField.isSecureTextEntry = secure.boolValue
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing isSecure", details: nil))
        }
      case "setBrightness":
        if let args = call.arguments as? [String: Any],
          let isDark = (args["isDark"] as? NSNumber)?.boolValue
        {
          if #available(iOS 13.0, *) {
            self.container.overrideUserInterfaceStyle = isDark ? .dark : .light
          }
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
  
  func view() -> UIView { container }
  
  @objc private func textFieldDidChange() {
    guard isEnabled else { return }
    channel.invokeMethod("textChanged", arguments: ["text": textField.text ?? ""])
  }
  
  // MARK: - UITextFieldDelegate
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    channel.invokeMethod("focusChanged", arguments: ["focused": true])
    return isEnabled
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    channel.invokeMethod("focusChanged", arguments: ["focused": false])
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    channel.invokeMethod("submitted", arguments: ["text": textField.text ?? ""])
    return true
  }
  
  // MARK: - Helper Methods
  
  private static func colorFromARGB(_ argb: Int) -> UIColor {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return UIColor(red: r, green: g, blue: b, alpha: a)
  }
  
  private static func keyboardTypeFromString(_ type: String) -> UIKeyboardType {
    switch type {
    case "default": return .default
    case "asciiCapable": return .asciiCapable
    case "numbersAndPunctuation": return .numbersAndPunctuation
    case "URL": return .URL
    case "numberPad": return .numberPad
    case "phonePad": return .phonePad
    case "namePhonePad": return .namePhonePad
    case "emailAddress": return .emailAddress
    case "decimalPad": return .decimalPad
    case "twitter": return .twitter
    case "webSearch": return .webSearch
    default: return .default
    }
  }
  
  private static func returnKeyTypeFromString(_ type: String) -> UIReturnKeyType {
    switch type {
    case "default": return .default
    case "go": return .go
    case "google": return .google
    case "join": return .join
    case "next": return .next
    case "route": return .route
    case "search": return .search
    case "send": return .send
    case "yahoo": return .yahoo
    case "done": return .done
    case "emergencyCall": return .emergencyCall
    case "continue": return .continue
    default: return .default
    }
  }
  
  private static func autocorrectionTypeFromString(_ type: String) -> UITextAutocorrectionType {
    switch type {
    case "default": return .default
    case "no": return .no
    case "yes": return .yes
    default: return .default
    }
  }
  
  private static func clearButtonModeFromString(_ mode: String) -> UITextField.ViewMode {
    switch mode {
    case "never": return .never
    case "whileEditing": return .whileEditing
    case "unlessEditing": return .unlessEditing
    case "always": return .always
    default: return .never
    }
  }
  
  @available(iOS 10.0, *)
  private static func textContentTypeFromString(_ type: String) -> UITextContentType? {
    switch type {
    case "name": return .name
    case "namePrefix": return .namePrefix
    case "givenName": return .givenName
    case "middleName": return .middleName
    case "familyName": return .familyName
    case "nameSuffix": return .nameSuffix
    case "nickname": return .nickname
    case "jobTitle": return .jobTitle
    case "organizationName": return .organizationName
    case "location": return .location
    case "fullStreetAddress": return .fullStreetAddress
    case "streetAddressLine1": return .streetAddressLine1
    case "streetAddressLine2": return .streetAddressLine2
    case "addressCity": return .addressCity
    case "addressState": return .addressState
    case "addressCityAndState": return .addressCityAndState
    case "sublocality": return .sublocality
    case "countryName": return .countryName
    case "postalCode": return .postalCode
    case "telephoneNumber": return .telephoneNumber
    case "emailAddress": return .emailAddress
    case "URL": return .URL
    case "creditCardNumber": return .creditCardNumber
    case "username": return .username
    case "password": return .password
    default: return nil
    }
  }
}


#if DEBUG
  import SwiftUI

  // A dummy class to satisfy the initializer of CupertinoInputPlatformView
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

  private struct CupertinoInputPlatformView_Preview: UIViewRepresentable {
    let args: [String: Any]
    
    func makeUIView(context: Context) -> UIView {
      let containerView = UIView()
      containerView.backgroundColor = .systemBackground

      let cupertinoInputPlatformView = CupertinoInputPlatformView(
        frame: CGRect(x: 0, y: 0, width: 300, height: 44),
        viewId: 0,
        args: args,
        messenger: DummyBinaryMessenger()
      ).view()
      
      // Create a container that represents an input field
      let inputContainer = UIView()
      inputContainer.backgroundColor = .systemBackground

      inputContainer.addSubview(cupertinoInputPlatformView)
      containerView.addSubview(inputContainer)
      
      // Set up constraints
      inputContainer.translatesAutoresizingMaskIntoConstraints = false
      cupertinoInputPlatformView.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        inputContainer.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
        inputContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
        inputContainer.widthAnchor.constraint(equalToConstant: 300),
        inputContainer.heightAnchor.constraint(equalToConstant: 44),
        
        cupertinoInputPlatformView.topAnchor.constraint(equalTo: inputContainer.topAnchor),
        cupertinoInputPlatformView.bottomAnchor.constraint(equalTo: inputContainer.bottomAnchor),
        cupertinoInputPlatformView.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor),
        cupertinoInputPlatformView.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor),
      ])
      
      return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
  }

  // The Preview provider that shows your input field in the Xcode canvas
  @available(iOS 13.0, *)
  struct CupertinoInputPreview: PreviewProvider {
    static var previews: some View {
      // You can create multiple previews to see different styles
      Group {
        CupertinoInputPlatformView_Preview(args: [
          "placeholder": "Enter your name",
          "borderStyle": "roundedRect",
          "fontSize": 17,
        ])
        .previewDisplayName("Default Input")

        CupertinoInputPlatformView_Preview(args: [
          "placeholder": "Search...",
          "borderStyle": "roundedRect",
          "keyboardType": "webSearch",
          "returnKeyType": "search",
          "clearButtonMode": "whileEditing",
        ])
        .previewDisplayName("Search Input")

        CupertinoInputPlatformView_Preview(args: [
          "placeholder": "Enter password",
          "borderStyle": "roundedRect",
          "isSecure": true,
          "textContentType": "password",
        ])
        .previewDisplayName("Password Input")

        CupertinoInputPlatformView_Preview(args: [
          "placeholder": "Email address",
          "borderStyle": "line",
          "keyboardType": "emailAddress",
          "textContentType": "emailAddress",
          "autocorrectionType": "no",
        ])
        .previewDisplayName("Email Input")

        CupertinoInputPlatformView_Preview(args: [
          "text": "Disabled input field",
          "enabled": false,
          "borderStyle": "bezel",
        ])
        .previewDisplayName("Disabled Input")

        CupertinoInputPlatformView_Preview(args: [
          "placeholder": "No border input",
          "borderStyle": "none",
          "fontSize": 18,
        ])
        .previewDisplayName("No Border Input")
      }
      .previewLayout(.fixed(width: 350, height: 80))
      .padding()
    }
  }
#endif
