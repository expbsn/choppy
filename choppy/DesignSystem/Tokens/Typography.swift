import SwiftUI

/// Font weights used by Choppy. Each bundled family maps them to its own named instances.
///
/// The variable fonts expose named instances with fixed PostScript names
/// (`NotoSansJP-Thin_<Weight>`, `Teko-Light_<Weight>`); using them directly is
/// the most reliable way to pick a weight from a variable font.
nonisolated enum ChoppyFontWeight: String, CaseIterable, Sendable {
    case light = "Light"
    case regular = "Regular"
    case medium = "Medium"
    case semibold = "SemiBold"
    case bold = "Bold"
    case black = "Black"

    var notoSansJPName: String { "NotoSansJP-Thin_\(rawValue)" }

    /// Teko goes from Light to Bold; Black falls back to Bold.
    var tekoName: String {
        switch self {
        case .light: "Teko-Light"
        case .black: "Teko-Light_Bold"
        default: "Teko-Light_\(rawValue)"
        }
    }
}

extension AccentFontFamily {
    func postScriptName(_ weight: ChoppyFontWeight) -> String {
        switch self {
        case .teko: weight.tekoName
        case .notoSansJP: weight.notoSansJPName
        }
    }

    /// Teko is condensed with a small x-height, so it is set larger to match Noto's visual size.
    var sizeScale: CGFloat {
        switch self {
        case .teko: 1.3
        case .notoSansJP: 1
        }
    }
}

extension Font {
    /// Accent font for headings and playful labels (Teko or Noto Sans JP, chosen in the theme editor).
    /// Scales with Dynamic Type relative to `textStyle`.
    static func choppyAccent(_ size: CGFloat, weight: ChoppyFontWeight = .bold, relativeTo textStyle: TextStyle = .body) -> Font {
        let family = ThemeStore.shared.settings.accentFont
        return .custom(family.postScriptName(weight), size: size * family.sizeScale, relativeTo: textStyle)
    }

    /// Font for kana, kanji and furigana: always Noto Sans JP, which covers all Japanese characters.
    static func choppyJapanese(_ size: CGFloat, weight: ChoppyFontWeight = .regular, relativeTo textStyle: TextStyle = .body) -> Font {
        .custom(weight.notoSansJPName, size: size, relativeTo: textStyle)
    }

    // MARK: Scale

    static var choppyDisplay: Font { choppyAccent(34, weight: .black, relativeTo: .largeTitle) }
    static var choppyTitle: Font { choppyAccent(24, weight: .bold, relativeTo: .title2) }
    static var choppyHeadline: Font { choppyAccent(18, weight: .semibold, relativeTo: .headline) }
    static var choppyCaption: Font { choppyAccent(13, weight: .medium, relativeTo: .caption) }
}

#Preview("Typografie") {
    VStack(alignment: .leading, spacing: Spacing.s) {
        Text("Choppy").font(.choppyDisplay)
        Text("Diese Woche").font(.choppyTitle)
        Text("Begrüßungen").font(.choppyHeadline)
        Text("Fließtext bleibt in SF – gut lesbar.").font(.body)
        Text("3 von 5 Lektionen").font(.choppyCaption).foregroundStyle(.inkSoft)
        Divider()
        Text("日本語を勉強しましょう").font(.choppyJapanese(28))
        HStack {
            ForEach(ChoppyFontWeight.allCases, id: \.self) { weight in
                Text("あ").font(.choppyJapanese(24, weight: weight))
            }
        }
    }
    .foregroundStyle(.ink)
    .padding()
}
