import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';

class SliderDemoPage extends StatefulWidget {
  const SliderDemoPage({super.key});

  @override
  State<SliderDemoPage> createState() => _SliderDemoPageState();
}

class _SliderDemoPageState extends State<SliderDemoPage> {
  double _fullWidthValue = 50;
  double _halfWidthValue = 25;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Slider')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const Text('Full width slider'),
            CNSlider(
              value: _fullWidthValue,
              min: 0,
              max: 100,
              enabled: true,
              onChanged: (v) => setState(() => _fullWidthValue = v),
            ),
            Text('Value: ${_fullWidthValue.toStringAsFixed(1)}'),
            const SizedBox(height: 24),
            const Text('Half width slider'),
            Align(
              alignment: Alignment.center,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: CNSlider(
                  value: _halfWidthValue,
                  min: 0,
                  max: 100,
                  enabled: true,
                  onChanged: (v) => setState(() => _halfWidthValue = v),
                ),
              ),
            ),
            Text(
              'Value: ${_halfWidthValue.toStringAsFixed(1)}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text('Disabled slider'),
            CNSlider(
              value: 75,
              min: 0,
              max: 100,
              enabled: false,
              onChanged: (_) {},
            ),
          ],
        ),
      ),
    );
  }
}
