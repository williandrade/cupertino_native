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
            const Text('SF Symbols (heart.fill / star.fill / bell.fill)'),
            Center(
              child: CNSegmentedControl(
                labels: const [],
                sfSymbols: const [
                  CNSFSymbol('heart.fill'),
                  CNSFSymbol('star.fill'),
                  CNSFSymbol('bell.fill'),
                ],
                selectedIndex: _index3,
                shrinkWrap: true,
                onValueChanged: (i) => setState(() => _index3 = i),
              ),
            ),
            Text('Selected: ${_index3 + 1}'),
          ],
        ),
      ),
    );
  }
}
