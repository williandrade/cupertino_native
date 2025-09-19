import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

import '../channel/params.dart';

/// A Cupertino-native text input field.
///
/// Embeds a native UITextField/NSTextField for authentic visuals and behavior on
/// iOS and macOS. Falls back to [CupertinoTextField] on other platforms.
class CNInput extends StatefulWidget {
  /// Creates a native text input field.
  const CNInput({
    super.key,
    this.controller,
    this.placeholder,
    this.borderStyle = CNInputBorderStyle.roundedRect,
    this.fontSize = 17.0,
    this.textColor,
    this.backgroundColor,
    this.isSecure = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.autocorrect = true,
    this.textContentType,
    this.enabled = true,
    this.clearButtonMode = CNInputClearButtonMode.never,
    this.height = 44.0,
    this.onChanged,
    this.onSubmitted,
    this.onFocusChanged,
  });

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Text that appears in the input field when it has no text.
  final String? placeholder;

  /// The visual style of the input field border.
  final CNInputBorderStyle borderStyle;

  /// The size of the text.
  final double fontSize;

  /// The color of the text.
  final Color? textColor;

  /// The background color of the input field.
  final Color? backgroundColor;

  /// Whether the input field obscures the text being entered.
  final bool isSecure;

  /// The type of keyboard to display for editing the text.
  final TextInputType keyboardType;

  /// An action the user has requested the text input control to perform.
  final TextInputAction textInputAction;

  /// Whether to enable autocorrection.
  final bool autocorrect;

  /// To identify the semantic meaning of a text-entry area.
  final String? textContentType;

  /// Whether the input field is enabled for user interaction.
  final bool enabled;

  /// Controls when the clear button appears.
  final CNInputClearButtonMode clearButtonMode;

  /// The height of the input field.
  final double height;

  /// Called when the user changes the text in the field.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the text in the field.
  final ValueChanged<String>? onSubmitted;

  /// Called when the input field gains or loses focus.
  final ValueChanged<bool>? onFocusChanged;

  @override
  State<CNInput> createState() => _CNInputState();
}

