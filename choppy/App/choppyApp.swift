import SwiftUI

@main
struct choppyApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
                // Light mode only for now (see DECISIONS.md, ADR-008).
                .preferredColorScheme(.light)
        }
    }
}
