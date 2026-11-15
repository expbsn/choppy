import SwiftUI

/// Where background motifs may go.
enum BackgroundLayout {
    /// A calm, even scatter of single leaves over the whole screen (most screens).
    case full
    /// The illustrated scene: misty hills and leafy branches reaching in from the left and right
    /// edges, keeping the middle free for the footprint path.
    case framing
}

/// Momiji (紅葉) – deeply cut maple leaves in stamp red and two palette browns.
/// `.full` spreads single leaves evenly over the screen (Poisson-disc style, no rows or columns);
/// `.framing` paints the Pfad scene in sumi-e style: green hills, dry ink-brush branches and
/// translucent watercolour leaves hanging from thin stalks. Everything is seeded, so it never changes between launches.
struct MomijiPattern: View {
    var layout: BackgroundLayout = .full
    /// Shrinks leaves, branches and spacing, e.g. for small previews.
    var scale: CGFloat = 1
    var seed: UInt64 = 0x4D4F_4D49

    private struct Palette {
        var leaves: [Color]
        var hills: [Color]
        var mist: Color
        var washes: [Color]
        var brushInk: Color
    }

    var body: some View {
        let palette = Palette(
            leaves: [.leafRed, .leafRed, .leafRed, .leafLight, .leafLight, .leafDark, .leafDark],
            hills: [Color.paper.mix(with: .bamboo, by: 0.22), Color.paper.mix(with: .bamboo, by: 0.42), Color.paper.mix(with: .accent, by: 0.3)],
            mist: Color.paper.mix(with: .card, by: 0.6),
            washes: [.leafRed, .leafRed, Color.leafRed.mix(with: .leafLight, by: 0.45), .leafLight, Color.leafLight.mix(with: .white, by: 0.35)],
            brushInk: Color.ink.mix(with: .leafDark, by: 0.3))
        Canvas { context, size in
            var rng = SeededRandom(seed: seed)
            var leaves: [Leaf]
            switch layout {
            case .full:
                leaves = Self.scatteredLeaves(size: size, scale: scale, rng: &rng)
            case .framing:
                Self.drawHills(in: &context, size: size, colors: palette.hills, mist: palette.mist, rng: &rng)
                leaves = []
                for branch in Self.edgeBranches(size: size, scale: scale, rng: &rng) {
                    Self.paint(branch, in: &context, palette: palette, scale: scale, rng: &rng)
                }
            }
            for leaf in leaves {
                var leafContext = context
                leafContext.translateBy(x: leaf.center.x, y: leaf.center.y)
                leafContext.rotate(by: leaf.angle)
                leafContext.scaleBy(x: leaf.radius, y: leaf.radius)
                let color = palette.leaves[leaf.colorIndex % palette.leaves.count]
                leafContext.fill(Self.leaf, with: .color(color.mix(with: .white, by: leaf.lighten)))
            }
        }
        .accessibilityHidden(true)
    }

    // MARK: Scene parts

    private struct Leaf {
        var center: CGPoint
        var radius: CGFloat
        var angle: Angle
        var colorIndex: Int
        var lighten: Double
    }

    private struct Branch {
        var start: CGPoint
        var control1: CGPoint
        var control2: CGPoint
        var end: CGPoint

        func point(at t: CGFloat) -> CGPoint {
            let u = 1 - t
            let a = u * u * u, b = 3 * u * u * t, c = 3 * u * t * t, d = t * t * t
            return CGPoint(x: a * start.x + b * control1.x + c * control2.x + d * end.x,
                           y: a * start.y + b * control1.y + c * control2.y + d * end.y)
        }
    }

