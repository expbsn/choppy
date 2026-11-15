import SwiftUI

struct GamesView: View {
    var body: some View {
        NavigationStack {
            ChoppyScreen("Spiele", japanese: "遊ぶ") {
                ContentUnavailableView(
                    "Noch keine Spiele",
                    systemImage: "gamecontroller",
                    description: Text("Hier tretet ihr bald gegeneinander an.")
                )
            }
        }
    }
}

#Preview {
    GamesView()
}
