import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';

class NavigationBarDemoPage extends StatefulWidget {
  const NavigationBarDemoPage({super.key});

  @override
  State<NavigationBarDemoPage> createState() => _NavigationBarDemoPageState();
}

class _NavigationBarDemoPageState extends State<NavigationBarDemoPage> {
  String _lastButtonPressed = 'None';
  bool _showCenterButtons = true;
  bool _showTrailingButtons = true;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Navigation Bar'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          children: [
            Text(
              'Last button pressed: $_lastButtonPressed',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),

            // Basic Navigation Bar
            const Text(
              'Basic Navigation Bar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            CNNavigationBar(
              title: 'Basic Title',
              leadingGroups: [
                CNNavigationBarButtonGroup(
                  buttons: [
                    CNNavigationBarButton(
                      title: 'Edit',
                      sfSymbol: 'pencil',
                      onPressed: () =>
                          setState(() => _lastButtonPressed = 'Edit'),
                    ),
                  ],
                ),
              ],
              trailingGroups: [
                CNNavigationBarButtonGroup(
                  buttons: [
                    CNNavigationBarButton(
                      title: 'Done',
                      sfSymbol: 'checkmark',
                      onPressed: () =>
                          setState(() => _lastButtonPressed = 'Done'),
                    ),
                  ],
                ),
              ],
              onButtonPressed: (groupType, groupIndex, buttonIndex) {
                setState(
                  () => _lastButtonPressed =
                      '$groupType-$groupIndex-$buttonIndex',
                );
              },
            ),

            const SizedBox(height: 32),

