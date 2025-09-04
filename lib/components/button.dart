import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

import '../channel/params.dart';
import '../style/sf_symbol.dart';
import '../style/button_style.dart';

class CNButton extends StatefulWidget {
  const CNButton({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.tint,
    this.height = 32.0,
    this.shrinkWrap = false,
    this.style = CNButtonStyle.automatic,
  })  : icon = null,
        width = null,
        round = false;

  const CNButton.icon({
    super.key,
    required this.icon,
    this.onPressed,
    this.enabled = true,
    this.tint,
    double size = 44.0,
    this.style = CNButtonStyle.glass,
  })  : label = null,
        round = true,
        width = size,
        height = size,
        shrinkWrap = false,
        super();

  final String? label; // null in icon mode
  final CNSymbol? icon; // non-null in icon mode
  final VoidCallback? onPressed;
  final bool enabled;
  final Color? tint;
  final double height;
  final double? width; // fixed when round/icon mode
  final bool shrinkWrap;
  final CNButtonStyle style;
  final bool round;

  bool get isIcon => icon != null;

  @override
  State<CNButton> createState() => _CNButtonState();
}

class _CNButtonState extends State<CNButton> {
  MethodChannel? _channel;
  bool? _lastIsDark;
  int? _lastTint;
  String? _lastTitle;
  String? _lastIconName;
  double? _lastIconSize;
  int? _lastIconColor;
  double? _intrinsicWidth;
  CNButtonStyle? _lastStyle;
  Offset? _downPosition;
  bool _pressed = false;

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CNButton oldWidget) {
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
      // Fallback Flutter implementation
      return SizedBox(
        height: widget.height,
        width: widget.isIcon && widget.round ? (widget.width ?? widget.height) : null,
        child: CupertinoButton(
          padding: widget.isIcon
              ? const EdgeInsets.all(4)
              : const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          onPressed: (widget.enabled && widget.onPressed != null) ? widget.onPressed : null,
          child: widget.isIcon
              ? Icon(CupertinoIcons.ellipsis, size: widget.icon?.size)
              : Text(widget.label ?? ''),
        ),
      );
    }

    const viewType = 'CupertinoNativeButton';

    final creationParams = <String, dynamic>{
      if (widget.label != null) 'buttonTitle': widget.label,
      if (widget.icon != null) 'buttonIconName': widget.icon!.name,
      if (widget.icon?.size != null) 'buttonIconSize': widget.icon!.size,
      if (widget.icon?.color != null)
        'buttonIconColor': resolveColorToArgb(widget.icon!.color, context),
      if (widget.isIcon) 'round': true,
      'buttonStyle': widget.style.name,
      'enabled': (widget.enabled && widget.onPressed != null),
      'isDark': _isDark,
      'style': encodeStyle(context, tint: widget.tint),
    };

    final platformView = defaultTargetPlatform == TargetPlatform.iOS
        ? UiKitView(
            viewType: viewType,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onCreated,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              // Forward taps to native; let Flutter keep drags for scrolling.
              Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
            },
          )
        : AppKitView(
            viewType: viewType,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onCreated,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
            },
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedWidth = constraints.hasBoundedWidth;
        final preferIntrinsic = widget.shrinkWrap || !hasBoundedWidth;
        double? width;
        if (widget.isIcon) {
          width = widget.width ?? widget.height;
        } else if (preferIntrinsic) {
          width = _intrinsicWidth ?? 80.0;
        }
        return Listener(
          onPointerDown: (e) {
            _downPosition = e.position;
            _setPressed(true);
          },
          onPointerMove: (e) {
            final start = _downPosition;
            if (start != null && _pressed) {
              final moved = (e.position - start).distance;
              if (moved > kTouchSlop) {
                _setPressed(false);
              }
            }
          },
          onPointerUp: (_) {
            _setPressed(false);
            _downPosition = null;
          },
          onPointerCancel: (_) {
            _setPressed(false);
            _downPosition = null;
          },
          child: SizedBox(height: widget.height, width: width, child: platformView),
        );
      },
    );
  }

  void _onCreated(int id) {
    final ch = MethodChannel('CupertinoNativeButton_$id');
    _channel = ch;
    ch.setMethodCallHandler(_onMethodCall);
    _lastTint = resolveColorToArgb(widget.tint, context);
    _lastIsDark = _isDark;
    _lastTitle = widget.label;
    _lastIconName = widget.icon?.name;
    _lastIconSize = widget.icon?.size;
    _lastIconColor = resolveColorToArgb(widget.icon?.color, context);
    _lastStyle = widget.style;
    if (!widget.isIcon) {
      _requestIntrinsicSize();
    }
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'pressed':
        if (widget.enabled && widget.onPressed != null) {
          widget.onPressed!();
        }
        break;
    }
    return null;
  }

  Future<void> _requestIntrinsicSize() async {
    final ch = _channel;
    if (ch == null) return;
    try {
      final size = await ch.invokeMethod<Map>('getIntrinsicSize');
      final w = (size?['width'] as num?)?.toDouble();
      if (w != null && mounted) {
        setState(() => _intrinsicWidth = w);
      }
    } catch (_) {}
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;
    final tint = resolveColorToArgb(widget.tint, context);
    final preIconName = widget.icon?.name;
    final preIconSize = widget.icon?.size;
    final preIconColor = resolveColorToArgb(widget.icon?.color, context);

    if (_lastTint != tint && tint != null) {
      await ch.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }
    if (_lastStyle != widget.style) {
      await ch.invokeMethod('setStyle', {
        'buttonStyle': widget.style.name,
      });
      _lastStyle = widget.style;
    }
    // Enabled state
    await ch.invokeMethod('setEnabled', {
      'enabled': (widget.enabled && widget.onPressed != null),
    });
    if (_lastTitle != widget.label && widget.label != null) {
      await ch.invokeMethod('setButtonTitle', {'title': widget.label});
      _lastTitle = widget.label;
      _requestIntrinsicSize();
    }

    if (widget.isIcon) {
      final iconName = preIconName;
      final iconSize = preIconSize;
      final iconColor = preIconColor;
      final updates = <String, dynamic>{};
      if (_lastIconName != iconName && iconName != null) {
        updates['buttonIconName'] = iconName;
        _lastIconName = iconName;
      }
      if (_lastIconSize != iconSize && iconSize != null) {
        updates['buttonIconSize'] = iconSize;
        _lastIconSize = iconSize;
      }
      if (_lastIconColor != iconColor && iconColor != null) {
        updates['buttonIconColor'] = iconColor;
        _lastIconColor = iconColor;
      }
      if (updates.isNotEmpty) {
        await ch.invokeMethod('setButtonIcon', updates);
      }
    }
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;
    final isDark = _isDark;
    if (_lastIsDark != isDark) {
      await ch.invokeMethod('setBrightness', {'isDark': isDark});
      _lastIsDark = isDark;
    }
  }

  Future<void> _setPressed(bool pressed) async {
    final ch = _channel;
    if (ch == null) return;
    if (_pressed == pressed) return;
    _pressed = pressed;
    try {
      await ch.invokeMethod('setPressed', {'pressed': pressed});
    } catch (_) {}
  }
}
