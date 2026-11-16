import ChoppyCore
import SwiftUI

/// The kana table: basic characters in the classic a-i-u-e-o grid, then voiced characters and combinations.
struct KanaChartView: View {
    @State var script: KanaItem.Script
    @Environment(\.content) private var content

    var body: some View {
        ChoppyScreen("Kana-Tabelle", subtitle: Text("\(content.kana(script).count) Zeichen"), showsBack: true) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.l) {
                    NorenSwitch(selection: $script, options: [(.hiragana, "Hiragana"), (.katakana, "Katakana")])

                    section("Grundzeichen", items: content.kana(script, group: .basic), columns: "aiueo")
                    section("Mit Dakuten ゛ und Handakuten ゜",
                            items: content.kana(script, group: .dakuten) + content.kana(script, group: .handakuten),
                            columns: "aiueo")
                    section("Kombinationen", items: content.kana(script, group: .combo), columns: "auo")
                }
                .padding(.horizontal, Spacing.l)
                .padding(.vertical, Spacing.m)
            }
        }
    }

    private func section(_ title: LocalizedStringKey, items: [KanaItem], columns: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(title).font(.choppyTitle)
            Grid(horizontalSpacing: Spacing.xs, verticalSpacing: Spacing.xs) {
                ForEach(rows(items), id: \.self) { row in
                    GridRow {
                        ForEach(Array(slots(row, columns: columns).enumerated()), id: \.offset) { _, item in
                            if let item {
                                KanaCell(item: item)
                            } else {
                                Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
                            }
                        }
                    }
                }
            }
        }
    }

    /// Items grouped by consonant row, keeping teaching order.
    private func rows(_ items: [KanaItem]) -> [[KanaItem]] {
        var result: [[KanaItem]] = []
        for item in items {
            if let last = result.last?.last, last.row == item.row, last.group == item.group {
                result[result.count - 1].append(item)
            } else {
                result.append([item])
            }
        }
        return result
    }

    /// Places each item in its vowel column so や, ゆ, よ line up under あ, う, お. ん goes first.
    private func slots(_ row: [KanaItem], columns: String) -> [KanaItem?] {
        Array(columns).map { vowel in row.first { ($0.vowel ?? "a") == vowel } }
    }
}

/// One character on a small sheet of lantern paper.
private struct KanaCell: View {
    let item: KanaItem

    var body: some View {
        VStack(spacing: 0) {
            Text(brush: item.kana, size: item.kana.count > 1 ? 22 : 26)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .foregroundStyle(.sumi)
            Text(item.romaji)
                .font(.choppyMono(11))
                .foregroundStyle(.sugi400)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background {
            Color.washi100.overlay(alignment: .bottom) { Color.washi300.frame(height: 2) }
                .clipShape(.rect(cornerRadius: Radius.s))
        }
        .accessibilityElement()
        .accessibilityLabel(Text("\(item.kana), \(item.romaji)"))
    }
}

#Preview {
    NavigationStack {
        KanaChartView(script: .hiragana)
    }
}
