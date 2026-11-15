/// The hand-written kana tables. Hiragana is listed once; katakana is derived from it,
/// because every katakana character sits exactly 0x60 code points after its hiragana twin.
public enum KanaCatalog {
    public static let hiragana: [KanaItem] = build(.hiragana)
    public static let katakana: [KanaItem] = build(.katakana)
    public static let all: [KanaItem] = hiragana + katakana

    private struct Entry {
        let kana: String
        let romaji: String
        let key: String
        let alternatives: [String]
        let row: String
        let group: KanaItem.Group
    }

    private static func build(_ script: KanaItem.Script) -> [KanaItem] {
        entries.enumerated().map { index, entry in
            KanaItem(
                id: ContentID(kind: .kana, source: script.rawValue, key: entry.key),
                kana: script == .hiragana ? entry.kana : toKatakana(entry.kana),
                romaji: entry.romaji,
                alternatives: entry.alternatives,
                script: script,
                group: entry.group,
                row: entry.row,
                order: index
            )
        }
    }

    /// Shifts hiragana (U+3041–U+3096) to katakana; other characters stay unchanged.
    public static func toKatakana(_ text: String) -> String {
        String(String.UnicodeScalarView(text.unicodeScalars.map { scalar in
            (0x3041...0x3096).contains(scalar.value) ? Unicode.Scalar(scalar.value + 0x60)! : scalar
        }))
    }

    // MARK: Table

    /// Builds one row. `spec` is `kana romaji[/alt…][=key]` per character, separated by spaces.
    private static func row(_ row: String, _ group: KanaItem.Group, _ spec: String...) -> [Entry] {
        spec.map { item in
            let parts = item.split(separator: " ").map(String.init)
            var spellings = parts[1]
            var key: String?
            if let equals = spellings.firstIndex(of: "=") {
                key = String(spellings[spellings.index(after: equals)...])
                spellings = String(spellings[..<equals])
            }
            let romaji = spellings.split(separator: "/").map(String.init)
            return Entry(kana: parts[0], romaji: romaji[0], key: key ?? romaji[0],
                         alternatives: Array(romaji.dropFirst()), row: row, group: group)
        }
    }

    private static let entries: [Entry] = [
        row("a", .basic, "あ a", "い i", "う u", "え e", "お o"),
        row("k", .basic, "か ka", "き ki", "く ku", "け ke", "こ ko"),
        row("s", .basic, "さ sa", "し shi/si", "す su", "せ se", "そ so"),
        row("t", .basic, "た ta", "ち chi/ti", "つ tsu/tu", "て te", "と to"),
        row("n", .basic, "な na", "に ni", "ぬ nu", "ね ne", "の no"),
        row("h", .basic, "は ha", "ひ hi", "ふ fu/hu", "へ he", "ほ ho"),
        row("m", .basic, "ま ma", "み mi", "む mu", "め me", "も mo"),
        row("y", .basic, "や ya", "ゆ yu", "よ yo"),
        row("r", .basic, "ら ra", "り ri", "る ru", "れ re", "ろ ro"),
        row("w", .basic, "わ wa", "を wo/o"),
        row("nn", .basic, "ん n/nn"),

        row("g", .dakuten, "が ga", "ぎ gi", "ぐ gu", "げ ge", "ご go"),
        row("z", .dakuten, "ざ za", "じ ji/zi", "ず zu", "ぜ ze", "ぞ zo"),
        // ぢ and づ sound like じ and ず; their keys keep the IDs unique.
        row("d", .dakuten, "だ da", "ぢ ji/di=di", "づ zu/du=du", "で de", "ど do"),
        row("b", .dakuten, "ば ba", "び bi", "ぶ bu", "べ be", "ぼ bo"),
        row("p", .handakuten, "ぱ pa", "ぴ pi", "ぷ pu", "ぺ pe", "ぽ po"),

        row("k", .combo, "きゃ kya", "きゅ kyu", "きょ kyo"),
        row("s", .combo, "しゃ sha/sya", "しゅ shu/syu", "しょ sho/syo"),
        row("t", .combo, "ちゃ cha/tya/cya", "ちゅ chu/tyu/cyu", "ちょ cho/tyo/cyo"),
        row("n", .combo, "にゃ nya", "にゅ nyu", "にょ nyo"),
        row("h", .combo, "ひゃ hya", "ひゅ hyu", "ひょ hyo"),
        row("m", .combo, "みゃ mya", "みゅ myu", "みょ myo"),
        row("r", .combo, "りゃ rya", "りゅ ryu", "りょ ryo"),
        row("g", .combo, "ぎゃ gya", "ぎゅ gyu", "ぎょ gyo"),
        row("z", .combo, "じゃ ja/zya/jya", "じゅ ju/zyu/jyu", "じょ jo/zyo/jyo"),
        row("b", .combo, "びゃ bya", "びゅ byu", "びょ byo"),
        row("p", .combo, "ぴゃ pya", "ぴゅ pyu", "ぴょ pyo"),
    ].flatMap { $0 }
}
