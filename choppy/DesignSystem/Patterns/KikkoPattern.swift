import SwiftUI

/// Kikkō (亀甲) – tortoise-shell hexagons, each with a second hexagon inside.
struct KikkoPattern: View {
    var radius: CGFloat = 20
    var color: Color = .ink
    var lineWidth: CGFloat = 0.9

    var body: some View {
        Canvas { context, size in
            let columnStep = radius * sqrt(3)
            let rowStep = radius * 1.5
            let rows = Int(size.height / rowStep) + 2
            let columns = Int(size.width / columnStep) + 2
            var path = Path()

            for row in -1..<rows {
                let shift = row.isMultiple(of: 2) ? 0 : columnStep / 2
                for column in -1..<columns {
                    let center = CGPoint(x: CGFloat(column) * columnStep + shift, y: CGFloat(row) * rowStep)
                    path.addPath(hexagon(center, radius))
                    path.addPath(hexagon(center, radius * 0.7))
                }
            }
            context.stroke(path, with: .color(color), lineWidth: lineWidth)
        }
        .accessibilityHidden(true)
    }

    /// Pointy-top hexagon.
    private func hexagon(_ center: CGPoint, _ r: CGFloat) -> Path {
        Path { path in
            let corners = (0..<6).map { i in
                let angle = Double(i) * .pi / 3 - .pi / 2
                return CGPoint(x: center.x + cos(angle) * r, y: center.y + sin(angle) * r)
            }
            path.addLines(corners)
            path.closeSubpath()
        }
    }
}

#Preview {
    KikkoPattern(color: .accent)
        .background(Color.paper)
}
