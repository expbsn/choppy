import SwiftUI

/// A row directly on the night background with a hairline below ("Wortzeile" in Figma):
/// a glyph, a title with an optional subtitle, and something at the trailing edge.
/// Used for vocabulary and, as the label of a `NavigationLink`, for navigation lists.
struct ListRow: View {
    enum Glyph {
        case symbol(String)
        /// Japanese text in the brush fonts.
        case brush(String)
    }

    enum Trailing {
        case none
        case chevron
        /// A chōchin that is lit once the word is learned.
        case lantern(isLit: Bool)
    }

    var glyph: Glyph?
    var title: Text
    var subtitle: Text?
    var trailing: Trailing = .chevron

    var body: some View {
        HStack(spacing: Spacing.s) {
            if let glyph {
                Group {
                    switch glyph {
                    case .symbol(let name):
                        Image(systemName: name).font(.system(size: 20, weight: .regular))
                    case .brush(let text):
                        Text(brush: text, size: 28).lineLimit(1).minimumScaleFactor(0.5)
                    }
                }
                .foregroundStyle(.washi50)
                .frame(width: glyphWidth(glyph), alignment: .leading)
            }
            VStack(alignment: .leading, spacing: 0) {
                title.font(.choppyAccent(15, relativeTo: .subheadline)).foregroundStyle(.washi100)
                subtitle?.font(.choppyFootnote).foregroundStyle(.washi300)
            }
            Spacer(minLength: 0)
            switch trailing {
            case .none: EmptyView()
            case .chevron:
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(.washi300)
            case .lantern(let isLit):
                Chochin(isLit: isLit)
            }
        }
        .padding(.vertical, Spacing.xs)
        .frame(minHeight: 57)
        .overlay(alignment: .bottom) { Color.washi100.opacity(0.12).frame(height: 1) }
        .contentShape(.rect)
    }

    /// Brush glyphs get the 64 pt column of the Figma row; symbols only need their own width.
    private func glyphWidth(_ glyph: Glyph) -> CGFloat {
        switch glyph {
        case .symbol: 28
        case .brush: 64
        }
    }
}

#Preview {
    VStack(spacing: Spacing.xxs) {
        ListRow(glyph: .brush("蕎麦"), title: Text("そば"), subtitle: Text("Buchweizennudeln"), trailing: .lantern(isLit: true))
        ListRow(glyph: .brush("水"), title: Text("みず"), subtitle: Text("Wasser"), trailing: .lantern(isLit: false))
        ListRow(glyph: .symbol("paintpalette"), title: Text("Farben & Stil"), subtitle: Text("Farben anpassen"))
    }
    .padding(.horizontal, Spacing.l)
    .frame(maxHeight: .infinity)
    .background { AppBackground() }
}
