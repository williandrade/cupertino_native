import Flutter
import UIKit

class CupertinoGlassEffectContainerPlatformView: NSObject, FlutterPlatformView {
  private let channel: FlutterMethodChannel
  private let container: UIView
  private let visualEffectView: UIVisualEffectView
  private let contentView: UIView
  private var tintColor: UIColor?
  private var isInteractive: Bool = false
  private var currentGlassStyle: String = "regular" // default
  private var tapGestureRecognizer: UITapGestureRecognizer?

  init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativeGlassEffectContainer_\(viewId)", binaryMessenger: messenger)
    self.container = UIView(frame: frame)
    
    var tint: UIColor? = nil
    var interactive: Bool = false
    var isDark: Bool = false
    var cornerRadius: CGFloat = 0
    var glassStyle: String = "regular"
    
    if let dict = args as? [String: Any] {
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
      if let gs = dict["glassStyle"] as? String {
        glassStyle = gs
      }
    }
    
    // Create the effect
    let visualEffect: UIVisualEffect
    if #available(iOS 26.0, *) {
      let style: UIGlassEffect.Style = glassStyle == "clear" ? .clear : .regular
      let glassEffect = UIGlassEffect(style: style)
      glassEffect.isInteractive = interactive
      
      visualEffect = glassEffect
      self.currentGlassStyle = glassStyle
    } else {
      visualEffect = UIBlurEffect(style: .systemMaterial) // fallback
    }
    self.visualEffectView = UIVisualEffectView(effect: visualEffect)
    
    // Create content view
    self.contentView = UIView()
    self.contentView.backgroundColor = .clear
    
    super.init()
    
    // Store current values
    self.tintColor = tint
    self.isInteractive = interactive
    
    // Set up container
    container.backgroundColor = .clear
    if #available(iOS 13.0, *) {
      container.overrideUserInterfaceStyle = isDark ? .dark : .light
    }
    
    // Set up visual effect view
    visualEffectView.translatesAutoresizingMaskIntoConstraints = false
    visualEffectView.clipsToBounds = true
    visualEffectView.layer.cornerRadius = cornerRadius
    
    // Add tint color if specified
    if let tint = tint {
      contentView.backgroundColor = tint.withAlphaComponent(0.1)
    }
    
    // Build the view hierarchy
    container.addSubview(visualEffectView)
    visualEffectView.contentView.addSubview(contentView)
    
    // Set up content view constraints
    contentView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      contentView.leadingAnchor.constraint(equalTo: visualEffectView.contentView.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: visualEffectView.contentView.trailingAnchor),
      contentView.topAnchor.constraint(equalTo: visualEffectView.contentView.topAnchor),
      contentView.bottomAnchor.constraint(equalTo: visualEffectView.contentView.bottomAnchor),
    ])
    
    // Set up visual effect view constraints
    NSLayoutConstraint.activate([
      visualEffectView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      visualEffectView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      visualEffectView.topAnchor.constraint(equalTo: container.topAnchor),
      visualEffectView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
    ])
    
    // Add interaction if requested
    if interactive {
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
      visualEffectView.addGestureRecognizer(tapGesture)
      self.tapGestureRecognizer = tapGesture
    }
    
    // Set up method channel handlers
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "getIntrinsicSize":
        let size = self.visualEffectView.intrinsicContentSize
        result(["width": Double(size.width), "height": Double(size.height)])
      case "setGlassStyle":
        if let args = call.arguments as? [String: Any] {
          if let glassStyle = args["glassStyle"] as? String {
            self.currentGlassStyle = glassStyle
            if #available(iOS 26.0, *) {
              let style: UIGlassEffect.Style = glassStyle == "clear" ? .clear : .regular
              let glassEffect = UIGlassEffect(style: style)
              glassEffect.isInteractive = self.isInteractive
              self.visualEffectView.effect = glassEffect
            } else {
              self.visualEffectView.effect = UIBlurEffect(style: .systemMaterial)
            }
          }
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing glassStyle", details: nil))
        }
      case "setTint":
        if let args = call.arguments as? [String: Any] {
          if let tintArgb = args["tint"] as? NSNumber {
            let tint = Self.colorFromARGB(tintArgb.intValue)
            self.tintColor = tint
            self.contentView.backgroundColor = tint.withAlphaComponent(0.1)
          } else {
            // Clear tint
            self.tintColor = nil
            self.contentView.backgroundColor = .clear
          }
          result(nil)
        } else if call.arguments == nil {
          // Clear tint when called with null
          self.tintColor = nil
          self.contentView.backgroundColor = .clear
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing tint", details: nil))
        }
      case "setCornerRadius":
        if let args = call.arguments as? [String: Any] {
          if let radiusNumber = args["cornerRadius"] as? NSNumber {
            let radius = CGFloat(truncating: radiusNumber)
            self.visualEffectView.layer.cornerRadius = radius
          }
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing corner radius", details: nil))
        }
      case "setBrightness":
        if let args = call.arguments as? [String: Any], let isDark = (args["isDark"] as? NSNumber)?.boolValue {
          if #available(iOS 13.0, *) {
            self.container.overrideUserInterfaceStyle = isDark ? .dark : .light
          }
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil))
        }
      case "setInteractive":
        if let args = call.arguments as? [String: Any], let interactive = (args["interactive"] as? NSNumber)?.boolValue {
          self.isInteractive = interactive
          // Update gesture recognizer
          if interactive {
            if self.tapGestureRecognizer == nil {
              let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
              self.visualEffectView.addGestureRecognizer(tap)
              self.tapGestureRecognizer = tap
            }
          } else {
            if let tap = self.tapGestureRecognizer {
              self.visualEffectView.removeGestureRecognizer(tap)
              self.tapGestureRecognizer = nil
            }
          }
          // Reapply interactive on the effect
          if #available(iOS 26.0, *) {
            let style: UIGlassEffect.Style = self.currentGlassStyle == "clear" ? .clear : .regular
            let glassEffect = UIGlassEffect(style: style)
            glassEffect.isInteractive = interactive
            self.visualEffectView.effect = glassEffect
          }
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing interactive", details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
  
  func view() -> UIView { container }
  
  @objc private func handleTap() {
    channel.invokeMethod("onTap", arguments: nil)
  }
  
  // MARK: - Helper Methods
  
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

  // A dummy class to satisfy the initializer
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

  private struct CupertinoGlassEffectContainerPlatformViewPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
      let messenger = DummyTestMessenger()
      let view = CupertinoGlassEffectContainerPlatformView(
        frame: CGRect(x: 0, y: 0, width: 200, height: 200),
        viewId: 0,
        args: [
          "glassStyle": "clear",
          "interactive": true,
          "cornerRadius": 16,
        ],
        messenger: messenger
      )
      return view.view()
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
  }

  // The Preview provider that shows your glass effect in the Xcode canvas
  @available(iOS 26.0, *)
  struct CupertinoGlassEffectContainerPlatformView_Preview: PreviewProvider {
    static var previews: some View {
      Group {
        CupertinoGlassEffectContainerPlatformViewPreview()
          .previewDisplayName("Glass Effect Container")
          .background(
            AsyncImage(url: URL(string: "https://images.pexels.com/photos/430207/pexels-photo-430207.jpeg")) { image in
              image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
            } placeholder: {
              Color.gray
            }
          )
      }
      .previewLayout(.fixed(width: 300, height: 200))
      .padding()
    }
  }
#endif
