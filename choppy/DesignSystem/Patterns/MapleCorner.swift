import CoreMotion
import Observation
import SwiftUI

/// The maple crown in the top right corner with two chōchin hanging from a branch.
/// Drawn by the screen header in front of scrolling content, so it always stays sharp.
/// The lanterns swing a little when a page opens or the tab changes, and follow the tilt of the phone.
struct MapleCorner: View {
    /// Width of the Figma screens the coordinates come from.
    private static let size = CGSize(width: 390, height: 176)
    /// Width from the right screen edge that the branch and lanterns take up, plus a little air.
    /// Header text keeps out of it.
    static let reservedWidth: CGFloat = 132

    var body: some View {
        let palette = NightScene.Palette.current
        ZStack(alignment: .topLeading) {
            Canvas { context, _ in
                NightScene.drawCorner(in: &context, dx: 0, palette: palette)
            }
            // Where the cords meet the branch.
            HangingChochin(palette: palette, strength: 1, delay: 0.02)
                .offset(x: 298 - HangingChochin.size.width / 2, y: 94)
            HangingChochin(palette: palette, strength: 0.8, delay: 0.1)
                .offset(x: 326 - HangingChochin.size.width / 2, y: 90)
        }
        .frame(width: Self.size.width, height: Self.size.height, alignment: .topLeading)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onAppear { LanternMotion.shared.start() }
    }
}

/// One red lantern on a cord, with its glow. It turns around the top of the cord like a pendulum.
private struct HangingChochin: View {
    static let size = CGSize(width: 42, height: 48)

    let palette: NightScene.Palette
    var strength: Double
    var delay: Double

    var body: some View {
        let motion = LanternMotion.shared
        Canvas { context, _ in
            Self.draw(in: &context, palette: palette)
        }
        .frame(width: Self.size.width, height: Self.size.height)
        // A push: swings out and settles.
        .keyframeAnimator(initialValue: 0.0, trigger: motion.pushes) { content, angle in
            content.rotationEffect(.degrees(angle), anchor: .top)
        } keyframes: { _ in
            LinearKeyframe(0, duration: delay)
            SpringKeyframe(7 * strength, duration: 0.3)
            SpringKeyframe(-4.5 * strength, duration: 0.55)
            SpringKeyframe(2.5 * strength, duration: 0.6)
            SpringKeyframe(-1 * strength, duration: 0.6)
            SpringKeyframe(0, duration: 0.8, spring: .smooth)
        }
        // Gravity: the lantern keeps hanging straight down when the phone is tilted.
        .rotationEffect(.degrees(motion.tilt * strength), anchor: .top)
        .animation(.interpolatingSpring(stiffness: 28, damping: 2.4), value: motion.tilt)
    }

    private static func draw(in context: inout GraphicsContext, palette: NightScene.Palette) {
        let cx = size.width / 2
        var cord = Path()
        cord.move(to: CGPoint(x: cx, y: 0))
        cord.addLine(to: CGPoint(x: cx, y: 11))
        context.stroke(cord, with: .color(SceneColor.soot), lineWidth: 1.2)

        let center = CGPoint(x: cx, y: 23)
        context.fill(Path(ellipseIn: CGRect(x: center.x - 21, y: center.y - 21, width: 42, height: 42)),
                     with: .radialGradient(Gradient(colors: [palette.glow.opacity(0.45), palette.lantern.opacity(0)]),
                                           center: center, startRadius: 0, endRadius: 21))

        context.fill(Path(CGRect(x: cx - 4, y: 10, width: 8, height: 4)), with: .color(SceneColor.soot))
        let shell = Path(roundedRect: CGRect(x: cx - 8, y: 13, width: 16, height: 20), cornerRadius: 6)
        context.fill(shell, with: .color(palette.lantern))
        var ribs = Path()
        for y in [19.0, 23.0, 27.0] {
            ribs.move(to: CGPoint(x: cx - 7.5, y: y))
            ribs.addLine(to: CGPoint(x: cx + 7.5, y: y))
        }
        context.stroke(ribs, with: .color(palette.lanternRib), lineWidth: 1)
        context.stroke(shell, with: .color(SceneColor.outline), lineWidth: 1.2)
        context.fill(Path(ellipseIn: CGRect(x: cx - 5, y: 17, width: 4, height: 8)), with: .color(palette.light.opacity(0.55)))
        context.fill(Path(CGRect(x: cx - 4, y: 32, width: 8, height: 4)), with: .color(SceneColor.soot))
    }
}

/// What moves the hanging lanterns: pushes (page opened, tab changed) and the tilt of the phone.
@Observable
final class LanternMotion {
    static let shared = LanternMotion()

    /// Counts pushes; each change makes the lanterns swing once.
    private(set) var pushes = 0
    /// Angle in degrees that keeps the lanterns hanging straight down, limited to a gentle range.
    private(set) var tilt = 0.0

    @ObservationIgnored private let manager = CMMotionManager()

    func push() {
        pushes += 1
    }

    /// Starts following the phone's tilt. Does nothing where motion data is unavailable (simulator).
    func start() {
        guard manager.isDeviceMotionAvailable, !manager.isDeviceMotionActive else { return }
        manager.deviceMotionUpdateInterval = 1.0 / 20
        manager.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let gravity = data?.gravity else { return }
            // Rolling the phone clockwise makes a pendulum on screen turn counter-clockwise.
            let angle = -atan2(gravity.x, -gravity.y) * 180 / .pi
            let limited = min(max(angle, -16), 16)
            MainActor.assumeIsolated {
                guard let self, abs(limited - self.tilt) > 0.4 else { return }
                self.tilt = limited
            }
        }
    }
}

#Preview {
    AppBackground()
        .overlay(alignment: .topTrailing) { MapleCorner().ignoresSafeArea() }
        .onTapGesture { LanternMotion.shared.push() }
}