    /// Single leaves dropped at random and kept only if they do not crowd a neighbour (Poisson-disc
    /// sampling): spread evenly, with no rows, columns or clumps. `keep` limits where leaves may go.
    private static func scatteredLeaves(size: CGSize, scale: CGFloat, rng: inout SeededRandom,
                                        keep: (CGPoint) -> Bool = { _ in true }) -> [Leaf] {
        var result: [Leaf] = []
        for _ in 0..<Int(size.width * size.height / 220) {
            let center = CGPoint(x: .random(in: -16...size.width + 16, using: &rng),
                                 y: .random(in: -16...size.height + 16, using: &rng))
            let radius = CGFloat.random(in: 13...22, using: &rng) * scale
            let angle = Angle.degrees(.random(in: 0...360, using: &rng))
            let colorIndex = Int.random(in: 0..<14, using: &rng)
            let lighten = Double.random(in: 0...0.12, using: &rng)
            guard keep(center),
                  result.allSatisfy({ hypot($0.center.x - center.x, $0.center.y - center.y) >= ($0.radius + radius) * 1.55 })
            else { continue }
            result.append(Leaf(center: center, radius: radius, angle: angle, colorIndex: colorIndex, lighten: lighten))
        }
        return result
    }

    /// Three soft ridges in the lower half, each fading into a band of mist.
    private static func drawHills(in context: inout GraphicsContext, size: CGSize, colors: [Color], mist: Color, rng: inout SeededRandom) {
        for (index, color) in colors.enumerated() {
            let baseY = size.height * (0.5 + CGFloat(index) * 0.13)
            let phase = CGFloat.random(in: 0...(2 * .pi), using: &rng)
            let amplitude = size.height * (0.035 + 0.01 * CGFloat(index))
            var ridge = Path()
            ridge.move(to: CGPoint(x: 0, y: size.height))
            for step in 0...40 {
                let x = size.width * CGFloat(step) / 40
                let wave = sin(x / size.width * 2.6 * .pi + phase) + 0.45 * sin(x / size.width * 6.3 * .pi + phase * 1.7)
                ridge.addLine(to: CGPoint(x: x, y: baseY - wave * amplitude))
            }
            ridge.addLine(to: CGPoint(x: size.width, y: size.height))
            ridge.closeSubpath()
            context.fill(ridge, with: .color(color))

            let mistBand = CGRect(x: 0, y: baseY + amplitude * 0.6, width: size.width, height: size.height * 0.1)
            context.fill(Path(mistBand), with: .linearGradient(
                Gradient(colors: [mist.opacity(0), mist.opacity(0.7), mist.opacity(0)]),
                startPoint: CGPoint(x: 0, y: mistBand.minY), endPoint: CGPoint(x: 0, y: mistBand.maxY)))
        }
    }

    /// Short branches from both edges. Each side has its own irregular rhythm, so branches never line up
    /// in rows or mirror each other.
    private static func edgeBranches(size: CGSize, scale: CGFloat, rng: inout SeededRandom) -> [Branch] {
        var result: [Branch] = []
        for left in [true, false] {
            var y = CGFloat.random(in: -40...60, using: &rng) * scale
            while y < size.height + 40 * scale {
                let length = size.width * .random(in: 0.07...0.24, using: &rng)
                let rise = CGFloat.random(in: -70...50, using: &rng) * scale
                let sign: CGFloat = left ? 1 : -1
                let startX: CGFloat = left ? -10 : size.width + 10
                result.append(Branch(
                    start: CGPoint(x: startX, y: y),
                    control1: CGPoint(x: startX + sign * length * 0.35, y: y - .random(in: 5...30, using: &rng) * scale),
                    control2: CGPoint(x: startX + sign * length * 0.7, y: y + rise * 0.4),
                    end: CGPoint(x: startX + sign * length, y: y + rise)))
                y += .random(in: 95...190, using: &rng) * scale
            }
        }
        return result
    }

    // MARK: Sumi-e branches (Pfad)

