import SwiftUI

/// The tab bar: one bamboo stalk lying along the bottom, drawn flat with fine ink outlines.
/// Each tab sits on its own section between two nodes; the selected tab is simply inked darker.
/// Only the right end is drawn cut open, as seen in perspective. There is nothing behind the stalk.
struct BambooTabBar<Tab: Hashable & Identifiable>: View {
    let tabs: [Tab]
    @Binding var selection: Tab
    let title: (Tab) -> LocalizedStringKey
    let systemImage: (Tab) -> String

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs) { tab in
                Button {
                    withAnimation(.spring(duration: 0.35, bounce: 0.3)) { selection = tab }
                } label: {
                    item(tab, isSelected: tab == selection)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(tab == selection ? [.isSelected, .isButton] : .isButton)
            }
        }
        .padding(.horizontal, BambooStalk.capWidth)
        .background {
            BambooStalk(sections: tabs.count)
                .padding(.top, -BambooStalk.leafRoom)
        }
        .padding(.horizontal, Spacing.s)
        .padding(.top, BambooStalk.leafRoom)
        .padding(.bottom, Spacing.xxs)
        .sensoryFeedback(.selection, trigger: selection)
    }

    private func item(_ tab: Tab, isSelected: Bool) -> some View {
        VStack(spacing: 2) {
            Image(systemName: systemImage(tab))
                .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                .symbolEffect(.bounce, value: isSelected)
            Text(title(tab))
                .font(.choppyAccent(12, weight: isSelected ? .semibold : .regular, relativeTo: .caption2))
                .lineLimit(1)
        }
        .foregroundStyle(isSelected ? Color.ink : Color.ink.opacity(0.45))
        .padding(.top, 14)
        .padding(.bottom, 5)
        .frame(maxWidth: .infinity)
        .contentShape(.rect)
    }
}

/// The drawn stalk. Sections line up with an `HStack` of equal-width items inset by `capWidth`.
private struct BambooStalk: View {
    static let capWidth: CGFloat = 14
    /// Space above the stalk for the leaves.
    static let leafRoom: CGFloat = 18

    var sections: Int

    private struct Palette {
        var stalk, node, leaf, ink, cut, hollow: Color
    }

    var body: some View {
        let palette = Palette(stalk: .bamboo,
                              node: Color.bamboo.mix(with: .ink, by: 0.18),
                              leaf: Color.bamboo.mix(with: .accent, by: 0.5),
                              ink: .ink,
                              cut: .paper,
                              hollow: .woodDark)
        Canvas { context, size in
            Self.draw(in: &context, size: size, sections: sections, palette: palette)
        }
        .accessibilityHidden(true)
    }

