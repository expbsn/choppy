# Project: Choppy – a cozy, competitive Japanese learning app for two

You are helping two people (a couple, both beginners in Japanese, studying together) build **Choppy**, a native iOS app for learning Japanese. Please read this whole brief before doing anything.

**First steps (before planning):**
1. Set up a new **GitHub repository** for the project (name: `choppy`, **private** – ask us before making anything public), with a Swift/Xcode `.gitignore`, a short `README.md` and an initial commit.
2. Save **this entire brief as `CLAUDE.md` in the repository root** and commit it, so it serves as the persistent project context. Whenever we change a decision, update `CLAUDE.md` accordingly.
3. Then start in plan mode: propose an architecture and a phased plan, list open questions, and wait for our confirmation before writing app code.

---

## 1. Product vision

Choppy is a Japanese learning app designed for **two learners who study the same material in sync** and **compete against each other in mini-games**. Each week, both users get the same vocabulary, kanji and grammar, but each has their own individual review schedule. Learning should feel like a cozy, traditional Japanese space, not a sterile flashcard tool.

Starting priority: **become confident in the writing systems** (hiragana, katakana, first kanji), then build vocabulary and sentences, starting with everyday topics.

Mascot: **Choppy** (we design the artwork ourselves – use clearly named placeholder assets). Choppy reflects the streak: happy and fed when we practice, hungry/sad when we miss days.

---

## 2. Hard constraints

- **Swift + SwiftUI only**, native iOS. **Minimum deployment target: iOS 26.** Use modern APIs freely (`@Observable`, `NavigationStack`, Translation framework, Foundation Models, current SwiftUI). Note: Foundation Models only runs on Apple Intelligence–capable devices with Apple Intelligence enabled – check availability at runtime and show a graceful fallback state for the chat practice if it's unavailable.
- **No external databases or backends.** All persistence and sync via **iCloud / CloudKit** (private + shared databases). Apple frameworks are fine (CloudKit, Game Center/GameKit, Translation, Foundation Models, PencilKit, AVFoundation, Core Text, etc.).
- **Images only from Unsplash or other license-free sources.** Respect Unsplash API guidelines (attribution, hotlinking, download tracking) or bundle curated license-free images with attribution stored alongside.
- **All bundled content must have a compatible license**, and attributions must be shown in an in-app "Credits / Licenses" screen.
- Keep third-party Swift packages to a minimum; justify every dependency.

---

## 3. Architecture requirements

### 3.1 Data & sync
- Local-first: the app must work offline; sync when available.
- **Private data per user** (e.g. individual spaced-repetition state, settings, personal streak) in the user's private CloudKit database.
- **Shared "pair" space** between the two users via **CKShare** (one user invites the other). The shared space holds: the weekly plan (which vocab/kanji/grammar are assigned this week), shared custom vocab added by either user, game results, weekly test results, the shared path/progress.
- Important: check the current state (iOS 26) of **SwiftData vs. Core Data (`NSPersistentCloudKitContainer`) regarding CloudKit *sharing* support** (shared database / `CKShare`). Pick the approach that actually supports sharing between two iCloud accounts (e.g. SwiftData for private data plus Core Data or direct CloudKit for the shared space, if needed). Explain the trade-off before committing.
- Design the schema so content can be versioned and extended later (more lessons, levels, games).

### 3.2 Multiplayer for games
CloudKit is not real-time. Propose a multiplayer approach per game type, e.g.:
- **Real-time** timed games (who answers more in X seconds): Game Center real-time matches, or MultipeerConnectivity when both are nearby.
- **Turn-based** games (Shiritori, Shogi, Tabu-style): Game Center turn-based matches.
- **Asynchronous** challenges (same set, compare scores later): CloudKit shared records.
- Optional: local pass-and-play on one device.
Build a small reusable game framework (game session, players, timer, scoring, result screen, result saved to shared space) so new games are cheap to add.

### 3.3 Spaced repetition
- Use a modern SRS algorithm (propose **FSRS** or SM-2 and justify). Scheduling is **individual per user**, while the **set of items introduced each week is shared**.
- Items that a user gets wrong often are tracked as "weak items" and fed into other modes (games, chat practice suggestions, weekly test).

