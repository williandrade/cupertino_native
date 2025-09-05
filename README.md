# cupertino_native

Native Liquid Glass widgets for iOS and macOS in Flutter with pixel‑perfect fidelity.

cupertino_native hosts real UIKit/AppKit controls inside Flutter using Platform Views and MethodChannels. It matches native look/feel while still fitting naturally into Flutter code.

Does it work and is it fast? Yes. Is it a vibe-coded Frankenstein's monster patched together with duct tape? Also yes.

This package is meant as a proof of concept of how we can bring Liquid Glass to Flutter. Contributions are most welcome, what we have here can serve as a great starting point for building a complete, polished library. The vision for this package is to bridge the gap until we have a good, new Cupertino library written entierly in Flutter. To make it more complete, we can also improve the parts that are easy to write in Flutter to match the new Liquid Glass style (e.g. improved CupertinoScaffold, theme, etc).

## Installation

Add the dependency in your app’s `pubspec.yaml`:

```yaml
dependencies:
  cupertino_native: ^0.0.1
```

Then run `flutter pub get`.

Ensure your platform minimums are compatible:

- iOS `platform :ios, '14.0'`
- macOS 11.0+

You will also need to install the XCode 26 beta and use `xcode-select` to set it as your default.

```bash
sudo xcode-select -s /Applications/Xcode-beta.app
```

## What's left to do?
So far, this is more of a proof of concept than a full package (although, the components in the do work). Future improvements include:

- Cleaning up the code. Probably by someone who knows a bit about Swift.
- Adding more native components.
- Reviewing the Flutter APIs, making sure everything is consistent and there are no redundencies.
- Extend the flexibility an styling options of the widgets.
- Investigate how to best combine scroll views with the native components.
- MacOS compiles and runs, but untested with Liquid Glass and generally doesn't look too good.

## How was this done?
Pretty much vibe-coded with Codex and GPT-5. 😅
