import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../channel/params.dart';
import '../style/sf_symbol.dart';

/// A button group for navigation bar.
class CNNavigationBarButtonGroup {
  /// Creates a navigation bar button group.
  const CNNavigationBarButtonGroup({required this.buttons});

  /// List of buttons in this group.
  final List<CNNavigationBarButton> buttons;

  /// Converts this button group to a map for platform channel communication.
  Map<String, dynamic> toMap(BuildContext context) {
    return {'buttons': buttons.map((button) => button.toMap(context)).toList()};
  }
}

/// A button for navigation bar.
class CNNavigationBarButton {
  /// Creates a navigation bar button.
  const CNNavigationBarButton({
    required this.title,
    this.sfSymbol,
    this.sfSymbolSize,
    this.sfSymbolColor,
    this.sfSymbolPaletteColors,
    this.sfSymbolRenderingMode,
    this.enabled = true,
    this.onPressed,
  });

  /// Button title.
  final String title;

  /// Optional SF Symbol.
  final String? sfSymbol;

  /// SF Symbol size.
  final double? sfSymbolSize;

  /// SF Symbol color.
  final Color? sfSymbolColor;

  /// SF Symbol palette colors.
  final List<Color>? sfSymbolPaletteColors;

  /// SF Symbol rendering mode.
  final CNSymbolRenderingMode? sfSymbolRenderingMode;

  /// Whether the button is enabled.
  final bool enabled;

  /// Callback when button is pressed.
  final VoidCallback? onPressed;

  /// Converts this button to a map for platform channel communication.
  Map<String, dynamic> toMap(BuildContext context) {
    return {
      'title': title,
      if (sfSymbol != null) 'sfSymbol': sfSymbol,
      if (sfSymbolSize != null) 'sfSymbolSize': sfSymbolSize,
      if (sfSymbolColor != null)
        'sfSymbolColor': resolveColorToArgb(sfSymbolColor, context),
      if (sfSymbolPaletteColors != null)
        'sfSymbolPaletteColors': sfSymbolPaletteColors!
            .map((c) => resolveColorToArgb(c, context))
            .toList(),
      if (sfSymbolRenderingMode != null)
        'sfSymbolRenderingMode': sfSymbolRenderingMode!.name,
      'enabled': enabled,
    };
  }
}

/// A Cupertino-native navigation bar.
///
/// Embeds a native UINavigationBar/NSView for pixel-perfect
/// fidelity on iOS and macOS.
class CNNavigationBar extends StatefulWidget {
  /// Creates a Cupertino-native navigation bar.
  const CNNavigationBar({
    super.key,
    this.title,
    this.leadingGroups = const [],
    this.centerGroups = const [],
    this.trailingGroups = const [],
    this.color,
    this.height = 44.0,
    this.onButtonPressed,
  });

  /// Navigation bar title.
  final String? title;

  /// Button groups on the leading side.
  final List<CNNavigationBarButtonGroup> leadingGroups;

  /// Button groups in the center.
  final List<CNNavigationBarButtonGroup> centerGroups;

  /// Button groups on the trailing side.
  final List<CNNavigationBarButtonGroup> trailingGroups;

  /// Tint color for the navigation bar.
  final Color? color;

  /// Navigation bar height.
  final double height;

  /// Called when a button is pressed.
  final void Function(String groupType, int groupIndex, int buttonIndex)?
  onButtonPressed;

  @override
  State<CNNavigationBar> createState() => _CNNavigationBarState();
}

class _CNNavigationBarState extends State<CNNavigationBar> {
  MethodChannel? _channel;

  bool? _lastIsDark;
  int? _lastTint;

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CNNavigationBar oldWidget) {
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
        height: widget.height,
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.separator.resolveFrom(context),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Leading buttons
            for (final group in widget.leadingGroups)
              for (final button in group.buttons)
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  onPressed: button.enabled ? button.onPressed : null,
                  child: Text(button.title),
                ),
            // Title
            Expanded(
              child: Center(
                child: Text(
                  widget.title ?? '',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // Trailing buttons
            for (final group in widget.trailingGroups)
              for (final button in group.buttons)
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  onPressed: button.enabled ? button.onPressed : null,
                  child: Text(button.title),
                ),
          ],
        ),
      );
    }

    const viewType = 'CupertinoNativeNavigationBar';
    final creationParams = <String, dynamic>{
      if (widget.title != null) 'title': widget.title,
      'height': widget.height,
      'isDark': _isDark,
      'style': encodeStyle(
        context,
        tint: widget.color ?? CupertinoTheme.of(context).primaryColor,
      ),
      'leadingGroups': widget.leadingGroups
          .map((g) => g.toMap(context))
          .toList(),
      'centerGroups': widget.centerGroups.map((g) => g.toMap(context)).toList(),
      'trailingGroups': widget.trailingGroups
          .map((g) => g.toMap(context))
          .toList(),
    };

    Widget platformView;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      platformView = UiKitView(
        viewType: viewType,
        creationParamsCodec: const StandardMessageCodec(),
        creationParams: creationParams,
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else {
      platformView = AppKitView(
        viewType: viewType,
        creationParamsCodec: const StandardMessageCodec(),
        creationParams: creationParams,
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }

    return SizedBox(height: widget.height, child: platformView);
  }

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('CupertinoNativeNavigationBar_$id');
    _channel = channel;
    channel.setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
    _syncBrightnessIfNeeded();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'buttonTapped') {
      final args = call.arguments as Map?;
      final groupType = args?['groupType'] as String?;
      final groupIndex = (args?['groupIndex'] as num?)?.toInt();
      final buttonIndex = (args?['buttonIndex'] as num?)?.toInt();

      if (groupType != null && groupIndex != null && buttonIndex != null) {
        widget.onButtonPressed?.call(groupType, groupIndex, buttonIndex);

        // Also call individual button callbacks
        CNNavigationBarButton? button;
        switch (groupType) {
          case 'leading':
            if (groupIndex < widget.leadingGroups.length &&
                buttonIndex < widget.leadingGroups[groupIndex].buttons.length) {
              button = widget.leadingGroups[groupIndex].buttons[buttonIndex];
            }
            break;
          case 'center':
            if (groupIndex < widget.centerGroups.length &&
                buttonIndex < widget.centerGroups[groupIndex].buttons.length) {
              button = widget.centerGroups[groupIndex].buttons[buttonIndex];
            }
            break;
          case 'trailing':
            if (groupIndex < widget.trailingGroups.length &&
                buttonIndex <
                    widget.trailingGroups[groupIndex].buttons.length) {
              button = widget.trailingGroups[groupIndex].buttons[buttonIndex];
            }
            break;
        }
        button?.onPressed?.call();
      }
    }
    return null;
  }

  void _cacheCurrentProps() {
    _lastIsDark = _isDark;
    _lastTint = resolveColorToArgb(
      widget.color ?? CupertinoTheme.of(context).primaryColor,
      context,
    );
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    final tint = resolveColorToArgb(
      widget.color ?? CupertinoTheme.of(context).primaryColor,
      context,
    );

    if (_lastTint != tint && tint != null) {
      await channel.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;
    final isDark = _isDark;
    final tint = resolveColorToArgb(
      widget.color ?? CupertinoTheme.of(context).primaryColor,
      context,
    );
    if (_lastIsDark != isDark) {
      await channel.invokeMethod('setBrightness', {'isDark': isDark});
      _lastIsDark = isDark;
    }
    if (_lastTint != tint && tint != null) {
      await channel.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }
  }
}