### 3.4 Language tooling
- **Furigana** everywhere it makes sense, toggleable per user and per difficulty level. Render with ruby annotations (Core Text `CTRubyAnnotation` wrapped for SwiftUI, or a custom view). Readings come from the content data; for user-added text, propose a way to generate readings on-device (e.g. `CFStringTokenizer` transcription) and allow manual correction.
- **Text-to-speech: Kokoro TTS.** Investigate how to run Kokoro (Japanese voice) on-device on iOS (Core ML / MLX ports), report feasibility, model size and licensing. Build a `SpeechService` protocol so we can fall back to `AVSpeechSynthesizer` and swap engines. Cache generated audio.
- **Translator → add as vocab**: translate a word/phrase (prefer Apple's on-device **Translation** framework) and add it directly as a vocabulary card (with reading, meaning, optional example sentence and image).
- **Chat practice** needs an LLM. Prefer Apple's on-device **Foundation Models** framework if it handles Japanese well enough; check availability/device requirements and design a `ChatTutorService` protocol so another provider could be plugged in later. Flag this as a decision for us.

### 3.5 Content sources (verify licenses)
Suggest and verify sources such as JMdict / KANJIDIC2 (EDRDG), KanjiVG (stroke order), Tatoeba (example sentences), JLPT-level lists. Build an offline content pipeline (script or tool) that converts sources into a bundled, versioned content format, organized by **topic** and **difficulty/lesson**, starting with everyday life (greetings, food, numbers, time, family, shopping, travel…).

---

## 4. Features

### 4.1 Vocabulary (flashcards)
- Flashcards with SRS, front/back configurable (JP→DE, DE→JP, kanji→reading, audio→meaning).
- Sorted by **topics**, starting with everyday life.
- Every word has: kanji/kana, reading, German meaning, audio, optional image, example sentence(s).
- Users can add their own words (manually or via translator); added words go to the shared space.

### 4.2 Sentences
- Learn vocab in context: example sentences per word, sentence building exercises (arrange words/particles), fill-in-the-gap.
- Sentences reuse the week's vocabulary.

### 4.3 Writing systems / alphabet practice
Divided into lessons and difficulty levels:
1. Romaji → write in hiragana / katakana / kanji (with help/hints at the start, fading out).
2. Hiragana → kanji.
3. Whole sentences.
4. Later: German → translate → write in Japanese.

### 4.4 Kanji drawing
- Draw kanji with finger/Apple Pencil (PencilKit), stroke-order animation and stroke-by-stroke checking (based on KanjiVG data).

### 4.5 Listening
- Mode: one player sees a German sentence, translates it into Japanese (spoken or typed); the app/TTS reads it out; the other player has to guess/understand the meaning. Also a solo listening mode with TTS.

### 4.6 Chat practice
- Predefined topic, conversation goal and tone (e.g. "order food at a restaurant, polite").
- Time limit.
- Hints and a help button during the conversation.
- Final evaluation: what went well, corrections, improvement suggestions, and a **suggested follow-up exercise** (e.g. automatically build a game round out of the vocabulary the user was unsure about).

### 4.7 Competitive games (very important)
Every game has a short **interactive tutorial** on first launch. Planned games:
- **Vocab / kanji matching & guessing** on time – who gets more right.
- **Sentence building race** – build/guess a sentence faster or more correctly.
- **Shiritori** (word chain, kana-based, with validation against the dictionary).
- **Wordle** (Japanese kana version).
- **Wordbox** (word search / letter box style with kana).
- **Kniffel/Yahtzee equivalent**: dice/categories map to word groups – topics, conjugation forms, etc. (e.g. "full house" = all conjugations of one verb). Propose a concrete rule set.
- **Memory**: pairs of image (Unsplash) ↔ kanji/word.
- **Tabu**: describe a Japanese word without using forbidden words.
- **Shogi** (later phase – large scope).
- Further Japanese adaptations of classic games (propose ideas).
Games pull from the current week's content and each user's weak items.

### 4.8 Goals, gamification & weekly rhythm
- Weekly goals: X new vocab, Y kanji (configurable together in the shared space).
- **Weekly test** at the end of each week covering that week's vocab, sentences, kanji, etc. Results saved and compared.
- **Streaks** with Choppy's mood (happy / hungry / sad).
- **Progress path**: weeks shown as a path of **small Choppy footprints**.
- XP / achievements / head-to-head stats between the two players (keep it friendly and motivating).

---

## 5. Design language

- **Design direction "Laternengasse"** (changed 2026-11-15, replaces the washi/forest look): a Japanese lantern alley at night, drawn clean, between cartoon and anime. Rectangular shapes: cedar planks, roof-tile edges, paper in wooden frames, chōchin and andon lanterns, noren cloths, a maple with autumn leaves, hanko stamps for achievements. The Figma file `choppy-local-new` (file key `oUYoeLDCRRrJAY7w1cQHmI`) is the reference; the app follows its variables, components and screens.
- **Colours:** night blues and indigo for the sky, dark cedar browns for wood, warm paper tones for cards and text, lantern amber as the light, chōchin red and maple greens as accents.
- **Dark appearance only.** The design is a night scene, so the app forces dark appearance (`UIUserInterfaceStyle = Dark` in Info.plist / `.preferredColorScheme(.dark)`) and system controls match. All colours are named tokens in the design system.
- **Typography (Google Fonts, all OFL, bundled):** Zen Maru Gothic for interface text and Japanese readings, Yuji Boku for kanji and Yuji Syuku for kana in brush lettering, DM Mono for numbers and small captions. All registered via `UIAppFonts`, exposed through the design system with Dynamic Type support, and listed on the Credits screen.
- Smooth, playful micro-animations (Choppy reactions, footprints appearing, stamp effects).
- Create a small design system first (colors, typography, spacing, components like card, button, stamp, footprint path) and use it consistently.
- Mascot art comes from us – use placeholders with clear asset names and document the needed asset list (poses/moods, sizes).

---

## 6. Suggested phases (adjust and propose your own)

1. **Foundation**: project setup, design system, data model, CloudKit private + shared (pairing via CKShare), content pipeline with a first everyday-topic set.
2. **Writing systems first**: hiragana/katakana lessons, romaji→kana exercises, furigana rendering, TTS service.
3. **Vocabulary**: flashcards + SRS, topics, weekly shared plan, add-own-words + translator.
4. **First competitive game** + reusable game framework (timed vocab/kanji matching), then Memory and Wordle.
5. **Gamification**: streaks, Choppy moods, weekly goals, footprint path, weekly test.
6. **Kanji drawing**, sentences, listening mode.
7. **Chat practice**.
8. More games (Shiritori, Kniffel, Tabu, Wordbox, Shogi, …).

---

## 7. How to work with us

- Start in **plan mode**: give us an architecture overview, folder/module structure, data model, sync strategy, multiplayer strategy, and a phase plan. List every decision you need from us and every technical risk (Kokoro on-device, Foundation Models Japanese quality, CloudKit sharing, Game Center).
- Then work **phase by phase in small, reviewable steps**. After each step, summarize what you did and what we should test.
- Write clean, modular SwiftUI code (MVVM or a structure you justify), with protocols around services (speech, chat tutor, translation, sync, content) so they can be swapped and mocked.
- Add unit tests for core logic (SRS scheduling, game scoring, Shiritori validation, content parsing).
- Use Xcode previews with mock data for all views.
- Keep a `README.md` and a `DECISIONS.md` (architecture decisions with reasons) up to date.
- Never add external backends, analytics or tracking SDKs.

---

## 8. Repository notes (kept up to date by Claude)

- Xcode project `choppy.xcodeproj` (Xcode 26, file-system-synchronized groups), targets `choppy`, `choppyTests`, `choppyUITests`. Bundle ID `chop.app.choppy`, deployment target iOS 26.0, Swift default actor isolation = MainActor, approachable concurrency on.
- CloudKit + push (`remote-notification`) capabilities are enabled in the entitlements. Planned iCloud container: `iCloud.chop.app.choppy`.
- Fonts (registered via `UIAppFonts`, in `choppy/Resources/Fonts/`, static files from Google Fonts): **Zen Maru Gothic** Regular and Medium (`ZenMaruGothic-<Weight>`, interface and Japanese readings), **Yuji Boku** (`YujiBoku-Regular`, kanji in brush lettering), **Yuji Syuku** (`YujiSyuku-Regular`, kana in brush lettering), **DM Mono** Regular and Medium (`DMMono-<Weight>`, counts and captions).
- iPhone only, portrait only.
- **GitHub:** `expbsn/choppy` is **public** since 2026-11-16 (was private). Never commit secrets, API keys or personal data; keys go in an untracked `Secrets.xcconfig`.
- **Confirmed decisions (2026-10-30):** German UI (development region `de`, String Catalog). Paid developer account. Both devices support Apple Intelligence. Kokoro TTS is **bundled** in the app.
- **Architecture:** see `DECISIONS.md`. In short: SwiftData (private) + CKSyncEngine with a zone-wide CKShare (pair space). Pure logic lives in the local package `Packages/ChoppyCore`. FSRS-6 is our own implementation. No third-party packages.
- **Layout:** `choppy/{App, DesignSystem, Features, Persistence, Services, Resources}`, `Packages/ChoppyCore`, `Tools/ContentPipeline` (planned).
- **Design system** (`choppy/DesignSystem/`, see ADR-011; follows the Figma file `oUYoeLDCRRrJAY7w1cQHmI`): colour tokens are defined in code (`Theme/ColorToken.swift`) and named like the Figma variables (`yoru900`, `yoru800`, `ai700`, `ai500`, `sumi`, `sugi800`, `sugi600`, `sugi400`, `kawara`, `washi50`, `washi100`, `washi300`, `kasumi`, `akari400`, `akari600`, `momiji900/700/500/300`, `kouyouDai`, `kouyouKin`, `chochin`, `chochinYoru`); they can be overridden live via `ThemeStore` in the in-app editor "Farben". Fixed scenery colours live in `SceneColor`. Use `Color.sumi` / `.foregroundStyle(.washi50)`, never hex values in views. Text on the night background is `washi50` (secondary `washi300`); text on paper is `sumi` (secondary `sugi400`). Inside `Canvas`, read token colours into locals in `body` first. Fonts: `Font.choppyAccent` / `.choppyJapanese` (Zen Maru Gothic), `.choppyMono` (DM Mono), `Text(brush:size:)` (kanji in Yuji Boku, kana in Yuji Syuku) and the scale `.choppyDisplay/.choppyTitle/.choppyHeadline/.choppyBody/.choppyFootnote/.choppyCaption`. Layout: `Spacing` (24 pt side margin on the night background), `Radius.s` (2 pt, the design is rectangular). **Every screen is wrapped in `ChoppyScreen(title, subtitle:, showsBack:)`** (custom header without buttons on the right, back button centred on title and caption, hides the system nav bar; pass `nil` as title for no header). Scrolled content blurs (system soft edge effect, starting 28 pt below the header) and darkens under a night veil; `MapleCorner` (crown plus two chōchin that swing on page and tab changes and follow the phone's tilt via `LanternMotion`) is drawn in front of it and stays sharp. Root tabs use the custom `LanternTabBar` (tile edge over a cedar beam; a small andon lantern under the selected tab lights it from below and glides to the new tab; the lantern stands in the bottom safe area). Scroll content clears the bar via `contentMargins`. `AppBackground` draws the night sky; screens can set `.environment(\.backgroundScene, .alley(groundY:))` for the lantern alley (moon, skyline, tall maple; used on the start screen). Components: `PaperCard` (paper in a wooden frame), `ProgressBoard`, `ListRow` (row with hairline on the night background), `.buttonStyle(.choppy(.paper/.ink/.plank/.quiet))`, `PlankIconButton`, `TileEdge`, `Chochin`, `ChochinCounter`, `Holztafel`, `NorenSwitch`, `LanternSign`, `LanternCard`, `AnswerPlank`, `HankoStamp`, `FootprintPath` (week 1 at the bottom), `ChoppyView(mood:)`. The debug-only "Design-Galerie" (Wir tab) shows them all.
- **Content** (ChoppyCore, ADR-003): `KanaCatalog` (kana tables in code), `VocabItem`/`FuriganaSegment`/`Topic`, `ContentBundle` + `ContentLibrary` (decode, validate, index). The app loads `choppy-content.json` once and passes the library through `@Environment(\.content)`.
- **Credits:** every bundled third-party item gets an entry in `Credit.all` (`choppy/Features/Credits/Credit.swift`) and, if available, its license text in `choppy/Resources/Licenses/`. A unit test checks that the license files exist.
- **Phase status:** Phase 1, steps 1–3 are done and restyled to the Laternengasse design. Added as drafts on 2026-11-15 (see ADR-012): the translator (Choppy on the start screen opens it; Apple Translation framework, de→ja, device only), the Wir page (player names, duel record, word boxes) and the first game, the Vokabelduell (two players take turns on one device; rules in `ChoppyCore/Games/VocabDuel.swift`). These keep their data in `LocalDraftStore` (one JSON file on the device, not synced) until SwiftData and the CloudKit pair space exist (step 5). Translator words are not yet part of flashcards or games. The Pfad screen is still the old footprint list; its new design is drafted in Figma ("Screen / Pfad"). Start-screen progress and streak stay at zero; `-sampleProgress YES` shows sample values in debug builds. Next: step 4 (content pipeline) and step 5 (persistence, pairing).
- **Commands:** `swift test --package-path Packages/ChoppyCore`; `xcodebuild -project choppy.xcodeproj -scheme choppy -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build` (or `test`).
