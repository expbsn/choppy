import SwiftUI

/// Shippō (七宝) – interlocking circles. Circles on a square grid spaced `radius·√2`
/// overlap their neighbours so the overlaps form four-petalled flowers.
struct ShippoPattern: View {
    var radius: CGFloat = 20
    var color: Color = .ink
    var lineWidth: CGFloat = 0.9

    var body: some View {
        Canvas { context, size in
            let step = radius * sqrt(2)
            let rows = Int(size.height / step) + 2
            let columns = Int(size.width / step) + 2
            var path = Path()

            for row in -1..<rows {
                for column in -1..<columns {
                    let center = CGPoint(x: CGFloat(column) * step, y: CGFloat(row) * step)
                    path.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
                }
            }
            context.stroke(path, with: .color(color), lineWidth: lineWidth)
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    ShippoPattern(color: .accent)
        .background(Color.paper)
}
