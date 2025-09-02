import 'package:flutter/cupertino.dart';
import 'demos/slider.dart';
import 'demos/switch.dart';

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
      home: HomePage(
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.isDarkMode, required this.onToggleTheme});

  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Cupertino Native'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onToggleTheme,
          child: Icon(
            isDarkMode ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_fill,
            size: 22,
          ),
        ),
      ),
      child: SafeArea(
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
                      CupertinoPageRoute(
                        builder: (_) => const SliderDemoPage(),
                      ),
                    );
                  },
                ),
                CupertinoListTile(
                  title: Text('Switch'),
                  trailing: CupertinoListTileChevron(),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => const SwitchDemoPage(),
                      ),
                    );
                  },
                ),
                // Button demo removed
              ],
            ),
          ],
        ),
      ),
    );
  }
}
