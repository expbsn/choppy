# Choppy

A cozy, competitive Japanese learning app for two – native iOS (SwiftUI, iOS 26+).

Two learners study the same weekly vocabulary, kanji and grammar in sync, each with their own spaced-repetition schedule, and compete in mini-games. All data stays on-device and in iCloud (CloudKit) – no external backends, no analytics.

## Status

Phase 1 (Foundation) – project structure in place. See [`CLAUDE.md`](CLAUDE.md) for the full product brief and [`DECISIONS.md`](DECISIONS.md) for architecture decisions.

## Requirements

- Xcode 26+
- iOS 26+ device or simulator
- An iCloud account (CloudKit sync & pairing)

## Getting started

Open `choppy.xcodeproj` in Xcode and run the `choppy` scheme.

## Project layout

- `choppy/` – app target (App, Features, DesignSystem, Persistence, Services, Resources)
- `Packages/ChoppyCore/` – pure Swift domain logic (SRS, kana, content model, game rules)
- `Tools/ContentPipeline/` – offline content builder (planned)

## Tests

```bash
swift test --package-path Packages/ChoppyCore
```
