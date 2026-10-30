import SwiftUI

struct GamesView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Noch keine Spiele",
                systemImage: "gamecontroller",
                description: Text("Hier tretet ihr bald gegeneinander an.")
            )
            .navigationTitle("Spiele")
        }
    }
}

#Preview {
    GamesView()
}
