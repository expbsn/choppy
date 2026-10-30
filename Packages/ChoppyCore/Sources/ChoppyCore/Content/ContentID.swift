/// Stable identifier for every learnable item, e.g. `vocab:jmdict:1206730` or `kana:hiragana:ka`.
///
/// SRS state, weekly plans and game results reference items only by `ContentID`,
/// so content updates never break schedules (see DECISIONS.md, ADR-003).
public struct ContentID: Hashable, Sendable, Codable, CustomStringConvertible {
    public enum Kind: String, Sendable, Codable, CaseIterable {
        case kana, vocab, kanji, sentence, grammar, custom
    }

    public let kind: Kind
    /// Where the item comes from (`jmdict`, `tatoeba`, `hiragana`, …). May contain no `:`.
    public let source: String
    /// Identifier within the source. May itself contain `:`.
    public let key: String

    public init(kind: Kind, source: String, key: String) {
        precondition(!source.isEmpty && !source.contains(":"), "Invalid ContentID source: \(source)")
        precondition(!key.isEmpty, "ContentID key must not be empty")
        self.kind = kind
        self.source = source
        self.key = key
    }

    /// Parses `kind:source:key`. Returns `nil` for malformed strings.
    public init?(_ string: String) {
        let parts = string.split(separator: ":", maxSplits: 2, omittingEmptySubsequences: false)
        guard parts.count == 3,
              let kind = Kind(rawValue: String(parts[0])),
              !parts[1].isEmpty, !parts[2].isEmpty
        else { return nil }
        self.init(kind: kind, source: String(parts[1]), key: String(parts[2]))
    }

    public var description: String { "\(kind.rawValue):\(source):\(key)" }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let id = ContentID(string) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid ContentID: \(string)")
        }
        self = id
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}
