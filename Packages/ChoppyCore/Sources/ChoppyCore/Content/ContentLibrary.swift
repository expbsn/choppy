import Foundation

/// The bundled content file (`choppy-content.json`) as decoded from disk.
public struct ContentBundle: Sendable, Codable {
    public static let supportedFormatVersion = 1

    /// Version of the file layout. Bumped only for breaking changes to this struct.
    public let formatVersion: Int
    /// Version of the content itself. Bumped whenever words are added or changed.
    public let contentVersion: Int
    public let topics: [Topic]
    public let vocab: [VocabItem]

    public init(formatVersion: Int = supportedFormatVersion, contentVersion: Int, topics: [Topic], vocab: [VocabItem]) {
        self.formatVersion = formatVersion
        self.contentVersion = contentVersion
        self.topics = topics
        self.vocab = vocab
    }
}

public enum ContentError: Error, Equatable, CustomStringConvertible {
    case unsupportedFormat(Int)
    case duplicateID(String)
    case wrongKind(ContentID)
    case unknownTopic(ContentID, String)
    case missingMeaning(ContentID)
    case furiganaMismatch(ContentID)
    case invalidDifficulty(ContentID)

    public var description: String {
        switch self {
        case .unsupportedFormat(let version): "Unsupported content format \(version)"
        case .duplicateID(let id): "Duplicate ID \(id)"
        case .wrongKind(let id): "\(id) is not a vocab ID"
        case .unknownTopic(let id, let topic): "\(id) refers to unknown topic \(topic)"
        case .missingMeaning(let id): "\(id) has an empty German meaning"
        case .furiganaMismatch(let id): "\(id): furigana does not add up to surface and reading"
        case .invalidDifficulty(let id): "\(id): difficulty must be 1–5"
        }
    }
}

/// All learnable content, validated and indexed for lookups by ID, topic or kana group.
public struct ContentLibrary: Sendable {
    public let contentVersion: Int
    public let kana: [KanaItem]
    public let topics: [Topic]
    public let vocab: [VocabItem]

    private let kanaByID: [ContentID: KanaItem]
    private let vocabByID: [ContentID: VocabItem]
    private let vocabByTopic: [String: [VocabItem]]

    /// Kana only, for previews and as a fallback if the content file cannot be read.
    public static let kanaOnly = try! ContentLibrary(bundle: ContentBundle(contentVersion: 0, topics: [], vocab: []))

    public init(bundle: ContentBundle, kana: [KanaItem] = KanaCatalog.all) throws {
        guard bundle.formatVersion == ContentBundle.supportedFormatVersion else {
            throw ContentError.unsupportedFormat(bundle.formatVersion)
        }
        try Self.validate(bundle, kana: kana)

        contentVersion = bundle.contentVersion
        self.kana = kana
        topics = bundle.topics
        vocab = bundle.vocab
        kanaByID = Dictionary(uniqueKeysWithValues: kana.map { ($0.id, $0) })
        vocabByID = Dictionary(uniqueKeysWithValues: bundle.vocab.map { ($0.id, $0) })
        vocabByTopic = Dictionary(grouping: bundle.vocab, by: \.topic)
    }

    /// Decodes and validates a content file.
    public init(data: Data) throws {
        try self.init(bundle: JSONDecoder().decode(ContentBundle.self, from: data))
    }

    // MARK: Lookups

    public func kana(_ script: KanaItem.Script, group: KanaItem.Group? = nil) -> [KanaItem] {
        kana.filter { $0.script == script && (group == nil || $0.group == group) }
    }

    public func kana(for id: ContentID) -> KanaItem? { kanaByID[id] }

    public func vocab(for id: ContentID) -> VocabItem? { vocabByID[id] }

    public func vocab(inTopic topic: String) -> [VocabItem] { vocabByTopic[topic] ?? [] }

    /// Whether an ID still exists, e.g. to skip review cards whose item was removed in a content update.
    public func contains(_ id: ContentID) -> Bool {
        kanaByID[id] != nil || vocabByID[id] != nil
    }

    // MARK: Validation

    private static func validate(_ bundle: ContentBundle, kana: [KanaItem]) throws {
        var seen = Set<String>()
        func insertUnique(_ id: String) throws {
            guard seen.insert(id).inserted else { throw ContentError.duplicateID(id) }
        }

        for item in kana { try insertUnique(item.id.description) }
        for topic in bundle.topics { try insertUnique("topic:\(topic.id)") }
        let topicIDs = Set(bundle.topics.map(\.id))

        for word in bundle.vocab {
            try insertUnique(word.id.description)
            guard word.id.kind == .vocab else { throw ContentError.wrongKind(word.id) }
            guard topicIDs.contains(word.topic) else { throw ContentError.unknownTopic(word.id, word.topic) }
            guard !word.meanings.isEmpty,
                  word.meanings.allSatisfy({ !$0.trimmingCharacters(in: .whitespaces).isEmpty })
            else { throw ContentError.missingMeaning(word.id) }
            guard (1...5).contains(word.difficulty) else { throw ContentError.invalidDifficulty(word.id) }

            let segments = word.segments
            guard segments.map(\.text).joined() == word.surface,
                  segments.map({ $0.reading ?? $0.text }).joined() == word.reading
            else { throw ContentError.furiganaMismatch(word.id) }
        }
    }
}
