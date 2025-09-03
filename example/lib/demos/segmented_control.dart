import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';

class SegmentedControlDemoPage extends StatefulWidget {
  const SegmentedControlDemoPage({super.key});

  @override
  State<SegmentedControlDemoPage> createState() =>
      _SegmentedControlDemoPageState();
}

class _SegmentedControlDemoPageState extends State<SegmentedControlDemoPage> {
  int _index1 = 0;
  int _index2 = 1;
  int _index3 = 0;
  int _index4 = 0;
  int _index5 = 0;
  int _index6 = 0;
  int _index7 = 0;
  int _index8 = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Segmented Control'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          children: [
            const Text('Basic'),
            Center(
              child: CNSegmentedControl(
                labels: const ['One', 'Two', 'Three'],
                selectedIndex: _index1,
                onValueChanged: (i) => setState(() => _index1 = i),
              ),
            ),
            Text('Selected: ${_index1 + 1}'),
            const SizedBox(height: 24),
            const Text('Tinted (systemPink) + shrinkWrap'),
            Center(
              child: CNSegmentedControl(
                labels: const ['A', 'B', 'C'],
                selectedIndex: _index2,
                tint: CupertinoColors.systemPink,
                shrinkWrap: true,
                onValueChanged: (i) => setState(() => _index2 = i),
              ),
            ),
            Text('Selected: ${_index2 + 1}'),
            const SizedBox(height: 24),
            const Text('SF Symbols (heart.fill / star.fill / bell.fill) with size 20'),
            Center(
              child: CNSegmentedControl(
                labels: const [],
                sfSymbols: const [
                  CNSFSymbol('heart.fill'),
                  CNSFSymbol('star.fill'),
                  CNSFSymbol('bell.fill'),
                ],
                selectedIndex: _index3,
                iconSize: 20,
                shrinkWrap: true,
                onValueChanged: (i) => setState(() => _index3 = i),
              ),
            ),
            Text('Selected: ${_index3 + 1}'),
            const SizedBox(height: 24),
            const Text('SF Symbols with per-icon size and color'),
            Center(
              child: CNSegmentedControl(
                labels: const [],
                sfSymbols: const [
                  CNSFSymbol('heart.fill', size: 22, color: CupertinoColors.systemPink),
                  CNSFSymbol('star.fill', size: 18, color: CupertinoColors.systemYellow),
                  CNSFSymbol('bell.fill', size: 26, color: CupertinoColors.systemBlue),
                ],
                selectedIndex: _index4,
                shrinkWrap: true,
                onValueChanged: (i) => setState(() => _index4 = i),
              ),
            ),
            Text('Selected: ${_index4 + 1}'),
            const SizedBox(height: 24),
            const Text('SF Symbols gradient toggle (future built-in, ignored on older OS)'),
            Center(
              child: CNSegmentedControl(
                labels: const [],
                sfSymbols: const [
                  CNSFSymbol('heart.fill', gradient: true),
                  CNSFSymbol('star.fill', gradient: true),
                  CNSFSymbol('bell.fill', gradient: true),
                ],
                selectedIndex: _index1,
                iconColor: CupertinoColors.systemPink,
                shrinkWrap: true,
                onValueChanged: (i) => setState(() => _index1 = i),
              ),
            ),
            Text('Selected: ${_index1 + 1}'),
            const SizedBox(height: 24),
            const Text('Rendering modes: Monochrome (pink)'),
            Center(
              child: CNSegmentedControl(
                labels: const [],
                sfSymbols: const [
                  CNSFSymbol('heart.fill', mode: CNSFSymbolRenderingMode.monochrome),
                  CNSFSymbol('star.fill', mode: CNSFSymbolRenderingMode.monochrome),
                  CNSFSymbol('bell.fill', mode: CNSFSymbolRenderingMode.monochrome),
                ],
                selectedIndex: _index5,
                iconRenderingMode: CNSFSymbolRenderingMode.monochrome,
                iconColor: CupertinoColors.systemPink,
                shrinkWrap: true,
                onValueChanged: (i) => setState(() => _index5 = i),
              ),
            ),
            Text('Selected: ${_index5 + 1}'),
            const SizedBox(height: 24),
            const Text('Rendering modes: Hierarchical (blue)'),
            Center(
              child: CNSegmentedControl(
                labels: const [],
                sfSymbols: const [
                  CNSFSymbol('heart.fill', mode: CNSFSymbolRenderingMode.hierarchical),
                  CNSFSymbol('star.fill', mode: CNSFSymbolRenderingMode.hierarchical),
                  CNSFSymbol('bell.fill', mode: CNSFSymbolRenderingMode.hierarchical),
                ],
                selectedIndex: _index6,
                iconRenderingMode: CNSFSymbolRenderingMode.hierarchical,
                iconColor: CupertinoColors.systemBlue,
                shrinkWrap: true,
                onValueChanged: (i) => setState(() => _index6 = i),
              ),
            ),
            Text('Selected: ${_index6 + 1}'),
            const SizedBox(height: 24),
            const Text('Rendering modes: Palette (yellow/orange)'),
            Center(
              child: CNSegmentedControl(
                labels: const [],
                sfSymbols: const [
                  CNSFSymbol('heart.fill', mode: CNSFSymbolRenderingMode.palette),
                  CNSFSymbol('star.fill', mode: CNSFSymbolRenderingMode.palette),
                  CNSFSymbol('bell.fill', mode: CNSFSymbolRenderingMode.palette),
                ],
                selectedIndex: _index7,
                iconRenderingMode: CNSFSymbolRenderingMode.palette,
                iconPaletteColors: const [
                  CupertinoColors.systemYellow,
                  CupertinoColors.systemOrange,
                ],
                shrinkWrap: true,
                onValueChanged: (i) => setState(() => _index7 = i),
              ),
            ),
            Text('Selected: ${_index7 + 1}'),
            const SizedBox(height: 24),
            const Text('Rendering modes: Multicolor'),
            Center(
              child: CNSegmentedControl(
                labels: const [],
                sfSymbols: const [
                  CNSFSymbol('heart.fill', mode: CNSFSymbolRenderingMode.multicolor),
                  CNSFSymbol('star.fill', mode: CNSFSymbolRenderingMode.multicolor),
                  CNSFSymbol('bell.fill', mode: CNSFSymbolRenderingMode.multicolor),
                ],
                selectedIndex: _index8,
                iconRenderingMode: CNSFSymbolRenderingMode.multicolor,
                shrinkWrap: true,
                onValueChanged: (i) => setState(() => _index8 = i),
              ),
            ),
            Text('Selected: ${_index8 + 1}'),
          ],
        ),
      ),
    );
  }
}