    private static func draw(in context: inout GraphicsContext, size: CGSize, sections: Int, palette: Palette) {
        let outline = GraphicsContext.Shading.color(palette.ink.opacity(0.8))
        let top = Self.leafRoom + 1
        let bottom = size.height - 1.5
        let left: CGFloat = 4, right = size.width - 4
        let sectionWidth = (right - left - Self.capWidth * 2 + 8) / CGFloat(sections)
        let nodes = (1..<sections).map { left + Self.capWidth - 4 + CGFloat($0) * sectionWidth }
        let edges = [left + 5] + nodes + [right - 5]

        // Sections, each gently waisted between its nodes.
        for (start, end) in zip(edges, edges.dropFirst()) {
            let mid = (start + end) / 2, waist: CGFloat = 1.5
            var section = Path()
            section.move(to: CGPoint(x: start, y: top))
            section.addQuadCurve(to: CGPoint(x: end, y: top), control: CGPoint(x: mid, y: top + waist * 2))
            section.addLine(to: CGPoint(x: end, y: bottom))
            section.addQuadCurve(to: CGPoint(x: start, y: bottom), control: CGPoint(x: mid, y: bottom - waist * 2))
            section.closeSubpath()
            context.fill(section, with: .color(palette.stalk))

            for (y, sag) in [(top, waist * 2), (bottom, -waist * 2)] {
                var edge = Path()
                edge.move(to: CGPoint(x: start, y: y))
                edge.addQuadCurve(to: CGPoint(x: end, y: y), control: CGPoint(x: mid, y: y + sag))
                context.stroke(edge, with: outline, style: StrokeStyle(lineWidth: 1.3, lineCap: .round))
            }
        }

        // Nodes: a slightly swollen ring between two fine curved lines.
        for x in nodes {
            let ring = CGRect(x: x - 3, y: top - 1.5, width: 6, height: bottom - top + 3)
            context.fill(Path(roundedRect: ring, cornerRadius: 2.5), with: .color(palette.node))
            for dx in [-3.0, 3.0] {
                var line = Path()
                line.move(to: CGPoint(x: x + dx, y: top - 1.5))
                line.addQuadCurve(to: CGPoint(x: x + dx, y: bottom + 1.5), control: CGPoint(x: x + dx * 1.5, y: (top + bottom) / 2))
                context.stroke(line, with: outline, style: StrokeStyle(lineWidth: 1.1, lineCap: .round))
            }
        }

        // Seen slightly from the right, only the right end shows its cut face and hollow;
        // the left end is just the rounded outside of the stalk.
        let leftEnd = CGRect(x: left, y: top - 0.5, width: 10, height: bottom - top + 1)
        context.fill(Path(ellipseIn: leftEnd), with: .color(palette.stalk))
        var leftArc = Path()
        let k: CGFloat = 0.5523 // cubic Bézier factor for a quarter ellipse
        let rx = leftEnd.width / 2, ry = leftEnd.height / 2
        leftArc.move(to: CGPoint(x: leftEnd.midX, y: leftEnd.minY))
        leftArc.addCurve(to: CGPoint(x: leftEnd.minX, y: leftEnd.midY),
                         control1: CGPoint(x: leftEnd.midX - rx * k, y: leftEnd.minY),
                         control2: CGPoint(x: leftEnd.minX, y: leftEnd.midY - ry * k))
        leftArc.addCurve(to: CGPoint(x: leftEnd.midX, y: leftEnd.maxY),
                         control1: CGPoint(x: leftEnd.minX, y: leftEnd.midY + ry * k),
                         control2: CGPoint(x: leftEnd.midX - rx * k, y: leftEnd.maxY))
        context.stroke(leftArc, with: outline, style: StrokeStyle(lineWidth: 1.3, lineCap: .round))

        let face = CGRect(x: right - 10, y: top - 0.5, width: 10, height: bottom - top + 1)
        context.fill(Path(ellipseIn: face), with: .color(palette.cut))
        context.fill(Path(ellipseIn: face.insetBy(dx: 2.2, dy: 6)), with: .color(palette.hollow))
        context.stroke(Path(ellipseIn: face), with: outline, lineWidth: 1.2)

        // Two small sprigs of leaves.
        let sprigs: [(CGFloat, [Double])] = [
            (nodes.first ?? left + 40, [-140, -112]),
            (nodes.last ?? right - 40, [-62, -36]),
        ]
        for (x, angles) in sprigs {
            for (index, degrees) in angles.enumerated() {
                Self.drawLeaf(from: CGPoint(x: x, y: top + 1), angle: CGFloat(degrees * .pi / 180),
                              length: index == 0 ? 26 : 21, fill: palette.leaf, outline: outline, in: &context)
            }
        }
    }

    /// A slender bamboo leaf: flat fill, fine outline and midrib.
    private static func drawLeaf(from base: CGPoint, angle: CGFloat, length: CGFloat, fill: Color,
                                 outline: GraphicsContext.Shading, in context: inout GraphicsContext) {
        let tip = CGPoint(x: base.x + cos(angle) * length, y: base.y + sin(angle) * length)
        let normal = CGPoint(x: -sin(angle), y: cos(angle))
        let width = length * 0.16
        func point(_ t: CGFloat, _ side: CGFloat) -> CGPoint {
            CGPoint(x: base.x + (tip.x - base.x) * t + normal.x * side, y: base.y + (tip.y - base.y) * t + normal.y * side)
        }
        var leaf = Path()
        leaf.move(to: base)
        leaf.addCurve(to: tip, control1: point(0.25, width), control2: point(0.7, width * 0.8))
        leaf.addCurve(to: base, control1: point(0.7, -width * 0.8), control2: point(0.25, -width))
        context.fill(leaf, with: .color(fill))
        context.stroke(leaf, with: outline, style: StrokeStyle(lineWidth: 1, lineJoin: .round))
        var rib = Path()
        rib.move(to: point(0.1, 0))
        rib.addLine(to: point(0.78, 0))
        context.stroke(rib, with: outline, lineWidth: 0.6)
    }
}

#Preview {
    @Previewable @State var selection = RootTab.learn
    VStack {
        Spacer()
        BambooTabBar(tabs: RootTab.allCases, selection: $selection, title: \.title, systemImage: \.systemImage)
    }
    .background { AppBackground() }
}
