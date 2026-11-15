import ChoppyCore
import SwiftUI

/// All words of one topic. A plain list for now; flashcards and furigana levels follow in Phase 3.
struct VocabListView: View {
    let topic: Topic
    @Environment(\.content) private var content

    var body: some View {
        ChoppyScreen("\(topic.title)", japanese: String(topic.japanese.prefix(2)), showsBack: true) {
            ScrollView {
                LazyVStack(spacing: Spacing.s) {
                    ForEach(content.vocab(inTopic: topic.id)) { word in
                        PaperCard(padding: Spacing.s) {
                            VStack(alignment: .leading, spacing: Spacing.xxs) {
                                if word.reading != word.surface {
                                    Text(word.reading).font(.choppyJapanese(13)).foregroundStyle(.inkSoft)
                                }
                                Text(word.surface).font(.choppyJapanese(24, weight: .bold))
                                Text(word.meanings.joined(separator: " · "))
                                if let note = word.note {
                                    Text(note).font(.footnote).foregroundStyle(.inkSoft)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    let content = try! ContentLibrary.loadBundled()
    NavigationStack {
        VocabListView(topic: content.topics[0])
    }
    .environment(\.content, content)
}
