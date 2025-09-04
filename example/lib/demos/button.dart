import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class ButtonDemoPage extends StatefulWidget {
  const ButtonDemoPage({super.key});

  @override
  State<ButtonDemoPage> createState() => _ButtonDemoPageState();
}

class _ButtonDemoPageState extends State<ButtonDemoPage> {
  String _last = 'None';

  void _set(String what) => setState(() => _last = what);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Button'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Styles'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                CNButton(
                  label: 'Automatic',
                  style: CNButtonStyle.automatic,
                  onPressed: () => _set('Automatic'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Bordered',
                  style: CNButtonStyle.bordered,
                  onPressed: () => _set('Bordered'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Prominent',
                  style: CNButtonStyle.borderedProminent,
                  onPressed: () => _set('Prominent'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Link',
                  style: CNButtonStyle.link,
                  onPressed: () => _set('Link'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Glass',
                  style: CNButtonStyle.glass,
                  onPressed: () => _set('Glass'),
                  shrinkWrap: true,
                ),
                CNButton(
                  label: 'Disabled',
                  style: CNButtonStyle.bordered,
                  onPressed: null, // disabled via null callback
                  shrinkWrap: true,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Icon'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CNButton.icon(
                  icon: const CNSymbol('heart.fill', size: 18),
                  style: CNButtonStyle.glass,
                  onPressed: () => _set('Icon Heart'),
                ),
                const SizedBox(width: 16),
                CNButton.icon(
                  icon: const CNSymbol('ellipsis', size: 18),
                  style: CNButtonStyle.accessoryBarAction,
                  onPressed: () => _set('Icon Ellipsis'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(child: Text('Last pressed: $_last')),
          ],
        ),
      ),
    );
  }
}
