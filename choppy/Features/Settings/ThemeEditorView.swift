import SwiftUI
import UIKit

/// "Farben & Stil": dial in colours, background and accent font live on the device.
/// Changes apply everywhere immediately; "Werte teilen" sends the current values
/// so they can be made the new defaults in code.
struct ThemeEditorView: View {
    @Bindable private var theme = ThemeStore.shared
    @State private var copied = false
    @State private var confirmReset = false

    var body: some View {
        ChoppyScreen("Farben & Stil", japanese: "色", showsBack: true) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.l) {
                    preview
                    backgroundSection
                    fontSection
                    colorSection
                    actions
                }
                .padding()
            }
        } trailing: {
            ShareLink(item: theme.exportText) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.woodDark)
                    .frame(width: 38, height: 38)
                    .background(Color.card, in: .circle)
                    .overlay { Circle().strokeBorder(Color.wood, lineWidth: 1.5) }
            }
            .accessibilityLabel(Text("Werte teilen"))
        }
    }

    // MARK: Sections

    private var preview: some View {
        PaperCard {
            HStack(alignment: .top, spacing: Spacing.m) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Diese Woche").font(.choppyTitle)
                    Text("12 neue Wörter · 3 Kanji").foregroundStyle(.inkSoft)
                    Text("こんにちは").font(.choppyJapanese(22, weight: .bold))
                    HStack {
                        Button("Lernen") {}.buttonStyle(.ink(.primary))
                        Button("Später") {}.buttonStyle(.ink(.secondary))
                    }
                }
                Spacer(minLength: 0)
                VStack(spacing: Spacing.s) {
                    ChoppyView(mood: .happy, size: 64)
                    HankoStamp(text: "合格", size: 48)
                }
            }
        }
    }

    private var backgroundSection: some View {
        section("Hintergrund") {
            LazyVGrid(columns: Array(repeating: GridItem(spacing: Spacing.xs), count: 3), spacing: Spacing.xs) {
                ForEach(BackgroundStyle.allCases) { style in
                    let isSelected = theme.settings.background == style
                    Button { theme.settings.background = style } label: {
                        VStack(spacing: Spacing.xxs) {
                            ZStack {
                                Color.paper
                                BackgroundPatternView(style: style, scale: 0.6)
                                    .opacity(max(theme.settings.patternOpacity, 0.35))
                            }
                            .frame(height: 64)
                            .clipShape(.rect(cornerRadius: Radius.s))
                            .overlay {
                                RoundedRectangle(cornerRadius: Radius.s)
                                    .strokeBorder(isSelected ? Color.accent : Color.woodDark.opacity(0.15), lineWidth: isSelected ? 2.5 : 1)
                            }
                            Text(style.title).font(.caption2).lineLimit(1).minimumScaleFactor(0.7)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
            labeledSlider("Musterstärke", value: $theme.settings.patternOpacity, in: 0.05...1)
            labeledSlider("Papierstruktur", value: $theme.settings.paperTexture, in: 0...1)
        }
    }

    private var fontSection: some View {
        section("Akzentschrift") {
            Picker("Akzentschrift", selection: $theme.settings.accentFont) {
                ForEach(AccentFontFamily.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)
            Text("Überschriften, Buttons und Beschriftungen. Japanisch bleibt in Noto Sans JP.")
                .font(.footnote)
                .foregroundStyle(.inkSoft)
        }
    }

    private var colorSection: some View {
        section("Farben") {
            VStack(spacing: Spacing.m) {
                ForEach(ColorToken.allCases) { token in
                    ColorTokenRow(token: token, theme: theme)
                    if token != ColorToken.allCases.last { Divider() }
                }
            }
        }
    }

    private var actions: some View {
        VStack(spacing: Spacing.s) {
            Button(copied ? "Kopiert ✓" : "Werte kopieren") {
                UIPasteboard.general.string = theme.exportText
                copied = true
            }
            .buttonStyle(.ink(.primary, fullWidth: true))
            .sensoryFeedback(.success, trigger: copied) { _, new in new }

            Button("Alles zurücksetzen", role: .destructive) { confirmReset = true }
                .buttonStyle(.ink(.quiet))
                .confirmationDialog("Alle Farben, Hintergrund und Schrift zurücksetzen?",
                                    isPresented: $confirmReset, titleVisibility: .visible) {
                    Button("Zurücksetzen", role: .destructive) { theme.resetAll() }
                }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Helpers

    private func section(_ title: LocalizedStringKey, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title).font(.choppyHeadline)
            PaperCard {
                VStack(alignment: .leading, spacing: Spacing.s) { content() }
            }
        }
    }

    private func labeledSlider(_ title: LocalizedStringKey, value: Binding<Double>, in range: ClosedRange<Double>) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title).font(.subheadline)
            Slider(value: value, in: range)
        }
    }
}

/// One colour: picker, hex value, the reference palette as suggestions and a reset button.
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
                        Text(token.rawValue).font(.choppyHeadline)
                        Text(token.role).font(.caption).foregroundStyle(.inkSoft)
                        Text(theme.hex(for: token)).font(.caption.monospaced()).foregroundStyle(.inkSoft)
                    }
                }
                if theme.isCustomized(token) {
                    Button { theme.reset(token) } label: {
                        Image(systemName: "arrow.uturn.backward.circle.fill").font(.title3)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.wood)
                    .accessibilityLabel(Text("Auf Standard zurücksetzen"))
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.xs) {
                    ForEach(token.suggestions, id: \.self) { suggestion in
                        Button { theme.setHex(suggestion.hex, for: token) } label: {
                            HStack(spacing: Spacing.xxs) {
                                Circle().fill(Color(hex: suggestion.hex)).frame(width: 16, height: 16)
                                    .overlay { Circle().strokeBorder(Color.ink.opacity(0.15)) }
                                Text(suggestion.name).font(.caption)
                            }
                            .padding(.horizontal, Spacing.xs)
                            .padding(.vertical, Spacing.xxs)
                            .background(Color.paper, in: .capsule)
                            .overlay {
                                Capsule().strokeBorder(theme.hex(for: token) == suggestion.hex ? Color.accent : Color.woodDark.opacity(0.15))
                            }
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
