# cupertino_native

Native iOS and macOS widgets in Flutter with pixel‑perfect fidelity.

cupertino_native hosts real UIKit/AppKit controls inside Flutter using Platform Views and MethodChannels. It aims to match native look/feel while fitting naturally into Flutter code.

Supported platforms: iOS and macOS. Graceful fallbacks are provided on other platforms using standard Flutter widgets.

## Features

- Native rendering: UIKit on iOS, AppKit on macOS
- Dark mode aware: syncs with `CupertinoTheme` brightness
- Tinting and style control with dynamic color resolution
- SF Symbols support with multiple rendering modes
- Intrinsic sizing for views that can shrink‑wrap
- Fallbacks to Flutter widgets for non‑Apple targets

## Controls

- Switch: `CNSwitch`
- Slider: `CNSlider`
- Segmented control: `CNSegmentedControl`
- Icon (SF Symbols): `CNIcon`
- Tab bar: `CNTabBar` + `CNTabBarItem`

## Requirements

- Flutter: `>= 3.3.0`
- Dart SDK: `>= 3.9.0`
- iOS: 14.0+
- macOS: 11.0+

## Installation

Add the dependency in your app’s `pubspec.yaml`:

```yaml
dependencies:
  cupertino_native: ^0.0.1
```

Then run `flutter pub get`.

No additional setup is required, but ensure your platform minimums are compatible:

- iOS `platform :ios, '14.0'`
- macOS 11.0+

## Usage

Import the package:

```dart
import 'package:cupertino_native/cupertino_native.dart';
```

### Switch

```dart
CNSwitch(
  value: isOn,
  onChanged: (v) => setState(() => isOn = v),
  color: CupertinoColors.systemPink, // optional tint
)
```

### Slider

```dart
CNSlider(
  value: progress,
  min: 0,
  max: 100,
  onChanged: (v) => setState(() => progress = v),
  step: 10, // optional stepping
  thumbColor: CupertinoColors.systemPink,
  trackColor: CupertinoColors.systemBlue,
  trackBackgroundColor: CupertinoColors.systemGrey2,
)
```

### Segmented Control

Text labels:

```dart
CNSegmentedControl(
  labels: const ['One', 'Two', 'Three'],
  selectedIndex: index,
  onValueChanged: (i) => setState(() => index = i),
  tint: CupertinoColors.systemPink, // optional
)
```

SF Symbols:

```dart
CNSegmentedControl(
  labels: const [],
  sfSymbols: const [
    CNSymbol('heart.fill', size: 22, color: CupertinoColors.systemPink),
    CNSymbol('star.fill',  size: 18, color: CupertinoColors.systemYellow),
    CNSymbol('bell.fill',  size: 26, color: CupertinoColors.systemBlue),
  ],
  selectedIndex: index,
  onValueChanged: (i) => setState(() => index = i),
  // Or set global icon options:
  // iconSize: 20,
  // iconColor: CupertinoColors.systemBlue,
  // iconRenderingMode: CNSFSymbolRenderingMode.hierarchical,
)
```

### Icon (SF Symbols)

```dart
const CNIcon(
  symbol: CNSymbol(
    'star.fill',
    size: 28,
    color: CupertinoColors.systemYellow,
    mode: CNSFSymbolRenderingMode.monochrome,
  ),
)
```

Palette and multicolor modes are supported where available by the OS. Set `paletteColors` and `mode: CNSFSymbolRenderingMode.palette` for palette icons, or `mode: CNSFSymbolRenderingMode.multicolor` for OS‑defined multicolor.

### Tab Bar

`CNTabBar` renders a native tab bar you can overlay on your page and sync with a `TabController` or app state.

```dart
Align(
  alignment: Alignment.bottomCenter,
  child: CNTabBar(
    items: const [
      CNTabBarItem(label: 'Home',    icon: CNSymbol('house.fill', size: 22)),
      CNTabBarItem(label: 'Profile', icon: CNSymbol('person.crop.circle', size: 22)),
      CNTabBarItem(label: 'Settings',icon: CNSymbol('gearshape.fill', size: 22)),
      CNTabBarItem(                  icon: CNSymbol('magnifyingglass', size: 22)),
    ],
    currentIndex: index,
    onTap: (i) => setState(() => index = i),
    // Optional layout options:
    split: true,
    rightCount: 1,
    shrinkCentered: true,
  ),
)
```

## API Overview

Key props (not exhaustive):

- `CNSwitch`
  - `value`, `onChanged`, `enabled`, `height`, `color`, `controller`
- `CNSlider`
  - `value`, `onChanged`, `min`, `max`, `enabled`, `height`
  - `color`, `thumbColor`, `trackColor`, `trackBackgroundColor`, `step`, `controller`
- `CNSegmentedControl`
  - `labels` or `sfSymbols`, `selectedIndex`, `onValueChanged`, `enabled`, `height`, `tint`, `shrinkWrap`
  - Icon options: `iconSize`, `iconColor`, `iconPaletteColors`, `iconRenderingMode`, `iconGradientEnabled`
- `CNIcon`
  - `symbol` (`CNSymbol`), `size`, `color`, `mode`, `gradient`, `height`
- `CNTabBar`
  - `items`, `currentIndex`, `onTap`, `tint`, `backgroundColor`, `iconSize`, `height`
  - Layout: `split`, `rightCount`, `shrinkCentered`, `splitSpacing`

## Behavior and Caveats

- Platform views: These widgets are hosted in native views (`UiKitView`/`AppKitView`). Some Flutter effects that rely on advanced compositing, clipping, or transforms can behave differently than pure Flutter widgets.
- Theming: Colors are resolved against `CupertinoTheme`. `CupertinoDynamicColor` values are resolved to concrete ARGB on the platform side.
- Fallbacks: On non‑Apple targets, equivalent Flutter widgets are used (`CupertinoSegmentedControl`, `CupertinoTabBar`, `Slider`, `Switch`). Functionality and appearance may not be identical.
- Gestures: Sliders and switches forward relevant gesture recognizers (drag/tap) to ensure correct behavior inside scroll views.
- Sizing: Some widgets support intrinsic measurement (e.g., segmented control and tab bar). Use `shrinkWrap` or allow the widget to size itself when appropriate.

## Example App

An example showcasing all controls is included:

```bash
cd example
flutter pub get
flutter run -d macos   # or: flutter run -d ios
```

Relevant demo pages:

- `example/lib/demos/switch.dart`
- `example/lib/demos/slider.dart`
- `example/lib/demos/segmented_control.dart`
- `example/lib/demos/icon.dart`
- `example/lib/demos/tab_bar.dart`

## Contributing

Contributions are welcome! Please follow these conventions when adding a new widget:

- Separate file and class under `lib/components`.
- Add a demo page under `example/lib/demos`.
- Implement corresponding Swift code for iOS under `ios/Classes` and for macOS under `macos/Classes`.
- Register the platform view factory with a unique viewType (e.g., `CupertinoNativeMyControl`).
- Follow Flutter style conventions and keep APIs consistent with existing components.
- Validate changes with `flutter analyze`.

## License

See `LICENSE`.
