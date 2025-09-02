import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CNSliderController {
  MethodChannel? _channel;

  void _attach(MethodChannel channel) {
    _channel = channel;
  }

  void _detach() {
    _channel = null;
  }

  Future<void> setValue(double value, {bool animated = false}) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.invokeMethod('setValue', {
      'value': value,
      'animated': animated,
    });
  }

  Future<void> setRange({required double min, required double max}) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.invokeMethod('setRange', {'min': min, 'max': max});
  }

  Future<void> setEnabled(bool enabled) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.invokeMethod('setEnabled', {'enabled': enabled});
  }
}

class CNSlider extends StatefulWidget {
  const CNSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.enabled = true,
    this.controller,
    this.height = 44.0,
  });

  final double value;
  final double min;
  final double max;
  final bool enabled;
  final ValueChanged<double> onChanged;
  final CNSliderController? controller;
  final double height;

  @override
  State<CNSlider> createState() => _CNSliderState();
}

class _CNSliderState extends State<CNSlider> {
  MethodChannel? _channel;

  double? _lastValue;
  double? _lastMin;
  double? _lastMax;
  bool? _lastEnabled;

  CNSliderController? _internalController;

  CNSliderController get _controller =>
      widget.controller ?? (_internalController ??= CNSliderController());

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    _controller._detach();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CNSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    // Fallback to Flutter Slider on unsupported platforms.
    if (!(defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS)) {
      return SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Slider(
          value: widget.value.clamp(widget.min, widget.max),
          min: widget.min,
          max: widget.max,
          onChanged: widget.enabled ? widget.onChanged : null,
        ),
      );
    }

    const viewType = 'CupertinoNativeSlider';
    final creationParams = <String, dynamic>{
      'min': widget.min,
      'max': widget.max,
      'value': widget.value,
      'enabled': widget.enabled,
    };

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return SizedBox(
        height: widget.height,
        width: double.infinity,
        child: UiKitView(
          viewType: viewType,
          creationParamsCodec: const StandardMessageCodec(),
          creationParams: creationParams,
          onPlatformViewCreated: _onPlatformViewCreated,
        ),
      );
    }

    // macOS
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      // AppKitView is available on macOS to host NSView platform views.
      child: AppKitView(
        viewType: viewType,
        creationParamsCodec: const StandardMessageCodec(),
        creationParams: creationParams,
        onPlatformViewCreated: _onPlatformViewCreated,
      ),
    );
  }

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('CupertinoNativeSlider_$id');
    _channel = channel;
    _controller._attach(channel);
    channel.setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'valueChanged') {
      final args = call.arguments as Map?;
      final value = (args?['value'] as num?)?.toDouble();
      if (value != null) {
        widget.onChanged(value);
        _lastValue = value;
      }
    }
    return null;
  }

  void _cacheCurrentProps() {
    _lastValue = widget.value;
    _lastMin = widget.min;
    _lastMax = widget.max;
    _lastEnabled = widget.enabled;
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    if (_lastMin != widget.min || _lastMax != widget.max) {
      await channel.invokeMethod('setRange', {
        'min': widget.min,
        'max': widget.max,
      });
      _lastMin = widget.min;
      _lastMax = widget.max;
    }

    if (_lastEnabled != widget.enabled) {
      await channel.invokeMethod('setEnabled', {'enabled': widget.enabled});
      _lastEnabled = widget.enabled;
    }

    final clamped = widget.value.clamp(widget.min, widget.max);
    if (_lastValue != clamped) {
      await channel.invokeMethod('setValue', {
        'value': clamped,
        'animated': false,
      });
      _lastValue = clamped;
    }
  }
}
