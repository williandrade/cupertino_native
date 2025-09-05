# cupertino_native

Native Liquid Glass widgets for iOS and macOS in Flutter with pixel‑perfect fidelity.

This plugin hosts real UIKit/AppKit controls inside Flutter using Platform Views and method channels. It matches native look/feel while still fitting naturally into Flutter code.

Does it work and is it fast? Yes. Is it a vibe-coded Frankenstein's monster patched together with duct tape? Also yes.

This package is a proof of concept for bringing Liquid Glass to Flutter. Contributions are most welcome. What we have here can serve as a great starting point for building a complete, polished library. The vision for this package is to bridge the gap until we have a good, new Cupertino library written entirely in Flutter. To move toward completeness, we can also improve parts that are easy to write in Flutter to match the new Liquid Glass style (e.g., improved `CupertinoScaffold`, theme, etc.).

## Installation

Add the dependency in your app’s `pubspec.yaml`:

```bash
flutter pub add cupertino_native
```

Then run `flutter pub get`.

Ensure your platform minimums are compatible:

- iOS `platform :ios, '14.0'`
- macOS 11.0+

You will also need to install the Xcode 26 beta and use `xcode-select` to set it as your default.

```bash
sudo xcode-select -s /Applications/Xcode-beta.app
```

## What's left to do?
So far, this is more of a proof of concept than a full package (although the included components do work). Future improvements include:

- Cleaning up the code. Probably by someone who knows a bit about Swift.
- Adding more native components.
- Reviewing the Flutter APIs to ensure consistency and eliminate redundancies.
- Extending the flexibility and styling options of the widgets.
- Investigate how to best combine scroll views with the native components.
- macOS compiles and runs, but it's untested with Liquid Glass and generally doesn't look great.

## How was this done?
Pretty much vibe-coded with Codex and GPT-5. 😅
