import SwiftUI

/// Frame for every screen: the shared app background and a custom header in place of the
/// system navigation bar – a small vermilion seal with the Japanese name, the title, and a brush stroke.
/// Push destinations pass `showsBack: true` to get the wooden back button.
struct ChoppyScreen<Content: View, Trailing: View>: View {
    let title: LocalizedStringKey
    var japanese: String?
    var showsBack: Bool
    @ViewBuilder var content: Content
    @ViewBuilder var trailing: Trailing

    @Environment(\.dismiss) private var dismiss
    @Environment(\.bottomBarInset) private var bottomBarInset

    init(_ title: LocalizedStringKey,
         japanese: String? = nil,
         showsBack: Bool = false,
         @ViewBuilder content: () -> Content,
         @ViewBuilder trailing: () -> Trailing) {
        self.title = title
        self.japanese = japanese
        self.showsBack = showsBack
        self.content = content()
        self.trailing = trailing()
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            // Scroll content ends above the tab bar, while the page background still runs underneath it.
            .contentMargins(.bottom, bottomBarInset, for: .scrollContent)
            .contentMargins(.bottom, bottomBarInset, for: .scrollIndicators)
            .safeAreaInset(edge: .top, spacing: 0) { header }
            .background { AppBackground() }
            .foregroundStyle(.ink)
            .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        VStack(spacing: Spacing.xs) {
            HStack(spacing: Spacing.s) {
                if showsBack {
                    WoodIconButton(systemImage: "chevron.left", label: "Zurück") { dismiss() }
                }
                if let japanese {
                    SealLabel(text: japanese)
                }
                Text(title)
                    .font(showsBack ? .choppyTitle : .choppyDisplay)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .accessibilityAddTraits(.isHeader)
                Spacer(minLength: 0)
                trailing
            }
            BrushStroke()
                .fill(Color.woodDark.opacity(0.55))
                .frame(height: 5)
        }
        .padding(.horizontal, Spacing.m)
        .padding(.top, Spacing.xxs)
        .padding(.bottom, Spacing.xs)
        // The same background as the page, so the pattern runs on seamlessly (both start at the screen's
        // top edge) while scrolled content disappears under the brush stroke.
        .background { AppBackground() }
    }
}

extension EnvironmentValues {
    /// Height of the floating tab bar, which screens keep their content clear of.
    @Entry var bottomBarInset: CGFloat = 0
}

extension ChoppyScreen where Trailing == EmptyView {
    init(_ title: LocalizedStringKey, japanese: String? = nil, showsBack: Bool = false, @ViewBuilder content: () -> Content) {
        self.init(title, japanese: japanese, showsBack: showsBack, content: content, trailing: { EmptyView() })
    }
}

/// A small filled vermilion seal with up to two characters stacked vertically, used next to titles.
struct SealLabel: View {
    var text: String
    var size: CGFloat = 34

    var body: some View {
        let chars = Array(text.prefix(2)).map(String.init)
        VStack(spacing: -size * 0.08) {
            ForEach(Array(chars.enumerated()), id: \.offset) { _, char in
                Text(char).font(.choppyJapanese(size * (chars.count > 1 ? 0.36 : 0.56), weight: .bold))
            }
        }
        .foregroundStyle(.card)
        .frame(width: size, height: size * (chars.count > 1 ? 1.25 : 1))
        .background(Color.hanko, in: .rect(cornerRadius: size * 0.14))
        .rotationEffect(.degrees(-3))
        .accessibilityHidden(true)
    }
}

/// Round wooden button with an SF Symbol, used for back and header actions.
struct WoodIconButton: View {
    var systemImage: String
    var label: LocalizedStringKey
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.woodDark)
                .frame(width: 38, height: 38)
                .background(Color.card, in: .circle)
                .overlay { Circle().strokeBorder(Color.wood, lineWidth: 1.5) }
                .paperShadow()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(label))
    }
}

/// A horizontal ink brush stroke: thick in the middle, tapering to dry ends.
struct BrushStroke: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let w = rect.width, h = rect.height, mid = rect.midY
            path.move(to: CGPoint(x: rect.minX, y: mid + h * 0.1))
            path.addCurve(to: CGPoint(x: rect.minX + w * 0.55, y: rect.minY),
                          control1: CGPoint(x: rect.minX + w * 0.12, y: mid - h * 0.3),
                          control2: CGPoint(x: rect.minX + w * 0.3, y: rect.minY))
            path.addCurve(to: CGPoint(x: rect.maxX, y: mid - h * 0.15),
                          control1: CGPoint(x: rect.minX + w * 0.8, y: rect.minY),
                          control2: CGPoint(x: rect.maxX - w * 0.06, y: mid - h * 0.3))
            path.addCurve(to: CGPoint(x: rect.minX + w * 0.45, y: rect.maxY),
                          control1: CGPoint(x: rect.maxX - w * 0.1, y: mid + h * 0.2),
                          control2: CGPoint(x: rect.minX + w * 0.7, y: rect.maxY))
            path.addCurve(to: CGPoint(x: rect.minX, y: mid + h * 0.1),
                          control1: CGPoint(x: rect.minX + w * 0.2, y: rect.maxY),
                          control2: CGPoint(x: rect.minX + w * 0.05, y: mid + h * 0.4))
            path.closeSubpath()
        }
    }
}

#Preview {
    NavigationStack {
        ChoppyScreen("Lernen", japanese: "学ぶ") {
            ScrollView {
                PaperCard { Text("Inhalt") }.padding()
            }
        } trailing: {
            WoodIconButton(systemImage: "gearshape", label: "Einstellungen") {}
        }
    }
}
