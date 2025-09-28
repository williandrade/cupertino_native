import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';

class NavigationBarDemoPage extends StatefulWidget {
  const NavigationBarDemoPage({super.key});

  @override
  State<NavigationBarDemoPage> createState() => _NavigationBarDemoPageState();
}

class _NavigationBarDemoPageState extends State<NavigationBarDemoPage> {
  String _lastButtonPressed = 'None';
  bool _showCenterButtons = false;
  bool _showTrailingButtons = false;
  bool _showLargeTitle = false;
  bool _showGlassEffect = true;
  bool _toggleLeftButton = false;
  bool _toggleTwoItemsToOne = false;

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
              color: CupertinoColors.activeOrange,
              leadingGroups: [
                CNNavigationBarButtonGroup(
                  buttons: [
                    CNNavigationBarButton(
                      title: 'Edit',
                      sfSymbol: 'pencil',
                      buttonType: ButtonType.prominent,
                      sfSymbolColor: CupertinoColors.activeOrange,
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
                      buttonType: ButtonType.plain,
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
                      title: _toggleLeftButton ? 'Edit' : 'Add',
                      sfSymbol: _toggleLeftButton ? 'pencil' : 'plus',
                      onPressed: () => setState(
                        () => _lastButtonPressed = _toggleLeftButton
                            ? 'Edit'
                            : 'Add',
                      ),
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
                            buttonType: ButtonType.prominent,
                            onPressed: () =>
                                setState(() => _lastButtonPressed = 'Search'),
                          ),
                          CNNavigationBarButton(
                            title: 'Filter',
                            sfSymbol: 'line.3.horizontal.decrease.circle',
                            sfSymbolColor: CupertinoColors.systemOrange,
                            sfSymbolRenderingMode:
                                CNSymbolRenderingMode.hierarchical,
                            buttonType: ButtonType.plain,
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
                            buttonType: ButtonType.prominent,
                            onPressed: () =>
                                setState(() => _lastButtonPressed = 'Share'),
                          ),
                        ],
                      ),
                      CNNavigationBarButtonGroup(
                        buttons: _toggleTwoItemsToOne
                            ? [
                                CNNavigationBarButton(
                                  title: 'Profile',
                                  sfSymbol: 'person.crop.circle',
                                  buttonType: ButtonType.plain,
                                  onPressed: () => setState(
                                    () => _lastButtonPressed = 'Profile',
                                  ),
                                ),
                                CNNavigationBarButton(
                                  title: 'Settings',
                                  sfSymbol: 'gearshape',
                                  buttonType: ButtonType.plain,
                                  onPressed: () => setState(
                                    () => _lastButtonPressed = 'Settings',
                                  ),
                                ),
                              ]
                            : [
                                CNNavigationBarButton(
                                  title: 'Settings',
                                  sfSymbol: 'gearshape',
                                  buttonType: ButtonType.plain,
                                  onPressed: () => setState(
                                    () => _lastButtonPressed = 'Settings',
                                  ),
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
                const Text('Toggle Left Button'),
                const Spacer(),
                CupertinoSwitch(
                  value: _toggleLeftButton,
                  onChanged: (value) =>
                      setState(() => _toggleLeftButton = !_toggleLeftButton),
                ),
              ],
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
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Toggle Two Items to One'),
                const Spacer(),
                CupertinoSwitch(
                  value: _toggleTwoItemsToOne,
                  onChanged: (value) =>
                      setState(() => _toggleTwoItemsToOne = value),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Show Large Title'),
                const Spacer(),
                CupertinoSwitch(
                  value: _showLargeTitle,
                  onChanged: (value) => setState(() => _showLargeTitle = value),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Show Glass Effect'),
                const Spacer(),
                CupertinoSwitch(
                  value: _showGlassEffect,
                  onChanged: (value) =>
                      setState(() => _showGlassEffect = value),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Text(
              'Button Types',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Text(
              '• Prominent buttons have a filled background\n• Plain buttons have a transparent background\n• Mix and match for different visual hierarchy',
              style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
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
                      buttonType: ButtonType.prominent,
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
                      buttonType: ButtonType.plain,
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
                      buttonType: ButtonType.prominent,
                      onPressed: () =>
                          setState(() => _lastButtonPressed = 'Sidebar'),
                    ),
                    CNNavigationBarButton(
                      title: '',
                      sfSymbol: 'house',
                      sfSymbolSize: 20,
                      buttonType: ButtonType.plain,
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
                      buttonType: ButtonType.prominent,
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
                      buttonType: ButtonType.plain,
                      onPressed: () =>
                          setState(() => _lastButtonPressed = 'Profile'),
                    ),
                    CNNavigationBarButton(
                      title: '',
                      sfSymbol: 'gearshape',
                      sfSymbolSize: 20,
                      buttonType: ButtonType.prominent,
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

            // New Features Demo
            const Text(
              'New Features Demo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            CNNavigationBar(
              title: _showLargeTitle ? 'Large Title Example' : 'New Features',
              backgroundColor: _showGlassEffect
                  ? CupertinoColors.systemBlue.withOpacity(0.5)
                  : CupertinoColors.systemRed,
              largeTitleDisplayMode: _showLargeTitle
                  ? LargeTitleDisplayMode.always
                  : LargeTitleDisplayMode.automatic,
              height: _showLargeTitle ? 96 : 44,
              leadingGroups: [
                CNNavigationBarButtonGroup(
                  buttons: [
                    CNNavigationBarButton(
                      title: 'Back',
                      sfSymbol: 'chevron.left',
                      buttonType: ButtonType.prominent,
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
                      title: 'Action',
                      sfSymbol: 'ellipsis',
                      buttonType: ButtonType.plain,
                      onPressed: () =>
                          setState(() => _lastButtonPressed = 'Action'),
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
                      buttonType: ButtonType.prominent,
                      enabled: false,
                      onPressed: () =>
                          setState(() => _lastButtonPressed = 'Disabled'),
                    ),
                    CNNavigationBarButton(
                      title: 'Enabled',
                      sfSymbol: 'checkmark',
                      buttonType: ButtonType.plain,
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

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
