import SwiftUI

struct LearnView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Bald geht's los",
                systemImage: "book.closed",
                description: Text("Hier lernt ihr Kana, Vokabeln, Kanji und Sätze.")
            )
            .navigationTitle("Lernen")
        }
    }
}

#Preview {
    LearnView()
}
