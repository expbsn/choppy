import SwiftUI

/// Choppy's button style: dark-green ink for primary actions, wood outline for secondary ones.
struct InkButtonStyle: ButtonStyle {
    enum Kind { case primary, secondary, quiet }

    var kind: Kind = .primary
    var fullWidth = false

    func makeBody(configuration: Configuration) -> some View {
        InkButtonBody(configuration: configuration, kind: kind, fullWidth: fullWidth)
    }
}

private struct InkButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let kind: InkButtonStyle.Kind
    let fullWidth: Bool
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        configuration.label
            .font(.choppyHeadline)
            .padding(.vertical, Spacing.s)
            .padding(.horizontal, Spacing.l)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .foregroundStyle(foreground)
            .background(background, in: .capsule)
            .overlay {
                if kind == .secondary {
                    Capsule().strokeBorder(Color.wood, lineWidth: 1.5)
                }
            }
            .contentShape(.capsule)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(isEnabled ? 1 : 0.45)
            .animation(.spring(duration: 0.25, bounce: 0.4), value: configuration.isPressed)
    }

    private var foreground: Color {
        switch kind {
        case .primary: .card
        case .secondary: .woodDark
        case .quiet: .accent
        }
    }

    private var background: Color {
        switch kind {
        case .primary: .accent
        case .secondary: .card
        case .quiet: .clear
        }
    }
}

extension ButtonStyle where Self == InkButtonStyle {
    static var ink: InkButtonStyle { InkButtonStyle() }

    static func ink(_ kind: InkButtonStyle.Kind, fullWidth: Bool = false) -> InkButtonStyle {
        InkButtonStyle(kind: kind, fullWidth: fullWidth)
    }
}

#Preview {
    VStack(spacing: Spacing.m) {
        Button("Lernen starten") {}.buttonStyle(.ink(.primary, fullWidth: true))
        Button("Herausfordern") {}.buttonStyle(.ink(.secondary))
        Button("Später") {}.buttonStyle(.ink(.quiet))
        Button("Gesperrt") {}.buttonStyle(.ink).disabled(true)
    }
    .padding()
    .background { AppBackground() }
}
