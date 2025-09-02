import 'package:flutter/cupertino.dart';
import 'demos/slider.dart';
import 'demos/switch.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Cupertino Native'),
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
