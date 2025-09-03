import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show TabController, TabBarView;
import 'package:cupertino_native/cupertino_native.dart';

class TabBarDemoPage extends StatefulWidget {
  const TabBarDemoPage({super.key});

  @override
  State<TabBarDemoPage> createState() => _TabBarDemoPageState();
}

class _TabBarDemoPageState extends State<TabBarDemoPage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
    _controller.addListener(() {
      final i = _controller.index;
      if (i != _index) setState(() => _index = i);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Native Tab Bar')),
      child: SafeArea(
        child: Stack(
          children: [
            // Content below
            Positioned.fill(
              child: TabBarView(
                controller: _controller,
                children: const [
                  _TabPage(title: 'Home', color: CupertinoColors.systemGroupedBackground),
                  _TabPage(title: 'Search', color: CupertinoColors.systemGrey5),
                  _TabPage(title: 'Profile', color: CupertinoColors.systemGrey6),
                ],
              ),
            ),
            // Native tab bar overlay
            Align(
              alignment: Alignment.bottomCenter,
              child: CNTabBar(
                items: const [
                  CNTabBarItem(label: 'Home', icon: CNSymbol('house.fill', size: 22)),
                  CNTabBarItem(label: 'Search', icon: CNSymbol('magnifyingglass', size: 22)),
                  CNTabBarItem(label: 'Profile', icon: CNSymbol('person.crop.circle', size: 22)),
                ],
                currentIndex: _index,
                tint: CupertinoColors.activeBlue,
                onTap: (i) {
                  setState(() => _index = i);
                  _controller.animateTo(i);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabPage extends StatelessWidget {
  const _TabPage({required this.title, required this.color});
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: Alignment.center,
      child: Text(title, style: const TextStyle(fontSize: 20)),
    );
  }
}