            // Multiple Button Groups
            const Text(
              'Multiple Button Groups',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            CNNavigationBar(
              title: 'Multi Groups',
              color: CupertinoColors.systemBlue,
              leadingGroups: [
                CNNavigationBarButtonGroup(
                  buttons: [
                    CNNavigationBarButton(
                      title: 'Edit',
                      sfSymbol: 'pencil',
                      onPressed: () =>
                          setState(() => _lastButtonPressed = 'Edit'),
                    ),
                    CNNavigationBarButton(
                      title: 'Add',
                      sfSymbol: 'plus',
                      onPressed: () =>
                          setState(() => _lastButtonPressed = 'Add'),
                    ),
                  ],
                ),
              ],
              centerGroups: _showCenterButtons
                  ? [
                      CNNavigationBarButtonGroup(
                        buttons: [
                          CNNavigationBarButton(
                            title: 'Search',
                            sfSymbol: 'magnifyingglass',
                            sfSymbolColor: CupertinoColors.systemPurple,
                            sfSymbolRenderingMode:
                                CNSymbolRenderingMode.hierarchical,
                            onPressed: () =>
                                setState(() => _lastButtonPressed = 'Search'),
                          ),
                          CNNavigationBarButton(
                            title: 'Filter',
                            sfSymbol: 'line.3.horizontal.decrease.circle',
                            sfSymbolColor: CupertinoColors.systemOrange,
                            sfSymbolRenderingMode:
                                CNSymbolRenderingMode.hierarchical,
                            onPressed: () =>
                                setState(() => _lastButtonPressed = 'Filter'),
                          ),
                        ],
                      ),
                    ]
                  : [],
              trailingGroups: _showTrailingButtons
                  ? [
                      CNNavigationBarButtonGroup(
                        buttons: [
                          CNNavigationBarButton(
                            title: 'Share',
                            sfSymbol: 'square.and.arrow.up',
                            onPressed: () =>
                                setState(() => _lastButtonPressed = 'Share'),
                          ),
                        ],
                      ),
                      CNNavigationBarButtonGroup(
                        buttons: [
                          CNNavigationBarButton(
                            title: 'More',
                            sfSymbol: 'ellipsis.circle',
                            onPressed: () =>
                                setState(() => _lastButtonPressed = 'More'),
                          ),
                        ],
                      ),
                    ]
                  : [],
              onButtonPressed: (groupType, groupIndex, buttonIndex) {
                setState(
                  () => _lastButtonPressed =
                      '$groupType-$groupIndex-$buttonIndex',
                );
              },
            ),

            const SizedBox(height: 32),

            // Controls
            const Text(
              'Controls',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Show Center Buttons'),
                const Spacer(),
                CupertinoSwitch(
                  value: _showCenterButtons,
                  onChanged: (value) =>
                      setState(() => _showCenterButtons = value),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Show Trailing Buttons'),
                const Spacer(),
                CupertinoSwitch(
                  value: _showTrailingButtons,
                  onChanged: (value) =>
                      setState(() => _showTrailingButtons = value),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Colored Navigation Bar
            const Text(
              'Colored Navigation Bar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            CNNavigationBar(
              title: 'Colored Bar',
              color: CupertinoColors.systemRed,
              height: 56,
              leadingGroups: [
                CNNavigationBarButtonGroup(
                  buttons: [
                    CNNavigationBarButton(
                      title: 'Back',
                      sfSymbol: 'arrow.left',
                      onPressed: () =>
                          setState(() => _lastButtonPressed = 'Back'),
                    ),
                  ],
                ),
              ],
              trailingGroups: [
                CNNavigationBarButtonGroup(
                  buttons: [
                    CNNavigationBarButton(
                      title: 'Save',
                      sfSymbol: 'square.and.arrow.down',
                      onPressed: () =>
                          setState(() => _lastButtonPressed = 'Save'),
                    ),
                  ],
                ),
              ],
              onButtonPressed: (groupType, groupIndex, buttonIndex) {
                setState(
                  () => _lastButtonPressed =
                      '$groupType-$groupIndex-$buttonIndex',
                );
              },
            ),

            const SizedBox(height: 32),

            // Icon-Only Navigation Bar
            const Text(
              'Icon-Only Navigation Bar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            CNNavigationBar(
              title: null,
              color: CupertinoColors.systemGreen,
              leadingGroups: [
                CNNavigationBarButtonGroup(
                  buttons: [
                    CNNavigationBarButton(
                      title: '',
                      sfSymbol: 'sidebar.left',
                      sfSymbolSize: 20,
                      onPressed: () =>
                          setState(() => _lastButtonPressed = 'Sidebar'),
                    ),
                    CNNavigationBarButton(
                      title: '',
                      sfSymbol: 'house',
                      sfSymbolSize: 20,
                      onPressed: () =>
                          setState(() => _lastButtonPressed = 'Home'),
                    ),
                  ],
                ),
              ],
              centerGroups: [
                CNNavigationBarButtonGroup(
                  buttons: [
                    CNNavigationBarButton(
                      title: '',
                      sfSymbol: 'apple.logo',
                      sfSymbolSize: 24,
                      sfSymbolRenderingMode: CNSymbolRenderingMode.multicolor,
                      onPressed: () =>
                          setState(() => _lastButtonPressed = 'Apple'),
                    ),
                  ],
                ),
              ],
              trailingGroups: [
                CNNavigationBarButtonGroup(
                  buttons: [
                    CNNavigationBarButton(
                      title: '',
                      sfSymbol: 'person.circle',
                      sfSymbolSize: 20,
                      onPressed: () =>
                          setState(() => _lastButtonPressed = 'Profile'),
                    ),
                    CNNavigationBarButton(
                      title: '',
                      sfSymbol: 'gearshape',
                      sfSymbolSize: 20,
                      onPressed: () =>
                          setState(() => _lastButtonPressed = 'Settings'),
                    ),
                  ],
                ),
              ],
              onButtonPressed: (groupType, groupIndex, buttonIndex) {
                setState(
                  () => _lastButtonPressed =
                      '$groupType-$groupIndex-$buttonIndex',
                );
              },
            ),

            const SizedBox(height: 32),

            // Disabled Buttons
            const Text(
              'Disabled Buttons',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            CNNavigationBar(
              title: 'Disabled Demo',
              leadingGroups: [
                CNNavigationBarButtonGroup(
                  buttons: [
                    CNNavigationBarButton(
                      title: 'Disabled',
                      sfSymbol: 'xmark',
                      enabled: false,
                      onPressed: () =>
                          setState(() => _lastButtonPressed = 'Disabled'),
                    ),
                    CNNavigationBarButton(
                      title: 'Enabled',
                      sfSymbol: 'checkmark',
                      enabled: true,
                      onPressed: () =>
                          setState(() => _lastButtonPressed = 'Enabled'),
                    ),
                  ],
                ),
              ],
              onButtonPressed: (groupType, groupIndex, buttonIndex) {
                setState(
                  () => _lastButtonPressed =
                      '$groupType-$groupIndex-$buttonIndex',
                );
              },
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
