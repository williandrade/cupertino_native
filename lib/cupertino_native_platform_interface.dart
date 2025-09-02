import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'cupertino_native_method_channel.dart';

abstract class CupertinoNativePlatform extends PlatformInterface {
  /// Constructs a CupertinoNativePlatform.
  CupertinoNativePlatform() : super(token: _token);

  static final Object _token = Object();

  static CupertinoNativePlatform _instance = MethodChannelCupertinoNative();

  /// The default instance of [CupertinoNativePlatform] to use.
  ///
  /// Defaults to [MethodChannelCupertinoNative].
  static CupertinoNativePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CupertinoNativePlatform] when
  /// they register themselves.
  static set instance(CupertinoNativePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
