import CoreText
import SwiftUI
import Testing
import UIKit
@testable import choppy

@MainActor
struct DesignSystemTests {
    @Test(arguments: ChoppyFontWeight.allCases)
    func zenMaruGothicWeightIsRegistered(_ weight: ChoppyFontWeight) throws {
        let font = try #require(UIFont(name: weight.zenMaruGothicName, size: 17))
        #expect(font.familyName == "Zen Maru Gothic")
    }

    @Test(arguments: ChoppyFontWeight.allCases)
    func dmMonoWeightIsRegistered(_ weight: ChoppyFontWeight) throws {
        let font = try #require(UIFont(name: weight.dmMonoName, size: 12))
        #expect(font.familyName == "DM Mono")
    }

    @Test(arguments: [BrushFont.kanjiName, BrushFont.kanaName, ChoppyFontWeight.regular.zenMaruGothicName])
    func japaneseFontCoversKanaAndKanji(_ name: String) throws {
        let font = try #require(UIFont(name: name, size: 17)) as CTFont
        let characters = Array("あア日本語".utf16)
        var glyphs = [CGGlyph](repeating: 0, count: characters.count)
        #expect(CTFontGetGlyphsForCharacters(font, characters, &glyphs, characters.count))
    }

    @Test func brushFontSplitsKanaFromKanji() {
        #expect(BrushFont.isKana("そ"))
        #expect(BrushFont.isKana("バ"))
        #expect(BrushFont.isKana("ー"))
        #expect(!BrushFont.isKana("蕎"))
        #expect(!BrushFont.isKana("a"))
    }

    @Test func everyCreditHasItsLicenseTextBundled() {
        for credit in Credit.all where credit.licenseFile != nil {
            #expect(credit.licenseText?.isEmpty == false, "Missing license text for \(credit.name)")
        }
    }

    @Test func hexRoundTrips() {
        for token in ColorToken.allCases {
            #expect(Color(hex: token.defaultHex).hexString == token.defaultHex)
        }
    }

    @Test func themeOverridesPersistAndReset() throws {
        let defaults = try #require(UserDefaults(suiteName: "ThemeStoreTests"))
        defaults.removePersistentDomain(forName: "ThemeStoreTests")

        let store = ThemeStore(defaults: defaults)
        store.setHex("#123456", for: .sugi400)

        let reloaded = ThemeStore(defaults: defaults)
        #expect(reloaded.hex(for: .sugi400) == "#123456")
        #expect(reloaded.isCustomized(.sugi400))
        #expect(!reloaded.isCustomized(.sumi))

        // Setting the default value again is not an override.
        reloaded.setHex(ColorToken.sugi400.defaultHex, for: .sugi400)
        #expect(!reloaded.isCustomized(.sugi400))

        reloaded.setHex("#654321", for: .washi50)
        reloaded.resetAll()
        #expect(ThemeStore(defaults: defaults).settings == ThemeStore.Settings())
    }
}

@MainActor
struct DraftTests {
    @Test func readingGeneratorTranscribesKanji() {
        #expect(ReadingGenerator.hiragana(for: "水を飲む") == "みずをのむ")
        #expect(ReadingGenerator.hiragana(for: "傘") == "かさ")
        #expect(ReadingGenerator.hiragana(for: "みず") == "みず")
    }

    @Test func draftStoreKeepsWordsAndCountsWins() throws {
        let url = FileManager.default.temporaryDirectory.appending(path: "draft-\(UUID().uuidString).json")
        let store = LocalDraftStore(fileURL: url)
        store.add(.init(german: "Wasser", japanese: "水", reading: "みず", list: .shared))
        store.add(.init(german: "Wasser", japanese: "水", reading: "みず", list: .shared))
        store.add(.init(german: "Wasser", japanese: "水", reading: "みず", list: .own))
        store.record(duel: [5, 3])
        store.record(duel: [2, 2])
        store.state.playerNames[0] = " Nana "

        let reloaded = LocalDraftStore(fileURL: url)
        #expect(reloaded.words(in: .shared).count == 1)
        #expect(reloaded.words(in: .own).count == 1)
        #expect(reloaded.wins == [1, 0])
        #expect(reloaded.name(of: 0) == "Nana")
        #expect(reloaded.name(of: 1) == "Spieler 2")
    }
}
