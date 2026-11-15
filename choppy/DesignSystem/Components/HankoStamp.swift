import SwiftUI

/// A hanko (判子) seal used for achievements. Up to four characters, read
/// top to bottom and right column first, like a real seal.
/// Toggle `isStamped` to play the stamping animation.
struct HankoStamp: View {
    var text: String
    var size: CGFloat = 72
    var isStamped = true

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.14)
                .strokeBorder(lineWidth: size * 0.06)
            RoundedRectangle(cornerRadius: size * 0.09)
                .strokeBorder(lineWidth: size * 0.015)
                .padding(size * 0.1)
            characters
        }
        .foregroundStyle(.hanko)
        .frame(width: size, height: size)
        .mask { InkSpeckleMask() }
        .rotationEffect(.degrees(-7))
        .scaleEffect(isStamped ? 1 : 1.8)
        .opacity(isStamped ? 0.92 : 0)
        .animation(.spring(response: 0.28, dampingFraction: 0.55), value: isStamped)
        .sensoryFeedback(.impact(weight: .heavy), trigger: isStamped) { _, stamped in stamped }
        .accessibilityLabel(Text("Stempel \(text)"))
    }

    private var characters: some View {
        let chars = Array(text.prefix(4)).map(String.init)
        let columns: [[String]] = chars.count <= 2
            ? [chars]
            : [Array(chars.prefix(2)), Array(chars.dropFirst(2))]
        let glyphScale: CGFloat = switch chars.count {
        case ...1: 0.5
        case 2: 0.32
        default: 0.28
        }
        let glyphSize = size * glyphScale

        // Right column is read first, so it is laid out last (trailing).
        return HStack(spacing: size * 0.02) {
            ForEach(Array(columns.reversed().enumerated()), id: \.offset) { _, column in
                VStack(spacing: -size * 0.04) {
                    ForEach(Array(column.enumerated()), id: \.offset) { _, char in
                        Text(char).font(.choppyJapanese(glyphSize, weight: .black))
                    }
                }
            }
        }
    }
}

/// Knocks small holes into the stamp so it looks pressed by hand.
private struct InkSpeckleMask: View {
    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.black))
            context.blendMode = .clear
            var rng = SeededRandom(seed: 0x4A4E_4B4F)
            for _ in 0..<Int(size.width * size.height / 90) {
                let r = Double.random(in: 0.4...1.6, using: &rng)
                let rect = CGRect(x: .random(in: 0...size.width, using: &rng),
                                  y: .random(in: 0...size.height, using: &rng),
                                  width: r, height: r)
                context.fill(Path(ellipseIn: rect), with: .color(.black))
            }
        }
    }
}

#Preview {
    @Previewable @State var stamped = true
    VStack(spacing: Spacing.l) {
        HStack(spacing: Spacing.l) {
            HankoStamp(text: "合格", isStamped: stamped)
            HankoStamp(text: "完", size: 56, isStamped: stamped)
            HankoStamp(text: "毎日練習", size: 88, isStamped: stamped)
        }
        Button("Stempeln") { stamped.toggle() }.buttonStyle(.ink(.secondary))
    }
    .padding()
    .background { AppBackground() }
}
