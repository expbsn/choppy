import SwiftUI

/// A sheet of lighter paper lying on the washi background. The default container for content blocks.
struct PaperCard<Content: View>: View {
    var padding: CGFloat = Spacing.m
    var lifted = false
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.card, in: .rect(cornerRadius: Radius.m))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.m)
                    .strokeBorder(Color.woodDark.opacity(0.15), lineWidth: 1)
            }
            .paperShadow(lifted: lifted)
    }
}

#Preview {
    VStack(spacing: Spacing.m) {
        PaperCard {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Diese Woche").font(.choppyHeadline)
                Text("12 neue Vokabeln · 3 Kanji").foregroundStyle(.inkSoft)
            }
        }
        PaperCard(lifted: true) {
            Text("ありがとう").font(.choppyJapanese(32))
        }
    }
    .foregroundStyle(.ink)
    .padding()
    .background { AppBackground() }
}
