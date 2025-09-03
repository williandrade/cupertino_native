import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';

class IconDemoPage extends StatelessWidget {
  const IconDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Icon')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Basic icons'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                CNIcon(symbol: CNSFSymbol('heart.fill'), size: 24, shrinkWrap: true),
                CNIcon(symbol: CNSFSymbol('star.fill'), size: 24, shrinkWrap: true),
                CNIcon(symbol: CNSFSymbol('bell.fill'), size: 24, shrinkWrap: true),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Sizes'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                CNIcon(symbol: CNSFSymbol('heart.fill'), size: 16, shrinkWrap: true),
                CNIcon(symbol: CNSFSymbol('heart.fill'), size: 24, shrinkWrap: true),
                CNIcon(symbol: CNSFSymbol('heart.fill'), size: 32, shrinkWrap: true),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Monochrome colors'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                CNIcon(symbol: CNSFSymbol('star.fill'), size: 28, color: CupertinoColors.systemPink, mode: CNSFSymbolRenderingMode.monochrome, shrinkWrap: true),
                CNIcon(symbol: CNSFSymbol('star.fill'), size: 28, color: CupertinoColors.systemBlue, mode: CNSFSymbolRenderingMode.monochrome, shrinkWrap: true),
                CNIcon(symbol: CNSFSymbol('star.fill'), size: 28, color: CupertinoColors.systemGreen, mode: CNSFSymbolRenderingMode.monochrome, shrinkWrap: true),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Hierarchical'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                CNIcon(symbol: CNSFSymbol('folder.fill'), size: 28, color: CupertinoColors.systemBlue, mode: CNSFSymbolRenderingMode.hierarchical, shrinkWrap: true),
                CNIcon(symbol: CNSFSymbol('doc.fill'), size: 28, color: CupertinoColors.systemTeal, mode: CNSFSymbolRenderingMode.hierarchical, shrinkWrap: true),
                CNIcon(symbol: CNSFSymbol('paperplane.fill'), size: 28, color: CupertinoColors.systemIndigo, mode: CNSFSymbolRenderingMode.hierarchical, shrinkWrap: true),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Multicolor (OS supported)'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                CNIcon(symbol: CNSFSymbol('paintpalette.fill'), size: 28, mode: CNSFSymbolRenderingMode.multicolor, shrinkWrap: true),
                CNIcon(symbol: CNSFSymbol('aqi.low'), size: 28, mode: CNSFSymbolRenderingMode.multicolor, shrinkWrap: true),
                CNIcon(symbol: CNSFSymbol('leaf.fill'), size: 28, mode: CNSFSymbolRenderingMode.multicolor, shrinkWrap: true),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Palette (best-effort on iOS; limited on macOS)'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                CNIcon(
                  symbol: CNSFSymbol(
                    'chart.bar.fill',
                    mode: CNSFSymbolRenderingMode.palette,
                    paletteColors: [CupertinoColors.systemYellow, CupertinoColors.systemOrange],
                  ),
                  size: 28,
                  shrinkWrap: true,
                ),
                CNIcon(
                  symbol: CNSFSymbol(
                    'waveform',
                    mode: CNSFSymbolRenderingMode.palette,
                    paletteColors: [CupertinoColors.systemBlue, CupertinoColors.systemTeal],
                  ),
                  size: 28,
                  shrinkWrap: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Gradient toggle (future OS support, base color shown otherwise)'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                CNIcon(symbol: CNSFSymbol('heart.fill', gradient: true), size: 28, color: CupertinoColors.systemPink, shrinkWrap: true),
                CNIcon(symbol: CNSFSymbol('star.fill', gradient: true), size: 28, color: CupertinoColors.systemYellow, shrinkWrap: true),
                CNIcon(symbol: CNSFSymbol('bell.fill', gradient: true), size: 28, color: CupertinoColors.systemBlue, shrinkWrap: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

