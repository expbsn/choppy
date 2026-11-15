import SwiftUI

/// Asanoha (麻の葉) – hemp-leaf star lattice. Built from a grid of equilateral
/// triangles, each with lines from its corners to its centre.
struct AsanohaPattern: View {
    var side: CGFloat = 36
    var color: Color = .ink
    var lineWidth: CGFloat = 0.8

    var body: some View {
        Canvas { context, size in
            let height = side * sqrt(3) / 2
            let rows = Int(size.height / height) + 2
            let columns = Int(size.width / side) + 2
            var path = Path()

            for row in 0..<rows {
                let y = CGFloat(row) * height
                let shift: CGFloat = row.isMultiple(of: 2) ? 0 : side / 2
                for column in -1..<columns {
                    let x = CGFloat(column) * side + shift
                    // Upward triangle and the downward triangle next to it.
                    let up = [CGPoint(x: x, y: y + height), CGPoint(x: x + side, y: y + height), CGPoint(x: x + side / 2, y: y)]
                    let down = [CGPoint(x: x + side / 2, y: y), CGPoint(x: x + side * 1.5, y: y), CGPoint(x: x + side, y: y + height)]
                    for triangle in [up, down] {
                        addLeaf(triangle, to: &path)
                    }
                }
            }
            context.stroke(path, with: .color(color), lineWidth: lineWidth)
        }
        .accessibilityHidden(true)
    }

    private func addLeaf(_ corners: [CGPoint], to path: inout Path) {
        let centre = CGPoint(x: corners.map(\.x).reduce(0, +) / 3, y: corners.map(\.y).reduce(0, +) / 3)
        path.addLines(corners + [corners[0]])
        for corner in corners {
            path.move(to: corner)
            path.addLine(to: centre)
        }
    }
}

#Preview {
    AsanohaPattern(color: .accent)
        .background(Color.paper)
}