    /// A painted branch: a dry ink stroke with twigs, each twig ending in a sprig of hanging leaves.
    private static func paint(_ branch: Branch, in context: inout GraphicsContext, palette: Palette,
                              scale: CGFloat, rng: inout SeededRandom) {
        brushStroke(along: { branch.point(at: $0) }, width: 4.2 * scale, taper: 0.7, ink: palette.brushInk, in: &context, rng: &rng)

        var sprigs: [(CGPoint, CGFloat)] = [(branch.end, .pi / 2)]
        for _ in 0..<Int.random(in: 2...4, using: &rng) {
            let t = CGFloat.random(in: 0.3...0.95, using: &rng)
            let base = branch.point(at: t)
            let ahead = branch.point(at: min(t + 0.04, 1))
            let along = atan2(ahead.y - base.y, ahead.x - base.x)
            // Twigs lean downwards, the way laden maple twigs droop.
            let angle = along + (Bool.random(using: &rng) ? -1 : 1) * .random(in: 0.4...1.0, using: &rng)
            let droop = (angle + .pi / 2) / 2 + .random(in: -0.3...0.3, using: &rng)
            let length = CGFloat.random(in: 26...58, using: &rng) * scale
            let tip = CGPoint(x: base.x + cos(droop) * length, y: base.y + sin(droop) * length)
            brushStroke(along: { CGPoint(x: base.x + (tip.x - base.x) * $0, y: base.y + (tip.y - base.y) * $0 + sin($0 * .pi) * 3 * scale) },
                        width: 1.8 * scale, taper: 0.6, ink: palette.brushInk, in: &context, rng: &rng)
            sprigs.append((tip, droop))
        }

        // Leaves first, stalks on top, as in the painting.
        var stalks: [(CGPoint, CGPoint)] = []
        for (point, direction) in sprigs {
            for _ in 0..<Int.random(in: 2...4, using: &rng) {
                let angle: CGFloat = direction * 0.35 + (.pi / 2) * 0.65 + .random(in: -1.2...1.2, using: &rng)
                let stalk = CGFloat.random(in: 5...12, using: &rng) * scale
                let leafBase = CGPoint(x: point.x + cos(angle) * stalk, y: point.y + sin(angle) * stalk)
                let color = palette.washes[Int.random(in: 0..<palette.washes.count, using: &rng)]
                paintLeaf(at: leafBase, direction: angle + .random(in: -0.25...0.25, using: &rng),
                          radius: .random(in: 20...32, using: &rng) * scale, color: color,
                          wash: .random(in: 0.55...0.85, using: &rng), ink: palette.brushInk, in: &context)
                stalks.append((point, leafBase))
            }
        }
        for (from, to) in stalks {
            var stalk = Path()
            stalk.move(to: from)
            stalk.addQuadCurve(to: to, control: CGPoint(x: (from.x + to.x) / 2 + 2 * scale, y: (from.y + to.y) / 2))
            context.stroke(stalk, with: .color(palette.brushInk.opacity(0.55)), style: StrokeStyle(lineWidth: 0.8 * scale, lineCap: .round))
        }
    }

    /// A dry-brush ink line: uneven width, the odd skipped bit and a faint second bristle line.
    private static func brushStroke(along point: (CGFloat) -> CGPoint, width: CGFloat, taper: CGFloat, ink: Color,
                                    in context: inout GraphicsContext, rng: inout SeededRandom) {
        let steps = 22
        for step in 0..<steps {
            let t0 = CGFloat(step) / CGFloat(steps), t1 = CGFloat(step + 1) / CGFloat(steps)
            guard Double.random(in: 0...1, using: &rng) > 0.07 else { continue }
            let a = point(t0), b = point(t1)
            let w = width * (1 - taper * t0) * .random(in: 0.7...1.15, using: &rng)
            var segment = Path()
            segment.move(to: a)
            segment.addLine(to: b)
            context.stroke(segment, with: .color(ink.opacity(.random(in: 0.75...0.95, using: &rng))),
                           style: StrokeStyle(lineWidth: w, lineCap: .round))
            let normal = CGPoint(x: -(b.y - a.y), y: b.x - a.x)
            let length = max(hypot(normal.x, normal.y), 0.001)
            let offset = CGPoint(x: normal.x / length * w * 0.55, y: normal.y / length * w * 0.55)
            var bristle = Path()
            bristle.move(to: CGPoint(x: a.x + offset.x, y: a.y + offset.y))
            bristle.addLine(to: CGPoint(x: b.x + offset.x, y: b.y + offset.y))
            context.stroke(bristle, with: .color(ink.opacity(0.25)), lineWidth: max(w * 0.25, 0.4))
        }
    }

