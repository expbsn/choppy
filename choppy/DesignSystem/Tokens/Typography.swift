import SwiftUI

/// The two weights bundled for Zen Maru Gothic and DM Mono.
nonisolated enum ChoppyFontWeight: String, CaseIterable, Sendable {
    case regular = "Regular"
    case medium = "Medium"

    var zenMaruGothicName: String { "ZenMaruGothic-\(rawValue)" }
    var dmMonoName: String { "DMMono-\(rawValue)" }
}

/// The brush fonts: Yuji Boku for kanji, Yuji Syuku for kana.
nonisolated enum BrushFont {
    static let kanjiName = "YujiBoku-Regular"
    static let kanaName = "YujiSyuku-Regular"

    /// Hiragana and katakana, including the long-vowel mark.
    static func isKana(_ character: Character) -> Bool {
        character.unicodeScalars.allSatisfy { (0x3040...0x30FF).contains($0.value) }
    }
}

extension Font {
    /// Interface font (Zen Maru Gothic): titles, labels, body text and Japanese readings.
    /// Scales with Dynamic Type relative to `textStyle`.
    static func choppyAccent(_ size: CGFloat, weight: ChoppyFontWeight = .medium, relativeTo textStyle: TextStyle = .body) -> Font {
        .custom(weight.zenMaruGothicName, size: size, relativeTo: textStyle)
    }

    /// Japanese running text and readings. Zen Maru Gothic covers kana and kanji.
    static func choppyJapanese(_ size: CGFloat, weight: ChoppyFontWeight = .regular, relativeTo textStyle: TextStyle = .body) -> Font {
        .custom(weight.zenMaruGothicName, size: size, relativeTo: textStyle)
    }

    /// Small data labels (DM Mono): counts, dates, captions.
    static func choppyMono(_ size: CGFloat = 12, weight: ChoppyFontWeight = .regular, relativeTo textStyle: TextStyle = .caption) -> Font {
        .custom(weight.dmMonoName, size: size, relativeTo: textStyle)
    }

    /// Brush font for kanji (Yuji Boku). For mixed kanji and kana use `Text(brush:size:)`.
    static func choppyBrush(_ size: CGFloat, relativeTo textStyle: TextStyle = .title) -> Font {
        .custom(BrushFont.kanjiName, size: size, relativeTo: textStyle)
    }

    /// Brush font for kana (Yuji Syuku).
    static func choppyBrushKana(_ size: CGFloat, relativeTo textStyle: TextStyle = .title) -> Font {
        .custom(BrushFont.kanaName, size: size, relativeTo: textStyle)
    }

    // MARK: Scale (sizes from the Figma board "02 Schrift")

    static var choppyDisplay: Font { choppyAccent(28, relativeTo: .largeTitle) }
    static var choppyTitle: Font { choppyAccent(20, relativeTo: .title3) }
    static var choppyHeadline: Font { choppyAccent(16, relativeTo: .headline) }
    static var choppyBody: Font { choppyAccent(15, weight: .regular, relativeTo: .body) }
    static var choppyFootnote: Font { choppyAccent(13, weight: .regular, relativeTo: .footnote) }
    static var choppyCaption: Font { choppyMono(12) }
}

extension Text {
    /// Japanese text in the brush fonts: kanji in Yuji Boku, kana in Yuji Syuku.
    init(brush string: String, size: CGFloat, relativeTo textStyle: Font.TextStyle = .title) {
        var result = AttributedString()
        for character in string {
            var part = AttributedString(String(character))
            part.font = BrushFont.isKana(character)
                ? .choppyBrushKana(size, relativeTo: textStyle)
                : .choppyBrush(size, relativeTo: textStyle)
            result += part
        }
        self.init(result)
    }
}

#Preview("Typografie") {
    VStack(alignment: .leading, spacing: Spacing.s) {
        Text("Wortschatz").font(.choppyDisplay)
        Text("Wörter der Woche").font(.choppyTitle)
        Text("Weiter lernen").font(.choppyHeadline)
        Text("Fließtext in Zen Maru Gothic.").font(.choppyBody)
        Text("Woche 3 · 8 von 20").font(.choppyCaption).foregroundStyle(.washi300)
        Text(brush: "蕎麦を食べる", size: 40)
        Text("日本語を勉強しましょう").font(.choppyJapanese(20))
    }
    .foregroundStyle(.washi50)
    .padding()
    .frame(maxWidth: .infinity, alignment: .leading)
    .background { AppBackground() }
}
