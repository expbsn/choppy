import ChoppyCore
import SwiftUI

struct GamesView: View {
    @Environment(\.content) private var content
    @State private var showsDuel = false

    var body: some View {
        let store = LocalDraftStore.shared
        NavigationStack {
            ChoppyScreen("Spiele", subtitle: Text("Zu zweit gegeneinander")) {
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.m) {
                        PaperCard(padding: Spacing.m) {
                            VStack(alignment: .leading, spacing: Spacing.s) {
                                HStack(alignment: .firstTextBaseline) {
                                    Text("Vokabelduell").font(.choppyTitle)
                                    Spacer(minLength: Spacing.xs)
                                    Text("\(store.wins[0]) : \(store.wins[1])").font(.choppyMono(20, weight: .medium))
                                }
                                Text("Abwechselnd an einem Gerät: Wer kennt mehr Wörter der Woche? Pro Frage \(VocabDuelRules.seconds) Sekunden.")
                                    .font(.choppyFootnote)
                                Text("\(store.name(of: 0)) gegen \(store.name(of: 1))")
                                    .font(.choppyCaption)
                                    .foregroundStyle(.sugi400)
                                Button("Duell starten") { showsDuel = true }
                                    .buttonStyle(.choppy(.ink, fullWidth: true))
                                    .disabled(content.vocab.count < 2)
                            }
                        }
                        Text("Weitere Spiele folgen: Memory, Wordle, Shiritori.")
                            .font(.choppyFootnote)
                            .foregroundStyle(.washi300)
                    }
                    .padding(.horizontal, Spacing.l)
                    .padding(.vertical, Spacing.m)
                }
            }
        }
        .fullScreenCover(isPresented: $showsDuel) {
            VocabDuelView(pool: content.topics.first.map { content.vocab(inTopic: $0.id) } ?? content.vocab)
        }
    }
}

#Preview {
    GamesView()
        .environment(\.content, try! .loadBundled())
}
