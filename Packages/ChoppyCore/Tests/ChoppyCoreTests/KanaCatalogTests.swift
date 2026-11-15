import Testing
@testable import ChoppyCore

struct KanaCatalogTests {
    @Test(arguments: KanaItem.Script.allCases)
    func groupSizes(_ script: KanaItem.Script) {
        let items = KanaCatalog.all.filter { $0.script == script }
        let count = { (group: KanaItem.Group) in items.filter { $0.group == group }.count }
        #expect(count(.basic) == 46)
        #expect(count(.dakuten) == 20)
        #expect(count(.handakuten) == 5)
        #expect(count(.combo) == 33)
    }

    @Test func idsAreUnique() {
        #expect(Set(KanaCatalog.all.map(\.id)).count == KanaCatalog.all.count)
    }

    @Test func katakanaMirrorsHiragana() {
        for (hira, kata) in zip(KanaCatalog.hiragana, KanaCatalog.katakana) {
            #expect(kata.kana == KanaCatalog.toKatakana(hira.kana))
            #expect(kata.romaji == hira.romaji)
            #expect(kata.id.key == hira.id.key)
            #expect(kata.id.source == "katakana")
        }
    }

    @Test func spotChecks() throws {
        let shi = try #require(KanaCatalog.hiragana.first { $0.kana == "し" })
        #expect(shi.romaji == "shi")
        #expect(shi.acceptedRomaji == ["shi", "si"])
        #expect(shi.id.description == "kana:hiragana:shi")

        let di = try #require(KanaCatalog.hiragana.first { $0.kana == "ぢ" })
        #expect(di.romaji == "ji")
        #expect(di.id.key == "di")

        let kyo = try #require(KanaCatalog.katakana.first { $0.romaji == "kyo" })
        #expect(kyo.kana == "キョ")
        #expect(kyo.group == .combo)

        #expect(KanaCatalog.katakana.first { $0.romaji == "wo" }?.kana == "ヲ")
        #expect(KanaCatalog.hiragana.first { $0.kana == "ん" }?.vowel == nil)
        #expect(KanaCatalog.hiragana.first { $0.kana == "ゆ" }?.vowel == "u")
    }

    @Test func katakanaConversionLeavesOtherCharacters() {
        #expect(KanaCatalog.toKatakana("こんにちは、Choppy！") == "コンニチハ、Choppy！")
    }
}
