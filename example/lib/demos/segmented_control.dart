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
            Row(
              children: [
                Text('Basic'),
                Spacer(),
                Text('Selected: ${_index1 + 1}'),
              ],
            ),
            const SizedBox(height: 12),
            CNSegmentedControl(
              labels: const ['One', 'Two', 'Three'],
              selectedIndex: _index1,
              onValueChanged: (i) => setState(() => _index1 = i),
            ),

            const SizedBox(height: 48),

            Row(
              children: [
                Text('Colored'),
                Spacer(),
                Text('Selected: ${_index3 + 1}'),
              ],
            ),
            const SizedBox(height: 12),
            CNSegmentedControl(
              labels: const ['One', 'Two', 'Three'],
              selectedIndex: _index3,
              color: CupertinoColors.systemPink,
              onValueChanged: (i) => setState(() => _index3 = i),
            ),

            const SizedBox(height: 48),

            Row(
              children: [
                Text('Shrink wrap'),
                Spacer(),
                Text('Selected: ${_index2 + 1}'),
              ],
            ),
            const SizedBox(height: 12),
            CNSegmentedControl(
              labels: const ['One', 'Two', 'Three'],
              selectedIndex: _index2,
              onValueChanged: (i) => setState(() => _index2 = i),
              shrinkWrap: true,
            ),

            const SizedBox(height: 48),

            Row(
              children: [
                Text('Icons'),
                Spacer(),
                Text('Selected: ${_index4 + 1}'),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: CNSegmentedControl(
                labels: const [],
                sfSymbols: const [
                  CNSymbol('list.clipboard'),
                  CNSymbol('leaf.arrow.trianglehead.clockwise'),
                  CNSymbol('figure.walk.diamond'),
                ],
                selectedIndex: _index4,
                iconColor: CupertinoColors.systemBlue,
                iconRenderingMode: CNSymbolRenderingMode.hierarchical,
                shrinkWrap: true,
                onValueChanged: (i) => setState(() => _index4 = i),
                height: 48,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
