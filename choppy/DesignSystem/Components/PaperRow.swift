import SwiftUI

/// A tappable row on a paper card: a glyph tile, title, optional subtitle and a chevron.
/// Use as the label of a `NavigationLink` with `.buttonStyle(.plain)`.
struct PaperRow: View {
    enum Glyph {
        case symbol(String)
        case japanese(String)
    }

    var glyph: Glyph
    var title: LocalizedStringKey
    var subtitle: LocalizedStringKey?

    var body: some View {
        PaperCard(padding: Spacing.s) {
            HStack(spacing: Spacing.s) {
                Group {
                    switch glyph {
                    case .symbol(let name):
                        Image(systemName: name).font(.system(size: 20, weight: .semibold))
                    case .japanese(let text):
                        Text(text).font(.choppyJapanese(text.count > 1 ? 19 : 26, weight: .bold)).minimumScaleFactor(0.5)
                    }
                }
                .foregroundStyle(.accent)
                .frame(width: 48, height: 48)
                .background(Color.accentSoft, in: .rect(cornerRadius: Radius.s))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.choppyHeadline)
                    if let subtitle {
                        Text(subtitle).font(.subheadline).foregroundStyle(.inkSoft)
                    }
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.wood)
            }
        }
        .contentShape(.rect)
    }
}

#Preview {
    VStack(spacing: Spacing.s) {
        PaperRow(glyph: .japanese("あ"), title: "Hiragana", subtitle: "104 Zeichen")
        PaperRow(glyph: .symbol("paintpalette"), title: "Farben & Stil")
    }
    .padding()
    .background { AppBackground() }
}
