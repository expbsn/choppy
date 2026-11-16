import SwiftUI

/// A row of roof tiles seen from the front ("Ziegelkante" in Figma): a tile band with one round
/// end cap every 14 points. Sits on top of wooden panels, the tab bar and lantern cards.
struct TileEdge: View {
    static let height: CGFloat = 17

    /// What the tiles rest on. Fills the slivers between the round caps; without it, whatever is
    /// behind the edge shows through there.
    var base: Color?

    var body: some View {
        let tile = Color.kawara
        Canvas { context, size in
            Self.draw(in: &context, width: size.width, tile: tile, base: base)
        }
        .frame(height: Self.height)
        .accessibilityHidden(true)
    }

    private static func draw(in context: inout GraphicsContext, width: CGFloat, tile: Color, base: Color?) {
        if let base {
            context.fill(Path(CGRect(x: 0, y: 12, width: width, height: height - 12)), with: .color(base))
        }
        context.fill(Path(CGRect(x: 0, y: 0, width: width, height: 14)), with: .color(tile))
        context.fill(Path(CGRect(x: 0, y: 0, width: width, height: 4)), with: .color(SceneColor.tileLight))

        // Spread the caps evenly, so the row is symmetrical on every screen width.
        let count = max(Int((width / 14).rounded()), 1)
        let pitch = width / CGFloat(count)
        let centers = (0..<count).map { (CGFloat($0) + 0.5) * pitch }

        var ridges = Path()
        for x in centers {
            ridges.move(to: CGPoint(x: x, y: 2))
            ridges.addLine(to: CGPoint(x: x, y: 8))
        }
        context.stroke(ridges, with: .color(SceneColor.tileDark), lineWidth: 1.5)

        for x in centers {
            let cap = Path(ellipseIn: CGRect(x: x - 5, y: 6, width: 10, height: 11))
            context.fill(cap, with: .color(SceneColor.tileDark))
            context.stroke(cap, with: .color(SceneColor.outline), lineWidth: 1.2)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        TileEdge()
        Color.sugi800.frame(height: 80)
    }
    .frame(maxHeight: .infinity)
    .background { AppBackground() }
}
