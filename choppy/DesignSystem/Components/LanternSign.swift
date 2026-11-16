import SwiftUI

/// The tall standing lantern of the start screen: two lit paper panels with vertical brush
/// lettering under a small tiled roof. `columns` are read right to left, like a real sign;
/// the first column is the smaller right-hand panel.
struct LanternSign: View {
    var columns: [String]

    static let size = CGSize(width: 122, height: 198)

    private struct Palette {
        var roof, frame, paperTop, paperMid, paperLow: Color
    }

    var body: some View {
        let palette = Palette(roof: .kawara, frame: .sumi, paperTop: .washi100, paperMid: .washi50, paperLow: .washi300)
        Canvas { context, _ in
            Self.draw(in: &context, palette: palette)
        }
        .frame(width: Self.size.width, height: Self.size.height)
        .overlay(alignment: .topLeading) {
            // Left panel: the main word, large. Right panel: the lead-in, smaller.
            if columns.count > 1 { lettering(columns[1], size: 42, panelX: 15) }
            if let first = columns.first { lettering(first, size: 30, panelX: 64) }
        }
        .background {
            RadialGradient(stops: [.init(color: Color.akari400.opacity(0.5), location: 0),
                                   .init(color: Color.akari600.opacity(0.16), location: 0.5),
                                   .init(color: Color.akari600.opacity(0), location: 1)],
                           center: .center, startRadius: 0, endRadius: 200)
                .frame(width: 400, height: 400)
                .allowsHitTesting(false)
        }
        .accessibilityElement()
        .accessibilityLabel(Text(columns.joined(separator: " ")))
    }

    /// Vertical lettering centred on one 43 x 160 paper panel, shrunk to fit longer words.
    private func lettering(_ text: String, size: CGFloat, panelX: CGFloat) -> some View {
        let count = CGFloat(max(text.count, 1))
        let fitted = min(size, 148 / count / 1.3)
        return VStack(spacing: 0) {
            ForEach(Array(text.enumerated()), id: \.offset) { _, character in
                Text(brush: String(character), size: fitted).frame(height: fitted * 1.3)
            }
        }
        .foregroundStyle(.sumi)
        .dynamicTypeSize(.large)
        .frame(width: 43, height: 160)
        .offset(x: panelX, y: 24)
    }

    private static func draw(in context: inout GraphicsContext, palette: Palette) {
        let outline = GraphicsContext.Shading.color(SceneColor.outline)

        let frame = Path(CGRect(x: 9, y: 18, width: 104, height: 172))
        context.fill(frame, with: .color(palette.frame))
        context.stroke(frame, with: outline, lineWidth: 1.5)
        for x in [15.0, 64.0] {
            let panel = CGRect(x: x, y: 24, width: 43, height: 160)
            context.fill(Path(panel), with: .linearGradient(
                Gradient(stops: [.init(color: palette.paperTop, location: 0), .init(color: palette.paperMid, location: 0.5),
                                 .init(color: palette.paperLow, location: 1)]),
                startPoint: CGPoint(x: panel.midX, y: panel.minY), endPoint: CGPoint(x: panel.midX, y: panel.maxY)))
        }

        let base = Path(CGRect(x: 4, y: 190, width: 114, height: 8))
        context.fill(base, with: .color(SceneColor.soot))
        context.stroke(base, with: outline, lineWidth: 1.5)

        let roof = Path(CGRect(x: 0.75, y: 6, width: 120.5, height: 12))
        context.fill(roof, with: .color(palette.roof))
        context.stroke(roof, with: outline, lineWidth: 1.5)
        let ridge = Path(CGRect(x: 5, y: 0.75, width: 112, height: 6.5))
        context.fill(ridge, with: .color(SceneColor.tileDark))
        context.stroke(ridge, with: outline, lineWidth: 1.5)
    }
}

#Preview {
    LanternSign(columns: ["今週", "挨拶"])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { AppBackground() }
}
