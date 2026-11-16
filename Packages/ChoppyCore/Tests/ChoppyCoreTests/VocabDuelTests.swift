import Testing
@testable import ChoppyCore

struct VocabDuelTests {
    private static let pool: [VocabItem] = ["Hallo", "Danke", "Ja", "Nein", "Wasser", "Feuer"].enumerated().map { index, meaning in
        VocabItem(id: ContentID(kind: .vocab, source: "test", key: "w\(index)"), surface: "語\(index)", reading: "ご\(index)",
                  meanings: [meaning, "Nebenbedeutung"], topic: "greetings", difficulty: 1)
    }

    @Test func sameSeedGivesSameRound() {
        let a = VocabDuel.makeRound(pool: Self.pool, questionCount: 8, seed: 42)
        let b = VocabDuel.makeRound(pool: Self.pool, questionCount: 8, seed: 42)
        #expect(a.map(\.word.id) == b.map(\.word.id))
        #expect(a.map(\.options) == b.map(\.options))
        let c = VocabDuel.makeRound(pool: Self.pool, questionCount: 8, seed: 43)
        #expect(a.map(\.options) != c.map(\.options))
    }

    @Test func everyQuestionHasFourDistinctOptionsWithTheAnswer() {
        let round = VocabDuel.makeRound(pool: Self.pool, questionCount: 12, seed: 7)
        #expect(round.count == 12)
        for question in round {
            #expect(question.options.count == 4)
            #expect(Set(question.options).count == 4)
            #expect(question.options[question.correctIndex] == question.word.meanings[0])
        }
    }

    @Test func wordsAreNotRepeatedBeforeThePoolIsUsedUp() {
        let round = VocabDuel.makeRound(pool: Self.pool, questionCount: 6, seed: 3)
        #expect(Set(round.map(\.word.id)).count == 6)
    }

    @Test func smallPoolsGiveFewerOptionsOrNoRound() {
        let two = VocabDuel.makeRound(pool: Array(Self.pool.prefix(2)), questionCount: 4, seed: 1)
        #expect(two.count == 4)
        #expect(two.allSatisfy { $0.options.count == 2 })
        #expect(VocabDuel.makeRound(pool: Array(Self.pool.prefix(1)), questionCount: 4, seed: 1).isEmpty)
    }

    @Test func playersTakeTurnsAndWinnerIsDecided() {
        #expect((0..<4).map(VocabDuel.player(forQuestion:)) == [0, 1, 0, 1])
        #expect(VocabDuel.winner(scores: [4, 2]) == 0)
        #expect(VocabDuel.winner(scores: [1, 5]) == 1)
        #expect(VocabDuel.winner(scores: [3, 3]) == nil)
    }
}
