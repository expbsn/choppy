import ChoppyCore
import SwiftUI

enum VocabDuelRules {
    static let seconds = VocabDuel.secondsPerQuestion
    static let questions = 12
}

/// The vocabulary duel ("Screen / Vokabelduell" in Figma). Two players share one device and take
/// turns: a word on the lantern, four meanings on planks, a few seconds per question.
struct VocabDuelView: View {
    let pool: [VocabItem]
    var seed = UInt64.random(in: 0...UInt64.max)

    @Environment(\.dismiss) private var dismiss
    @State private var round: [DuelQuestion] = []
    @State private var index = 0
    @State private var scores = [0, 0]
    @State private var chosen: Int?
    @State private var timedOut = false
    @State private var timeLeft = VocabDuelRules.seconds
    @State private var isFinished = false

    private var store: LocalDraftStore { .shared }
    private var question: DuelQuestion? { round.indices.contains(index) ? round[index] : nil }
    private var isRevealed: Bool { chosen != nil || timedOut }

    var body: some View {
        // The shop front of the Figma screen: sky with the header, roof, wall with the noren score
        // boards, the lantern card and the answers, then the lit window and the paving.
        VStack(spacing: 0) {
            header
                .padding(.horizontal, Spacing.l)
                .padding(.top, Spacing.xs)
                .padding(.bottom, Spacing.s)
            ShopRoof()
            VStack(spacing: Spacing.m) {
                scoreboard
                if isFinished {
                    result
                } else if let question {
                    card(question)
                    answers(question)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background { ShopWall() }
            LatticeWindow()
            StonePavement().frame(height: 58)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // The paving runs under the home indicator.
        .ignoresSafeArea(edges: .bottom)
        .background { AppBackground() }
        .environment(\.sceneGroundY, nil)
        .font(.choppyBody)
        .foregroundStyle(.washi50)
        .onAppear { if round.isEmpty { start() } }
        .task(id: index) { await countDown() }
    }

    // MARK: Parts

    private var header: some View {
        HStack(alignment: .center, spacing: Spacing.s) {
            PlankIconButton(systemImage: "xmark", label: "Duell beenden") { dismiss() }
            VStack(alignment: .leading, spacing: 0) {
                Text("Vokabelduell").font(.choppyTitle)
                Text(isFinished ? "Ergebnis" : "Frage \(min(index + 1, round.count)) von \(round.count)")
                    .font(.choppyCaption)
                    .foregroundStyle(.washi300)
            }
            Spacer(minLength: 0)
            if !isFinished {
                Text("0:\(String(format: "%02d", timeLeft))")
                    .font(.choppyMono(20, weight: .medium))
                    .foregroundStyle(timeLeft <= 3 ? .chochin : .akari400)
                    .contentTransition(.numericText(countsDown: true))
                    .accessibilityLabel(Text("Noch \(timeLeft) Sekunden"))
            }
        }
    }

    private var scoreboard: some View {
        VStack(spacing: 0) {
            SceneColor.outline.frame(height: 5).padding(.horizontal, -8)
            HStack(alignment: .top, spacing: Spacing.xs) {
                score(of: 0)
                NorenCloth {
                    Canvas { context, size in
                        context.fill(NightScene.leafPath(center: CGPoint(x: size.width / 2, y: size.height / 2 + 6), radius: 22, rotation: 0),
                                     with: .color(Color(hex: ColorToken.washi100.defaultHex)))
                    }
                }
                .frame(height: 104)
                score(of: 1)
            }
        }
    }

    private func score(of player: Int) -> some View {
        let isActive = !isFinished && VocabDuel.player(forQuestion: index) == player
        return NorenCloth {
            VStack(spacing: 0) {
                Text(store.name(of: player)).font(.choppyAccent(14, relativeTo: .subheadline)).foregroundStyle(.washi100)
                    .lineLimit(1).minimumScaleFactor(0.7)
                Text("\(scores[player])")
                    .font(.choppyMono(32, weight: .medium, relativeTo: .largeTitle))
                    .foregroundStyle(isActive || isFinished ? .washi50 : .washi300)
                    .contentTransition(.numericText())
            }
            .padding(.top, 14)
            .padding(.horizontal, Spacing.xxs)
        }
        .frame(height: 92)
        // The cloth of the player whose turn it is hangs in the lantern light.
        .overlay(alignment: .bottom) { Color.akari400.frame(height: isActive ? 3 : 0) }
        .opacity(isActive || isFinished ? 1 : 0.7)
        .animation(.easeOut(duration: 0.2), value: isActive)
        .accessibilityElement(children: .combine)
    }

    private func card(_ question: DuelQuestion) -> some View {
        LanternCard {
            VStack(spacing: Spacing.xxs) {
                Text("\(store.name(of: VocabDuel.player(forQuestion: index))), was bedeutet das?")
                    .font(.choppyFootnote)
                    .foregroundStyle(.sugi400)
                Text(brush: question.word.surface, size: min(72, 264 / CGFloat(max(question.word.surface.count, 1))))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(minHeight: 84)
                if question.word.reading != question.word.surface {
                    Text(question.word.reading).font(.choppyTitle)
                }
            }
        }
        .id(question.id)
        .transition(.opacity)
    }

    private func answers(_ question: DuelQuestion) -> some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: Spacing.m), GridItem(.flexible())], spacing: Spacing.m) {
            ForEach(Array(question.options.enumerated()), id: \.offset) { option, text in
                Button { choose(option, in: question) } label: {
                    AnswerPlank(text: text, status: status(of: option, in: question))
                }
                .buttonStyle(.plain)
                .disabled(isRevealed)
            }
        }
        .sensoryFeedback(trigger: chosen) { _, new in
            guard let new else { return nil }
            return new == question.correctIndex ? .success : .error
        }
    }

    private var result: some View {
        let winner = VocabDuel.winner(scores: scores)
        return VStack(spacing: Spacing.m) {
            LanternCard {
                VStack(spacing: Spacing.xs) {
                    Text(winner == nil ? "Unentschieden" : "Gewonnen hat").font(.choppyFootnote).foregroundStyle(.sugi400)
                    Text(winner.map { store.name(of: $0) } ?? "\(scores[0]) : \(scores[1])").font(.choppyDisplay)
                    HankoStamp(text: winner == nil ? "引分" : "勝", size: 64)
                }
            }
            Button("Noch ein Duell") { start() }.buttonStyle(.choppy(.paper, fullWidth: true))
            Button("Fertig") { dismiss() }.buttonStyle(.choppy(.plank, fullWidth: true))
        }
    }

    // MARK: Flow

    private func status(of option: Int, in question: DuelQuestion) -> AnswerPlank.Status {
        guard isRevealed else { return .open }
        if option == question.correctIndex { return .correct }
        return option == chosen ? .wrong : .open
    }

    private func start() {
        round = VocabDuel.makeRound(pool: pool, questionCount: VocabDuelRules.questions,
                                    seed: seed &+ UInt64(store.state.duels.count))
        index = 0
        scores = [0, 0]
        chosen = nil
        timedOut = false
        isFinished = round.isEmpty
        timeLeft = VocabDuelRules.seconds
    }

    private func choose(_ option: Int, in question: DuelQuestion) {
        guard !isRevealed else { return }
        chosen = option
        if option == question.correctIndex {
            withAnimation { scores[VocabDuel.player(forQuestion: index)] += 1 }
        }
        Task { await advance(after: question.id) }
    }

    /// Counts the seconds of the current question down; running out counts as a miss.
    private func countDown() async {
        guard !isFinished, question != nil else { return }
        timeLeft = VocabDuelRules.seconds
        let current = index
        while timeLeft > 0 {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled, current == index, !isRevealed else { return }
            withAnimation { timeLeft -= 1 }
        }
        timedOut = true
        await advance(after: current)
    }

    /// Shows the right answer briefly, then moves on or ends the duel.
    private func advance(after questionID: Int) async {
        try? await Task.sleep(for: .seconds(1.1))
        guard questionID == index, !isFinished else { return }
        if index + 1 < round.count {
            withAnimation(.easeOut(duration: 0.2)) {
                chosen = nil
                timedOut = false
                index += 1
            }
        } else {
            store.record(duel: scores)
            withAnimation { isFinished = true }
        }
    }
}

#Preview {
    VocabDuelView(pool: (try! ContentLibrary.loadBundled()).vocab, seed: 1)
}
