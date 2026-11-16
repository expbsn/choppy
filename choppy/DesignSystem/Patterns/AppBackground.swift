import SwiftUI

/// What is drawn on the night sky behind a screen.
enum BackgroundScene: Equatable {
    /// The sky over a street at night: roofs with lit windows, bushes and a stone lantern standing on
    /// the tab bar's roof edge (`sceneGroundY`). The maple corner with its lanterns is drawn by the
    /// screen header (`MapleCorner`), in front of scrolling content. The default.
    case night
    /// The lantern alley of the start screen: moon and skyline standing on the wooden panel whose
    /// top edge is at `groundY` (window coordinates), and a tall maple on the right.
    case alley(groundY: CGFloat)
}

/// The one background used behind every screen: the night sky of the lantern alley.
/// Screens get it through `ChoppyScreen`, so it is always the same.
struct AppBackground: View {
    @Environment(\.backgroundScene) private var scene
    @Environment(\.windowSize) private var windowSize
    @Environment(\.sceneGroundY) private var groundY

    var body: some View {
        let palette = NightScene.Palette.current
        let groundY = groundY
        Color.yoru900
            .overlay(alignment: .top) {
                Canvas { context, size in
                    NightScene.draw(scene, in: &context, size: size, streetGroundY: groundY, palette: palette)
                }
                .frame(width: windowSize?.width, height: windowSize?.height)
            }
            .clipped()
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

extension EnvironmentValues {
    /// The scenery drawn behind the current screen.
    @Entry var backgroundScene: BackgroundScene = .night
    /// Size of the whole window including safe areas, measured once at the root.
    @Entry var windowSize: CGSize?
    /// Top edge of the tab bar in window coordinates: the ground the street scenery stands on.
    @Entry var sceneGroundY: CGFloat?
}

/// Draws the scenery. All coordinates come from the 390 pt wide Figma screens; things on the right
/// are anchored to the right edge, things on the ground to `groundY`.
enum NightScene {
    struct Palette {
        var skyMid, skyLow, crownDark, crownLight: Color
        var leaves: [Color]
        var moon, light, glow, lantern, lanternRib: Color

        /// Reads the current theme colours. Call it in a view body, so the view follows the theme.
        static var current: Palette {
            Palette(skyMid: .ai700, skyLow: .ai500, crownDark: .momiji900, crownLight: .momiji700,
                    leaves: [.momiji500, .momiji300, .momiji300, .kouyouDai, .kouyouKin],
                    moon: .washi100, light: .akari400, glow: .akari600,
                    lantern: .chochin, lanternRib: .chochinYoru)
        }
    }

    typealias Circle = (x: CGFloat, y: CGFloat, r: CGFloat)

    static func draw(_ scene: BackgroundScene, in context: inout GraphicsContext, size: CGSize,
                     streetGroundY: CGFloat? = nil, palette: Palette) {
        context.fill(Path(CGRect(origin: .zero, size: size)),
                     with: .linearGradient(Gradient(stops: [.init(color: SceneColor.skyTop, location: 0),
                                                            .init(color: palette.skyMid, location: 0.55),
                                                            .init(color: palette.skyLow, location: 1)]),
                                           startPoint: .zero, endPoint: CGPoint(x: 0, y: size.height)))

        guard case .alley(let groundY) = scene, groundY > 1 else {
            if scene == .night, let streetGroundY, streetGroundY > 1 {
                drawStreet(in: &context, width: size.width, groundY: streetGroundY, palette: palette)
            }
            return
        }
        // Shifts Figma x coordinates so the right-hand scenery hugs the right edge.
        let dx = size.width - 390
        drawMoon(in: &context, center: CGPoint(x: 84, y: groundY - 162), palette: palette)
        drawSkyline(in: &context, groundY: groundY, palette: palette)

        // Trunk and a branch reaching into the crown.
        context.fill(Path(CGRect(x: 330 + dx, y: 150, width: 12, height: groundY - 146)), with: .color(SceneColor.soot))
        var branch = Path()
        branch.move(to: CGPoint(x: 336 + dx, y: 300))
        branch.addQuadCurve(to: CGPoint(x: 388 + dx, y: 42), control: CGPoint(x: 342 + dx, y: 150))
        context.stroke(branch, with: .color(SceneColor.soot), style: StrokeStyle(lineWidth: 5, lineCap: .round))

        drawCrown(in: &context, dx: dx, palette: palette, leafCount: 26, seed: 0x5EED,
                  dark: [(252, 6, 40), (304, -14, 48), (362, 10, 52), (404, 60, 46), (330, 70, 44),
                         (372, 128, 48), (322, 150, 36), (392, 196, 46), (346, 236, 40), (330, 268, 34)],
                  light: [(258, 8, 30), (306, -8, 38), (360, 16, 40), (398, 64, 34), (334, 72, 34),
                          (372, 130, 36), (326, 150, 26), (388, 196, 34), (348, 236, 30), (334, 262, 22)])
    }

    /// The small crown in the top right corner of ordinary screens, with the branch the lanterns hang from.
    static func drawCorner(in context: inout GraphicsContext, dx: CGFloat, palette: Palette) {
        var branch = Path()
        branch.move(to: CGPoint(x: 376 + dx, y: 84))
        branch.addQuadCurve(to: CGPoint(x: 274 + dx, y: 99), control: CGPoint(x: 322 + dx, y: 88))
        context.stroke(branch, with: .color(SceneColor.soot), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
        drawCrown(in: &context, dx: dx, palette: palette, leafCount: 8, seed: 0xA11E,
                  dark: [(296, 18, 34), (338, 0, 40), (384, 24, 44), (352, 66, 34), (396, 86, 36)],
                  light: [(310, 24, 24), (346, 10, 28), (382, 34, 30), (356, 68, 22), (390, 84, 20)])
    }

    /// The crown is a clean union of circles in two greens; the leaves only sit on the crown.
    private static func drawCrown(in context: inout GraphicsContext, dx: CGFloat, palette: Palette, leafCount: Int,
                                  seed: UInt64, dark: [Circle], light: [Circle]) {
        for (circles, color) in [(dark, palette.crownDark), (light, palette.crownLight)] {
            var crown = Path()
            for c in circles {
                crown.addEllipse(in: CGRect(x: c.x + dx - c.r, y: c.y - c.r, width: c.r * 2, height: c.r * 2))
            }
            context.fill(crown, with: .color(color))
        }

        var rng = SeededRandom(seed: seed)
        for index in 0..<leafCount {
            let circle = light[index % light.count]
            let angle = CGFloat.random(in: 0...(2 * .pi), using: &rng)
            let distance = circle.r * CGFloat.random(in: 0...0.75, using: &rng).squareRoot()
            let center = CGPoint(x: circle.x + dx + cos(angle) * distance, y: circle.y + sin(angle) * distance)
            let color = palette.leaves[Int.random(in: 0..<palette.leaves.count, using: &rng)]
            let leaf = leafPath(center: center, radius: .random(in: 9...11.5, using: &rng),
                                rotation: .random(in: 0...(2 * .pi), using: &rng))
            context.fill(leaf, with: .color(color))
        }
    }

    /// The maple leaf of the Figma screens (layer "Blätter"): a 22-point outline with four pointed
    /// lobes, small teeth between them and a stem. Coordinates as drawn there, about 15 x 16 pt.
    private static let leafOutline: [CGPoint] = leafPoints.map { CGPoint(x: ($0.0 - 8) / 9, y: ($0.1 - 9) / 9) }

    private static let leafPoints: [(CGFloat, CGFloat)] = [
        (10.5, 11.6), (9.5, 13.5), (8.1, 16.5), (8.1, 13.2), (7.4, 12.8), (5.5, 13.1), (0.4, 13.8), (4.7, 11),
        (6.3, 10), (4.1, 8.2), (0, 3.8), (5.6, 6.1), (8, 7.5), (8.5, 5.6), (9.6, 0.7), (10.6, 5.6), (11, 7.5),
        (11.7, 8.1), (14.8, 6.9), (12.5, 9.3), (11, 10.9),
    ]

    static func leafPath(center: CGPoint, radius: CGFloat, rotation: CGFloat) -> Path {
        let transform = CGAffineTransform(translationX: center.x, y: center.y)
            .rotated(by: rotation)
            .scaledBy(x: radius, y: radius)
        var path = Path()
        path.addLines(leafOutline.map { $0.applying(transform) })
        path.closeSubpath()
        return path
    }

    /// The street behind ordinary screens: two rows of roofs across the whole width with a few lit
    /// windows, round bushes and a glowing stone lantern. Kept low and dark, so content stays readable.
    private static func drawStreet(in context: inout GraphicsContext, width: CGFloat, groundY g: CGFloat, palette: Palette) {
        var rng = SeededRandom(seed: 0x57EE7)
        var far = Path(), near = Path(), windows = Path()
        var x: CGFloat = -6
        while x < width {
            let w = CGFloat.random(in: 38...74, using: &rng), h = CGFloat.random(in: 34...92, using: &rng)
            far.addRect(CGRect(x: x, y: g - h, width: w + 1, height: h + 20))
            // A shallow roof line on every house.
            far.addRect(CGRect(x: x - 3, y: g - h - 4, width: w + 6, height: 5))
            if h > 52, Bool.random(using: &rng) {
                let wx = x + CGFloat.random(in: 8...(w - 26), using: &rng)
                windows.addRect(CGRect(x: wx, y: g - h + 16, width: 8, height: 8))
                windows.addRect(CGRect(x: wx + 13, y: g - h + 16, width: 8, height: 8))
            }
            x += w
        }
        x = -10
        while x < width {
            let w = CGFloat.random(in: 50...110, using: &rng), h = CGFloat.random(in: 8...26, using: &rng)
            near.addRect(CGRect(x: x, y: g - h, width: w + 1, height: h + 20))
            x += w
        }
        context.fill(far, with: .color(SceneColor.skylineFar))
        context.fill(windows, with: .color(palette.light.opacity(0.8)))
        context.fill(near, with: .color(SceneColor.skylineNear))

        // Bushes: clean circles in the two maple greens.
        let darkBush: [Circle] = [(-16, 12, 15), (2, 17, 20), (22, 11, 14)]
        let lightBush: [Circle] = [(-12, 10, 9), (4, 16, 12), (20, 9, 8)]
        for (bx, scale) in [(width * 0.16, CGFloat(1)), (width * 0.62, CGFloat(0.8))] {
            for (circles, color) in [(darkBush, palette.crownDark), (lightBush, palette.crownLight)] {
                var bush = Path()
                for c in circles {
                    bush.addEllipse(in: CGRect(x: bx + (c.x - c.r) * scale, y: g - (c.y + c.r) * scale + 4,
                                               width: c.r * 2 * scale, height: c.r * 2 * scale))
                }
                context.fill(bush, with: .color(color))
            }
        }

        // Stone lantern (tōrō) on the right.
        let lx = width - 78
        context.fill(Path(ellipseIn: CGRect(x: lx - 50, y: g - 88, width: 100, height: 100)),
                     with: .radialGradient(Gradient(colors: [palette.light.opacity(0.35), palette.light.opacity(0)]),
                                           center: CGPoint(x: lx, y: g - 38), startRadius: 0, endRadius: 50))
        let stone = SceneColor.tileDark, outline = GraphicsContext.Shading.color(SceneColor.outline)
        for rect in [CGRect(x: lx - 4, y: g - 26, width: 8, height: 30), CGRect(x: lx - 11, y: g - 50, width: 22, height: 24)] {
            context.fill(Path(rect), with: .color(stone))
            context.stroke(Path(rect), with: outline, lineWidth: 1.2)
        }
        context.fill(Path(CGRect(x: lx - 6, y: g - 45, width: 12, height: 14)), with: .color(palette.light))
        var roof = Path()
        roof.move(to: CGPoint(x: lx - 18, y: g - 50))
        roof.addLine(to: CGPoint(x: lx - 8, y: g - 60))
        roof.addLine(to: CGPoint(x: lx + 8, y: g - 60))
        roof.addLine(to: CGPoint(x: lx + 18, y: g - 50))
        roof.closeSubpath()
        context.fill(roof, with: .color(stone))
        context.stroke(roof, with: outline, lineWidth: 1.2)
        context.fill(Path(CGRect(x: lx - 3, y: g - 65, width: 6, height: 5)), with: .color(stone))
    }

    private static func drawMoon(in context: inout GraphicsContext, center: CGPoint, palette: Palette) {
        context.fill(Path(ellipseIn: CGRect(x: center.x - 70, y: center.y - 70, width: 140, height: 140)),
                     with: .radialGradient(Gradient(colors: [palette.moon.opacity(0.3), palette.moon.opacity(0)]),
                                           center: center, startRadius: 0, endRadius: 70))
        context.fill(Path(ellipseIn: CGRect(x: center.x - 17, y: center.y - 17, width: 34, height: 34)), with: .color(palette.moon))
    }

    /// Two rows of flat roofs on the left, with two lit windows.
    private static func drawSkyline(in context: inout GraphicsContext, groundY g: CGFloat, palette: Palette) {
        func silhouette(_ steps: [(CGFloat, CGFloat)]) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: g + 20))
            for (x, height) in steps {
                path.addLine(to: CGPoint(x: path.currentPoint?.x ?? 0, y: g - height))
                path.addLine(to: CGPoint(x: x, y: g - height))
            }
            path.addLine(to: CGPoint(x: steps.last?.0 ?? 0, y: g + 20))
            path.closeSubpath()
            return path
        }
        context.fill(silhouette([(44, 40), (96, 56), (136, 44), (194, 70), (264, 22)]), with: .color(SceneColor.skylineFar))
        for x in [150.0, 164.0] {
            context.fill(Path(CGRect(x: x, y: g - 52, width: 8, height: 8)), with: .color(palette.light.opacity(0.8)))
        }
        context.fill(silhouette([(76, 4), (150, 12), (264, 4)]), with: .color(SceneColor.skylineNear))
    }
}

#Preview("Nacht") {
    AppBackground().overlay(alignment: .topTrailing) { MapleCorner().ignoresSafeArea() }
}

#Preview("Gasse") {
    AppBackground()
        .environment(\.backgroundScene, .alley(groundY: 492))
}
