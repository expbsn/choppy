import Foundation

/// Attribution for one piece of bundled third-party material.
struct Credit: Identifiable, Hashable {
    enum Category: CaseIterable {
        case fonts, content, speech, images

        var title: LocalizedStringResource {
            switch self {
            case .fonts: "Schriften"
            case .content: "Lerninhalte"
            case .speech: "Sprachausgabe"
            case .images: "Bilder"
            }
        }
    }

    var id: String { name }
    let name: String
    let category: Category
    /// What Choppy uses it for, shown to the user.
    let usage: LocalizedStringResource
    let copyright: String
    let license: String
    let licenseURL: URL
    /// Name of the bundled license text file (without extension), if any.
    let licenseFile: String?

    var licenseText: String? {
        guard let licenseFile,
              let url = Bundle.main.url(forResource: licenseFile, withExtension: "txt")
        else { return nil }
        return try? String(contentsOf: url, encoding: .utf8)
    }

    static func == (lhs: Credit, rhs: Credit) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension Credit {
    /// Every attribution shown on the Credits screen. Extend this whenever new material is bundled.
    static let all: [Credit] = [
        Credit(
            name: "Noto Sans JP",
            category: .fonts,
            usage: "Japanische Schrift (Kana, Kanji, Furigana)",
            copyright: "© 2014–2021 Adobe (http://www.adobe.com/), with Reserved Font Name 'Source'.",
            license: "SIL Open Font License 1.1",
            licenseURL: URL(string: "https://openfontlicense.org")!,
            licenseFile: "OFL-NotoSansJP"
        ),
        Credit(
            name: "Teko",
            category: .fonts,
            usage: "Überschriften und Akzente",
            copyright: "© 2023 The Teko Project Authors (https://www.github.com/googlefonts/teko)",
            license: "SIL Open Font License 1.1",
            licenseURL: URL(string: "https://openfontlicense.org")!,
            licenseFile: "OFL-Teko"
        ),
    ]
}
