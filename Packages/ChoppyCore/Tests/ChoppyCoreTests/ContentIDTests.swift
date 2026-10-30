import Foundation
import Testing
@testable import ChoppyCore

struct ContentIDTests {
    @Test func parsesThreeParts() throws {
        let id = try #require(ContentID("vocab:jmdict:1206730"))
        #expect(id.kind == .vocab)
        #expect(id.source == "jmdict")
        #expect(id.key == "1206730")
    }

    @Test func keyMayContainColons() throws {
        let id = try #require(ContentID("grammar:choppy:te-form:requests"))
        #expect(id.key == "te-form:requests")
        #expect(id.description == "grammar:choppy:te-form:requests")
    }

    @Test func keepsJapaneseKeys() throws {
        let id = try #require(ContentID("kanji:kanjidic:日"))
        #expect(id.key == "日")
    }

    @Test(arguments: ["", "vocab", "vocab:jmdict", "vocab::1", "vocab:jmdict:", "planet:x:1"])
    func rejectsMalformed(_ string: String) {
        #expect(ContentID(string) == nil)
    }

    @Test func roundTripsThroughJSON() throws {
        let ids = [ContentID(kind: .kana, source: "hiragana", key: "ka"), ContentID(kind: .custom, source: "user", key: "3F2A")]
        let data = try JSONEncoder().encode(ids)
        #expect(String(decoding: data, as: UTF8.self) == #"["kana:hiragana:ka","custom:user:3F2A"]"#)
        #expect(try JSONDecoder().decode([ContentID].self, from: data) == ids)
    }

    @Test func decodingInvalidStringThrows() {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(ContentID.self, from: Data(#""nope""#.utf8))
        }
    }
}
