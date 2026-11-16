import SwiftUI

/// Frame for every screen: the shared night background and a custom header in place of the
/// system navigation bar – the title with an optional small caption below it, as on the Figma screens.
/// Push destinations pass `showsBack: true` to get the plank back button. Screens that bring
/// their own opening (the start screen) pass no title and get no header.
///
/// The header has no buttons on the right: that corner belongs to the maple and its lanterns.
/// Content scrolling up starts to blur and darken a little below the header and has dissolved into
/// the night behind the title. The maple corner is drawn in front of it and stays sharp.
struct ChoppyScreen<Content: View>: View {
    let title: LocalizedStringKey?
    var subtitle: Text?
    var showsBack: Bool
    @ViewBuilder var content: Content

    @Environment(\.dismiss) private var dismiss
    @Environment(\.bottomBarInset) private var bottomBarInset
    /// How far below the header the blur and darkening already begin.
    private let fadeReach: CGFloat = 48

    init(_ title: LocalizedStringKey?,
         subtitle: Text? = nil,
         showsBack: Bool = false,
         @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.showsBack = showsBack
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            // Scroll content ends above the tab bar, while the page background still runs underneath it.
            .contentMargins(.bottom, bottomBarInset, for: .scrollContent)
            .contentMargins(.bottom, bottomBarInset, for: .scrollIndicators)
            // The bar reaches `fadeReach` below the header (and content starts that much higher), so the
            // system's soft edge blur begins early. The night veil in the bar darkens what is blurred.
            .scrollEdgeEffectStyle(.soft, for: .top)
            // At rest the content sits just below the fade, so its first line is clear.
            .contentMargins(.top, title == nil ? 0 : fadeReach - Spacing.xxs, for: .scrollContent)
            .safeAreaBar(edge: .top, spacing: title == nil ? 0 : -fadeReach) {
                if let title {
                    VStack(spacing: 0) {
                        header(title)
                        Color.clear.frame(height: fadeReach)
                    }
                    .background(alignment: .top) { veil }
                }
            }
            .onAppear { LanternMotion.shared.push() }
            .background { AppBackground() }
            .font(.choppyBody)
            .foregroundStyle(.washi50)
            .toolbar(.hidden, for: .navigationBar)
    }

    private func header(_ title: LocalizedStringKey) -> some View {
        // The back button is centred on the title and its caption together.
        HStack(alignment: .center, spacing: Spacing.s) {
            if showsBack {
                PlankIconButton(systemImage: "chevron.left", label: "Zurück") { dismiss() }
            }
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.choppyDisplay)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .accessibilityAddTraits(.isHeader)
                subtitle?
                    .font(.choppyCaption)
                    .foregroundStyle(.washi300)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            Spacer(minLength: 0)
        }
        .foregroundStyle(.washi50)
        .padding(.leading, Spacing.l)
        // Title and caption end well before the branch and lanterns of the maple corner.
        .padding(.trailing, MapleCorner.reservedWidth)
        .padding(.top, Spacing.xs)
        .padding(.bottom, Spacing.xxs)
    }

    /// What lies over scrolled content in the header zone, bottom to top:
    /// a blur that grows towards the top (two frosted layers with fading masks, so it does not depend
    /// on the system edge effect), a veil of night sky that thins out downwards, and the maple corner,
    /// which therefore stays sharp.
    private var veil: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial)
                .mask { fade(solidUntil: 0.55, clearAt: 1) }
            Rectangle().fill(.regularMaterial)
                .mask { fade(solidUntil: 0.3, clearAt: 0.78) }
            LinearGradient(stops: [.init(color: SceneColor.skyTop, location: 0),
                                   .init(color: SceneColor.skyTop, location: 0.26),
                                   .init(color: SceneColor.skyTop.opacity(0.86), location: 0.42),
                                   .init(color: SceneColor.skyTop.opacity(0.6), location: 0.58),
                                   .init(color: SceneColor.skyTop.opacity(0.34), location: 0.74),
                                   .init(color: SceneColor.skyTop.opacity(0.12), location: 0.9),
                                   .init(color: SceneColor.skyTop.opacity(0), location: 1)],
                           startPoint: .top, endPoint: .bottom)
        }
        .overlay(alignment: .topTrailing) { MapleCorner() }
        .ignoresSafeArea(edges: .top)
        .allowsHitTesting(false)
    }

    private func fade(solidUntil: CGFloat, clearAt: CGFloat) -> some View {
        LinearGradient(stops: [.init(color: .black, location: 0), .init(color: .black, location: solidUntil),
                               .init(color: .clear, location: clearAt)],
                       startPoint: .top, endPoint: .bottom)
    }
}

extension EnvironmentValues {
    /// Height of the floating tab bar, which screens keep their content clear of.
    @Entry var bottomBarInset: CGFloat = 0
}

#Preview {
    NavigationStack {
        ChoppyScreen("Wortschatz", subtitle: Text("Woche 3 · Essen und Trinken"), showsBack: true) {
            ScrollView {
                PaperCard { Text("Inhalt") }.padding(Spacing.l)
            }
        }
    }
}
