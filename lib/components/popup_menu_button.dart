import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../channel/params.dart';
import '../style/sf_symbol.dart';

abstract class CNPopupMenuEntry {
  const CNPopupMenuEntry();
}

class CNPopupMenuItem extends CNPopupMenuEntry {
  const CNPopupMenuItem({
    required this.label,
    this.icon,
    this.enabled = true,
  });
  final String label;
  final CNSymbol? icon;
  final bool enabled;
}

class CNPopupMenuDivider extends CNPopupMenuEntry {
  const CNPopupMenuDivider();
}

class CNPopupMenuButton extends StatefulWidget {
  const CNPopupMenuButton({
    super.key,
    required this.buttonLabel,
    required this.items,
    required this.onSelected,
    this.tint,
    this.height = 32.0,
    this.shrinkWrap = false,
  });

  final String buttonLabel;
  final List<CNPopupMenuEntry> items;
  final ValueChanged<int> onSelected;
  final Color? tint;
  final double height;
  final bool shrinkWrap;

  @override
  State<CNPopupMenuButton> createState() => _CNPopupMenuButtonState();
}

class _CNPopupMenuButtonState extends State<CNPopupMenuButton> {
  MethodChannel? _channel;
  bool? _lastIsDark;
  int? _lastTint;
  String? _lastTitle;
  double? _intrinsicWidth;

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBrightnessIfNeeded();
  }

  @override
  void didUpdateWidget(covariant CNPopupMenuButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
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
      return SizedBox(
        height: widget.height,
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          onPressed: () async {
            final selected = await showCupertinoModalPopup<int>(
              context: context,
              builder: (ctx) {
                return CupertinoActionSheet(
                  title: Text(widget.buttonLabel),
                  actions: [
                    for (var i = 0; i < widget.items.length; i++)
                      if (widget.items[i] is CNPopupMenuItem)
                        CupertinoActionSheetAction(
                          onPressed: () => Navigator.of(ctx).pop(i),
                          child: Text((widget.items[i] as CNPopupMenuItem).label),
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
          child: Text(widget.buttonLabel),
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
      'buttonTitle': widget.buttonLabel,
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
          )
        : AppKitView(
            viewType: viewType,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onCreated,
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedWidth = constraints.hasBoundedWidth;
        // If shrinkWrap or width is unbounded (e.g. inside a Row), prefer intrinsic width.
        final preferIntrinsic = widget.shrinkWrap || !hasBoundedWidth;
        final width = preferIntrinsic ? (_intrinsicWidth ?? 80.0) : null;
        return SizedBox(height: widget.height, width: width, child: platformView);
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
    _requestIntrinsicSize();
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
    final tint = resolveColorToArgb(widget.tint, context);
    if (_lastTint != tint && tint != null) {
      await ch.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }
    if (_lastTitle != widget.buttonLabel) {
      await ch.invokeMethod('setButtonTitle', {'title': widget.buttonLabel});
      _lastTitle = widget.buttonLabel;
      _requestIntrinsicSize();
    }

    // Update items (labels/icons/dividers)
    final labels = <String>[];
    final symbols = <String>[];
    final isDivider = <bool>[];
    final enabled = <bool>[];
    for (final e in widget.items) {
      if (e is CNPopupMenuDivider) {
        labels.add(''); symbols.add(''); isDivider.add(true); enabled.add(false);
      } else if (e is CNPopupMenuItem) {
        labels.add(e.label); symbols.add(e.icon?.name ?? ''); isDivider.add(false); enabled.add(e.enabled);
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
}
