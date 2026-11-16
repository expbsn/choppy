/// Small deterministic generator (SplitMix64), so both players get the same round from one seed.
public struct SplitMix64: RandomNumberGenerator, Sendable {
    private var state: UInt64

    public init(seed: UInt64) { state = seed }

    public mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

/// One question of the vocabulary duel: a word and up to four German meanings to choose from.
public struct DuelQuestion: Sendable, Identifiable {
    public let id: Int
    public let word: VocabItem
    public let options: [String]
    public let correctIndex: Int
}

/// Rules of the vocabulary duel: two players take turns on one device, one question each.
public enum VocabDuel {
    /// Seconds a player has for one question.
    public static let secondsPerQuestion = 12

    /// Builds a round. The same pool and seed always give the same questions and option order.
    /// Words are not repeated until the pool is used up. Returns no questions if the pool has
    /// fewer than two different meanings to choose between.
    public static func makeRound(pool: [VocabItem], questionCount: Int, seed: UInt64) -> [DuelQuestion] {
        var rng = SplitMix64(seed: seed)
        let usable = pool.filter { !$0.meanings.isEmpty }
        let allAnswers = Set(usable.map { $0.meanings[0] })
        guard allAnswers.count >= 2, questionCount > 0 else { return [] }

        var picked: [VocabItem] = []
        while picked.count < questionCount {
            picked += usable.shuffled(using: &rng).prefix(questionCount - picked.count)
        }
        return picked.enumerated().map { index, word in
            let answer = word.meanings[0]
            let wrong = allAnswers.subtracting([answer]).sorted().shuffled(using: &rng).prefix(3)
            let options = ([answer] + wrong).shuffled(using: &rng)
            return DuelQuestion(id: index, word: word, options: options, correctIndex: options.firstIndex(of: answer) ?? 0)
        }
    }

    /// The players take turns: even questions go to player 0, odd ones to player 1.
    public static func player(forQuestion index: Int) -> Int { index % 2 }

    /// Index of the winner, or `nil` for a draw.
    public static func winner(scores: [Int]) -> Int? {
        guard scores.count == 2, scores[0] != scores[1] else { return nil }
        return scores[0] > scores[1] ? 0 : 1
    }
}
