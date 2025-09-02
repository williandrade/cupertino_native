import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';

class SwitchDemoPage extends StatefulWidget {
  const SwitchDemoPage({super.key});

  @override
  State<SwitchDemoPage> createState() => _SwitchDemoPageState();
}

class _SwitchDemoPageState extends State<SwitchDemoPage> {
  bool _value1 = true;
  bool _value2 = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Switch')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const Text('Basic switch'),
            CNSwitch(
              value: _value1,
              enabled: true,
              onChanged: (v) => setState(() => _value1 = v),
            ),
            Text('Value: ${_value1 ? 'ON' : 'OFF'}'),
            const SizedBox(height: 24),
            const Text('Centered switch'),
            Align(
              alignment: Alignment.center,
              child: CNSwitch(
                value: _value2,
                enabled: true,
                onChanged: (v) => setState(() => _value2 = v),
              ),
            ),
            Text(
              'Value: ${_value2 ? 'ON' : 'OFF'}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text('Disabled switch'),
            const CNSwitch(
              value: false,
              enabled: false,
              onChanged: _noop,
            ),
          ],
        ),
      ),
    );
  }
}

void _noop(bool _) {}

