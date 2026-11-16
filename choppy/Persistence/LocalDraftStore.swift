import Foundation
import Observation

/// Local stand-in for the data that will live in SwiftData and the shared CloudKit pair space
/// (Phase 1, step 5): the two players' names, words added through the translator and duel results.
/// Saved as one JSON file on this device only. Nothing here is synced yet.
@Observable
final class LocalDraftStore {
    static let shared = LocalDraftStore()

    /// Where a translated word is kept.
    enum WordList: String, Codable, CaseIterable {
        /// The words both learn together. Will move to the shared pair space.
        case shared
        /// One player's own card box.
        case own
    }

    struct CustomWord: Codable, Identifiable, Hashable {
        var id = UUID()
        var german: String
        var japanese: String
        var reading: String
        var list: WordList
        var addedAt = Date()
    }

    struct DuelResult: Codable, Identifiable, Hashable {
        var id = UUID()
        var date = Date()
        /// Points of player 0 and player 1.
        var scores: [Int]
    }

    struct State: Codable, Equatable {
        var playerNames = ["", ""]
        var words: [CustomWord] = []
        var duels: [DuelResult] = []
    }

    var state: State {
        didSet { save() }
    }

    @ObservationIgnored private let fileURL: URL

    init(fileURL: URL = URL.applicationSupportDirectory.appending(path: "draft-store.json")) {
        self.fileURL = fileURL
        if let data = try? Data(contentsOf: fileURL), let stored = try? JSONDecoder().decode(State.self, from: data) {
            state = stored
        } else {
            state = State()
        }
    }

    /// The name to show for a player; "Spieler 1/2" until one is entered.
    func name(of player: Int) -> String {
        let name = state.playerNames[player].trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? "Spieler \(player + 1)" : name
    }

    func words(in list: WordList) -> [CustomWord] {
        state.words.filter { $0.list == list }
    }

    func contains(japanese: String, in list: WordList) -> Bool {
        state.words.contains { $0.japanese == japanese && $0.list == list }
    }

    func add(_ word: CustomWord) {
        guard !contains(japanese: word.japanese, in: word.list) else { return }
        state.words.insert(word, at: 0)
    }

    func remove(_ word: CustomWord) {
        state.words.removeAll { $0.id == word.id }
    }

    func record(duel scores: [Int]) {
        state.duels.insert(DuelResult(scores: scores), at: 0)
    }

    /// Duels won by each player; draws count for neither.
    var wins: [Int] {
        state.duels.reduce(into: [0, 0]) { wins, duel in
            guard duel.scores.count == 2, duel.scores[0] != duel.scores[1] else { return }
            wins[duel.scores[0] > duel.scores[1] ? 0 : 1] += 1
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(state) else { return }
        try? FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? data.write(to: fileURL, options: .atomic)
    }
}
