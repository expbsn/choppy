import SwiftUI

/// Choppy's buttons, named like the Figma components "Button / …".
struct ChoppyButtonStyle: ButtonStyle {
    enum Kind {
        /// Lantern paper: the main action on the night background and on wood.
        case paper
        /// Ink-dark plank with a cedar edge: the main action on a paper card.
        case ink
        /// Plain dark plank: secondary actions.
        case plank
        /// Text only, with a small arrow: quiet links such as "Alle Themen".
        case quiet
    }

    var kind: Kind = .paper
    var fullWidth = false

    func makeBody(configuration: Configuration) -> some View {
        ChoppyButtonBody(configuration: configuration, kind: kind, fullWidth: fullWidth)
    }
}

private struct ChoppyButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let kind: ChoppyButtonStyle.Kind
    let fullWidth: Bool
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        label
            .font(.choppyHeadline)
            .foregroundStyle(foreground)
            .padding(.vertical, Spacing.s)
            .padding(.horizontal, kind == .quiet ? 0 : 20)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background { face }
            .padding(kind == .quiet ? 0 : border.width)
            .background(border.color, in: .rect(cornerRadius: Radius.s + border.width))
            .contentShape(.rect)
            .offset(y: configuration.isPressed ? 1 : 0)
            .opacity(isEnabled ? (configuration.isPressed ? 0.85 : 1) : 0.45)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }

    @ViewBuilder
    private var label: some View {
        if kind == .quiet {
            HStack(spacing: Spacing.xxs) {
                configuration.label
                Image(systemName: "chevron.right").font(.system(size: 11, weight: .semibold))
            }
        } else {
            configuration.label
        }
    }

    /// The flat face of the button with its one-sided inner edge.
    @ViewBuilder
    private var face: some View {
        switch kind {
        case .paper:
            Color.washi50.overlay(alignment: .bottom) { Color.washi300.frame(height: 3) }
                .clipShape(.rect(cornerRadius: Radius.s))
        case .ink:
            Color.sugi800.clipShape(.rect(cornerRadius: Radius.s))
        case .plank:
            Color.sugi800.overlay(alignment: .top) { Color.sugi600.frame(height: 1) }
                .clipShape(.rect(cornerRadius: Radius.s))
        case .quiet:
            Color.clear
        }
    }

    private var border: (color: Color, width: CGFloat) {
        switch kind {
        case .paper: (.washi100, 3)
        case .ink: (.sugi600, 3)
        case .plank: (.sumi, 2)
        case .quiet: (.clear, 0)
        }
    }

    private var foreground: Color {
        switch kind {
        case .paper: .sumi
        case .ink: .washi50
        case .plank: .washi100
        case .quiet: .washi300
        }
    }
}

extension ButtonStyle where Self == ChoppyButtonStyle {
    static func choppy(_ kind: ChoppyButtonStyle.Kind, fullWidth: Bool = false) -> ChoppyButtonStyle {
        ChoppyButtonStyle(kind: kind, fullWidth: fullWidth)
    }
}

/// Square plank with an SF Symbol, used for back and header actions.
struct PlankIconButton: View {
    var systemImage: String
    var label: LocalizedStringKey
    var action: () -> Void

    var body: some View {
        Button(action: action) { PlankIcon(systemImage: systemImage) }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(label))
    }
}

/// The look of `PlankIconButton`, for use as the label of links and share buttons.
struct PlankIcon: View {
    var systemImage: String

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.washi100)
            .frame(width: 36, height: 36)
            .background {
                Color.sugi800.overlay(alignment: .top) { Color.sugi600.frame(height: 1) }
                    .clipShape(.rect(cornerRadius: Radius.s))
            }
            .padding(2)
            .background(Color.sumi, in: .rect(cornerRadius: Radius.s + 2))
            .contentShape(.rect)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.m) {
        Button("Weiter lernen") {}.buttonStyle(.choppy(.paper))
        Button("Weiter lernen") {}.buttonStyle(.choppy(.ink))
        Button("Später") {}.buttonStyle(.choppy(.plank))
        Button("Alle Themen") {}.buttonStyle(.choppy(.quiet))
        Button("Gesperrt") {}.buttonStyle(.choppy(.paper, fullWidth: true)).disabled(true)
        PlankIconButton(systemImage: "chevron.left", label: "Zurück") {}
    }
    .padding(Spacing.l)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background { AppBackground() }
}
