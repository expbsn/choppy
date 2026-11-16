import SwiftUI
import UIKit

/// "Farben": dial in the palette live on the device.
/// Changes apply everywhere immediately; "Werte teilen" at the bottom sends the current values
/// so they can be made the new defaults in code and in the Figma variables.
struct ThemeEditorView: View {
    private let theme = ThemeStore.shared
    @State private var copied = false
    @State private var confirmReset = false

    var body: some View {
        ChoppyScreen("Farben", subtitle: Text("Laternengasse · \(ColorToken.allCases.count) Töne"), showsBack: true) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.l) {
                    preview
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Palette").font(.choppyTitle)
                        PaperCard {
                            VStack(spacing: Spacing.s) {
                                ForEach(ColorToken.allCases) { token in
                                    ColorTokenRow(token: token, theme: theme)
                                    if token != ColorToken.allCases.last {
                                        Color.sumi.opacity(0.15).frame(height: 1)
                                    }
                                }
                            }
                        }
                    }
                    actions
                }
                .padding(.horizontal, Spacing.l)
                .padding(.vertical, Spacing.m)
            }
        }
    }

    private var preview: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            PaperCard(padding: Spacing.m) {
                HStack(spacing: Spacing.m) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Wort des Tages").font(.choppyCaption).foregroundStyle(.sugi400)
                        Text(brush: "蕎麦", size: 28)
                        Text("Buchweizennudeln").font(.choppyFootnote)
                    }
                    Spacer(minLength: 0)
                    Button("Lernen") {}.buttonStyle(.choppy(.ink))
                }
            }
            HStack(spacing: Spacing.m) {
                ChochinCounter(lit: 4)
                Spacer(minLength: 0)
                Button("Später") {}.buttonStyle(.choppy(.plank))
            }
        }
    }

    private var actions: some View {
        VStack(spacing: Spacing.s) {
            Button(copied ? "Kopiert ✓" : "Werte kopieren") {
                UIPasteboard.general.string = theme.exportText
                copied = true
            }
            .buttonStyle(.choppy(.paper, fullWidth: true))
            .sensoryFeedback(.success, trigger: copied) { _, new in new }

            ShareLink(item: theme.exportText) {
                Label("Werte teilen", systemImage: "square.and.arrow.up").frame(maxWidth: .infinity)
            }
            .buttonStyle(.choppy(.plank, fullWidth: true))

            Button("Alles zurücksetzen", role: .destructive) { confirmReset = true }
                .buttonStyle(.choppy(.plank, fullWidth: true))
                .confirmationDialog("Alle Farben zurücksetzen?", isPresented: $confirmReset, titleVisibility: .visible) {
                    Button("Zurücksetzen", role: .destructive) { theme.resetAll() }
                }
        }
    }
}

/// One colour: picker, hex value, the palette as suggestions and a reset button.
private struct ColorTokenRow: View {
    let token: ColorToken
    let theme: ThemeStore

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(spacing: Spacing.s) {
                ColorPicker(selection: Binding(get: { theme.color(token) },
                                               set: { theme.setColor($0, for: token) }),
                            supportsOpacity: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(token.figmaName).font(.choppyHeadline)
                        Text(token.role).font(.choppyFootnote).foregroundStyle(.sugi400)
                        Text(theme.hex(for: token)).font(.choppyCaption).foregroundStyle(.sugi400)
                    }
                }
                if theme.isCustomized(token) {
                    Button { theme.reset(token) } label: {
                        Image(systemName: "arrow.uturn.backward.circle.fill").font(.title3)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.sugi400)
                    .accessibilityLabel(Text("Auf Standard zurücksetzen"))
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.xs) {
                    ForEach(token.suggestions, id: \.self) { suggestion in
                        let isCurrent = theme.hex(for: token) == suggestion.hex
                        Button { theme.setHex(suggestion.hex, for: token) } label: {
                            HStack(spacing: Spacing.xxs) {
                                Color(hex: suggestion.hex).frame(width: 14, height: 14)
                                    .border(Color.sumi.opacity(0.3), width: 1)
                                Text(suggestion.name).font(.choppyCaption)
                            }
                            .padding(.horizontal, Spacing.xs)
                            .padding(.vertical, Spacing.xxs)
                            .background(Color.washi50)
                            .border(isCurrent ? Color.sumi : Color.sumi.opacity(0.15), width: isCurrent ? 1.5 : 1)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ThemeEditorView()
    }
}
