import SwiftUI

/// A standing lantern as a card ("Laternenkarte" in Figma): a tiled roof, lit paper in a dark
/// frame, and a base. Holds the question of a game or the translator. Text on it is ink-dark.
struct LanternCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            Color.kawara
                .frame(height: 6)
                .border(Color.sumi, width: 1.5)
                .padding(.horizontal, Spacing.m)
            TileEdge(base: .sumi)
            content
                .padding(.vertical, Spacing.m)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.sumi)
                .background { Color.washi50.overlay(alignment: .bottom) { Color.washi300.frame(height: 6) } }
                .padding(6)
                .background(Color.sumi)
                .padding(.horizontal, Spacing.xs)
            Color.sumi.frame(height: 8)
        }
    }
}

/// One answer of a multiple-choice question ("Antwort / …" in Figma): a dark plank that turns
/// to paper when chosen and gets a green or red marker once the answer is revealed.
struct AnswerPlank: View {
    enum Status { case open, selected, correct, wrong }

    var text: String
    var status: Status = .open

    var body: some View {
        let isPaper = status == .selected
        HStack(spacing: Spacing.s) {
            if status == .correct || status == .wrong {
                (status == .correct ? Color.momiji500 : Color.chochin).frame(width: 4, height: 20)
            }
            Text(text)
                .font(.choppyHeadline)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Spacer(minLength: 0)
        }
        .foregroundStyle(isPaper ? .sumi : .washi100)
        .padding(.horizontal, Spacing.m)
        .frame(height: 44)
        .background {
            (isPaper ? Color.washi50 : Color.sugi800)
                .overlay(alignment: isPaper ? .bottom : .top) {
                    (isPaper ? Color.washi300 : Color.sugi600).frame(height: isPaper ? 3 : 1)
                }
                .clipShape(.rect(cornerRadius: Radius.s))
        }
        .padding(2)
        .background(isPaper ? Color.washi100 : Color.sumi, in: .rect(cornerRadius: Radius.s + 2))
        .contentShape(.rect)
    }
}

#Preview {
    VStack(spacing: Spacing.m) {
        LanternCard {
            VStack(spacing: Spacing.xxs) {
                Text("Was bedeutet das?").font(.choppyFootnote).foregroundStyle(.sugi400)
                Text(brush: "水", size: 88)
                Text("みず").font(.choppyTitle)
            }
        }
        Grid(horizontalSpacing: Spacing.m, verticalSpacing: Spacing.m) {
            GridRow { AnswerPlank(text: "Wasser", status: .selected); AnswerPlank(text: "Feuer") }
            GridRow { AnswerPlank(text: "Baum", status: .correct); AnswerPlank(text: "Berg", status: .wrong) }
        }
    }
    .padding(Spacing.l)
    .frame(maxHeight: .infinity)
    .background { AppBackground() }
}
