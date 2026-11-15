import SwiftUI

/// The four top-level areas of Choppy.
enum RootTab: String, CaseIterable, Identifiable {
    case learn, games, path, pair

    var id: Self { self }

    var title: LocalizedStringKey {
        switch self {
        case .learn: "Lernen"
        case .games: "Spiele"
        case .path: "Pfad"
        case .pair: "Wir"
        }
    }

    var systemImage: String {
        switch self {
        case .learn: "book.closed.fill"
        case .games: "gamecontroller.fill"
        case .path: "pawprint.fill"
        case .pair: "person.2.fill"
        }
    }
}

/// Root container with the bamboo tab bar. All tabs stay alive, so each keeps
/// its navigation stack and scroll position when switching.
struct RootTabView: View {
    @State private var selection: RootTab = .learn
    @State private var barHeight: CGFloat = 0
    @State private var windowSize: CGSize?

    var body: some View {
        ZStack {
            AppBackground()
                // Size plus safe areas, so patterns cover the whole screen down to the bottom edge.
                .onGeometryChange(for: CGSize.self) { proxy in
                    CGSize(width: proxy.size.width + proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing,
                           height: proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom)
                } action: { windowSize = $0 }
            ForEach(RootTab.allCases) { tab in
                let isSelected = tab == selection
                content(for: tab)
                    .opacity(isSelected ? 1 : 0)
                    .allowsHitTesting(isSelected)
                    .accessibilityHidden(!isSelected)
            }
        }
        // Screens add this as bottom safe-area padding (see ChoppyScreen), so scroll views end above the bamboo.
        .environment(\.bottomBarInset, barHeight)
        .environment(\.windowSize, windowSize)
        .overlay(alignment: .bottom) {
            BambooTabBar(tabs: RootTab.allCases, selection: $selection, title: \.title, systemImage: \.systemImage)
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { barHeight = $0 }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .tint(.accent)
    }

    @ViewBuilder
    private func content(for tab: RootTab) -> some View {
        switch tab {
        case .learn: LearnView()
        case .games: GamesView()
        case .path: PathView()
        case .pair: PairView()
        }
    }
}

#Preview {
    RootTabView()
}
