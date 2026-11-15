import SwiftUI
import UIKit

/// The semantic colours of Choppy. Default values live here; the theme editor can override each one.
///
/// Every default comes from the forest reference palette (`referencePalette`), with its two yellows
/// pushed towards gold. Not taken 1:1: `paper` is the green of the lower hill silhouettes (fern on
/// parchment), `card` and `accentSoft` are light tints of palette colours, and `hanko` stays seal
/// vermilion, which the maple leaves share.
enum ColorToken: String, CaseIterable, Identifiable, Codable, CodingKeyRepresentable {
    case paper, paperDeep, card, ink, inkSoft, wood, woodDark, accent, accentSoft, hanko, success, warning
    case bamboo, leafRed, leafLight, leafDark

    var id: Self { self }

    var defaultHex: String {
        switch self {
        case .paper: "#D5CE98"      // green of the lower hills: fern on parchment
        case .paperDeep: "#D8AF7F"  // palette: sand
        case .card: "#FBF0D6"       // tint of parchment
        case .ink: "#464232"        // palette: shadow
        case .inkSoft: "#80673B"    // palette: earth
        case .wood: "#BB8A44"       // palette: ochre
        case .woodDark: "#5A5034"   // palette: bark
        case .accent: "#495635"     // palette: fir
        case .accentSoft: "#DCD19C" // tint of fern on parchment
        case .hanko: "#B4412F"      // seal vermilion (not in the palette)
        case .success: "#5F6F3A"    // palette: moss
        case .warning: "#DEA537"    // palette: honey gold, more golden
        case .bamboo: "#909F43"     // palette: fern
        case .leafRed: "#B4412F"    // stamp red
        case .leafLight: "#BB8A44"  // palette: ochre
        case .leafDark: "#80673B"   // palette: earth
        }
    }

    /// What the colour is used for, shown in the theme editor.
    var role: LocalizedStringResource {
        switch self {
        case .paper: "Hintergrund – Waldgrün"
        case .paperDeep: "Papier dunkel – Flächen, Hügel, Blätter"
        case .card: "Karten"
        case .ink: "Tinte – Text, Konturen"
        case .inkSoft: "Tinte hell – Nebentext"
        case .wood: "Holz – Rahmen, Buttons, Blätter"
        case .woodDark: "Holz dunkel – Äste, Schatten"
        case .accent: "Akzent – Buttons, Fortschritt"
        case .accentSoft: "Akzent hell – Markierungen"
        case .hanko: "Stempel-Zinnober"
        case .success: "Richtig"
        case .warning: "Achtung, Blätter"
        case .bamboo: "Bambus – Tab-Leiste"
        case .leafRed: "Ahornblatt rot"
        case .leafLight: "Ahornblatt hellbraun"
        case .leafDark: "Ahornblatt dunkelbraun"
        }
    }

    /// The forest reference palette, yellows made more golden. Offered for every token in the editor.
    static let referencePalette: [ColorSuggestion] = [
        .init("Hügelgrün", "#D5CE98"), .init("Pergament", "#F5E1B9"), .init("Sand", "#D8AF7F"), .init("Sonnengold", "#F3C24A"), .init("Honiggold", "#DEA537"),
        .init("Ocker", "#BB8A44"), .init("Erde", "#80673B"), .init("Stein", "#8E7D69"), .init("Rinde", "#5A5034"),
        .init("Schatten", "#464232"), .init("Farn", "#909F43"), .init("Moos", "#5F6F3A"), .init("Tanne", "#495635"), .init("Stempelrot", "#B4412F"),
    ]

    var suggestions: [ColorSuggestion] { Self.referencePalette }
}

struct ColorSuggestion: Hashable {
    let name: String
    let hex: String

    init(_ name: String, _ hex: String) {
        self.name = name
        self.hex = hex
    }
}

extension Color {
    /// Creates a colour from `#RRGGBB`. Falls back to magenta so a typo is obvious.
    init(hex: String) {
        let value = UInt32(hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")), radix: 16) ?? 0xFF00FF
        self.init(.sRGB,
                  red: Double((value >> 16) & 0xFF) / 255,
                  green: Double((value >> 8) & 0xFF) / 255,
                  blue: Double(value & 0xFF) / 255)
    }

    /// `#RRGGBB` in sRGB, clamping colours that lie outside it (for example Display P3 picks).
    var hexString: String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        func byte(_ c: CGFloat) -> Int { Int((min(max(c, 0), 1) * 255).rounded()) }
        return String(format: "#%02X%02X%02X", byte(r), byte(g), byte(b))
    }
}

// Token accessors. Reading them inside a view body registers with Observation,
// so every view redraws when a colour is changed in the theme editor.
extension Color {
    static var paper: Color { ThemeStore.shared.color(.paper) }
    static var paperDeep: Color { ThemeStore.shared.color(.paperDeep) }
    static var card: Color { ThemeStore.shared.color(.card) }
    static var ink: Color { ThemeStore.shared.color(.ink) }
    static var inkSoft: Color { ThemeStore.shared.color(.inkSoft) }
    static var wood: Color { ThemeStore.shared.color(.wood) }
    static var woodDark: Color { ThemeStore.shared.color(.woodDark) }
    static var accent: Color { ThemeStore.shared.color(.accent) }
    static var accentSoft: Color { ThemeStore.shared.color(.accentSoft) }
    static var hanko: Color { ThemeStore.shared.color(.hanko) }
    static var success: Color { ThemeStore.shared.color(.success) }
    static var warning: Color { ThemeStore.shared.color(.warning) }
    static var bamboo: Color { ThemeStore.shared.color(.bamboo) }
    static var leafRed: Color { ThemeStore.shared.color(.leafRed) }
    static var leafLight: Color { ThemeStore.shared.color(.leafLight) }
    static var leafDark: Color { ThemeStore.shared.color(.leafDark) }
}

extension ShapeStyle where Self == Color {
    static var paper: Color { Color.paper }
    static var paperDeep: Color { Color.paperDeep }
    static var card: Color { Color.card }
    static var ink: Color { Color.ink }
    static var inkSoft: Color { Color.inkSoft }
    static var wood: Color { Color.wood }
    static var woodDark: Color { Color.woodDark }
    static var accent: Color { Color.accent }
    static var accentSoft: Color { Color.accentSoft }
    static var hanko: Color { Color.hanko }
    static var success: Color { Color.success }
    static var warning: Color { Color.warning }
    static var bamboo: Color { Color.bamboo }
    static var leafRed: Color { Color.leafRed }
    static var leafLight: Color { Color.leafLight }
    static var leafDark: Color { Color.leafDark }
}
