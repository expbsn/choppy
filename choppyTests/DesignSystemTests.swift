import CoreText
import SwiftUI
import Testing
import UIKit
@testable import choppy

@MainActor
struct DesignSystemTests {
    @Test(arguments: ChoppyFontWeight.allCases)
    func notoSansJPWeightIsRegistered(_ weight: ChoppyFontWeight) throws {
        let font = try #require(UIFont(name: weight.notoSansJPName, size: 17))
        #expect(font.familyName == "Noto Sans JP")
    }

    @Test(arguments: ChoppyFontWeight.allCases)
    func tekoWeightIsRegistered(_ weight: ChoppyFontWeight) throws {
        let font = try #require(UIFont(name: weight.tekoName, size: 17))
        #expect(font.familyName == "Teko")
    }

    @Test func notoSansJPCoversKanaAndKanji() throws {
        let font = try #require(UIFont(name: ChoppyFontWeight.regular.notoSansJPName, size: 17)) as CTFont
        let characters = Array("あア日本語".utf16)
        var glyphs = [CGGlyph](repeating: 0, count: characters.count)
        #expect(CTFontGetGlyphsForCharacters(font, characters, &glyphs, characters.count))
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
        store.setHex("#123456", for: .wood)
        store.settings.background = .kikko
        store.settings.accentFont = .notoSansJP

        let reloaded = ThemeStore(defaults: defaults)
        #expect(reloaded.hex(for: .wood) == "#123456")
        #expect(reloaded.isCustomized(.wood))
        #expect(reloaded.settings.background == .kikko)
        #expect(reloaded.settings.accentFont == .notoSansJP)

        // Setting the default value again is not an override.
        reloaded.setHex(ColorToken.wood.defaultHex, for: .wood)
        #expect(!reloaded.isCustomized(.wood))

        reloaded.resetAll()
        #expect(ThemeStore(defaults: defaults).settings == ThemeStore.Settings())
    }
}
