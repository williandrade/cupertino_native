import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CNButtonController {
  MethodChannel? _channel;

  void _attach(MethodChannel channel) {
    _channel = channel;
  }

  void _detach() {
    _channel = null;
  }

  Future<void> setTitle(String title) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.invokeMethod('setTitle', {'title': title});
  }

  Future<void> setEnabled(bool enabled) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.invokeMethod('setEnabled', {'enabled': enabled});
  }
}

class CNButton extends StatefulWidget {
  const CNButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.enabled = true,
    this.controller,
    this.height = 44.0,
  });

  final String title;
  final bool enabled;
  final VoidCallback onPressed;
  final CNButtonController? controller;
  final double height;

  @override
  State<CNButton> createState() => _CNButtonState();
}

class _CNButtonState extends State<CNButton> {
  MethodChannel? _channel;
  String? _lastTitle;
  bool? _lastEnabled;

  CNButtonController? _internalController;
  CNButtonController get _controller =>
      widget.controller ?? (_internalController ??= CNButtonController());

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    _controller._detach();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CNButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    if (!(defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS)) {
      return SizedBox(
        height: widget.height,
        child: ElevatedButton(
          onPressed: widget.enabled ? widget.onPressed : null,
          child: Text(widget.title),
        ),
      );
    }

    const viewType = 'CupertinoNativeButton';
    final creationParams = <String, dynamic>{
      'title': widget.title,
      'enabled': widget.enabled,
    };

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return SizedBox(
        height: widget.height,
        child: UiKitView(
          viewType: viewType,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: _onPlatformViewCreated,
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
          },
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: AppKitView(
        viewType: viewType,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
        },
      ),
    );
  }

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('CupertinoNativeButton_$id');
    _channel = channel;
    _controller._attach(channel);
    channel.setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'pressed') {
      widget.onPressed();
    }
    return null;
  }

  void _cacheCurrentProps() {
    _lastTitle = widget.title;
    _lastEnabled = widget.enabled;
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    if (_lastTitle != widget.title) {
      await channel.invokeMethod('setTitle', {'title': widget.title});
      _lastTitle = widget.title;
    }

    if (_lastEnabled != widget.enabled) {
      await channel.invokeMethod('setEnabled', {'enabled': widget.enabled});
      _lastEnabled = widget.enabled;
    }
  }
}