    /// A watercolour leaf: a translucent wash, pigment pooling towards the middle,
    /// darker dried edges and fine veins. `direction` is where the leaf points from its stalk.
    private static func paintLeaf(at base: CGPoint, direction: CGFloat, radius: CGFloat, color: Color, wash: Double,
                                  ink: Color, in context: inout GraphicsContext) {
        var leaf = context
        leaf.translateBy(x: base.x, y: base.y)
        leaf.rotate(by: .radians(Double(direction) + .pi / 2))
        leaf.scaleBy(x: radius, y: radius)
        leaf.fill(slenderLeaf, with: .color(color.opacity(wash)))

        var core = leaf
        core.translateBy(x: 0, y: -0.4)
        core.scaleBy(x: 0.6, y: 0.6)
        core.translateBy(x: 0, y: 0.4)
        core.fill(slenderLeaf, with: .color(color.mix(with: ink, by: 0.12).opacity(0.28)))

        leaf.stroke(slenderLeaf, with: .color(color.mix(with: ink, by: 0.28).opacity(0.45)), lineWidth: 0.035)
        leaf.stroke(slenderVeins, with: .color(color.mix(with: ink, by: 0.4).opacity(0.5)), lineWidth: 0.022)
    }

    // MARK: Leaf shape

    /// Lobes as (angle from the tip direction in degrees, length): a deeply cut seven-lobed Japanese maple.
    private static let lobes: [(Double, CGFloat)] = [(-120, 0.5), (-76, 0.82), (-37, 0.97), (0, 1), (37, 0.97), (76, 0.82), (120, 0.5)]

    /// A unit-size leaf pointing up, with its stalk at the origin.
    static let leaf: Path = Path { path in
        path.move(to: polar(-150, 0.14))
        for (index, (angle, length)) in lobes.enumerated() {
            let nextValley = index + 1 < lobes.count
                ? polar((angle + lobes[index + 1].0) / 2, 0.3)
                : polar(150, 0.14)
            path.addQuadCurve(to: polar(angle, length), control: polar(angle - 15, length * 0.64))
            path.addQuadCurve(to: nextValley, control: polar(angle + 15, length * 0.64))
        }
        path.addLine(to: polar(180, 0.08))
        path.closeSubpath()

        // Stalk
        path.move(to: polar(180, 0.04))
        path.addQuadCurve(to: CGPoint(x: 0.1, y: 0.58), control: CGPoint(x: -0.02, y: 0.36))
        path.addLine(to: CGPoint(x: 0.14, y: 0.56))
        path.addQuadCurve(to: polar(172, 0.04), control: CGPoint(x: 0.03, y: 0.34))
        path.closeSubpath()
    }

    /// The painted leaf: seven long, narrow, sharply pointed lobes from a common base at the origin.
    private static let slenderLobes: [(Double, CGFloat)] = [(-112, 0.45), (-72, 0.78), (-35, 0.95), (0, 1), (35, 0.95), (72, 0.78), (112, 0.45)]

    static let slenderLeaf: Path = Path { path in
        path.move(to: polar(-140, 0.08))
        for (index, (angle, length)) in slenderLobes.enumerated() {
            let nextValley = index + 1 < slenderLobes.count
                ? polar((angle + slenderLobes[index + 1].0) / 2, 0.24)
                : polar(140, 0.08)
            path.addCurve(to: polar(angle, length), control1: polar(angle - 14, length * 0.45), control2: polar(angle - 7, length * 0.8))
            path.addCurve(to: nextValley, control1: polar(angle + 7, length * 0.8), control2: polar(angle + 14, length * 0.45))
        }
        path.closeSubpath()
    }

    static let slenderVeins: Path = Path { path in
        for (angle, length) in slenderLobes {
            path.move(to: .zero)
            path.addLine(to: polar(angle, length * 0.85))
        }
    }

    /// Point at `degrees` clockwise from straight up, `radius` from the origin.
    private static func polar(_ degrees: Double, _ radius: CGFloat) -> CGPoint {
        let radians = degrees * .pi / 180
        return CGPoint(x: sin(radians) * radius, y: -cos(radians) * radius)
    }
}

#Preview("Verteilt") {
    MomijiPattern()
        .background(Color.paper)
        .ignoresSafeArea()
}

#Preview("Pfad") {
    MomijiPattern(layout: .framing)
        .background(Color.paper)
        .ignoresSafeArea()
}
