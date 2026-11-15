import Observation
import SwiftUI

/// Background patterns. One is chosen app-wide, so every screen looks the same.
enum BackgroundStyle: String, CaseIterable, Identifiable, Codable {
    case plain, momiji, seigaiha, asanoha, kikko, shippo

    var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .plain: "Schlicht"
        case .momiji: "Momiji 紅葉"
        case .seigaiha: "Seigaiha 青海波"
        case .asanoha: "Asanoha 麻の葉"
        case .kikko: "Kikkō 亀甲"
        case .shippo: "Shippō 七宝"
        }
    }
}

/// Font family for headings and accents. Japanese text always uses Noto Sans JP.
enum AccentFontFamily: String, CaseIterable, Identifiable, Codable {
    case teko, notoSansJP

    var id: Self { self }

    var title: String {
        switch self {
        case .teko: "Teko"
        case .notoSansJP: "Noto Sans JP"
        }
    }
}

/// The live, user-adjustable look of the app: colours, background and accent font.
/// Persisted locally in `UserDefaults`; the defaults live in code (`ColorToken.defaultHex`).
@Observable
final class ThemeStore {
    static let shared = ThemeStore()

    struct Settings: Codable, Equatable {
        var colorOverrides: [ColorToken: String] = [:]
        var background: BackgroundStyle = .momiji
        var patternOpacity: Double = 0.7
        var paperTexture: Double = 0.5
        var accentFont: AccentFontFamily = .notoSansJP
    }

    var settings: Settings {
        didSet { save() }
    }

    private let defaults: UserDefaults
    // Bumped when the defaults change, so earlier test overrides do not mask them.
    private static let key = "theme.v4"

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

    /// Plain-text summary of the current look, to send to whoever bakes it into the defaults.
    var exportText: String {
        var lines = ColorToken.allCases.map { token in
            "\(token.rawValue): \(hex(for: token))\(isCustomized(token) ? "  (geändert)" : "")"
        }
        lines.append("background: \(settings.background.rawValue), pattern \(String(format: "%.2f", settings.patternOpacity)), texture \(String(format: "%.2f", settings.paperTexture))")
        lines.append("accentFont: \(settings.accentFont.rawValue)")
        return lines.joined(separator: "\n")
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        defaults.set(data, forKey: Self.key)
    }
}
