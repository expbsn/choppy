import SwiftUI

/// A sheet of paper in a wooden frame ("Speisetafel" in Figma), like the menu boards in the alley.
/// The default container for content blocks; text on it is ink-dark.
struct PaperCard<Content: View>: View {
    var padding: CGFloat = Spacing.s
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.sumi)
            .background(Color.washi100)
            .padding(4)
            .background(Color.sugi400, in: .rect(cornerRadius: Radius.s))
            .padding(1.5)
            .background(Color.sumi, in: .rect(cornerRadius: Radius.s + 1.5))
    }
}

/// A small board with a title, a count and a thin progress line, e.g. "Hiragana, 46 von 104".
struct ProgressBoard: View {
    var title: LocalizedStringKey
    var done: Int
    var total: Int

    var body: some View {
        PaperCard {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(title).font(.choppyAccent(15, relativeTo: .subheadline)).lineLimit(1).minimumScaleFactor(0.8)
                Text("\(done) von \(total)").font(.choppyCaption).foregroundStyle(.sugi400)
                GeometryReader { proxy in
                    Color.sumi.opacity(0.15)
                        .overlay(alignment: .leading) {
                            Color.sumi.frame(width: proxy.size.width * fraction)
                        }
                }
                .frame(height: 4)
                .padding(.vertical, Spacing.xxs)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var fraction: CGFloat {
        total > 0 ? min(max(CGFloat(done) / CGFloat(total), 0), 1) : 0
    }
}

#Preview {
    VStack(spacing: Spacing.s) {
        PaperCard(padding: Spacing.m) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Wort des Tages").font(.choppyCaption).foregroundStyle(.sugi400)
                Text("そば").font(.choppyTitle)
                Text("Buchweizennudeln").font(.choppyBody)
            }
        }
        HStack(spacing: Spacing.s) {
            ProgressBoard(title: "Hiragana", done: 46, total: 104)
            ProgressBoard(title: "Wörter der Woche", done: 8, total: 20)
        }
    }
    .padding()
    .frame(maxHeight: .infinity)
    .background { AppBackground() }
}
