import SwiftUI
import Translation

/// The translator: type a word in German or Japanese, get the other language with a guessed reading,
/// and add it either to the words both learn together or to your own card box.
/// Translation runs on the device with Apple's Translation framework (not available in the simulator).
struct TranslatorView: View {
    enum Direction {
        case germanToJapanese, japaneseToGerman

        var source: (name: LocalizedStringKey, language: Locale.Language) {
            self == .germanToJapanese ? ("Deutsch", .init(identifier: "de")) : ("Japanisch", .init(identifier: "ja"))
        }

        var target: (name: LocalizedStringKey, language: Locale.Language) {
            self == .germanToJapanese ? ("Japanisch", .init(identifier: "ja")) : ("Deutsch", .init(identifier: "de"))
        }

        var flipped: Direction { self == .germanToJapanese ? .japaneseToGerman : .germanToJapanese }
    }

    @State private var direction = Direction.germanToJapanese
    @State private var input = ""
    @State private var query = ""
    @State private var output = ""
    @State private var reading = ""
    @State private var isWorking = false
    @State private var failure: String?
    @State private var configuration: TranslationSession.Configuration?
    @FocusState private var inputFocused: Bool

    private var store: LocalDraftStore { .shared }
    /// The pair of the current result, whichever way it was translated.
    private var german: String { direction == .germanToJapanese ? query : output }
    private var japanese: String { direction == .germanToJapanese ? output : query }

