import SwiftUI

/// Pieces of the shop front from the Figma screen "Vokabelduell": a deep tiled roof, a wooden wall
/// with posts, a lit lattice window and stone paving with fallen maple leaves.
/// They are stacked top to bottom behind a game, so the players stand in front of a shop at night.

/// A deep tiled roof seen from the front, with a dark beam under it.
struct ShopRoof: View {
    static let height: CGFloat = 64

    var body: some View {
        let tile = Color.kawara
        Canvas { context, size in
            let w = size.width
            let band = CGRect(x: 0, y: 0, width: w, height: 52)
            context.fill(Path(band), with: .color(tile))
            context.fill(Path(CGRect(x: 0, y: 0, width: w, height: 16)), with: .color(SceneColor.tileLight))
            let count = max(Int((w / 14).rounded()), 1)
            let pitch = w / CGFloat(count)
            var ridges = Path()
            for i in 0..<count {
                let x = (CGFloat(i) + 0.5) * pitch
                ridges.move(to: CGPoint(x: x, y: 2))
                ridges.addLine(to: CGPoint(x: x, y: 46))
            }
            context.stroke(ridges, with: .color(SceneColor.tileDark), lineWidth: 1.5)
            context.fill(Path(CGRect(x: 0, y: 52, width: w, height: 12)), with: .color(SceneColor.soot))
            for i in 0..<count {
                let x = (CGFloat(i) + 0.5) * pitch
                let cap = Path(ellipseIn: CGRect(x: x - 5, y: 44, width: 10, height: 11))
                context.fill(cap, with: .color(SceneColor.tileDark))
                context.stroke(cap, with: .color(SceneColor.outline), lineWidth: 1.2)
            }
            context.stroke(Path(CGRect(x: 0, y: 0.75, width: w, height: 51)), with: .color(SceneColor.outline), lineWidth: 1.5)
        }
        .frame(height: Self.height)
        .accessibilityHidden(true)
    }
}

/// The wooden wall of the shop: dark boards, three posts and the warm light of the window below.
struct ShopWall: View {
    var body: some View {
        let post = Color.sugi800
        let light = Color.akari400
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(SceneColor.wall))
            for x in [0.13, 0.53, 0.8] {
                context.fill(Path(CGRect(x: size.width * x, y: 0, width: 26, height: size.height)), with: .color(post.opacity(0.6)))
            }
            let center = CGPoint(x: size.width / 2, y: size.height + 40)
            context.fill(Path(CGRect(origin: .zero, size: size)),
                         with: .radialGradient(Gradient(colors: [light.opacity(0.42), light.opacity(0)]),
                                               center: center, startRadius: 0, endRadius: 300))
        }
        .accessibilityHidden(true)
    }
}

/// A lit lattice window (kōshi): warm light behind fine vertical bars.
struct LatticeWindow: View {
    static let height: CGFloat = 96

    var body: some View {
        let light = Color.akari400, deep = Color.akari600, bar = Color.sumi
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            context.fill(Path(rect), with: .linearGradient(Gradient(colors: [light, deep]),
                                                           startPoint: .zero, endPoint: CGPoint(x: 0, y: size.height)))
            var bars = Path()
            var x: CGFloat = 5
            while x < size.width {
                bars.addRect(CGRect(x: x, y: 0, width: 3.5, height: size.height))
                x += 8.5
            }
            context.fill(bars, with: .color(bar))
            for y in [0, size.height * 0.58] {
                context.fill(Path(CGRect(x: 0, y: y, width: size.width, height: 4)), with: .color(bar))
            }
            context.stroke(Path(rect.insetBy(dx: 2.5, dy: 2.5)), with: .color(bar), lineWidth: 5)
        }
        .frame(height: Self.height)
        .accessibilityHidden(true)
    }
}

/// Stone paving in front of the shop with a few fallen maple leaves. Extends under the home indicator.
struct StonePavement: View {
    var body: some View {
        let leaves: [Color] = [.kouyouDai, .kouyouKin, .chochin]
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            context.fill(Path(rect), with: .color(SceneColor.tileDark))
            var joints = Path()
            for x in [0.25, 0.54, 0.82] {
                joints.move(to: CGPoint(x: size.width * x, y: 0))
                joints.addLine(to: CGPoint(x: size.width * x, y: size.height))
            }
            joints.move(to: .zero)
            joints.addLine(to: CGPoint(x: size.width, y: 0))
            context.stroke(joints, with: .color(SceneColor.outline), lineWidth: 1.5)
            var rng = SeededRandom(seed: 0x1EAF)
            for index in 0..<7 {
                let center = CGPoint(x: size.width * .random(in: 0.08...0.7, using: &rng), y: .random(in: 14...36, using: &rng))
                context.fill(NightScene.leafPath(center: center, radius: .random(in: 6...8.5, using: &rng),
                                                 rotation: .random(in: 0...(2 * .pi), using: &rng)),
                             with: .color(leaves[index % leaves.count]))
            }
        }
        .accessibilityHidden(true)
    }
}

/// One cloth of a noren curtain, used as a score board or sign.
struct NorenCloth<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .foregroundStyle(.washi50)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background { Color.ai700.overlay(alignment: .top) { Color.ai500.opacity(0.6).frame(height: 16) } }
            .border(SceneColor.outline, width: 1.5)
    }
}

#Preview {
    VStack(spacing: 0) {
        Color.clear.frame(height: 80)
        ShopRoof()
        ShopWall()
        LatticeWindow()
        StonePavement().frame(height: 54)
    }
    .background { AppBackground() }
    .ignoresSafeArea(edges: .bottom)
}
