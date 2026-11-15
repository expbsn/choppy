import SwiftUI

/// The one background used behind every screen: paper colour, a soft paper grain and the
/// pattern chosen in the theme editor. Screens get it through `ChoppyScreen`, so it is always the same.
///
/// The pattern is always laid out at full window size from the top edge, so the copy behind a
/// screen header lines up exactly with the one behind the page.
struct AppBackground: View {
    @Environment(\.backgroundLayout) private var layout
    @Environment(\.windowSize) private var windowSize

    var body: some View {
        let settings = ThemeStore.shared.settings
        Color.paper
            .overlay(alignment: .top) {
                ZStack {
                    PaperTexture(strength: settings.paperTexture)
                    BackgroundPatternView(style: settings.background, layout: layout)
                        .opacity(settings.patternOpacity)
                }
                .frame(width: windowSize?.width, height: windowSize?.height)
            }
            .clipped()
            .ignoresSafeArea()
            // Purely decorative. The copy behind a header is laid out at full window size and only clipped
            // visually, so it must never take touches meant for the page below.
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

extension EnvironmentValues {
    /// Where background motifs may go on the current screen.
    @Entry var backgroundLayout: BackgroundLayout = .full
    /// Size of the whole window including safe areas, measured once at the root.
    @Entry var windowSize: CGSize?
}

/// Draws one background pattern in the current theme colours.
/// `scale` below 1 makes the motifs smaller, for previews.
struct BackgroundPatternView: View {
    var style: BackgroundStyle
    var layout: BackgroundLayout = .full
    var scale: CGFloat = 1

    var body: some View {
        switch style {
        case .plain: Color.clear
        case .momiji: MomijiPattern(layout: layout, scale: scale)
        default: linePattern.opacity(0.3).mask { framingMask }
        }
    }

    /// The geometric patterns are fine lines, so they are drawn lighter than the illustrated momiji scene.
    @ViewBuilder
    private var linePattern: some View {
        switch style {
        case .seigaiha: SeigaihaPattern(radius: 22 * scale, color: .ink, fill: .paper)
        case .asanoha: AsanohaPattern(side: 36 * scale, color: .ink)
        case .kikko: KikkoPattern(radius: 20 * scale, color: .ink)
        case .shippo: ShippoPattern(radius: 20 * scale, color: .ink)
        case .plain, .momiji: Color.clear
        }
    }

    @ViewBuilder
    private var framingMask: some View {
        switch layout {
        case .full: Color.black
        case .framing:
            LinearGradient(stops: [.init(color: .black, location: 0), .init(color: .black, location: 0.14),
                                   .init(color: .clear, location: 0.3), .init(color: .clear, location: 0.7),
                                   .init(color: .black, location: 0.86), .init(color: .black, location: 1)],
                           startPoint: .leading, endPoint: .trailing)
        }
    }
}

/// Fine paper grain: tiny specks and a few long, very light fibers.
/// `strength` 0 is flat colour, 1 is clearly textured.
struct PaperTexture: View {
    var strength: Double

    var body: some View {
        let fiberColor = Color.woodDark
        let speckColor = Color.wood
        Canvas { context, size in
            guard strength > 0 else { return }
            var rng = SeededRandom(seed: 0x5EED_CAFE)
            let area = size.width * size.height

            for _ in 0..<Int(area / 1_100 * strength) {
                let r = CGFloat.random(in: 0.4...1.2, using: &rng)
                let rect = CGRect(x: .random(in: 0...size.width, using: &rng),
                                  y: .random(in: 0...size.height, using: &rng),
                                  width: r, height: r)
                context.fill(Path(ellipseIn: rect), with: .color(speckColor.opacity(.random(in: 0.06...0.16, using: &rng))))
            }

            for _ in 0..<Int(area / 9_000 * strength) {
                let start = CGPoint(x: .random(in: 0...size.width, using: &rng),
                                    y: .random(in: 0...size.height, using: &rng))
                let length = CGFloat.random(in: 20...60, using: &rng)
                let angle = CGFloat.random(in: 0...(2 * .pi), using: &rng)
                let bend = CGFloat.random(in: -10...10, using: &rng)
                let end = CGPoint(x: start.x + cos(angle) * length, y: start.y + sin(angle) * length)
                let control = CGPoint(x: (start.x + end.x) / 2 + bend, y: (start.y + end.y) / 2 - bend)

                var fiber = Path()
                fiber.move(to: start)
                fiber.addQuadCurve(to: end, control: control)
                context.stroke(fiber, with: .color(fiberColor.opacity(.random(in: 0.015...0.035, using: &rng))),
                               lineWidth: .random(in: 0.3...0.6, using: &rng))
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview("Alle Muster") {
    ScrollView {
        LazyVGrid(columns: [GridItem(), GridItem()]) {
            ForEach(BackgroundStyle.allCases) { style in
                ZStack {
                    Color.paper
                    PaperTexture(strength: 0.5)
                    BackgroundPatternView(style: style).opacity(0.6)
                }
                .frame(height: 180)
                .overlay(alignment: .bottom) { Text(style.title).font(.choppyCaption).padding(4) }
            }
        }
        .padding()
    }
}
