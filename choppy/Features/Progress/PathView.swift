import SwiftUI

struct PathView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Euer Pfad",
                systemImage: "pawprint",
                description: Text("Jede Woche hinterlässt Choppy hier neue Fußspuren.")
            )
            .navigationTitle("Pfad")
        }
    }
}

#Preview {
    PathView()
}
