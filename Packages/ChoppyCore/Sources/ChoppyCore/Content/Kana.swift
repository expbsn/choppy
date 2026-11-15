/// One hiragana or katakana character (or yōon combination such as きゃ).
public struct KanaItem: Identifiable, Hashable, Sendable {
    public enum Script: String, Sendable, CaseIterable, Codable {
        case hiragana, katakana
    }

    public enum Group: String, Sendable, CaseIterable, Codable {
        /// The 46 basic characters (gojūon).
        case basic
        /// Voiced with ゛ (が, ざ, だ, ば).
        case dakuten
        /// Half-voiced with ゜ (ぱ).
        case handakuten
        /// Combinations with small ゃ ゅ ょ (きゃ, しゅ, …).
        case combo
    }

    /// `kana:<script>:<key>`, e.g. `kana:hiragana:shi`.
    public let id: ContentID
    public let kana: String
    /// Hepburn romanisation, shown to learners.
    public let romaji: String
    /// Other spellings accepted as input (Kunrei/Nihon-shiki, e.g. `si` for し).
    public let alternatives: [String]
    public let script: Script
    public let group: Group
    /// Consonant row the character belongs to (`a`, `k`, `s`, … `nn` for ん), used for lessons and charts.
    public let row: String
    /// Position within its script, in teaching order.
    public let order: Int

    /// The vowel column (a, i, u, e, o) for chart layouts; `nil` for ん.
    public var vowel: Character? {
        romaji.last.flatMap { "aiueo".contains($0) ? $0 : nil }
    }

    /// Every romaji spelling that counts as correct.
    public var acceptedRomaji: [String] { [romaji] + alternatives }
}
