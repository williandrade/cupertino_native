import 'package:flutter/cupertino.dart';

enum CNSymbolRenderingMode { monochrome, hierarchical, palette, multicolor }

class CNSymbol {
  final String name;
  final double size; // point size
  final Color? color; // preferred icon color (monochrome/hierarchical)
  final List<Color>? paletteColors; // multi-color palette
  final CNSymbolRenderingMode? mode; // per-icon rendering mode
  final bool? gradient; // prefer built-in gradient when available

  const CNSymbol(
    this.name, {
    this.size = 24.0,
    this.color,
    this.paletteColors,
    this.mode,
    this.gradient,
  });
}
