export 'cupertino_native_platform_interface.dart';
export 'cupertino_native_method_channel.dart';
export 'cupertino_native_slider.dart';

import 'cupertino_native_platform_interface.dart';

class CupertinoNative {
  Future<String?> getPlatformVersion() {
    return CupertinoNativePlatform.instance.getPlatformVersion();
  }
}
