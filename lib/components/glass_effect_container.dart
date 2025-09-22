import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// Enum for glass effect styles.
enum CNGlassStyle {
  /// Regular glass style.
  regular,

  /// Clear glass style.
  clear,
}

/// A Cupertino-native glass effect container.
///
/// Provides native glass morphing effects using UIVisualEffectView on iOS
/// and NSVisualEffectView on macOS. On iOS 16+, can use the modern UIGlassEffect
/// for enhanced liquid glass appearance.
///
///
/// Example:
/// ```dart
/// CNGlassEffectContainer(
///   glassStyle: CNGlassStyle.regular,
///   tint: CupertinoColors.systemBlue,
///   cornerRadius: 16,
///   interactive: false,
///   onTap: () {},
///   width: 200,
///   height: 100,
///   child: Container(), // Your Flutter content
/// )
/// ```
class CNGlassEffectContainer extends StatelessWidget {
  /// Creates a Cupertino-native glass effect container.
  const CNGlassEffectContainer({
    super.key,
    required this.child,
    this.glassStyle = CNGlassStyle.regular,
    this.tint,
    this.cornerRadius = 0.0,
    this.interactive = false,
    this.onTap,
    this.width = double.infinity,
    this.height = double.infinity,
  });

  /// The child widget.
  final Widget child;

  /// The glass style.
  final CNGlassStyle glassStyle;

  /// Optional tint color. Must comply with ARGB format.
  final Color? tint;

  /// Corner radius.
  final double cornerRadius;

  /// If interactive.
  final bool interactive;

  /// Tap callback.
  final VoidCallback? onTap;

  /// Width.
  final double width;

  /// Height.
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CNGlassEffectContainerInternal(
            glassStyle: glassStyle,
            tint: tint,
            cornerRadius: cornerRadius,
            interactive: interactive,
            onTap: onTap,
            width: double.infinity,
            height: double.infinity,
            child: Container(), // Empty container
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

/// A simplified Cupertino-native glass effect container focused on UIGlassEffect.
///
/// Provides native glass morphing effects using UIVisualEffectView on iOS
/// and NSVisualEffectView on macOS. On iOS 16+, can use the modern UIGlassEffect
/// for enhanced liquid glass appearance.
///
/// **Important**: Due to platform view limitations, you cannot directly place
/// Flutter widgets inside this container. Instead, use a Stack to overlay
/// Flutter content on top of the glass effect:
///
/// ```dart
/// Stack(
///   children: [
///     CNGlassEffectContainerInternal(
///       effect: CNGlassEffect.systemMaterial,
///       useGlassEffect: true, // Enable modern glass effect (iOS 16+)
///       width: 200,
///       height: 100,
///       child: Container(), // Empty container
///     ),
///     Positioned.fill(
///       child: YourFlutterContent(),
///     ),
///   ],
/// )
/// ```
class CNGlassEffectContainerInternal extends StatefulWidget {
  /// Creates a glass effect container.
  const CNGlassEffectContainerInternal({
    super.key,
    required this.child,
    this.glassStyle = CNGlassStyle.regular,
    this.tint,
    this.cornerRadius = 0.0,
    this.interactive = false,
    this.onTap,
    this.width,
    this.height,
  });

  /// The child widget (typically empty).
  final Widget child;

  /// The glass style.
  final CNGlassStyle glassStyle;

  /// Optional tint color.
  final Color? tint;

  /// Corner radius.
  final double cornerRadius;

  /// If interactive.
  final bool interactive;

  /// Tap callback.
  final VoidCallback? onTap;

  /// Width.
  final double? width;

  /// Height.
  final double? height;

  @override
  State<CNGlassEffectContainerInternal> createState() =>
      _CNGlassEffectContainerState();
}

class _CNGlassEffectContainerState
    extends State<CNGlassEffectContainerInternal> {
  MethodChannel? _channel;

  CNGlassStyle? _lastGlassStyle;
  Color? _lastTint;
  double? _lastCornerRadius;
  bool? _lastIsDark;

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CNGlassEffectContainerInternal oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBrightnessIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    if (!(defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS)) {
      // Fallback for unsupported platforms
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color:
              _applyOpacity(widget.tint, 0.1) ??
              _applyOpacity(
                CupertinoColors.systemBackground.resolveFrom(context),
                0.8,
              ),
          borderRadius: BorderRadius.circular(widget.cornerRadius),
        ),
        child: widget.interactive
            ? GestureDetector(onTap: widget.onTap, child: widget.child)
            : widget.child,
      );
    }

    const viewType = 'CupertinoNativeGlassEffectContainer';
    final creationParams = <String, dynamic>{
      'isDark': _isDark,
      'cornerRadius': widget.cornerRadius,
      'interactive': widget.interactive,
      if (widget.tint != null) 'tint': _colorToArgb(widget.tint!),
      if (defaultTargetPlatform == TargetPlatform.iOS)
        'glassStyle': widget.glassStyle.name,
      // For macOS, use defaults
      if (defaultTargetPlatform == TargetPlatform.macOS) ...{
        'material': 'sidebar', // default
        'blending': 'behindWindow', // default
      },
    };

    Widget platformView;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      platformView = UiKitView(
        viewType: viewType,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else {
      platformView = AppKitView(
        viewType: viewType,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }

    Widget finalView = ClipRRect(
      borderRadius: BorderRadius.circular(widget.cornerRadius),
      child: platformView,
    );

    if (widget.width != null || widget.height != null) {
      finalView = SizedBox(
        width: widget.width,
        height: widget.height,
        child: finalView,
      );
    }

    return finalView;
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('CupertinoNativeGlassEffectContainer_$id');
    _channel!.setMethodCallHandler(_handleMethodCall);
    _cacheCurrentProps();
    _syncBrightnessIfNeeded();
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onTap') {
      widget.onTap?.call();
    }
    return null;
  }

  void _cacheCurrentProps() {
    _lastGlassStyle = widget.glassStyle;
    _lastTint = widget.tint;
    _lastCornerRadius = widget.cornerRadius;
    _lastIsDark = _isDark;
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    if (_channel == null || !mounted) return;

    if (_lastGlassStyle != widget.glassStyle &&
        defaultTargetPlatform == TargetPlatform.iOS) {
      await _channel!.invokeMethod('setGlassStyle', {
        'glassStyle': widget.glassStyle.name,
      });
      _lastGlassStyle = widget.glassStyle;
    }

    if (_lastTint != widget.tint) {
      if (widget.tint != null) {
        await _channel!.invokeMethod('setTint', {
          'tint': _colorToArgb(widget.tint!),
        });
      } else {
        // Handle clearing tint if needed
        await _channel!.invokeMethod('setTint', null);
      }
      _lastTint = widget.tint;
    }

    if (_lastCornerRadius != widget.cornerRadius) {
      await _channel!.invokeMethod('setCornerRadius', {
        'cornerRadius': widget.cornerRadius,
      });
      _lastCornerRadius = widget.cornerRadius;
    }
  }

  Future<void> _syncBrightnessIfNeeded() async {
    if (_channel == null) return;
    if (_lastIsDark != _isDark) {
      await _channel!.invokeMethod('setBrightness', {'isDark': _isDark});
      _lastIsDark = _isDark;
    }
  }

  int _colorToArgb(Color color) {
    return color.value;
  }

  Color? _applyOpacity(Color? color, double opacity) {
    if (color == null) return null;
    final alpha = (opacity * 255).round();
    return Color((color.value & 0x00ffffff) | (alpha << 24));
  }
}
