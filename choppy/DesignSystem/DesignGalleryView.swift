#if DEBUG
import SwiftUI

/// Debug-only overview of every design-system token and component, for reviewing the look on a device.
struct DesignGalleryView: View {
    @State private var mood = ChoppyMood.happy
    @State private var stamped = true
    @State private var completedWeeks = 3

    var body: some View {
        ChoppyScreen("Design-Galerie", showsBack: true) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.l) {
                    section("Farben") {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 88), spacing: Spacing.s)], spacing: Spacing.s) {
                            ForEach(ColorToken.allCases) { token in
                                VStack(spacing: Spacing.xxs) {
                                    RoundedRectangle(cornerRadius: Radius.s)
                                        .fill(ThemeStore.shared.color(token))
                                        .frame(height: 44)
                                        .overlay { RoundedRectangle(cornerRadius: Radius.s).strokeBorder(Color.ink.opacity(0.1)) }
                                    Text(token.rawValue).font(.caption2)
                                }
                            }
                        }
                    }

                    section("Typografie") {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Display").font(.choppyDisplay)
                            Text("Titel").font(.choppyTitle)
                            Text("Überschrift").font(.choppyHeadline)
                            Text("Fließtext in SF Pro").font(.body)
                            Text("Beschriftung").font(.choppyCaption)
                            Text("いただきます・日本語").font(.choppyJapanese(26))
                        }
                    }

                    section("Buttons") {
                        VStack(alignment: .leading, spacing: Spacing.s) {
                            Button("Lernen starten") {}.buttonStyle(.ink(.primary, fullWidth: true))
                            HStack {
                                Button("Herausfordern") {}.buttonStyle(.ink(.secondary))
                                Button("Später") {}.buttonStyle(.ink(.quiet))
                            }
                            HStack(spacing: Spacing.s) {
                                WoodIconButton(systemImage: "chevron.left", label: "Zurück") {}
                                WoodIconButton(systemImage: "gearshape", label: "Einstellungen") {}
                                SealLabel(text: "学ぶ")
                                SealLabel(text: "道")
                            }
                        }
                    }

                    section("Choppy") {
                        VStack(spacing: Spacing.s) {
                            ChoppyView(mood: mood, size: 140)
                                .frame(maxWidth: .infinity)
                            Picker("Stimmung", selection: $mood) {
                                ForEach(ChoppyMood.allCases) { Text($0.label).tag($0) }
                            }
                        }
                    }

                    section("Stempel") {
                        VStack(alignment: .leading, spacing: Spacing.m) {
                            HStack(spacing: Spacing.l) {
                                HankoStamp(text: "合格", isStamped: stamped)
                                HankoStamp(text: "完", size: 56, isStamped: stamped)
                                HankoStamp(text: "毎日練習", size: 84, isStamped: stamped)
                            }
                            Button(stamped ? "Stempel entfernen" : "Stempeln") { stamped.toggle() }
                                .buttonStyle(.ink(.secondary))
                        }
                    }

                    section("Muster") {
                        LazyVGrid(columns: [GridItem(), GridItem()], spacing: Spacing.s) {
                            ForEach(BackgroundStyle.allCases) { style in
                                VStack(spacing: Spacing.xxs) {
                                    ZStack {
                                        Color.paper
                                        PaperTexture(strength: 0.5)
                                        BackgroundPatternView(style: style).opacity(0.25)
                                    }
                                    .frame(height: 110)
                                    .clipShape(.rect(cornerRadius: Radius.s))
                                    Text(style.title).font(.caption2)
                                }
                            }
                        }
                    }

                    section("Fußspuren-Pfad") {
                        VStack {
                            Stepper("Abgeschlossen: \(completedWeeks)", value: $completedWeeks, in: 0...8)
                            FootprintPath(weeks: 8, completed: completedWeeks)
                        }
                    }
                }
                .padding()
            }
        }
    }

    private func section(_ title: LocalizedStringKey, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title).font(.choppyHeadline)
            PaperCard { content() }
        }
    }
}

#Preview {
    NavigationStack {
        DesignGalleryView()
    }
}
#endif
