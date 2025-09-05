import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/components/button.dart';
import 'package:cupertino_native/style/sf_symbol.dart';
import 'demos/slider.dart';
import 'demos/switch.dart';
import 'demos/segmented_control.dart';
import 'demos/tab_bar.dart';
import 'demos/icon.dart';
import 'demos/popup_menu_button.dart';
import 'demos/button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
      home: HomePage(isDarkMode: _isDarkMode, onToggleTheme: _toggleTheme),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        border: null,
        // middle: const Text('Cupertino Native'),
        trailing: CNButton.icon(
          icon: CNSymbol(isDarkMode ? 'sun.max.fill' : 'moon.fill', size: 18),
          onPressed: onToggleTheme,
        ),
      ),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          CupertinoListSection.insetGrouped(
            header: Text('Components'),
            children: [
              CupertinoListTile(
                title: Text('Slider'),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const SliderDemoPage()),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Switch'),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const SwitchDemoPage()),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Segmented Control'),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const SegmentedControlDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Icon'),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const IconDemoPage()),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Popup Menu Button'),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const PopupMenuButtonDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Button'),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const ButtonDemoPage()),
                  );
                },
              ),
            ],
          ),
          CupertinoListSection.insetGrouped(
            header: Text('Navigation'),
            children: [
              CupertinoListTile(
                title: Text('Tab Bar'),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const TabBarDemoPage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
