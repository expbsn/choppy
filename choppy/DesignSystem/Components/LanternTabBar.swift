import SwiftUI

/// The tab bar ("Tab-Leiste / Laterne" in Figma): a tile edge over a cedar beam. A small andon
/// lantern stands under the selected tab and lights its icon and label from below; the other
/// tabs stay dim. The lantern glides to the new tab when the selection changes.
struct LanternTabBar<Tab: Hashable & Identifiable>: View {
    let tabs: [Tab]
    @Binding var selection: Tab
    let title: (Tab) -> LocalizedStringKey
    let systemImage: (Tab) -> String
    /// Bottom safe-area inset of the window. The lantern stands in that strip, above the home indicator.
    var safeAreaBottom: CGFloat = 0

    private let sideInset: CGFloat = 7
    private let gap: CGFloat = 4
    private let topInset: CGFloat = 6
    private let tabHeight: CGFloat = 46

    /// How often each tab has been chosen. Only the newly selected icon bounces.
    @State private var bounces: [Tab: Int] = [:]

    /// Room below the labels for the lantern, on top of the safe area.
    private var lanternRoom: CGFloat { max(2, 24 - safeAreaBottom) }

    var body: some View {
        VStack(spacing: 0) {
            TileEdge(base: .sugi800)
            HStack(spacing: gap) {
                ForEach(tabs) { tab in
                    Button {
                        guard tab != selection else { return }
                        bounces[tab, default: 0] += 1
                        withAnimation(.spring(duration: 0.45, bounce: 0.2)) { selection = tab }
                    } label: {
                        item(tab, isSelected: tab == selection)
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(tab == selection ? [.isSelected, .isButton] : .isButton)
                }
            }
            .padding(.horizontal, sideInset)
            .padding(.top, topInset)
            .padding(.bottom, lanternRoom)
            .background(alignment: .topLeading) {
                GeometryReader { proxy in light(barWidth: proxy.size.width) }
            }
            .background { Color.sugi800.ignoresSafeArea(edges: .bottom) }
        }
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
        .sensoryFeedback(.selection, trigger: selection)
    }

    private func item(_ tab: Tab, isSelected: Bool) -> some View {
        VStack(spacing: 2) {
            Image(systemName: systemImage(tab))
                .font(.system(size: 17, weight: .regular))
                .frame(height: 20)
                .symbolEffect(.bounce, value: bounces[tab, default: 0])
            Text(title(tab))
                .font(.choppyAccent(12, relativeTo: .caption2))
                .lineLimit(1)
        }
        .foregroundStyle(.washi50)
        .opacity(isSelected ? 1 : 0.55)
        .frame(maxWidth: .infinity)
        .frame(height: tabHeight)
        .contentShape(.rect)
    }

    private func light(barWidth: CGFloat) -> some View {
        let count = CGFloat(max(tabs.count, 1))
        let tabWidth = (barWidth - sideInset * 2 - gap * (count - 1)) / count
        let index = CGFloat(tabs.firstIndex(of: selection) ?? 0)
        let center = sideInset + tabWidth / 2 + index * (tabWidth + gap)
        let width = max(tabWidth, LanternLight.glowWidth) + 8
        return LanternLight(tabWidth: tabWidth)
            .frame(width: width, height: LanternLight.height)
            .offset(x: center - width / 2)
            .allowsHitTesting(false)
    }
}

/// The lantern and its light, drawn in the coordinate space of the beam: the top edge is the
/// underside of the tile edge, the lantern stands 56 points below it.
private struct LanternLight: View {
    static let height: CGFloat = 96
    static let glowWidth: CGFloat = 104

    var tabWidth: CGFloat

    private struct Palette {
        var light, glow, paper, frame, rib: Color
    }

    var body: some View {
        let palette = Palette(light: .akari400, glow: .akari600, paper: .washi50, frame: .sugi400, rib: .akari600)
        Canvas { context, size in
            Self.draw(in: &context, size: size, tabWidth: tabWidth, palette: palette)
        }
        .accessibilityHidden(true)
    }

    private static func draw(in context: inout GraphicsContext, size: CGSize, tabWidth: CGFloat, palette: Palette) {
        let cx = size.width / 2
        let lanternTop: CGFloat = 56

        // Soft glow around the lantern.
        let glow = CGRect(x: cx - glowWidth / 2, y: 35, width: glowWidth, height: 56)
        context.drawLayer { layer in
            layer.translateBy(x: glow.midX, y: glow.midY)
            layer.scaleBy(x: 1, y: glow.height / glow.width)
            let radius = glow.width / 2
            layer.fill(Path(ellipseIn: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2)),
                       with: .radialGradient(Gradient(colors: [palette.glow.opacity(0.4), palette.glow.opacity(0)]),
                                             center: .zero, startRadius: 0, endRadius: radius))
        }

        // Two flat light cones, widening from the lantern up to the tile edge.
        let half = tabWidth / 2
        for (bottom, top, strength) in [(14.5, half - 1, 0.3), (8.5, half * 0.54, 0.32)] {
            var cone = Path()
            cone.move(to: CGPoint(x: cx - bottom, y: lanternTop))
            cone.addLine(to: CGPoint(x: cx + bottom, y: lanternTop))
            cone.addLine(to: CGPoint(x: cx + top, y: 0))
            cone.addLine(to: CGPoint(x: cx - top, y: 0))
            cone.closeSubpath()
            context.fill(cone, with: .linearGradient(Gradient(colors: [palette.light.opacity(0), palette.light.opacity(strength)]),
                                                     startPoint: CGPoint(x: cx, y: 0), endPoint: CGPoint(x: cx, y: lanternTop)))
        }

        // The underside of the tile edge catches the light.
        context.fill(Path(CGRect(x: cx - half, y: 0, width: tabWidth, height: 1.5)),
                     with: .linearGradient(Gradient(colors: [palette.light.opacity(0), palette.light.opacity(0.7), palette.light.opacity(0)]),
                                           startPoint: CGPoint(x: cx - half, y: 0), endPoint: CGPoint(x: cx + half, y: 0)))

        // The andon: paper body with two ribs between wooden frames.
        let outline = GraphicsContext.Shading.color(SceneColor.outline)
        let body = Path(CGRect(x: cx - 10.9, y: lanternTop + 2.6, width: 21.8, height: 8.8))
        context.fill(body, with: .color(palette.paper))
        context.stroke(body, with: outline, lineWidth: 1.2)
        var ribs = Path()
        for dx in [-4.0, 4.0] {
            ribs.move(to: CGPoint(x: cx + dx, y: lanternTop + 3.2))
            ribs.addLine(to: CGPoint(x: cx + dx, y: lanternTop + 10.8))
        }
        context.stroke(ribs, with: .color(palette.rib), lineWidth: 1)
        for y in [lanternTop + 0.6, lanternTop + 10.8] {
            let cap = Path(roundedRect: CGRect(x: cx - 13.9, y: y, width: 27.8, height: 2.6), cornerRadius: 0.6)
            context.fill(cap, with: .color(palette.frame))
            context.stroke(cap, with: outline, lineWidth: 1.2)
        }
    }
}

#Preview {
    @Previewable @State var selection = RootTab.learn
    VStack {
        Spacer()
        LanternTabBar(tabs: RootTab.allCases, selection: $selection, title: \.title, systemImage: \.systemImage)
    }
    .background { AppBackground() }
}
