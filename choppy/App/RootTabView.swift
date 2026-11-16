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
        case .learn: "book"
        case .games: "gamecontroller"
        case .path: "point.bottomleft.forward.to.point.topright.scurvepath"
        case .pair: "person.2"
        }
    }
}

/// Root container with the lantern tab bar. All tabs stay alive, so each keeps
/// its navigation stack and scroll position when switching.
struct RootTabView: View {
    @State private var selection: RootTab = .learn
    @State private var barHeight: CGFloat = 0
    @State private var window = WindowMetrics()

    private nonisolated struct WindowMetrics: Equatable, Sendable {
        var size: CGSize?
        var safeAreaBottom: CGFloat = 0
    }

    var body: some View {
        ZStack {
            AppBackground()
                // Size plus safe areas, so the scene covers the whole screen down to the bottom edge.
                .onGeometryChange(for: WindowMetrics.self) { proxy in
                    WindowMetrics(
                        size: CGSize(width: proxy.size.width + proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing,
                                     height: proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom),
                        safeAreaBottom: proxy.safeAreaInsets.bottom)
                } action: { window = $0 }
            ForEach(RootTab.allCases) { tab in
                let isSelected = tab == selection
                content(for: tab)
                    .opacity(isSelected ? 1 : 0)
                    .allowsHitTesting(isSelected)
                    .accessibilityHidden(!isSelected)
            }
        }
        // Screens add this as bottom content margin (see ChoppyScreen), so scroll views end above the tile edge.
        .environment(\.bottomBarInset, barHeight)
        .environment(\.windowSize, window.size)
        .environment(\.sceneGroundY, window.size.map { $0.height - barHeight - window.safeAreaBottom })
        .overlay(alignment: .bottom) {
            LanternTabBar(tabs: RootTab.allCases, selection: $selection, title: \.title, systemImage: \.systemImage,
                          safeAreaBottom: window.safeAreaBottom)
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { barHeight = $0 }
        }
        .onChange(of: selection) { LanternMotion.shared.push() }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .tint(.akari400)
    }

    @ViewBuilder
    private func content(for tab: RootTab) -> some View {
        switch tab {
        case .learn: TodayView()
        case .games: GamesView()
        case .path: PathView()
        case .pair: PairView()
        }
    }
}

#Preview {
    RootTabView()
}
