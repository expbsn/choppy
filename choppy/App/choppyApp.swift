import ChoppyCore
import SwiftUI

@main
struct choppyApp: App {
    private let content: ContentLibrary = {
        do {
            return try .loadBundled()
        } catch {
            assertionFailure("Bundled content is invalid: \(error)")
            return .kanaOnly
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(\.content, content)
                .preferredColorScheme(.light)
        }
    }
}
