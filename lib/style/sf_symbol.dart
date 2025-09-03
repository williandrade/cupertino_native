import 'package:flutter/cupertino.dart';

enum CNSFSymbolRenderingMode {
  monochrome,
  hierarchical,
  palette,
  multicolor,
}

class CNSFSymbol {
  final String name;
  final double? size; // point size
  final Color? color; // preferred icon color (monochrome/hierarchical)
  final List<Color>? paletteColors; // multi-color palette
  final CNSFSymbolRenderingMode? mode; // per-icon rendering mode
  final bool? gradient; // prefer built-in gradient when available

  const CNSFSymbol(
    this.name, {
    this.size,
    this.color,
    this.paletteColors,
    this.mode,
    this.gradient,
  });
}
