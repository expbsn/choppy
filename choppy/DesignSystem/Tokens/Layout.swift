import SwiftUI

/// Spacing scale. Use these instead of literal paddings.
enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let s: CGFloat = 12
    static let m: CGFloat = 16
    /// Side margin of content that sits directly on the night background.
    static let l: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

/// Corner radius. The design is rectangular: planks, paper and tiles only get a hint of rounding.
enum Radius {
    static let s: CGFloat = 2
}
