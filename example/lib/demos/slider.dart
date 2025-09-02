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
  double _stepValue = 0;
  double _styledValue = 40;
  double _pinkValue = 30;

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
            const Text('Tinted slider (systemPink)'),
            CNSlider(
              value: _pinkValue,
              min: 0,
              max: 100,
              enabled: true,
              color: CupertinoColors.systemPink,
              onChanged: (v) => setState(() => _pinkValue = v),
            ),
            Text('Value: ${_pinkValue.toStringAsFixed(1)}'),
            const SizedBox(height: 24),
            const Text('Step slider (step = 10)'),
            CNSlider(
              value: _stepValue,
              min: 0,
              max: 100,
              enabled: true,
              step: 10,
              onChanged: (v) => setState(() => _stepValue = v),
            ),
            Text('Value: ${_stepValue.toStringAsFixed(0)}'),
            const SizedBox(height: 24),
            const Text('Styled slider (thumb/track/background)'),
            CNSlider(
              value: _styledValue,
              min: 0,
              max: 100,
              enabled: true,
              thumbColor: CupertinoColors.systemPink,
              trackColor: CupertinoColors.systemBlue,
              trackBackgroundColor: CupertinoColors.systemGrey2,
              onChanged: (v) => setState(() => _styledValue = v),
            ),
            Text('Value: ${_styledValue.toStringAsFixed(1)}'),
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
