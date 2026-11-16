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
            name: "Zen Maru Gothic",
            category: .fonts,
            usage: "Überschriften, Texte und japanische Lesungen",
            copyright: "© 2021 The Zen Maru Gothic Project Authors (https://github.com/googlefonts/zen-marugothic)",
            license: "SIL Open Font License 1.1",
            licenseURL: URL(string: "https://openfontlicense.org")!,
            licenseFile: "OFL-ZenMaruGothic"
        ),
        Credit(
            name: "Yuji Boku",
            category: .fonts,
            usage: "Pinselschrift für Kanji",
            copyright: "© 2021 The Yuji Project Authors (https://github.com/Kinutafontfactory/Yuji)",
            license: "SIL Open Font License 1.1",
            licenseURL: URL(string: "https://openfontlicense.org")!,
            licenseFile: "OFL-YujiBoku"
        ),
        Credit(
            name: "Yuji Syuku",
            category: .fonts,
            usage: "Pinselschrift für Hiragana und Katakana",
            copyright: "© 2021 The Yuji Project Authors (https://github.com/Kinutafontfactory/Yuji)",
            license: "SIL Open Font License 1.1",
            licenseURL: URL(string: "https://openfontlicense.org")!,
            licenseFile: "OFL-YujiSyuku"
        ),
        Credit(
            name: "DM Mono",
            category: .fonts,
            usage: "Zahlen und kleine Beschriftungen",
            copyright: "© 2020 The DM Mono Project Authors (https://www.github.com/googlefonts/dm-mono)",
            license: "SIL Open Font License 1.1",
            licenseURL: URL(string: "https://openfontlicense.org")!,
            licenseFile: "OFL-DMMono"
        ),
    ]
}
