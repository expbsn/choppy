import ChoppyCore
import Foundation
import SwiftUI

extension ContentLibrary {
    /// Loads and validates `choppy-content.json` from the app bundle.
    static func loadBundled(from bundle: Bundle = .main) throws -> ContentLibrary {
        guard let url = bundle.url(forResource: "choppy-content", withExtension: "json") else {
            throw CocoaError(.fileReadNoSuchFile)
        }
        return try ContentLibrary(data: Data(contentsOf: url))
    }
}

extension EnvironmentValues {
    /// All bundled learning content. Previews get the kana-only library unless they inject one.
    @Entry var content: ContentLibrary = .kanaOnly
}
