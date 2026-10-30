import SwiftUI

/// The four top-level areas of Choppy.
enum RootTab: Hashable {
    case learn, games, path, pair
}

struct RootTabView: View {
    @State private var selection: RootTab = .learn

    var body: some View {
        TabView(selection: $selection) {
            Tab("Lernen", systemImage: "book.closed", value: .learn) {
                LearnView()
            }
            Tab("Spiele", systemImage: "gamecontroller", value: .games) {
                GamesView()
            }
            Tab("Pfad", systemImage: "pawprint", value: .path) {
                PathView()
            }
            Tab("Wir", systemImage: "person.2", value: .pair) {
                PairView()
            }
        }
    }
}

#Preview {
    RootTabView()
}
