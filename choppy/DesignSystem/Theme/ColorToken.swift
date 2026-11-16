import SwiftUI
import UIKit

/// The colours of Choppy: the "Laternengasse" palette from the Figma design board (variable
/// collection of the same name). Token names follow the Figma variables one to one
/// (`sugi/800` is `sugi800`). Default values live here; the theme editor can override each one.
enum ColorToken: String, CaseIterable, Identifiable, Codable, CodingKeyRepresentable {
    case yoru900, yoru800, ai700, ai500
    case sumi, sugi800, sugi600, sugi400, kawara
    case washi50, washi100, washi300, kasumi
    case akari400, akari600
    case momiji900, momiji700, momiji500, momiji300
    case kouyouDai, kouyouKin, chochin, chochinYoru

    var id: Self { self }

    /// Name of the matching Figma variable.
    var figmaName: String {
        switch self {
        case .yoru900: "yoru/900"
        case .yoru800: "yoru/800"
        case .ai700: "ai/700"
        case .ai500: "ai/500"
        case .sumi: "sumi"
        case .sugi800: "sugi/800"
        case .sugi600: "sugi/600"
        case .sugi400: "sugi/400"
        case .kawara: "kawara"
        case .washi50: "washi/50"
        case .washi100: "washi/100"
        case .washi300: "washi/300"
        case .kasumi: "kasumi"
        case .akari400: "akari/400"
        case .akari600: "akari/600"
        case .momiji900: "momiji/900"
        case .momiji700: "momiji/700"
        case .momiji500: "momiji/500"
        case .momiji300: "momiji/300"
        case .kouyouDai: "kouyou/dai"
        case .kouyouKin: "kouyou/kin"
        case .chochin: "chochin"
        case .chochinYoru: "chochin/yoru"
        }
    }

    var defaultHex: String {
        switch self {
        case .yoru900: "#0F1115"
        case .yoru800: "#171A21"
        case .ai700: "#232A45"
        case .ai500: "#3D4470"
        case .sumi: "#1B1512"
        case .sugi800: "#2A1F1A"
        case .sugi600: "#47332A"
        case .sugi400: "#7A5238"
        case .kawara: "#3C4650"
        case .washi50: "#FBF1DC"
        case .washi100: "#F4E3C1"
        case .washi300: "#E6C98F"
        case .kasumi: "#9C8E78"
        case .akari400: "#F2B866"
        case .akari600: "#E08A2E"
        case .momiji900: "#1C3325"
        case .momiji700: "#2F5234"
        case .momiji500: "#5C8A3F"
        case .momiji300: "#9DBB5A"
        case .kouyouDai: "#C9722B"
        case .kouyouKin: "#DDA83A"
        case .chochin: "#C23A28"
        case .chochinYoru: "#8E2A1F"
        }
    }

    /// What the colour is used for, shown in the theme editor.
    var role: LocalizedStringResource {
        switch self {
        case .yoru900: "Nacht – tiefster Hintergrund"
        case .yoru800: "Nacht – Flächen"
        case .ai700: "Indigo – Himmel, Noren aus"
        case .ai500: "Indigo hell – Horizont, Noren an"
        case .sumi: "Tusche – Text auf Papier, Konturen"
        case .sugi800: "Zeder dunkel – Balken, Planken"
        case .sugi600: "Zeder – Kanten"
        case .sugi400: "Zeder hell – Rahmen, Nebentext auf Papier"
        case .kawara: "Dachziegel"
        case .washi50: "Papier hell – Text auf Nacht, Laternenpapier"
        case .washi100: "Papier – Karten"
        case .washi300: "Papier dunkel – Nebentext auf Nacht"
        case .kasumi: "Dunst – ausgeschaltete Laternen"
        case .akari400: "Laternenlicht"
        case .akari600: "Laternenlicht tief – Schein"
        case .momiji900: "Ahorn – Krone im Schatten"
        case .momiji700: "Ahorn – Krone im Licht"
        case .momiji500: "Ahornblatt grün, Richtig"
        case .momiji300: "Ahornblatt hellgrün"
        case .kouyouDai: "Herbstblatt orange"
        case .kouyouKin: "Herbstblatt gold"
        case .chochin: "Chōchin-Rot – Laternen, Stempel, Falsch"
        case .chochinYoru: "Chōchin-Rot dunkel – Rippen"
        }
    }

