import Observation
import SwiftUI

/// The live, user-adjustable colours of the app.
/// Persisted locally in `UserDefaults`; the defaults live in code (`ColorToken.defaultHex`).
@Observable
final class ThemeStore {
    static let shared = ThemeStore()

    struct Settings: Codable, Equatable {
        var colorOverrides: [ColorToken: String] = [:]
    }

    var settings: Settings {
        didSet { save() }
    }

    private let defaults: UserDefaults
    // Bumped when the palette changes, so overrides of an older palette do not mask it.
    private static let key = "theme.v5"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Self.key),
           let stored = try? JSONDecoder().decode(Settings.self, from: data) {
            settings = stored
        } else {
            settings = Settings()
        }
    }

    func hex(for token: ColorToken) -> String {
        settings.colorOverrides[token] ?? token.defaultHex
    }

    func color(_ token: ColorToken) -> Color {
        Color(hex: hex(for: token))
    }

    func isCustomized(_ token: ColorToken) -> Bool {
        settings.colorOverrides[token] != nil
    }

    func setColor(_ color: Color, for token: ColorToken) {
        setHex(color.hexString, for: token)
    }

    func setHex(_ hex: String, for token: ColorToken) {
        settings.colorOverrides[token] = hex == token.defaultHex ? nil : hex
    }

    func reset(_ token: ColorToken) {
        settings.colorOverrides[token] = nil
    }

    func resetAll() {
        settings = Settings()
    }

    /// Plain-text summary of the current colours, to send to whoever bakes them into the defaults.
    var exportText: String {
        ColorToken.allCases.map { token in
            "\(token.figmaName): \(hex(for: token))\(isCustomized(token) ? "  (geändert)" : "")"
        }
        .joined(separator: "\n")
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        defaults.set(data, forKey: Self.key)
    }
}
