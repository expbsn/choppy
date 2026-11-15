/// One piece of a word with an optional reading above it, e.g. 元気 with げんき.
/// Kana-only pieces have no reading.
public struct FuriganaSegment: Hashable, Sendable, Codable {
    public let text: String
    public let reading: String?

    public init(_ text: String, reading: String? = nil) {
        self.text = text
        self.reading = reading
    }
}

/// A vocabulary item from the bundled content.
public struct VocabItem: Identifiable, Hashable, Sendable, Codable {
    public let id: ContentID
    /// The written form, e.g. お元気ですか.
    public let surface: String
    /// The full reading in kana, e.g. おげんきですか.
    public let reading: String
    /// Furigana segments. Omitted in the JSON when the word is written in kana only.
    public let furigana: [FuriganaSegment]?
    /// German meanings; the first one is shown on cards.
    public let meanings: [String]
    /// ID of the `Topic` the word belongs to.
    public let topic: String
    /// 1 (easiest) to 5.
    public let difficulty: Int
    /// JLPT level 5 (N5) to 1, if known.
    public let jlpt: Int?
    /// Short usage note in German, e.g. "vor dem Essen".
    public let note: String?

    public init(id: ContentID, surface: String, reading: String, furigana: [FuriganaSegment]? = nil,
                meanings: [String], topic: String, difficulty: Int = 1, jlpt: Int? = nil, note: String? = nil) {
        self.id = id
        self.surface = surface
        self.reading = reading
        self.furigana = furigana
        self.meanings = meanings
        self.topic = topic
        self.difficulty = difficulty
        self.jlpt = jlpt
        self.note = note
    }

    /// Segments to render, falling back to the plain surface for kana-only words.
    public var segments: [FuriganaSegment] {
        furigana ?? [FuriganaSegment(surface)]
    }
}

/// An everyday topic grouping words, e.g. "Begrüßungen".
public struct Topic: Identifiable, Hashable, Sendable, Codable {
    public let id: String
    /// German title.
    public let title: String
    public let japanese: String
    /// SF Symbol name shown next to the topic.
    public let symbol: String
}
