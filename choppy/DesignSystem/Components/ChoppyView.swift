import SwiftUI
import UIKit

/// Choppy's moods. Each mood maps to an artwork asset named `choppy_<mood>`
/// (see "Mascot assets" in README.md). Until the artwork exists, a drawn placeholder is shown.
enum ChoppyMood: String, CaseIterable, Identifiable {
    case happy, fed, hungry, sad, sleeping, cheering, thinking, celebrating

    var id: Self { self }
    var assetName: String { "choppy_\(rawValue)" }

    var label: LocalizedStringResource {
        switch self {
        case .happy: "Fröhlich"
        case .fed: "Satt"
        case .hungry: "Hungrig"
        case .sad: "Traurig"
        case .sleeping: "Schläft"
        case .cheering: "Feuert an"
        case .thinking: "Denkt nach"
        case .celebrating: "Feiert"
        }
    }
}

/// The mascot. Bounces whenever its mood changes.
struct ChoppyView: View {
    var mood: ChoppyMood
    var size: CGFloat = 120

    var body: some View {
        Group {
            if UIImage(named: mood.assetName) != nil {
                Image(mood.assetName).resizable().scaledToFit()
            } else {
                ChoppyPlaceholder(mood: mood)
            }
        }
        .frame(width: size, height: size)
        .keyframeAnimator(initialValue: 1.0, trigger: mood) { content, scale in
            content.scaleEffect(x: 2 - scale, y: scale, anchor: .bottom)
        } keyframes: { _ in
            SpringKeyframe(0.85, duration: 0.12)
            SpringKeyframe(1.12, duration: 0.18)
            SpringKeyframe(1.0, duration: 0.3, spring: .bouncy)
        }
        .accessibilityElement()
        .accessibilityLabel(Text("Choppy: \(mood.label)"))
    }
}

/// Simple drawn stand-in for the real artwork, dashed to make clear it is a placeholder.
private struct ChoppyPlaceholder: View {
    let mood: ChoppyMood

    var body: some View {
        Canvas { context, size in
            let s = min(size.width, size.height)
            let body = CGRect(x: s * 0.08, y: s * 0.12, width: s * 0.84, height: s * 0.8)
            context.fill(Path(ellipseIn: body), with: .color(.sugi400))
            context.stroke(Path(ellipseIn: body.insetBy(dx: -s * 0.03, dy: -s * 0.03)),
                           with: .color(.washi300.opacity(0.5)),
                           style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))

            // Ears
            for x in [0.22, 0.78] {
                let ear = CGRect(x: s * x - s * 0.1, y: s * 0.06, width: s * 0.2, height: s * 0.2)
                context.fill(Path(ellipseIn: ear), with: .color(.sugi600))
            }

            // Cheeks
            for x in [0.27, 0.73] {
                let cheek = CGRect(x: s * x - s * 0.07, y: s * 0.58, width: s * 0.14, height: s * 0.08)
                context.fill(Path(ellipseIn: cheek), with: .color(.chochin.opacity(0.45)))
            }

            let ink = GraphicsContext.Shading.color(.sumi)
            let line = StrokeStyle(lineWidth: s * 0.035, lineCap: .round)

            // Eyes
            for x in [0.36, 0.64] {
                let c = CGPoint(x: s * x, y: s * 0.47)
                switch mood {
                case .sleeping, .fed:
                    var p = Path()
                    p.move(to: CGPoint(x: c.x - s * 0.05, y: c.y))
                    p.addQuadCurve(to: CGPoint(x: c.x + s * 0.05, y: c.y), control: CGPoint(x: c.x, y: c.y + s * 0.04))
                    context.stroke(p, with: ink, style: line)
                case .happy, .cheering, .celebrating:
                    var p = Path()
                    p.move(to: CGPoint(x: c.x - s * 0.05, y: c.y + s * 0.02))
                    p.addQuadCurve(to: CGPoint(x: c.x + s * 0.05, y: c.y + s * 0.02), control: CGPoint(x: c.x, y: c.y - s * 0.05))
                    context.stroke(p, with: ink, style: line)
                default:
                    context.fill(Path(ellipseIn: CGRect(x: c.x - s * 0.035, y: c.y - s * 0.035, width: s * 0.07, height: s * 0.07)), with: ink)
                }
            }

            // Mouth
            let m = CGPoint(x: s * 0.5, y: s * 0.64)
            var mouth = Path()
            switch mood {
            case .happy, .fed, .cheering, .celebrating:
                mouth.move(to: CGPoint(x: m.x - s * 0.08, y: m.y))
                mouth.addQuadCurve(to: CGPoint(x: m.x + s * 0.08, y: m.y), control: CGPoint(x: m.x, y: m.y + s * 0.08))
            case .sad:
                mouth.move(to: CGPoint(x: m.x - s * 0.07, y: m.y + s * 0.04))
                mouth.addQuadCurve(to: CGPoint(x: m.x + s * 0.07, y: m.y + s * 0.04), control: CGPoint(x: m.x, y: m.y - s * 0.03))
            case .hungry:
                mouth.addEllipse(in: CGRect(x: m.x - s * 0.04, y: m.y - s * 0.02, width: s * 0.08, height: s * 0.09))
            case .sleeping, .thinking:
                mouth.move(to: CGPoint(x: m.x - s * 0.05, y: m.y + s * 0.02))
                mouth.addLine(to: CGPoint(x: m.x + s * 0.05, y: m.y + (mood == .thinking ? 0 : s * 0.02)))
            }
            context.stroke(mouth, with: ink, style: line)

            if mood == .sleeping {
                context.draw(Text("z").font(.choppyAccent(s * 0.16)).foregroundStyle(.washi300), at: CGPoint(x: s * 0.86, y: s * 0.16))
            }
        }
    }
}

#Preview {
    @Previewable @State var mood = ChoppyMood.happy
    VStack(spacing: Spacing.l) {
        ChoppyView(mood: mood, size: 160)
        Picker("Stimmung", selection: $mood) {
            ForEach(ChoppyMood.allCases) { Text($0.label).tag($0) }
        }
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 72))]) {
            ForEach(ChoppyMood.allCases) { ChoppyView(mood: $0, size: 64) }
        }
    }
    .padding()
    .background { AppBackground() }
}
