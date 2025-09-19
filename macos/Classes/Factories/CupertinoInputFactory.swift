import FlutterMacOS
import Cocoa

class CupertinoInputViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }

  func create(withViewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
    return FlutterPlatformViewWrapper(view: CupertinoInputNSView(viewId: viewId, args: args, messenger: messenger))
  }
}

class FlutterPlatformViewWrapper: NSObject, FlutterPlatformView {
  private let _view: NSView
  
  init(view: NSView) {
    _view = view
  }
  
  func view() -> NSView {
    return _view
  }
}
