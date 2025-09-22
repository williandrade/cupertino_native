import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';

class GlassEffectContainerDemoPage extends StatefulWidget {
  const GlassEffectContainerDemoPage({super.key});

  @override
  State<GlassEffectContainerDemoPage> createState() =>
      _GlassEffectContainerDemoPageState();
}

class _GlassEffectContainerDemoPageState
    extends State<GlassEffectContainerDemoPage> {
  CNGlassStyle _selectedGlassStyle = CNGlassStyle.regular;
  Color? _selectedTint;
  double _cornerRadius = 16.0;
  bool _interactive = true;
  String _lastTapEvent = 'None';

  final List<Color> _availableColors = [
    CupertinoColors.systemBlue,
    CupertinoColors.systemGreen,
    CupertinoColors.systemRed,
    CupertinoColors.systemOrange,
    CupertinoColors.systemPurple,
    CupertinoColors.systemPink,
    CupertinoColors.systemYellow,
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Glass Effect Container'),
      ),
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/home.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            children: [
              Text(
                'Last tap event: $_lastTapEvent',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Basic Glass Effect Container
              const Text(
                'Basic Glass Effect',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.white,
                ),
              ),
              const SizedBox(height: 12),
              CNGlassEffectContainer(
                glassStyle: _selectedGlassStyle,
                tint: _selectedTint,
                cornerRadius: _cornerRadius,
                interactive: _interactive,
                height: 150,
                width: 20,
                onTap: () =>
                    setState(() => _lastTapEvent = 'Basic container tapped'),
                child: Container(
                  width: double.infinity,
                  height: 120,
                  padding: const EdgeInsets.all(16.0),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Glass Effect Container',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.label,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Native glass effects with translucent backgrounds.',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.label,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Stack(
              //   children: [
              //     CNGlassEffectContainer(
              //       glassStyle: _selectedGlassStyle,
              //       tint: _selectedTint,
              //       cornerRadius: _cornerRadius,
              //       interactive: _interactive,
              //       width: double.infinity,
              //       height: 120,
              //       onTap: () => setState(
              //         () => _lastTapEvent = 'Basic container tapped',
              //       ),
              //       child: Container(),
              //     ),
              //     Container(
              //       width: double.infinity,
              //       height: 120,
              //       padding: const EdgeInsets.all(16.0),
              //       child: const Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Text(
              //             'Glass Effect Container',
              //             style: TextStyle(
              //               fontSize: 20,
              //               fontWeight: FontWeight.bold,
              //               color: CupertinoColors.label,
              //             ),
              //           ),
              //           SizedBox(height: 8),
              //           Text(
              //             'Native glass effects with translucent backgrounds.',
              //             style: TextStyle(
              //               fontSize: 14,
              //               color: CupertinoColors.label,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 32),

              // Stacked Glass Effects (updated to use glassStyle)
              const Text(
                'Stacked Glass Effects',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.white,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    // Background glass
                    CNGlassEffectContainer(
                      glassStyle: CNGlassStyle.regular,
                      cornerRadius: 20,
                      width: double.infinity,
                      height: 200,
                      child: Container(),
                    ),
                    // Foreground glass cards
                    Positioned(
                      top: 20,
                      left: 20,
                      child: CNGlassEffectContainer(
                        glassStyle: CNGlassStyle.clear,
                        tint: CupertinoColors.systemBlue,
                        cornerRadius: 12,
                        interactive: true,
                        width: 120,
                        height: 80,
                        onTap: () =>
                            setState(() => _lastTapEvent = 'Blue card tapped'),
                        child: Container(),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      right: 20,
                      child: CNGlassEffectContainer(
                        glassStyle: CNGlassStyle.regular,
                        tint: CupertinoColors.systemGreen,
                        cornerRadius: 12,
                        interactive: true,
                        width: 120,
                        height: 80,
                        onTap: () =>
                            setState(() => _lastTapEvent = 'Green card tapped'),
                        child: Container(),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 50,
                      right: 50,
                      child: CNGlassEffectContainer(
                        glassStyle: CNGlassStyle.clear,
                        tint: CupertinoColors.systemPurple,
                        cornerRadius: 12,
                        interactive: true,
                        height: 60,
                        onTap: () => setState(
                          () => _lastTapEvent = 'Purple card tapped',
                        ),
                        child: Container(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Controls
              Stack(
                children: [
                  CNGlassEffectContainer(
                    glassStyle: CNGlassStyle.regular,
                    cornerRadius: 16,
                    width: double.infinity,
                    height: 300, // Adjusted height
                    child: Container(),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Controls',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Glass Style Selector
                        Row(
                          children: [
                            const Text('Glass Style:'),
                            const Spacer(),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: _showGlassStylePicker,
                              child: Text(_selectedGlassStyle.name),
                            ),
                          ],
                        ),

                        // Tint Color Selector
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tint:'),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 50,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _availableColors.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    return GestureDetector(
                                      onTap: () =>
                                          setState(() => _selectedTint = null),
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: _selectedTint == null
                                                ? CupertinoColors.activeBlue
                                                : CupertinoColors.separator,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          CupertinoIcons.clear,
                                          size: 20,
                                        ),
                                      ),
                                    );
                                  }
                                  final color = _availableColors[index - 1];
                                  return GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedTint = color),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: color,
                                        border: Border.all(
                                          color: _selectedTint == color
                                              ? CupertinoColors.activeBlue
                                              : CupertinoColors.separator,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        // Corner Radius Slider
                        Row(
                          children: [
                            const Text('Corner Radius:'),
                            const Spacer(),
                            Text('${_cornerRadius.toInt()}'),
                          ],
                        ),
                        CupertinoSlider(
                          value: _cornerRadius,
                          min: 0,
                          max: 30,
                          divisions: 30,
                          onChanged: (value) =>
                              setState(() => _cornerRadius = value),
                        ),

                        // Interactive Toggle
                        Row(
                          children: [
                            const Text('Interactive:'),
                            const Spacer(),
                            CupertinoSwitch(
                              value: _interactive,
                              onChanged: (value) =>
                                  setState(() => _interactive = value),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  void _showGlassStylePicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: CupertinoPicker(
            itemExtent: 32,
            onSelectedItemChanged: (index) {
              setState(() => _selectedGlassStyle = CNGlassStyle.values[index]);
            },
            children: CNGlassStyle.values
                .map((style) => Text(style.name))
                .toList(),
          ),
        );
      },
    );
  }
}
