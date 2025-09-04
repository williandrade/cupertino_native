import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class PopupMenuButtonDemoPage extends StatefulWidget {
  const PopupMenuButtonDemoPage({super.key});

  @override
  State<PopupMenuButtonDemoPage> createState() =>
      _PopupMenuButtonDemoPageState();
}

class _PopupMenuButtonDemoPageState extends State<PopupMenuButtonDemoPage> {
  int? _lastSelected;

  @override
  Widget build(BuildContext context) {
    final items = <CNPopupMenuEntry>[
      CNPopupMenuItem(label: 'New File', icon: const CNSymbol('doc', size: 18)),
      CNPopupMenuItem(
        label: 'New Folder',
        icon: const CNSymbol('folder', size: 18),
      ),
      const CNPopupMenuDivider(),
      CNPopupMenuItem(
        label: 'Rename',
        icon: const CNSymbol('rectangle.and.pencil.and.ellipsis', size: 18),
      ),
      CNPopupMenuItem(
        label: 'Delete',
        icon: const CNSymbol('trash', size: 18),
        enabled: true,
      ),
    ];

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Popup Menu Button'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CNPopupMenuButton(
                  buttonLabel: 'Actions',
                  items: items,
                  shrinkWrap: true,
                  onSelected: (index) {
                    setState(() => _lastSelected = index);
                  },
                  buttonStyle: CNButtonStyle.automatic,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CNPopupMenuButton.icon(
                  buttonIcon: const CNSymbol('ellipsis', size: 18),
                  size: 44,
                  items: items,
                  onSelected: (index) {
                    setState(() => _lastSelected = index);
                  },
                  buttonStyle: CNButtonStyle.glass,
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_lastSelected != null)
              Center(child: Text('Selected index: $_lastSelected')),
            const SizedBox(height: 24),
            const Text('Menu supports icons, text, and dividers.'),
          ],
        ),
      ),
    );
  }
}
