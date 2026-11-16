import ChoppyCore
import SwiftUI

enum LearnRoute: Hashable {
    case kana(KanaItem.Script)
    case topic(Topic)
    case translator
}

/// What the start screen shows about the current week.
/// Progress and streak stay at zero until persistence exists (Phase 1, step 5).
struct TodaySummary: Equatable {
    var week = 1
    var streak = 0
    var kanaLearned = 0
    var wordsLearned = 0

    /// The values of the Figma screen, for previews and design checks.
    static let sample = TodaySummary(week: 3, streak: 4, kanaLearned: 46, wordsLearned: 8)

    static var current: TodaySummary {
        #if DEBUG
        // Launch with `-sampleProgress YES` to see the screen with progress filled in.
        if UserDefaults.standard.bool(forKey: "sampleProgress") { return .sample }
        #endif
        return TodaySummary()
    }
}

/// The start screen ("Screen / Start" in Figma): the lantern alley with today's overview on top,
/// and a wooden panel with the word of the day and the week's progress below.
struct TodayView: View {
    var summary = TodaySummary.current

    @Environment(\.content) private var content
    @Environment(\.bottomBarInset) private var bottomBarInset
    @State private var groundY: CGFloat = 0

    private var topic: Topic? { content.topics.first }
    private var words: [VocabItem] { topic.map { content.vocab(inTopic: $0.id) } ?? [] }

    private var wordOfTheDay: VocabItem? {
        guard !words.isEmpty else { return nil }
        let day = Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 0
        return words[day % words.count]
    }

    var body: some View {
        NavigationStack {
            ChoppyScreen(nil) {
                GeometryReader { proxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            alley
                            panel
                        }
                        .frame(minHeight: max(proxy.size.height - bottomBarInset, 0))
                    }
                    .scrollBounceBehavior(.basedOnSize)
                }
            }
            .environment(\.backgroundScene, .alley(groundY: groundY))
            .navigationDestination(for: LearnRoute.self) { route in
                switch route {
                case .kana(let script): KanaChartView(script: script)
                case .topic(let topic): VocabListView(topic: topic)
                case .translator: TranslatorView()
                }
            }
        }
    }

    // MARK: Alley

    private var alley: some View {
        ZStack(alignment: .bottomTrailing) {
            if let topic {
                // The sign names this week's topic, kanji on the left and its reading on the right,
                // and opens the week's words.
                NavigationLink(value: LearnRoute.topic(topic)) {
                    LanternSign(columns: [topic.reading ?? "", topic.japanese])
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("Thema der Woche: \(topic.title)"))
                .accessibilityHint(Text("Öffnet die Wörter der Woche"))
                .padding(.trailing, 15)
                // The base stands a little behind the tile edge of the panel.
                .padding(.bottom, -4)
            }
            today
                .padding(.horizontal, Spacing.l)
                .padding(.top, Spacing.m)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(minHeight: 260, maxHeight: .infinity)
        // Choppy stands on the roof edge at the left and opens the translator.
        .overlay(alignment: .bottomLeading) {
            NavigationLink(value: LearnRoute.translator) {
                VStack(spacing: Spacing.xxs) {
                    Text("Übersetzen")
                        .font(.choppyCaption)
                        .foregroundStyle(.washi100)
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, Spacing.xxs)
                        .background(Color.sugi800)
                        .border(Color.sumi, width: 1.5)
                    ChoppyView(mood: .thinking, size: 64)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("Übersetzer öffnen"))
            .padding(.leading, Spacing.l)
        }
    }

    private var today: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("Woche \(summary.week) · \(Date.now.formatted(.dateTime.weekday(.wide)))")
                    .font(.choppyCaption)
                    .foregroundStyle(.washi300)
                // Two lines set tighter than the font's own line height, as in Figma (28/36).
                VStack(alignment: .leading, spacing: -4) {
                    Text("Heute")
                    Text("\(words.count) Wörter")
                }
                .font(.choppyDisplay)
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(.isHeader)
            }
            VStack(alignment: .leading, spacing: Spacing.xs) {
                if let topic {
                    Text("Thema: \(topic.title)").font(.choppyFootnote).foregroundStyle(.washi100)
                }
                ChochinCounter(lit: min(summary.streak, 7))
                Text(summary.streak == 0 ? "Noch keine Serie" : "\(summary.streak) Tage in Folge")
                    .font(.choppyCaption)
                    .foregroundStyle(.washi300)
            }
        }
    }

    // MARK: Panel

    private var panel: some View {
        VStack(spacing: 0) {
            TileEdge()
                .onGeometryChange(for: CGFloat.self) { $0.frame(in: .global).minY } action: { groundY = $0 }
            VStack(spacing: Spacing.s) {
                if let word = wordOfTheDay, let topic {
                    wordOfTheDayCard(word, topic: topic)
                }
                HStack(spacing: Spacing.s) {
                    NavigationLink(value: LearnRoute.kana(.hiragana)) {
                        ProgressBoard(title: "Hiragana", done: summary.kanaLearned, total: content.kana(.hiragana).count)
                    }
                    if let topic {
                        NavigationLink(value: LearnRoute.topic(topic)) {
                            ProgressBoard(title: "Wörter der Woche", done: summary.wordsLearned, total: words.count)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Spacing.m)
            .padding(.top, Spacing.s)
            .padding(.bottom, Spacing.m)
            .frame(maxWidth: .infinity)
            // The wood runs on behind the tab bar, so no sky shows between its roof tiles.
            .background { Color.sugi800.padding(.bottom, -(bottomBarInset + 80)) }
        }
    }

    private func wordOfTheDayCard(_ word: VocabItem, topic: Topic) -> some View {
        PaperCard(padding: 0) {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: Spacing.m) {
                    wordOfTheDayText(word)
                    Spacer(minLength: 0)
                    continueButton(topic)
                }
                VStack(alignment: .leading, spacing: Spacing.s) {
                    wordOfTheDayText(word)
                    continueButton(topic)
                }
            }
            .padding(.vertical, Spacing.s)
            .padding(.horizontal, Spacing.m)
        }
    }

    private func wordOfTheDayText(_ word: VocabItem) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Wort des Tages").font(.choppyCaption).foregroundStyle(.sugi400)
            Text(word.reading).font(.choppyTitle).lineLimit(1)
            Text(word.meanings.first ?? "").font(.choppyAccent(14, weight: .regular, relativeTo: .subheadline)).lineLimit(1)
        }
        .fixedSize(horizontal: true, vertical: false)
        .accessibilityElement(children: .combine)
    }

    private func continueButton(_ topic: Topic) -> some View {
        NavigationLink(value: LearnRoute.topic(topic)) { Text("Weiter lernen").fixedSize() }
            .buttonStyle(.choppy(.ink))
    }
}

#Preview("Leer") {
    TodayView()
        .environment(\.content, try! .loadBundled())
}

#Preview("Mit Fortschritt") {
    TodayView(summary: .sample)
        .environment(\.content, try! .loadBundled())
}