    var body: some View {
        ChoppyScreen("Übersetzer", subtitle: Text("Deutsch ⇄ Japanisch"), showsBack: true) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.l) {
                    VStack(spacing: Spacing.s) {
                        directionBar
                        lantern
                    }
                    wordList("Unsere Wörter", list: .shared, empty: "Wörter, die ihr beide lernt, erscheinen hier.")
                    wordList("Meine Kartei", list: .own, empty: "Wörter nur für dich erscheinen hier.")
                    Text("Vorerst auf diesem Gerät gespeichert, noch ohne Abgleich und noch nicht in den Lernkarten.")
                        .font(.choppyFootnote)
                        .foregroundStyle(.kasumi)
                }
                .padding(.horizontal, Spacing.l)
                .padding(.vertical, Spacing.m)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .translationTask(configuration) { session in
            guard !query.isEmpty else { return }
            do {
                output = try await session.translate(query).targetText
                reading = ReadingGenerator.hiragana(for: japanese)
                failure = nil
            } catch {
                failure = "Das ließ sich nicht übersetzen. Die Übersetzung braucht ein echtes Gerät und die Sprachpakete Deutsch und Japanisch."
            }
            isWorking = false
        }
    }

    // MARK: Direction

    /// From-language on the left, to-language on the right; the button in the middle swaps them.
    private var directionBar: some View {
        HStack(spacing: Spacing.xs) {
            languageCloth(direction.source.name, caption: "Von")
            Button(action: swap) {
                PlankIcon(systemImage: "arrow.left.arrow.right")
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("Richtung tauschen"))
            languageCloth(direction.target.name, caption: "Nach")
        }
        .sensoryFeedback(.selection, trigger: direction)
    }

    private func languageCloth(_ name: LocalizedStringKey, caption: LocalizedStringKey) -> some View {
        Button(action: swap) {
            VStack(spacing: 0) {
                Text(caption).font(.choppyCaption).foregroundStyle(.washi300)
                Text(name).font(.choppyHeadline).foregroundStyle(.washi50)
                    .contentTransition(.opacity)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.xs)
            .background(Color.ai500)
            .overlay(alignment: .top) { Color.sumi.frame(height: 4) }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityHint(Text("Tauscht die Richtung"))
    }

    private func swap() {
        withAnimation(.easeOut(duration: 0.2)) { direction = direction.flipped }
        // A finished translation becomes the new input, so you can check it the other way round.
        if !output.isEmpty { input = output }
        output = ""
        failure = nil
        configuration = nil
    }

    // MARK: Lantern

    private var lantern: some View {
        LanternCard {
            VStack(alignment: .leading, spacing: Spacing.s) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(direction.source.name).font(.choppyCaption).foregroundStyle(.sugi400)
                    HStack(alignment: .center, spacing: Spacing.xs) {
                        TextField("Wort oder kurzer Satz", text: $input, axis: .vertical)
                            .font(.choppyTitle)
                            .lineLimit(1...3)
                            .focused($inputFocused)
                            .submitLabel(.search)
                            .autocorrectionDisabled(direction == .japaneseToGerman)
                            .onSubmit(translate)
                            .onChange(of: input) { _, new in
                                // Return in a multi-line field adds a line break; treat it as "translate".
                                if new.contains("\n") {
                                    input = new.replacingOccurrences(of: "\n", with: "")
                                    translate()
                                }
                            }
                        if !input.isEmpty {
                            Button { input = ""; output = ""; failure = nil; inputFocused = true } label: {
                                Image(systemName: "xmark.circle.fill").font(.system(size: 18)).foregroundStyle(.sugi400)
                                    .frame(width: 36, height: 36)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(Text("Eingabe löschen"))
                        }
                    }
                }
                Color.sumi.opacity(0.3).frame(height: 1)

                VStack(alignment: .leading, spacing: 2) {
                    Text(direction.target.name).font(.choppyCaption).foregroundStyle(.sugi400)
                    if isWorking {
                        Text("Übersetze …").font(.choppyTitle).foregroundStyle(.sugi400)
                    } else if !output.isEmpty {
                        if direction == .germanToJapanese {
                            Text(brush: output, size: output.count > 6 ? 28 : 44).lineLimit(2).minimumScaleFactor(0.5)
                        } else {
                            Text(output).font(.choppyDisplay).lineLimit(3).minimumScaleFactor(0.6)
                        }
                        HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                            TextField("Lesung", text: $reading).font(.choppyHeadline)
                            Text("Lesung, änderbar").font(.choppyCaption).foregroundStyle(.sugi400)
                        }
                        .textSelection(.enabled)
                    } else if let failure {
                        Text(failure).font(.choppyFootnote).foregroundStyle(.chochinYoru)
                    } else {
                        Text("Die Übersetzung erscheint hier.").font(.choppyBody).foregroundStyle(.sugi400)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 56, alignment: .topLeading)

                if output.isEmpty {
                    Button("Übersetzen", action: translate)
                        .buttonStyle(.choppy(.ink, fullWidth: true))
                        .disabled(isWorking || input.trimmingCharacters(in: .whitespaces).isEmpty)
                } else {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Hinzufügen zu").font(.choppyCaption).foregroundStyle(.sugi400)
                        HStack(spacing: Spacing.xs) {
                            addButton("Unsere Wörter", list: .shared)
                            addButton("Meine Kartei", list: .own)
                        }
                    }
                }
            }
        }
        .onAppear { inputFocused = input.isEmpty }
    }

    private func addButton(_ title: LocalizedStringKey, list: LocalDraftStore.WordList) -> some View {
        let isAdded = store.contains(japanese: japanese, in: list)
        return Button {
            store.add(.init(german: german, japanese: japanese, reading: reading, list: list))
        } label: {
            Label(title, systemImage: isAdded ? "checkmark" : "plus")
                .font(.choppyAccent(14, relativeTo: .subheadline))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.choppy(.ink, fullWidth: true))
        .disabled(isAdded)
        .sensoryFeedback(.success, trigger: isAdded) { _, new in new }
    }

    // MARK: Lists

    @ViewBuilder
    private func wordList(_ title: LocalizedStringKey, list: LocalDraftStore.WordList, empty: LocalizedStringKey) -> some View {
        let words = store.words(in: list)
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            HStack(alignment: .firstTextBaseline) {
                Text(title).font(.choppyTitle)
                Spacer()
                Text(words.count == 1 ? "1 Wort" : "\(words.count) Wörter").font(.choppyCaption).foregroundStyle(.washi300)
            }
            if words.isEmpty {
                Text(empty).font(.choppyFootnote).foregroundStyle(.washi300).padding(.vertical, Spacing.xs)
            }
            ForEach(words) { word in
                HStack(spacing: Spacing.s) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(brush: word.japanese, size: 22, relativeTo: .title3).foregroundStyle(.washi50)
                        Text("\(word.reading) · \(word.german)").font(.choppyFootnote).foregroundStyle(.washi300)
                    }
                    Spacer(minLength: 0)
                    Button { withAnimation { store.remove(word) } } label: {
                        Image(systemName: "xmark").font(.system(size: 12, weight: .semibold)).foregroundStyle(.kasumi)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text("\(word.german) entfernen"))
                }
                .padding(.vertical, Spacing.xxs)
                .overlay(alignment: .bottom) { Color.washi100.opacity(0.12).frame(height: 1) }
            }
        }
    }

    private func translate() {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isWorking else { return }
        query = text
        output = ""
        failure = nil
        isWorking = true
        inputFocused = false
        if configuration == nil {
            configuration = .init(source: direction.source.language, target: direction.target.language)
        } else {
            configuration?.invalidate()
        }
    }
}

#Preview {
    NavigationStack {
        TranslatorView()
    }
}
