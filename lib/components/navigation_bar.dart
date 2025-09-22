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
    this.buttonType = ButtonType.plain,
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

  /// Button type (plain or prominent).
  final ButtonType buttonType;

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
      'buttonType': buttonType.name,
      'enabled': enabled,
    };
  }
}

/// Button type for navigation bar buttons.
enum ButtonType {
  /// Plain button style (default).
  plain,

  /// Prominent button style.
  prominent,
}

/// Large title display mode for navigation bar.
enum LargeTitleDisplayMode {
  /// The large title is displayed automatically based on context.
  automatic,

  /// The large title is always displayed.
  always,

  /// The large title is never displayed.
  never,
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
    this.backgroundColor,
    this.height = 44.0,
    this.translucent = true,
    this.largeTitleDisplayMode = LargeTitleDisplayMode.automatic,
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

  /// Background color for the navigation bar.
  final Color? backgroundColor;

  /// Navigation bar height.
  final double height;

  /// Whether the navigation bar is translucent.
  final bool translucent;

  /// How the large title should be displayed.
  final LargeTitleDisplayMode largeTitleDisplayMode;

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
  int? _lastBackgroundColor;
  bool? _lastTranslucent;
  String? _lastLargeTitleDisplayMode;

  // Track widget properties for reactivity
  String? _lastTitle;
  double? _lastHeight;
  List<CNNavigationBarButtonGroup>? _lastLeadingGroups;
  List<CNNavigationBarButtonGroup>? _lastCenterGroups;
  List<CNNavigationBarButtonGroup>? _lastTrailingGroups;

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
      if (widget.backgroundColor != null)
        'backgroundColor': resolveColorToArgb(widget.backgroundColor!, context),
      'translucent': widget.translucent,
      'largeTitleDisplayMode': widget.largeTitleDisplayMode.name,
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
    _lastBackgroundColor = widget.backgroundColor != null
        ? resolveColorToArgb(widget.backgroundColor!, context)
        : null;
    _lastTranslucent = widget.translucent;
    _lastLargeTitleDisplayMode = widget.largeTitleDisplayMode.name;

