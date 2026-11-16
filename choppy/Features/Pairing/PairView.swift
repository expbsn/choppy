import SwiftUI

/// "Wir": who the two players are, how their duels stand, their word boxes, and app settings.
/// Names and results are kept on this device for now; inviting each other and syncing through
/// iCloud follow with the pair space (Phase 1, step 5).
struct PairView: View {
    @Bindable private var store = LocalDraftStore.shared

    var body: some View {
        NavigationStack {
            ChoppyScreen("Wir", subtitle: Text("\(store.name(of: 0)) und \(store.name(of: 1))")) {
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.l) {
                        section("Ihr zwei") {
                            PaperCard(padding: Spacing.m) {
                                VStack(spacing: Spacing.s) {
                                    nameField("Spieler 1", text: $store.state.playerNames[0])
                                    Color.sumi.opacity(0.15).frame(height: 1)
                                    nameField("Spieler 2", text: $store.state.playerNames[1])
                                }
                            }
                            Text("Die Namen gelten vorerst nur auf diesem Gerät. Einladen und Abgleich über iCloud folgen.")
                                .font(.choppyFootnote)
                                .foregroundStyle(.washi300)
                        }

                        section("Duell-Stand") { duelRecord }

                        section("Wörter") {
                            HStack(spacing: Spacing.s) {
                                countBoard("Unsere Wörter", count: store.words(in: .shared).count)
                                countBoard("Meine Kartei", count: store.words(in: .own).count)
                            }
                            NavigationLink { TranslatorView() } label: {
                                ListRow(glyph: .symbol("character.bubble"), title: Text("Übersetzer"),
                                        subtitle: Text("Wort übersetzen und hinzufügen"))
                            }
                        }

                        section("App") {
                            VStack(spacing: Spacing.xxs) {
                                NavigationLink { ThemeEditorView() } label: {
                                    ListRow(glyph: .symbol("paintpalette"), title: Text("Farben"),
                                            subtitle: Text("Die Palette live anpassen"))
                                }
                                NavigationLink { CreditsView() } label: {
                                    ListRow(glyph: .symbol("heart.text.square"), title: Text("Credits & Lizenzen"))
                                }
                                #if DEBUG
                                NavigationLink { DesignGalleryView() } label: {
                                    ListRow(glyph: .symbol("swatchpalette"), title: Text("Design-Galerie"),
                                            subtitle: Text("Alle Bausteine auf einen Blick"))
                                }
                                #endif
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, Spacing.l)
                    .padding(.vertical, Spacing.m)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
    }

    @ViewBuilder
    private var duelRecord: some View {
        let wins = store.wins
        PaperCard(padding: Spacing.m) {
            if store.state.duels.isEmpty {
                Text("Noch kein Duell gespielt. Startet eins unter Spiele.").font(.choppyFootnote)
            } else {
                VStack(spacing: Spacing.xs) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(store.name(of: 0)).font(.choppyHeadline).frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(wins[0]) : \(wins[1])").font(.choppyMono(28, weight: .medium, relativeTo: .title))
                        Text(store.name(of: 1)).font(.choppyHeadline).frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    if let last = store.state.duels.first, last.scores.count == 2 {
                        Text("Letztes Duell \(last.scores[0]) : \(last.scores[1]) · \(last.date.formatted(.dateTime.day().month()))")
                            .font(.choppyCaption)
                            .foregroundStyle(.sugi400)
                    }
                }
            }
        }
    }

    private func section(_ title: LocalizedStringKey, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title).font(.choppyTitle)
            content()
        }
    }

    private func nameField(_ label: LocalizedStringKey, text: Binding<String>) -> some View {
        HStack(spacing: Spacing.s) {
            Text(label).font(.choppyCaption).foregroundStyle(.sugi400)
            TextField("Name", text: text)
                .font(.choppyHeadline)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .submitLabel(.done)
        }
    }

    private func countBoard(_ title: LocalizedStringKey, count: Int) -> some View {
        PaperCard {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(title).font(.choppyAccent(15, relativeTo: .subheadline))
                Text(count == 1 ? "1 Wort" : "\(count) Wörter").font(.choppyCaption).foregroundStyle(.sugi400)
            }
        }
    }
}

#Preview {
    PairView()
}
