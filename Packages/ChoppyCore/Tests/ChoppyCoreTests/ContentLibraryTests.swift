import Foundation
import Testing
@testable import ChoppyCore

struct ContentLibraryTests {
    private static let greetings = Topic(id: "greetings", title: "Begrüßungen", japanese: "挨拶", symbol: "hand.wave")

    private static func word(_ key: String, _ surface: String, _ reading: String,
                             furigana: [FuriganaSegment]? = nil, meanings: [String] = ["Test"],
                             topic: String = "greetings", difficulty: Int = 1) -> VocabItem {
        VocabItem(id: ContentID(kind: .vocab, source: "test", key: key), surface: surface, reading: reading,
                  furigana: furigana, meanings: meanings, topic: topic, difficulty: difficulty)
    }

    private static func library(_ vocab: [VocabItem]) throws -> ContentLibrary {
        try ContentLibrary(bundle: ContentBundle(contentVersion: 1, topics: [greetings], vocab: vocab))
    }

    @Test func decodesJSONAndIndexes() throws {
        let json = """
        {
          "formatVersion": 1,
          "contentVersion": 3,
          "topics": [{ "id": "greetings", "title": "Begrüßungen", "japanese": "挨拶", "symbol": "hand.wave" }],
          "vocab": [
            { "id": "vocab:test:konnichiwa", "surface": "こんにちは", "reading": "こんにちは",
              "meanings": ["Hallo", "Guten Tag"], "topic": "greetings", "difficulty": 1, "jlpt": 5 },
            { "id": "vocab:test:ogenki", "surface": "お元気ですか", "reading": "おげんきですか",
              "furigana": [{ "text": "お" }, { "text": "元気", "reading": "げんき" }, { "text": "ですか" }],
              "meanings": ["Wie geht es dir?"], "topic": "greetings", "difficulty": 2, "note": "höflich" }
          ]
        }
        """
        let library = try ContentLibrary(data: Data(json.utf8))
        #expect(library.contentVersion == 3)
        #expect(library.vocab(inTopic: "greetings").count == 2)

        let ogenki = try #require(library.vocab(for: ContentID("vocab:test:ogenki")!))
        #expect(ogenki.segments[1] == FuriganaSegment("元気", reading: "げんき"))
        #expect(ogenki.note == "höflich")
        #expect(ogenki.jlpt == nil)

        let konnichiwa = try #require(library.vocab(for: ContentID("vocab:test:konnichiwa")!))
        #expect(konnichiwa.segments == [FuriganaSegment("こんにちは")])

        #expect(library.kana(.hiragana).count == 104)
        #expect(library.kana(.katakana, group: .handakuten).map(\.kana) == ["パ", "ピ", "プ", "ペ", "ポ"])
        #expect(library.contains(ContentID("kana:hiragana:ka")!))
        #expect(!library.contains(ContentID("vocab:test:gone")!))
    }

    @Test func rejectsUnsupportedFormat() {
        #expect(throws: ContentError.unsupportedFormat(2)) {
            try ContentLibrary(bundle: ContentBundle(formatVersion: 2, contentVersion: 1, topics: [], vocab: []))
        }
    }

    @Test func rejectsDuplicateIDs() {
        #expect(throws: ContentError.duplicateID("vocab:test:a")) {
            try Self.library([Self.word("a", "あ", "あ"), Self.word("a", "い", "い")])
        }
    }

    @Test func rejectsWrongKind() {
        let kanaID = VocabItem(id: ContentID("kana:test:a")!, surface: "あ", reading: "あ", meanings: ["a"], topic: "greetings")
        #expect(throws: ContentError.wrongKind(kanaID.id)) { try Self.library([kanaID]) }
    }

    @Test func rejectsUnknownTopic() {
        let word = Self.word("a", "あ", "あ", topic: "food")
        #expect(throws: ContentError.unknownTopic(word.id, "food")) { try Self.library([word]) }
    }

    @Test func rejectsBlankMeaning() {
        let word = Self.word("a", "あ", "あ", meanings: ["Hallo", " "])
        #expect(throws: ContentError.missingMeaning(word.id)) { try Self.library([word]) }
    }

    @Test func rejectsDifficultyOutOfRange() {
        let word = Self.word("a", "あ", "あ", difficulty: 6)
        #expect(throws: ContentError.invalidDifficulty(word.id)) { try Self.library([word]) }
    }

    @Test func rejectsFuriganaThatDoesNotAddUp() {
        let wrongSurface = Self.word("a", "元気", "げんき", furigana: [FuriganaSegment("元", reading: "げん")])
        let wrongReading = Self.word("b", "元気", "げんき", furigana: [FuriganaSegment("元気", reading: "げんぎ")])
        let missingFurigana = Self.word("c", "元気", "げんき")
        for word in [wrongSurface, wrongReading, missingFurigana] {
            #expect(throws: ContentError.furiganaMismatch(word.id)) { try Self.library([word]) }
        }
    }

    @Test func kanaOnlyLibraryHasAllKana() {
        #expect(ContentLibrary.kanaOnly.kana.count == 208)
        #expect(ContentLibrary.kanaOnly.vocab.isEmpty)
    }
}