    // Cache widget properties
    _lastTitle = widget.title;
    _lastHeight = widget.height;
    _lastLeadingGroups = widget.leadingGroups;
    _lastCenterGroups = widget.centerGroups;
    _lastTrailingGroups = widget.trailingGroups;
  }

  // Helper method to resolve current tint color
  int? _resolveCurrentTint() {
    return resolveColorToArgb(
      widget.color ?? CupertinoTheme.of(context).primaryColor,
      context,
    );
  }

  // Helper method to resolve current background color
  int? _resolveCurrentBackgroundColor() {
    return widget.backgroundColor != null
        ? resolveColorToArgb(widget.backgroundColor!, context)
        : null;
  }

  // Helper method to compare button groups
  bool _areButtonGroupsEqual(
    List<CNNavigationBarButtonGroup>? a,
    List<CNNavigationBarButtonGroup>? b,
  ) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i].buttons.length != b[i].buttons.length) return false;
      for (int j = 0; j < a[i].buttons.length; j++) {
        final buttonA = a[i].buttons[j];
        final buttonB = b[i].buttons[j];
        if (buttonA.title != buttonB.title ||
            buttonA.sfSymbol != buttonB.sfSymbol ||
            buttonA.sfSymbolSize != buttonB.sfSymbolSize ||
            buttonA.sfSymbolColor != buttonB.sfSymbolColor ||
            buttonA.sfSymbolPaletteColors?.length !=
                buttonB.sfSymbolPaletteColors?.length ||
            buttonA.sfSymbolRenderingMode != buttonB.sfSymbolRenderingMode ||
            buttonA.buttonType != buttonB.buttonType ||
            buttonA.enabled != buttonB.enabled) {
          return false;
        }
      }
    }
    return true;
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    // Sync title
    if (_lastTitle != widget.title) {
      await channel.invokeMethod('setTitle', {'title': widget.title});
      _lastTitle = widget.title;
    }

    // Sync tint color
    final tint = _resolveCurrentTint();
    if (_lastTint != tint && tint != null) {
      await channel.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }

    // Sync background color
    final backgroundColorValue = _resolveCurrentBackgroundColor();
    if (_lastBackgroundColor != backgroundColorValue) {
      await channel.invokeMethod('setBackgroundColor', {
        'backgroundColor': backgroundColorValue,
      });
      _lastBackgroundColor = backgroundColorValue;
    }

    // Sync translucent state
    if (_lastTranslucent != widget.translucent) {
      await channel.invokeMethod('setTranslucent', {
        'translucent': widget.translucent,
      });
      _lastTranslucent = widget.translucent;
    }

    // Sync large title display mode
    if (_lastLargeTitleDisplayMode != widget.largeTitleDisplayMode.name) {
      await channel.invokeMethod('setLargeTitleDisplayMode', {
        'largeTitleDisplayMode': widget.largeTitleDisplayMode.name,
      });
      _lastLargeTitleDisplayMode = widget.largeTitleDisplayMode.name;
    }

    // Sync height
    if (_lastHeight != widget.height) {
      await channel.invokeMethod('setHeight', {'height': widget.height});
      _lastHeight = widget.height;
    }

    // Sync button groups
    if (!_areButtonGroupsEqual(_lastLeadingGroups, widget.leadingGroups) ||
        !_areButtonGroupsEqual(_lastCenterGroups, widget.centerGroups) ||
        !_areButtonGroupsEqual(_lastTrailingGroups, widget.trailingGroups)) {
      final args = <String, dynamic>{
        'leadingGroups': [],
        'centerGroups': [],
        'trailingGroups': [],
      };
      if (widget.leadingGroups.isNotEmpty) {
        args['leadingGroups'] = widget.leadingGroups
            .map((g) => g.toMap(context))
            .toList();
      }
      if (widget.centerGroups.isNotEmpty) {
        args['centerGroups'] = widget.centerGroups
            .map((g) => g.toMap(context))
            .toList();
      }
      if (widget.trailingGroups.isNotEmpty) {
        args['trailingGroups'] = widget.trailingGroups
            .map((g) => g.toMap(context))
            .toList();
      }
      await channel.invokeMethod('setButtonGroups', args);
      _lastLeadingGroups = widget.leadingGroups;
      _lastCenterGroups = widget.centerGroups;
      _lastTrailingGroups = widget.trailingGroups;
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

  /// Updates the navigation bar title dynamically.
  Future<void> setTitle(String title) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.invokeMethod('setTitle', {'title': title});
  }

  /// Updates the navigation bar button groups dynamically.
  Future<void> setButtonGroups({
    List<CNNavigationBarButtonGroup>? leadingGroups,
    List<CNNavigationBarButtonGroup>? centerGroups,
    List<CNNavigationBarButtonGroup>? trailingGroups,
  }) async {
    final channel = _channel;
    if (channel == null) return;

    final args = <String, dynamic>{};
    if (leadingGroups != null) {
      args['leadingGroups'] = leadingGroups
          .map((g) => g.toMap(context))
          .toList();
    }
    if (centerGroups != null) {
      args['centerGroups'] = centerGroups.map((g) => g.toMap(context)).toList();
    }
    if (trailingGroups != null) {
      args['trailingGroups'] = trailingGroups
          .map((g) => g.toMap(context))
          .toList();
    }

    await channel.invokeMethod('setButtonGroups', args);
  }

  /// Updates the navigation bar background color dynamically.
  Future<void> setBackgroundColor(Color color) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.invokeMethod('setBackgroundColor', {
      'backgroundColor': resolveColorToArgb(color, context),
    });
  }

  /// Updates the navigation bar translucent state dynamically.
  Future<void> setTranslucent(bool translucent) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.invokeMethod('setTranslucent', {'translucent': translucent});
  }

  /// Updates the navigation bar large title display mode dynamically.
  Future<void> setLargeTitleDisplayMode(LargeTitleDisplayMode mode) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.invokeMethod('setLargeTitleDisplayMode', {
      'largeTitleDisplayMode': mode.name,
    });
  }
}
