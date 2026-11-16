#if DEBUG
import SwiftUI

/// Debug-only overview of every design-system token and component, for reviewing the look on a device.
struct DesignGalleryView: View {
    @State private var mood = ChoppyMood.happy
    @State private var stamped = true
    @State private var completedWeeks = 3
    @State private var script = "hiragana"
    @State private var streak = 4

    var body: some View {
        ChoppyScreen("Design-Galerie", subtitle: Text("Laternengasse"), showsBack: true) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.l) {
                    section("Farben") {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 76), spacing: Spacing.xs)], spacing: Spacing.s) {
                            ForEach(ColorToken.allCases) { token in
                                VStack(alignment: .leading, spacing: Spacing.xxs) {
                                    ThemeStore.shared.color(token)
                                        .frame(height: 40)
                                        .border(Color.washi100.opacity(0.2), width: 1)
                                    Text(token.figmaName).font(.choppyMono(10)).foregroundStyle(.washi300)
                                }
                            }
                        }
                    }

                    section("Schrift") {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Display").font(.choppyDisplay)
                            Text("Titel").font(.choppyTitle)
                            Text("Überschrift").font(.choppyHeadline)
                            Text("Fließtext in Zen Maru Gothic").font(.choppyBody)
                            Text("Beschriftung · 12 von 20").font(.choppyCaption).foregroundStyle(.washi300)
                            Text(brush: "蕎麦を食べる", size: 34)
                            Text("いただきます・日本語").font(.choppyJapanese(20))
                        }
                    }

                    section("Buttons") {
                        VStack(alignment: .leading, spacing: Spacing.s) {
                            HStack(spacing: Spacing.s) {
                                Button("Weiter lernen") {}.buttonStyle(.choppy(.paper))
                                Button("Weiter lernen") {}.buttonStyle(.choppy(.ink))
                            }
                            HStack(spacing: Spacing.m) {
                                Button("Später") {}.buttonStyle(.choppy(.plank))
                                Button("Alle Themen") {}.buttonStyle(.choppy(.quiet))
                                PlankIconButton(systemImage: "chevron.left", label: "Zurück") {}
                            }
                        }
                    }

                    section("Laternen, Holztafel und Noren") {
                        VStack(alignment: .leading, spacing: Spacing.m) {
                            Stepper(value: $streak, in: 0...7) { ChochinCounter(lit: streak) }
                            HStack(alignment: .top, spacing: Spacing.m) {
                                Holztafel(text: "学ぶ")
                                Holztafel(text: "道")
                                NorenSwitch(selection: $script, options: [("hiragana", "Hiragana"), ("katakana", "Katakana")])
                            }
                        }
                    }

                    section("Papier und Zeilen") {
                        VStack(spacing: Spacing.s) {
                            HStack(spacing: Spacing.s) {
                                ProgressBoard(title: "Hiragana", done: 46, total: 104)
                                ProgressBoard(title: "Wörter der Woche", done: 8, total: 20)
                            }
                            ListRow(glyph: .brush("蕎麦"), title: Text("そば"), subtitle: Text("Buchweizennudeln"),
                                    trailing: .lantern(isLit: true))
                            ListRow(glyph: .brush("水"), title: Text("みず"), subtitle: Text("Wasser"),
                                    trailing: .lantern(isLit: false))
                        }
                    }

                    section("Laternenschild") {
                        LanternSign(columns: ["今週", "挨拶"])
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.l)
                    }

                    section("Stempel") {
                        VStack(alignment: .leading, spacing: Spacing.m) {
                            HStack(spacing: Spacing.l) {
                                HankoStamp(text: "合格", isStamped: stamped)
                                HankoStamp(text: "完", size: 56, isStamped: stamped)
                                HankoStamp(text: "毎日練習", size: 84, isStamped: stamped)
                            }
                            Button(stamped ? "Stempel entfernen" : "Stempeln") { stamped.toggle() }
                                .buttonStyle(.choppy(.plank))
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

                    section("Fußspuren-Pfad") {
                        VStack {
                            Stepper("Abgeschlossen: \(completedWeeks)", value: $completedWeeks, in: 0...8)
                            FootprintPath(weeks: 8, completed: completedWeeks)
                        }
                    }
                }
                .padding(.horizontal, Spacing.l)
                .padding(.vertical, Spacing.m)
            }
        }
    }

    private func section(_ title: LocalizedStringKey, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(title).font(.choppyTitle)
            content()
        }
    }
}

#Preview {
    NavigationStack {
        DesignGalleryView()
    }
}
#endif
