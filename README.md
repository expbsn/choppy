# Choppy

A cozy, competitive Japanese learning app for two – native iOS (SwiftUI, iOS 26+).

Two learners study the same weekly vocabulary, kanji and grammar in sync, each with their own spaced-repetition schedule, and compete in mini-games. All data stays on-device and in iCloud (CloudKit) – no external backends, no analytics.

## Status

Phase 1 (Foundation) – structure, the "Laternengasse" design system and the content model with kana are in place. See [`CLAUDE.md`](CLAUDE.md) for the full product brief and [`DECISIONS.md`](DECISIONS.md) for architecture decisions.

## Requirements

- Xcode 26+
- iOS 26+ device or simulator
- An iCloud account (CloudKit sync & pairing)

## Getting started

Open `choppy.xcodeproj` in Xcode and run the `choppy` scheme.

## Project layout

- `choppy/` – app target (App, Features, DesignSystem, Persistence, Services, Resources)
- `Packages/ChoppyCore/` – pure Swift domain logic (SRS, kana, content model, game rules)
- `choppy/Resources/Content/choppy-content.json` – bundled vocabulary and topics
- `Tools/ContentPipeline/` – offline content builder (planned)

## Tests

```bash
swift test --package-path Packages/ChoppyCore
xcodebuild -project choppy.xcodeproj -scheme choppy -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

## Design

The look follows the Figma file "choppy-local-new" (design direction "Laternengasse": a lantern alley at night). Colour tokens in `choppy/DesignSystem/Theme/ColorToken.swift` are named like the Figma variables. Fonts: Zen Maru Gothic, Yuji Boku, Yuji Syuku and DM Mono (Google Fonts, OFL).

In the app, open **Wir → Farben** to change any colour live on the device. "Werte kopieren" or the share button sends the current values, so they can be made the new defaults in code and in Figma.

Debug builds show the start screen with sample progress when launched with `-sampleProgress YES`.

## Mascot assets (to be drawn by us)

Drop the artwork into `choppy/Assets.xcassets` under exactly these names. Until then, the app shows a drawn placeholder (dashed outline).

| Asset name | Used for | Format |
|---|---|---|
| `choppy_happy` | default, after practising | PDF vector (preferred) or PNG @2x/@3x, square, 160 pt |
| `choppy_fed` | streak kept today | same |
| `choppy_hungry` | no practice yet today | same |
| `choppy_sad` | streak broken | same |
| `choppy_sleeping` | night / inactive | same |
| `choppy_cheering` | during games, encouraging | same |
| `choppy_thinking` | chat practice, hints | same |
| `choppy_celebrating` | wins, weekly test passed | same |
| `footprint` | progress path (rendered as a template, tinted by the app) | single-colour PDF, square, 28 pt |
