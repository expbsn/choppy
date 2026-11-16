import ChoppyCore
import SwiftUI

/// All words of one topic, in the style of "Wörter der Woche" on the Figma screen "Wortschatz".
/// A plain list for now; the translator lantern, flashcards and furigana levels follow in Phase 3.
struct VocabListView: View {
    let topic: Topic
    @Environment(\.content) private var content

    var body: some View {
        let words = content.vocab(inTopic: topic.id)
        ChoppyScreen("\(topic.title)", subtitle: Text("\(topic.japanese) \(topic.reading ?? "") · \(words.count) Wörter"), showsBack: true) {
            ScrollView {
                LazyVStack(spacing: Spacing.xxs) {
                    ForEach(words) { word in
                        WordRow(word: word)
                    }
                }
                .padding(.horizontal, Spacing.l)
                .padding(.vertical, Spacing.xs)
            }
        }
    }
}

/// One word. Short kanji words follow the Figma row (brush glyph, reading, meaning). Kana-only words
/// and phrases that are too long for the glyph column are set on their own line instead.
private struct WordRow: View {
    let word: VocabItem

    var body: some View {
        // No learning state yet, so every lantern is still unlit.
        if word.surface != word.reading, word.surface.count <= 3 {
            ListRow(glyph: .brush(word.surface), title: Text(word.reading), subtitle: Text(meanings),
                    trailing: .lantern(isLit: false))
        } else {
            HStack(spacing: Spacing.s) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(brush: word.surface, size: 24, relativeTo: .title2)
                        .foregroundStyle(.washi50)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    if word.reading != word.surface {
                        Text(word.reading).font(.choppyAccent(15, relativeTo: .subheadline)).foregroundStyle(.washi100)
                    }
                    Text(meanings).font(.choppyFootnote).foregroundStyle(.washi300)
                    if let note = word.note {
                        Text(note).font(.choppyFootnote).foregroundStyle(.kasumi)
                    }
                }
                Spacer(minLength: 0)
                Chochin(isLit: false)
            }
            .padding(.vertical, Spacing.xs)
            .overlay(alignment: .bottom) { Color.washi100.opacity(0.12).frame(height: 1) }
            .accessibilityElement(children: .combine)
        }
    }

    private var meanings: String { word.meanings.joined(separator: " · ") }
}

#Preview {
    let content = try! ContentLibrary.loadBundled()
    NavigationStack {
        VocabListView(topic: content.topics[0])
    }
    .environment(\.content, content)
}