    /// The whole palette, offered for every token in the editor.
    static let referencePalette: [ColorSuggestion] = allCases.map { ColorSuggestion($0.figmaName, $0.defaultHex) }

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

/// Fixed colours of the drawn scenery (sky, roof tiles, skyline). They belong to the illustrations
/// in the Figma file and are not part of the adjustable palette.
enum SceneColor {
    static let skyTop = Color(hex: "#0D1124")
    static let tileLight = Color(hex: "#4C5965")
    static let tileDark = Color(hex: "#2B333B")
    static let outline = Color(hex: "#0E0D0C")
    static let soot = Color(hex: "#14110F")
    static let skylineFar = Color(hex: "#1A2038")
    static let skylineNear = Color(hex: "#141829")
    static let wall = Color(hex: "#1E1714")
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
    static var yoru900: Color { ThemeStore.shared.color(.yoru900) }
    static var yoru800: Color { ThemeStore.shared.color(.yoru800) }
    static var ai700: Color { ThemeStore.shared.color(.ai700) }
    static var ai500: Color { ThemeStore.shared.color(.ai500) }
    static var sumi: Color { ThemeStore.shared.color(.sumi) }
    static var sugi800: Color { ThemeStore.shared.color(.sugi800) }
    static var sugi600: Color { ThemeStore.shared.color(.sugi600) }
    static var sugi400: Color { ThemeStore.shared.color(.sugi400) }
    static var kawara: Color { ThemeStore.shared.color(.kawara) }
    static var washi50: Color { ThemeStore.shared.color(.washi50) }
    static var washi100: Color { ThemeStore.shared.color(.washi100) }
    static var washi300: Color { ThemeStore.shared.color(.washi300) }
    static var kasumi: Color { ThemeStore.shared.color(.kasumi) }
    static var akari400: Color { ThemeStore.shared.color(.akari400) }
    static var akari600: Color { ThemeStore.shared.color(.akari600) }
    static var momiji900: Color { ThemeStore.shared.color(.momiji900) }
    static var momiji700: Color { ThemeStore.shared.color(.momiji700) }
    static var momiji500: Color { ThemeStore.shared.color(.momiji500) }
    static var momiji300: Color { ThemeStore.shared.color(.momiji300) }
    static var kouyouDai: Color { ThemeStore.shared.color(.kouyouDai) }
    static var kouyouKin: Color { ThemeStore.shared.color(.kouyouKin) }
    static var chochin: Color { ThemeStore.shared.color(.chochin) }
    static var chochinYoru: Color { ThemeStore.shared.color(.chochinYoru) }
}

extension ShapeStyle where Self == Color {
    static var yoru900: Color { Color.yoru900 }
    static var yoru800: Color { Color.yoru800 }
    static var ai700: Color { Color.ai700 }
    static var ai500: Color { Color.ai500 }
    static var sumi: Color { Color.sumi }
    static var sugi800: Color { Color.sugi800 }
    static var sugi600: Color { Color.sugi600 }
    static var sugi400: Color { Color.sugi400 }
    static var kawara: Color { Color.kawara }
    static var washi50: Color { Color.washi50 }
    static var washi100: Color { Color.washi100 }
    static var washi300: Color { Color.washi300 }
    static var kasumi: Color { Color.kasumi }
    static var akari400: Color { Color.akari400 }
    static var akari600: Color { Color.akari600 }
    static var momiji900: Color { Color.momiji900 }
    static var momiji700: Color { Color.momiji700 }
    static var momiji500: Color { Color.momiji500 }
    static var momiji300: Color { Color.momiji300 }
    static var kouyouDai: Color { Color.kouyouDai }
    static var kouyouKin: Color { Color.kouyouKin }
    static var chochin: Color { Color.chochin }
    static var chochinYoru: Color { Color.chochinYoru }
}
