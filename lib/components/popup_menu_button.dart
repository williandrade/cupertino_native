import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

import '../channel/params.dart';
import '../style/sf_symbol.dart';
import '../style/button_style.dart';

abstract class CNPopupMenuEntry {
  const CNPopupMenuEntry();
}

class CNPopupMenuItem extends CNPopupMenuEntry {
  const CNPopupMenuItem({required this.label, this.icon, this.enabled = true});
  final String label;
  final CNSymbol? icon;
  final bool enabled;
}

class CNPopupMenuDivider extends CNPopupMenuEntry {
  const CNPopupMenuDivider();
}

// Reusable style enum for buttons across widgets (popup menu, future CNButton, ...)

class CNPopupMenuButton extends StatefulWidget {
  const CNPopupMenuButton({
    super.key,
    required this.buttonLabel,
    required this.items,
    required this.onSelected,
    this.tint,
    this.height = 32.0,
    this.shrinkWrap = false,
    this.buttonStyle = CNButtonStyle.automatic,
  }) : buttonIcon = null,
       width = null,
       round = false;

  const CNPopupMenuButton.icon({
    super.key,
    required this.buttonIcon,
    required this.items,
    required this.onSelected,
    this.tint,
    double size = 44.0, // button diameter (width = height)
    this.buttonStyle = CNButtonStyle.glass,
  }) : buttonLabel = null,
       round = true,
       width = size,
       height = size,
       shrinkWrap = false,
       super();

  final String? buttonLabel; // null in icon mode
  final CNSymbol? buttonIcon; // non-null in icon mode
  // Fixed size (width = height) when in icon mode.
  final double? width;
  final bool round; // internal: text=false, icon=true
  final List<CNPopupMenuEntry> items;
  final ValueChanged<int> onSelected;
  final Color? tint;
  final double height;
  final bool shrinkWrap;
  final CNButtonStyle buttonStyle;

  bool get isIconButton => buttonIcon != null;

  @override
  State<CNPopupMenuButton> createState() => _CNPopupMenuButtonState();
}

class _CNPopupMenuButtonState extends State<CNPopupMenuButton> {
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
  void didUpdateWidget(covariant CNPopupMenuButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBrightnessIfNeeded();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!(defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS)) {
      // Fallback Flutter implementation
      return SizedBox(
        height: widget.height,
        width: widget.isIconButton && widget.round
            ? (widget.width ?? widget.height)
            : null,
        child: CupertinoButton(
          padding: widget.isIconButton
              ? const EdgeInsets.all(4)
              : const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          onPressed: () async {
            final selected = await showCupertinoModalPopup<int>(
              context: context,
              builder: (ctx) {
                return CupertinoActionSheet(
                  title: widget.buttonLabel != null
                      ? Text(widget.buttonLabel!)
                      : null,
                  actions: [
                    for (var i = 0; i < widget.items.length; i++)
                      if (widget.items[i] is CNPopupMenuItem)
                        CupertinoActionSheetAction(
                          onPressed: () => Navigator.of(ctx).pop(i),
                          child: Text(
                            (widget.items[i] as CNPopupMenuItem).label,
                          ),
                        )
                      else
                        const SizedBox(height: 8),
                  ],
                  cancelButton: CupertinoActionSheetAction(
                    onPressed: () => Navigator.of(ctx).pop(),
                    isDefaultAction: true,
                    child: const Text('Cancel'),
                  ),
                );
              },
            );
            if (selected != null) widget.onSelected(selected);
          },
          child: widget.isIconButton
              ? Icon(CupertinoIcons.ellipsis, size: widget.buttonIcon?.size)
              : Text(widget.buttonLabel ?? ''),
        ),
      );
    }

    const viewType = 'CupertinoNativePopupMenuButton';

