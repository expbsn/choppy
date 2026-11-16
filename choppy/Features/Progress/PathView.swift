import SwiftUI

struct PathView: View {
    /// The path starts at the bottom (week 1), so the screen opens scrolled to the bottom.
    @State private var position = ScrollPosition(edge: .bottom)

    var body: some View {
        NavigationStack {
            ChoppyScreen("Pfad", subtitle: Text("Woche für Woche")) {
                ScrollView {
                    VStack(spacing: Spacing.m) {
                        Text("Jede Woche hinterlässt Choppy hier eine neue Fußspur – von unten nach oben.")
                            .foregroundStyle(.washi300)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        // Placeholder until weekly plans exist (Phase 5).
                        FootprintPath(weeks: 8, completed: 0)
                    }
                    .padding(.horizontal, Spacing.l)
                    .padding(.vertical, Spacing.m)
                }
                .scrollPosition($position)
                .defaultScrollAnchor(.bottom)
            }
        }
    }
}

#Preview {
    PathView()
}
