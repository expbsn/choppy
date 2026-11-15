import SwiftUI

struct PathView: View {
    /// The path starts at the bottom (week 1), so the screen opens scrolled to the bottom.
    @State private var position = ScrollPosition(edge: .bottom)

    var body: some View {
        NavigationStack {
            ChoppyScreen("Pfad", japanese: "道") {
                ScrollView {
                    VStack(spacing: Spacing.m) {
                        PaperCard {
                            Text("Jede Woche hinterlässt Choppy hier eine neue Fußspur – von unten nach oben.")
                                .foregroundStyle(.inkSoft)
                        }
                        // Placeholder until weekly plans exist (Phase 5).
                        FootprintPath(weeks: 8, completed: 0)
                    }
                    .padding()
                }
                .scrollPosition($position)
                .defaultScrollAnchor(.bottom)
            }
            // Leaves only along the sides, so the footprint path stays free.
            .environment(\.backgroundLayout, .framing)
        }
    }
}

#Preview {
    PathView()
}
