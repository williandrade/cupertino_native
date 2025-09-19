import FlutterMacOS
import Cocoa

class CupertinoGlassEffectContainerViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }

  func create(withViewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
    return CupertinoGlassEffectContainerNSView(viewId: viewId, args: args, messenger: messenger)
  }
}