    // Flatten entries into parallel arrays for the platform view.
    final labels = <String>[];
    final symbols = <String>[];
    final isDivider = <bool>[];
    final enabled = <bool>[];
    final sizes = <double?>[];
    final colors = <int?>[];
    for (final e in widget.items) {
      if (e is CNPopupMenuDivider) {
        labels.add('');
        symbols.add('');
        isDivider.add(true);
        enabled.add(false);
        sizes.add(null);
        colors.add(null);
      } else if (e is CNPopupMenuItem) {
        labels.add(e.label);
        symbols.add(e.icon?.name ?? '');
        isDivider.add(false);
        enabled.add(e.enabled);
        sizes.add(e.icon?.size);
        colors.add(resolveColorToArgb(e.icon?.color, context));
      }
    }

    final creationParams = <String, dynamic>{
      if (widget.buttonLabel != null) 'buttonTitle': widget.buttonLabel,
      if (widget.buttonIcon != null) 'buttonIconName': widget.buttonIcon!.name,
      if (widget.buttonIcon?.size != null)
        'buttonIconSize': widget.buttonIcon!.size,
      if (widget.buttonIcon?.color != null)
        'buttonIconColor': resolveColorToArgb(
          widget.buttonIcon!.color,
          context,
        ),
      if (widget.isIconButton) 'round': true,
      'buttonStyle': widget.buttonStyle.name,
      'labels': labels,
      'sfSymbols': symbols,
      'isDivider': isDivider,
      'enabled': enabled,
      'sfSymbolSizes': sizes,
      'sfSymbolColors': colors,
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
        // If shrinkWrap or width is unbounded (e.g. inside a Row), prefer intrinsic width.
        final preferIntrinsic = widget.shrinkWrap || !hasBoundedWidth;
        double? width;
        if (widget.isIconButton) {
          // Fixed circle size for icon buttons
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
          child: SizedBox(
            height: widget.height,
            width: width,
            child: platformView,
          ),
        );
      },
    );
  }

  void _onCreated(int id) {
    final ch = MethodChannel('CupertinoNativePopupMenuButton_$id');
    _channel = ch;
    ch.setMethodCallHandler(_onMethodCall);
    _lastTint = resolveColorToArgb(widget.tint, context);
    _lastIsDark = _isDark;
    _lastTitle = widget.buttonLabel;
    _lastIconName = widget.buttonIcon?.name;
    _lastIconSize = widget.buttonIcon?.size;
    _lastIconColor = resolveColorToArgb(widget.buttonIcon?.color, context);
    _lastStyle = widget.buttonStyle;
    if (!widget.isIconButton) {
      _requestIntrinsicSize();
    }
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'itemSelected') {
      final args = call.arguments as Map?;
      final idx = (args?['index'] as num?)?.toInt();
      if (idx != null) widget.onSelected(idx);
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
    // Capture context-dependent values before any awaits
    final tint = resolveColorToArgb(widget.tint, context);
    final preIconName = widget.buttonIcon?.name;
    final preIconSize = widget.buttonIcon?.size;
    final preIconColor = resolveColorToArgb(widget.buttonIcon?.color, context);
    if (_lastTint != tint && tint != null) {
      await ch.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }
    if (_lastStyle != widget.buttonStyle) {
      await ch.invokeMethod('setStyle', {
        'buttonStyle': widget.buttonStyle.name,
      });
      _lastStyle = widget.buttonStyle;
    }
    if (_lastTitle != widget.buttonLabel && widget.buttonLabel != null) {
      await ch.invokeMethod('setButtonTitle', {'title': widget.buttonLabel});
      _lastTitle = widget.buttonLabel;
      _requestIntrinsicSize();
    }

    if (widget.isIconButton) {
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

    // Update items (labels/icons/dividers)
    final labels = <String>[];
    final symbols = <String>[];
    final isDivider = <bool>[];
    final enabled = <bool>[];
    for (final e in widget.items) {
      if (e is CNPopupMenuDivider) {
        labels.add('');
        symbols.add('');
        isDivider.add(true);
        enabled.add(false);
      } else if (e is CNPopupMenuItem) {
        labels.add(e.label);
        symbols.add(e.icon?.name ?? '');
        isDivider.add(false);
        enabled.add(e.enabled);
      }
    }
    await ch.invokeMethod('setItems', {
      'labels': labels,
      'sfSymbols': symbols,
      'isDivider': isDivider,
      'enabled': enabled,
    });
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
