import SwiftUI

/// "Credits & Lizenzen": attribution for all bundled fonts, content, voices and images.
struct CreditsView: View {
    var credits: [Credit] = Credit.all

    var body: some View {
        ChoppyScreen("Credits & Lizenzen", showsBack: true) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.s) {
                    Text("Choppy steht auf den Schultern vieler großzügiger Projekte. Danke!")
                        .foregroundStyle(.inkSoft)

                    ForEach(Credit.Category.allCases, id: \.self) { category in
                        let entries = credits.filter { $0.category == category }
                        if !entries.isEmpty {
                            Text(category.title).font(.choppyHeadline).padding(.top, Spacing.s)
                            ForEach(entries) { credit in
                                NavigationLink { CreditDetailView(credit: credit) } label: {
                                    PaperCard(padding: Spacing.s) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: Spacing.xxs) {
                                                Text(credit.name).font(.choppyHeadline)
                                                Text(credit.usage).font(.subheadline).foregroundStyle(.inkSoft)
                                                Text(credit.license).font(.choppyCaption).foregroundStyle(.accent)
                                            }
                                            Spacer(minLength: 0)
                                            Image(systemName: "chevron.right")
                                                .font(.footnote.weight(.bold))
                                                .foregroundStyle(.wood)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding()
            }
        }
    }
}

private struct CreditDetailView: View {
    let credit: Credit

    var body: some View {
        ChoppyScreen("\(credit.name)", showsBack: true) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.m) {
                    PaperCard {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text(credit.usage).foregroundStyle(.inkSoft)
                            Text(credit.copyright).font(.footnote)
                            Link(credit.license, destination: credit.licenseURL)
                                .font(.choppyCaption)
                                .tint(.accent)
                        }
                    }
                    if let text = credit.licenseText {
                        PaperCard {
                            Text(text)
                                .font(.caption.monospaced())
                                .textSelection(.enabled)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    NavigationStack {
        CreditsView()
    }
}
