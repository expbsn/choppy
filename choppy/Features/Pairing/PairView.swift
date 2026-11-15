import SwiftUI

struct PairView: View {
    var body: some View {
        NavigationStack {
            ChoppyScreen("Wir", japanese: "二人") {
                ScrollView {
                    VStack(spacing: Spacing.s) {
                        PaperCard {
                            Text("Hier ladet ihr euch bald gegenseitig ein und vergleicht eure Fortschritte.")
                                .foregroundStyle(.inkSoft)
                        }
                        .padding(.bottom, Spacing.s)

                        NavigationLink { ThemeEditorView() } label: {
                            PaperRow(glyph: .symbol("paintpalette.fill"), title: "Farben & Stil",
                                     subtitle: "Farben, Hintergrund und Schrift anpassen")
                        }
                        NavigationLink { CreditsView() } label: {
                            PaperRow(glyph: .symbol("heart.text.square.fill"), title: "Credits & Lizenzen")
                        }
                        #if DEBUG
                        NavigationLink { DesignGalleryView() } label: {
                            PaperRow(glyph: .symbol("swatchpalette.fill"), title: "Design-Galerie",
                                     subtitle: "Alle Bausteine auf einen Blick")
                        }
                        #endif
                    }
                    .buttonStyle(.plain)
                    .padding()
                }
            }
        }
    }
}

#Preview {
    PairView()
}
