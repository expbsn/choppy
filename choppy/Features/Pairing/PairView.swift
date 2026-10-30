import SwiftUI

struct PairView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Lernt zu zweit",
                systemImage: "person.2",
                description: Text("Hier ladet ihr euch gegenseitig ein und vergleicht eure Fortschritte.")
            )
            .navigationTitle("Wir")
        }
    }
}

#Preview {
    PairView()
}
