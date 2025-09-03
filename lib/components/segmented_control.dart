import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../channel/params.dart';
import '../style/sf_symbol.dart';

class CNSegmentedControl extends StatefulWidget {
  const CNSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onValueChanged,
    this.enabled = true,
    this.tint,
    this.height = 32.0,
    this.shrinkWrap = false,
    this.sfSymbols,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onValueChanged;
  final bool enabled;
  final Color? tint;
  final double height;
  final bool shrinkWrap;
  final List<CNSFSymbol>? sfSymbols;

  @override
  State<CNSegmentedControl> createState() => _CNSegmentedControlState();
}

class _CNSegmentedControlState extends State<CNSegmentedControl> {
  MethodChannel? _channel;

  int? _lastSelected;
  bool? _lastEnabled;
  bool? _lastIsDark;
  int? _lastTint;
  double? _intrinsicWidth;

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CNSegmentedControl oldWidget) {
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
      return SizedBox(
        height: widget.height,
        child: CupertinoSegmentedControl<int>(
          children: {
            for (var i = 0; i < widget.labels.length; i++) i: Text(widget.labels[i])
          },
          groupValue: widget.selectedIndex,
          onValueChanged: widget.enabled ? (i) => widget.onValueChanged(i) : (_) {},
        ),
      );
    }

    const viewType = 'CupertinoNativeSegmentedControl';
    final creationParams = <String, dynamic>{
      'labels': widget.labels,
      'selectedIndex': widget.selectedIndex,
      'enabled': widget.enabled,
      'isDark': _isDark,
      'style': encodeStyle(context, tint: widget.tint),
      if (widget.sfSymbols != null)
        'sfSymbols': widget.sfSymbols!.map((e) => e.name).toList(),
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

    if (widget.shrinkWrap) {
      final width = _intrinsicWidth;
      return Center(
        child: SizedBox(
          height: widget.height,
          width: width, // if null, stretches initially until measured
          child: platformView,
        ),
      );
    }

    return SizedBox(height: widget.height, child: platformView);
  }

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('CupertinoNativeSegmentedControl_$id');
    _channel = channel;
    channel.setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
    _syncBrightnessIfNeeded();
    _requestIntrinsicSize();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'valueChanged') {
      final args = call.arguments as Map?;
      final idx = (args?['index'] as num?)?.toInt();
      if (idx != null) {
        widget.onValueChanged(idx);
        _lastSelected = idx;
      }
    }
    return null;
  }

  void _cacheCurrentProps() {
    _lastSelected = widget.selectedIndex;
    _lastEnabled = widget.enabled;
    _lastIsDark = _isDark;
    _lastTint = resolveColorToArgb(widget.tint, context);
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    final tint = resolveColorToArgb(widget.tint, context);

    if (_lastEnabled != widget.enabled) {
      await channel.invokeMethod('setEnabled', {'enabled': widget.enabled});
      _lastEnabled = widget.enabled;
    }
    if (_lastSelected != widget.selectedIndex) {
      await channel.invokeMethod('setSelectedIndex', {'index': widget.selectedIndex});
      _lastSelected = widget.selectedIndex;
    }
    if (_lastTint != tint && tint != null) {
      await channel.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }
  }

  Future<void> _requestIntrinsicSize() async {
    final channel = _channel;
    if (channel == null) return;
    try {
      final size = await channel.invokeMethod<Map>('getIntrinsicSize');
      final w = (size?['width'] as num?)?.toDouble();
      if (w != null && mounted) {
        setState(() => _intrinsicWidth = w);
      }
    } catch (_) {}
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;
    final isDark = _isDark;
    final tint = resolveColorToArgb(widget.tint, context);
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
