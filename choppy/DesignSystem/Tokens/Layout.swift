import SwiftUI

/// Spacing scale. Use these instead of literal paddings.
enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let s: CGFloat = 12
    static let m: CGFloat = 16
    static let l: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

/// Corner radius scale.
enum Radius {
    static let s: CGFloat = 8
    static let m: CGFloat = 14
    static let l: CGFloat = 22
}

extension View {
    /// Soft, warm shadow used for paper elements lying on the background.
    func paperShadow(lifted: Bool = false) -> some View {
        shadow(color: Color.woodDark.opacity(lifted ? 0.22 : 0.12), radius: lifted ? 10 : 4, x: 0, y: lifted ? 6 : 2)
    }
}
