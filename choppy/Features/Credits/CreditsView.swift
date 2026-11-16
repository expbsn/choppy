import SwiftUI

/// "Credits & Lizenzen": attribution for all bundled fonts, content, voices and images.
struct CreditsView: View {
    var credits: [Credit] = Credit.all

    var body: some View {
        ChoppyScreen("Credits & Lizenzen", showsBack: true) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.s) {
                    Text("Choppy steht auf den Schultern vieler großzügiger Projekte. Danke!")
                        .foregroundStyle(.washi300)

                    ForEach(Credit.Category.allCases, id: \.self) { category in
                        let entries = credits.filter { $0.category == category }
                        if !entries.isEmpty {
                            Text(category.title).font(.choppyTitle).padding(.top, Spacing.s)
                            ForEach(entries) { credit in
                                NavigationLink { CreditDetailView(credit: credit) } label: {
                                    PaperCard(padding: Spacing.s) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: Spacing.xxs) {
                                                Text(credit.name).font(.choppyHeadline)
                                                Text(credit.usage).font(.choppyFootnote)
                                                Text(credit.license).font(.choppyCaption).foregroundStyle(.sugi400)
                                            }
                                            Spacer(minLength: 0)
                                            Image(systemName: "chevron.right")
                                                .font(.footnote.weight(.bold))
                                                .foregroundStyle(.sugi400)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, Spacing.l)
                .padding(.vertical, Spacing.m)
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
                            Text(credit.usage)
                            Text(credit.copyright).font(.choppyFootnote)
                            Link(credit.license, destination: credit.licenseURL)
                                .font(.choppyCaption)
                                .tint(.sugi400)
                        }
                    }
                    if let text = credit.licenseText {
                        PaperCard {
                            Text(text)
                                .font(.choppyMono(11))
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
