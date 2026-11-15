import ChoppyCore
import SwiftUI

enum LearnRoute: Hashable {
    case kana(KanaItem.Script)
    case topic(Topic)
}

struct LearnView: View {
    @Environment(\.content) private var content

    var body: some View {
        NavigationStack {
            ChoppyScreen("Lernen", japanese: "学ぶ") {
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.m) {
                        HStack(alignment: .center, spacing: Spacing.s) {
                            ChoppyView(mood: .happy, size: 96)
                            PaperCard {
                                VStack(alignment: .leading, spacing: Spacing.xxs) {
                                    Text("いらっしゃいませ！").font(.choppyJapanese(20, weight: .bold))
                                    Text("Willkommen! Fangt mit den Kana an.")
                                        .font(.subheadline)
                                        .foregroundStyle(.inkSoft)
                                }
                            }
                        }

                        Text("Schriften").font(.choppyTitle)
                        NavigationLink(value: LearnRoute.kana(.hiragana)) {
                            PaperRow(glyph: .japanese("あ"), title: "Hiragana",
                                     subtitle: "\(content.kana(.hiragana).count) Zeichen")
                        }
                        NavigationLink(value: LearnRoute.kana(.katakana)) {
                            PaperRow(glyph: .japanese("ア"), title: "Katakana",
                                     subtitle: "\(content.kana(.katakana).count) Zeichen")
                        }

                        if !content.topics.isEmpty {
                            Text("Themen").font(.choppyTitle).padding(.top, Spacing.xs)
                            ForEach(content.topics) { topic in
                                NavigationLink(value: LearnRoute.topic(topic)) {
                                    PaperRow(glyph: .japanese(topic.japanese), title: "\(topic.title)",
                                             subtitle: "\(content.vocab(inTopic: topic.id).count) Wörter")
                                }
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .padding()
                }
            }
            .navigationDestination(for: LearnRoute.self) { route in
                switch route {
                case .kana(let script): KanaChartView(script: script)
                case .topic(let topic): VocabListView(topic: topic)
                }
            }
        }
    }
}

#Preview {
    LearnView()
        .environment(\.content, try! .loadBundled())
}
