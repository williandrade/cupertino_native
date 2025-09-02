import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import '../channel/params.dart';

class CNSwitchController {
  MethodChannel? _channel;

  void _attach(MethodChannel channel) {
    _channel = channel;
  }

  void _detach() {
    _channel = null;
  }

  Future<void> setValue(bool value, {bool animated = false}) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.invokeMethod('setValue', {
      'value': value,
      'animated': animated,
    });
  }

  Future<void> setEnabled(bool enabled) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.invokeMethod('setEnabled', {'enabled': enabled});
  }
}

class CNSwitch extends StatefulWidget {
  const CNSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.controller,
    this.height = 44.0,
    this.color,
  });

  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final CNSwitchController? controller;
  final double height;
  final Color? color;

  @override
  State<CNSwitch> createState() => _CNSwitchState();
}

class _CNSwitchState extends State<CNSwitch> {
  MethodChannel? _channel;

  bool? _lastValue;
  bool? _lastEnabled;
  bool? _lastIsDark;
  int? _lastTint;
  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;

  CNSwitchController? _internalController;

  CNSwitchController get _controller =>
      widget.controller ?? (_internalController ??= CNSwitchController());

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    _controller._detach();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CNSwitch oldWidget) {
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
    // Fallback to Flutter Switch on unsupported platforms.
    if (!(defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS)) {
      return SizedBox(
        height: widget.height,
        child: Switch(
          value: widget.value,
          onChanged: widget.enabled ? widget.onChanged : null,
        ),
      );
    }

    const viewType = 'CupertinoNativeSwitch';
    final creationParams = <String, dynamic>{
      'value': widget.value,
      'enabled': widget.enabled,
      'isDark': _isDark,
      'style': encodeStyle(context, tint: widget.color),
    };

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return SizedBox(
        height: widget.height,
        child: UiKitView(
          viewType: viewType,
          creationParamsCodec: const StandardMessageCodec(),
          creationParams: creationParams,
          onPlatformViewCreated: _onPlatformViewCreated,
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<HorizontalDragGestureRecognizer>(
              () => HorizontalDragGestureRecognizer(),
            ),
            Factory<TapGestureRecognizer>(
              () => TapGestureRecognizer(),
            ),
          },
        ),
      );
    }

    // macOS
    return SizedBox(
      height: widget.height,
      child: AppKitView(
        viewType: viewType,
        creationParamsCodec: const StandardMessageCodec(),
        creationParams: creationParams,
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<HorizontalDragGestureRecognizer>(
            () => HorizontalDragGestureRecognizer(),
          ),
          Factory<TapGestureRecognizer>(
            () => TapGestureRecognizer(),
          ),
        },
      ),
    );
  }

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('CupertinoNativeSwitch_$id');
    _channel = channel;
    _controller._attach(channel);
    channel.setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
    _syncBrightnessIfNeeded();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'valueChanged') {
      final args = call.arguments as Map?;
      final value = args?['value'] as bool?;
      if (value != null) {
        widget.onChanged(value);
        _lastValue = value;
      }
    }
    return null;
  }

  void _cacheCurrentProps() {
    _lastValue = widget.value;
    _lastEnabled = widget.enabled;
    _lastIsDark = _isDark;
    _lastTint = resolveColorToArgb(widget.color, context);
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    // Resolve theme-dependent values before awaiting.
    final int? tint = resolveColorToArgb(widget.color, context);

    if (_lastEnabled != widget.enabled) {
      await channel.invokeMethod('setEnabled', {'enabled': widget.enabled});
      _lastEnabled = widget.enabled;
    }

    if (_lastValue != widget.value) {
      await channel.invokeMethod('setValue', {
        'value': widget.value,
        'animated': false,
      });
      _lastValue = widget.value;
    }

    // Style updates (e.g., tint color)
    if (_lastTint != tint && tint != null) {
      await channel.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;
    final isDark = _isDark;
    final int? tint = resolveColorToArgb(widget.color, context);

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
