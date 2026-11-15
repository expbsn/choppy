import SwiftUI

/// Seigaiha (青海波) – overlapping wave scales. Rows are drawn top to bottom
/// and each wave is filled first, so lower rows cover the upper ones.
struct SeigaihaPattern: View {
    var radius: CGFloat = 22
    var color: Color = .ink
    var fill: Color = .paper
    var rings = 4
    var lineWidth: CGFloat = 1

    var body: some View {
        Canvas { context, size in
            let columnStep = radius * 2
            let rowStep = radius / 2
            let rows = Int(size.height / rowStep) + 3
            let columns = Int(size.width / columnStep) + 2

            for row in 0..<rows {
                let y = CGFloat(row) * rowStep
                let offset = row.isMultiple(of: 2) ? 0 : radius
                for column in -1..<columns {
                    let center = CGPoint(x: CGFloat(column) * columnStep + offset, y: y)
                    context.fill(circle(center, radius), with: .color(fill))
                    for ring in 0..<rings {
                        let r = radius * (1 - CGFloat(ring) / CGFloat(rings))
                        context.stroke(circle(center, r), with: .color(color), lineWidth: lineWidth)
                    }
                }
            }
        }
        .accessibilityHidden(true)
    }

    private func circle(_ center: CGPoint, _ r: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2))
    }
}

#Preview {
    SeigaihaPattern(color: .accent, fill: .paper)
        .background(Color.paper)
}