class _CNInputState extends State<CNInput> {
  MethodChannel? _channel;
  bool? _lastIsDark;
  String? _lastText;
  String? _lastPlaceholder;
  late TextEditingController _controller;

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _lastText = _controller.text;
    _lastPlaceholder = widget.placeholder;
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CNInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _controller.dispose();
      }
      _controller = widget.controller ?? TextEditingController();
    }
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
        child: CupertinoTextField(
          controller: _controller,
          placeholder: widget.placeholder,
          obscureText: widget.isSecure,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autocorrect: widget.autocorrect,
          enabled: widget.enabled,
          style: TextStyle(fontSize: widget.fontSize, color: widget.textColor),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: widget.borderStyle == CNInputBorderStyle.none
                ? null
                : Border.all(color: CupertinoColors.systemGrey4),
          ),
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
        ),
      );
    }

    const viewType = 'CupertinoNativeInput';

    final creationParams = <String, dynamic>{
      if (widget.placeholder != null) 'placeholder': widget.placeholder,
      'text': _controller.text,
      'borderStyle': widget.borderStyle.name,
      'fontSize': widget.fontSize,
      if (widget.textColor != null)
        'textColor': resolveColorToArgb(widget.textColor, context),
      if (widget.backgroundColor != null)
        'backgroundColor': resolveColorToArgb(widget.backgroundColor, context),
      'isSecure': widget.isSecure,
      'keyboardType': _keyboardTypeToString(widget.keyboardType),
      'returnKeyType': _textInputActionToString(widget.textInputAction),
      'autocorrectionType': widget.autocorrect ? 'yes' : 'no',
      if (widget.textContentType != null)
        'textContentType': widget.textContentType,
      'enabled': widget.enabled,
      'clearButtonMode': widget.clearButtonMode.name,
      'isDark': _isDark,
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

    return SizedBox(height: widget.height, child: platformView);
  }

  void _onCreated(int id) {
    final ch = MethodChannel('CupertinoNativeInput_$id');
    _channel = ch;
    ch.setMethodCallHandler(_onMethodCall);
    _lastIsDark = _isDark;
    _lastText = _controller.text;
    _lastPlaceholder = widget.placeholder;
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'textChanged':
        final text = call.arguments['text'] as String? ?? '';
        if (_controller.text != text) {
          _controller.value = _controller.value.copyWith(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          );
        }
        if (widget.onChanged != null) {
          widget.onChanged!(text);
        }
        break;
      case 'focusChanged':
        final focused = call.arguments['focused'] as bool? ?? false;
        if (widget.onFocusChanged != null) {
          widget.onFocusChanged!(focused);
        }
        break;
      case 'submitted':
        final text = call.arguments['text'] as String? ?? '';
        if (widget.onSubmitted != null) {
          widget.onSubmitted!(text);
        }
        break;
    }
    return null;
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;

    // Sync text if changed
    if (_lastText != _controller.text) {
      await ch.invokeMethod('setText', {'text': _controller.text});
      _lastText = _controller.text;
    }

    // Sync placeholder if changed
    if (_lastPlaceholder != widget.placeholder && widget.placeholder != null) {
      await ch.invokeMethod('setPlaceholder', {
        'placeholder': widget.placeholder,
      });
      _lastPlaceholder = widget.placeholder;
    }

    // Sync enabled state
    await ch.invokeMethod('setEnabled', {'enabled': widget.enabled});

    // Sync secure mode
    await ch.invokeMethod('setSecure', {'isSecure': widget.isSecure});

    // Sync border style
    await ch.invokeMethod('setBorderStyle', {
      'borderStyle': widget.borderStyle.name,
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

  String _keyboardTypeToString(TextInputType keyboardType) {
    switch (keyboardType) {
      case TextInputType.text:
        return 'default';
      case TextInputType.number:
        return 'numberPad';
      case TextInputType.phone:
        return 'phonePad';
      case TextInputType.emailAddress:
        return 'emailAddress';
      case TextInputType.url:
        return 'URL';
      case TextInputType.multiline:
        return 'default';
      case TextInputType.name:
        return 'namePhonePad';
      case TextInputType.streetAddress:
        return 'default';
      case TextInputType.datetime:
        return 'numbersAndPunctuation';
      case TextInputType.visiblePassword:
        return 'asciiCapable';
      default:
        return 'default';
    }
  }

  String _textInputActionToString(TextInputAction action) {
    switch (action) {
      case TextInputAction.none:
        return 'default';
      case TextInputAction.unspecified:
        return 'default';
      case TextInputAction.done:
        return 'done';
      case TextInputAction.go:
        return 'go';
      case TextInputAction.search:
        return 'search';
      case TextInputAction.send:
        return 'send';
      case TextInputAction.next:
        return 'next';
      case TextInputAction.previous:
        return 'default';
      case TextInputAction.continueAction:
        return 'continue';
      case TextInputAction.join:
        return 'join';
      case TextInputAction.route:
        return 'route';
      case TextInputAction.emergencyCall:
        return 'emergencyCall';
      case TextInputAction.newline:
        return 'default';
    }
  }
}

/// The visual style of the input field border.
enum CNInputBorderStyle {
  /// No border.
  none('none'),

  /// A simple line border.
  line('line'),

  /// A bezel-style border.
  bezel('bezel'),

  /// A rounded rectangle border.
  roundedRect('roundedRect');

  const CNInputBorderStyle(this.name);

  /// The native name of the border style.
  final String name;
}

/// Controls when the clear button appears in the input field.
enum CNInputClearButtonMode {
  /// Never show the clear button.
  never('never'),

  /// Show the clear button while editing.
  whileEditing('whileEditing'),

  /// Show the clear button unless editing.
  unlessEditing('unlessEditing'),

  /// Always show the clear button.
  always('always');

  const CNInputClearButtonMode(this.name);

  /// The native name of the clear button mode.
  final String name;
}
