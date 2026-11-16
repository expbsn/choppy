import SwiftUI

/// A small paper lantern ("Chōchin" in Figma). Lit ones are red with a warm highlight,
/// unlit ones are only outlined. Used as a marker for streak days and learned words.
struct Chochin: View {
    var isLit: Bool

    private struct Palette {
        var body, rib, light, off, ink: Color
    }

    var body: some View {
        let palette = Palette(body: .chochin, rib: .chochinYoru, light: .akari400, off: .kasumi, ink: .sumi)
        Canvas { context, _ in
            Self.draw(in: &context, isLit: isLit, palette: palette)
        }
        .frame(width: 16, height: 26)
        .accessibilityHidden(true)
    }

    private static func draw(in context: inout GraphicsContext, isLit: Bool, palette: Palette) {
        let line = isLit ? palette.ink : palette.off
        let shell = Path(roundedRect: CGRect(x: 1, y: 4, width: 14, height: 18), cornerRadius: 6)
        if isLit {
            context.fill(shell, with: .color(palette.body))
        }
        var ribs = Path()
        for y in [9.0, 13.0, 17.0] {
            ribs.move(to: CGPoint(x: 1.6, y: y))
            ribs.addLine(to: CGPoint(x: 14.4, y: y))
        }
        context.stroke(ribs, with: .color(isLit ? palette.rib : palette.off.opacity(0.5)), lineWidth: 1)
        context.stroke(shell, with: .color(line), lineWidth: 1.2)
        if isLit {
            context.fill(Path(ellipseIn: CGRect(x: 3.8, y: 7.2, width: 3.2, height: 6.4)), with: .color(palette.light.opacity(0.6)))
        }
        for y in [1.0, 22.0] {
            context.fill(Path(CGRect(x: 5, y: y, width: 6, height: 3)), with: .color(line))
        }
    }
}

/// A row of lanterns counting something out of a total, e.g. the days practiced this week.
struct ChochinCounter: View {
    var lit: Int
    var total: Int = 7

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { index in
                Chochin(isLit: index < lit)
            }
        }
        .accessibilityElement()
        .accessibilityLabel(Text("\(lit) von \(total)"))
    }
}

/// A hanging wooden plaque with vertical brush lettering ("Holztafel" in Figma).
struct Holztafel: View {
    var text: String

    var body: some View {
        VStack(spacing: 6) {
            Circle().fill(Color.kasumi).frame(width: 4, height: 4)
            VStack(spacing: 0) {
                ForEach(Array(text.enumerated()), id: \.offset) { _, character in
                    Text(brush: String(character), size: 22).frame(height: 28)
                }
            }
            .foregroundStyle(.washi100)
        }
        .padding(.vertical, Spacing.s)
        .padding(.horizontal, Spacing.xs)
        .background {
            Color.sugi800.overlay(alignment: .top) { Color.sugi600.frame(height: 1) }
                .clipShape(.rect(cornerRadius: Radius.s))
        }
        .padding(2)
        .background(Color.sumi, in: .rect(cornerRadius: Radius.s + 2))
        .accessibilityElement()
        .accessibilityLabel(Text(text))
    }
}

/// A two-way switch made of noren cloths hanging from a rod ("Noren-Umschalter" in Figma).
struct NorenSwitch<Value: Hashable>: View {
    @Binding var selection: Value
    var options: [(value: Value, title: LocalizedStringKey)]

    var body: some View {
        VStack(spacing: 0) {
            Color.sumi.frame(height: 4)
            HStack(spacing: Spacing.xxs) {
                ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                    let isSelected = option.value == selection
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) { selection = option.value }
                    } label: {
                        Text(option.title)
                            .font(.choppyAccent(14, relativeTo: .subheadline))
                            .foregroundStyle(isSelected ? .washi50 : .washi300)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(isSelected ? Color.ai500 : Color.ai700)
                            // The unselected cloth has the colour of the mid sky, so it gets a fine edge.
                            .border(Color.ai500.opacity(isSelected ? 0 : 0.7), width: 1)
                            .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
            .padding(.horizontal, Spacing.xxs)
        }
        .sensoryFeedback(.selection, trigger: selection)
    }
}

#Preview {
    @Previewable @State var script = "hiragana"
    VStack(alignment: .leading, spacing: Spacing.l) {
        ChochinCounter(lit: 4)
        HStack(spacing: Spacing.m) {
            Holztafel(text: "学ぶ")
            Holztafel(text: "道")
        }
        NorenSwitch(selection: $script, options: [("hiragana", "Hiragana"), ("katakana", "Katakana")])
            .frame(width: 232)
    }
    .padding(Spacing.l)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    .background { AppBackground() }
}
