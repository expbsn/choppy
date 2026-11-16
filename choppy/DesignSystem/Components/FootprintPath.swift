import SwiftUI
import UIKit

/// The progress path: one Choppy footprint per week along a winding trail that climbs
/// from the bottom (week 1) to the top. Finished weeks are green, the current week is
/// highlighted, future weeks are faint.
struct FootprintPath: View {
    var weeks: Int
    /// Number of finished weeks; the week after them is the current one.
    var completed: Int
    var stepHeight: CGFloat = 72

    @State private var appeared = false

    var body: some View {
        GeometryReader { proxy in
            let points = (0..<weeks).map { point(for: $0, size: proxy.size) }
            ZStack(alignment: .topLeading) {
                trail(through: points)
                    .stroke(Color.washi300.opacity(0.35), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [2, 7]))

                ForEach(0..<weeks, id: \.self) { week in
                    footprint(week: week)
                        .rotationEffect(heading(at: week, points: points))
                        .position(points[week])
                        .offset(x: week.isMultiple(of: 2) ? -6 : 6)
                        .scaleEffect(appeared ? 1 : 0.3, anchor: .center)
                        .opacity(appeared ? 1 : 0)
                        .animation(.spring(duration: 0.45, bounce: 0.45).delay(Double(week) * 0.07), value: appeared)

                    Text("\(week + 1)")
                        .font(.choppyCaption)
                        .foregroundStyle(.washi300)
                        .position(x: points[week].x + (points[week].x > proxy.size.width / 2 ? -44 : 44), y: points[week].y)
                }
            }
        }
        .frame(height: CGFloat(weeks) * stepHeight)
        .onAppear { appeared = true }
        .accessibilityElement()
        .accessibilityLabel(Text("Woche \(min(completed + 1, weeks)) von \(weeks)"))
    }

    private func point(for week: Int, size: CGSize) -> CGPoint {
        CGPoint(x: size.width / 2 + sin(Double(week) * 0.85) * size.width * 0.22,
                y: size.height - stepHeight * (CGFloat(week) + 0.5))
    }

    /// Smooth Catmull-Rom curve that passes through every footprint.
    private func trail(through points: [CGPoint]) -> Path {
        Path { path in
            guard let first = points.first else { return }
            path.move(to: first)
            for i in 0..<(points.count - 1) {
                let p0 = points[max(i - 1, 0)], p1 = points[i]
                let p2 = points[i + 1], p3 = points[min(i + 2, points.count - 1)]
                path.addCurve(
                    to: p2,
                    control1: CGPoint(x: p1.x + (p2.x - p0.x) / 6, y: p1.y + (p2.y - p0.y) / 6),
                    control2: CGPoint(x: p2.x - (p3.x - p1.x) / 6, y: p2.y - (p3.y - p1.y) / 6)
                )
            }
        }
    }

    /// Footprints point in the walking direction (upwards along the trail).
    private func heading(at week: Int, points: [CGPoint]) -> Angle {
        let from = points[max(week - 1, 0)]
        let to = points[min(week + 1, points.count - 1)]
        return .radians(atan2(to.y - from.y, to.x - from.x)) + .degrees(90)
    }

    @ViewBuilder
    private func footprint(week: Int) -> some View {
        let isCurrent = week == completed
        let style: Color = week < completed ? .momiji300 : isCurrent ? .akari400 : .kasumi.opacity(0.4)
        Group {
            if UIImage(named: "footprint") != nil {
                Image("footprint").renderingMode(.template).resizable().scaledToFit()
            } else {
                Image(systemName: "pawprint.fill").resizable().scaledToFit()
            }
        }
        .foregroundStyle(style)
        .frame(width: 28, height: 28)
        .phaseAnimator(isCurrent ? [false, true] : [false]) { content, pulse in
            content.scaleEffect(pulse ? 1.18 : 1)
        } animation: { _ in .easeInOut(duration: 0.9) }
    }
}

#Preview {
    ScrollView {
        FootprintPath(weeks: 10, completed: 4)
            .padding()
    }
    .defaultScrollAnchor(.bottom)
    .background { AppBackground() }
}
