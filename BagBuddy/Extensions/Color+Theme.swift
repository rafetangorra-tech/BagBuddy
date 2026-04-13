import SwiftUI

extension Color {
    // MARK: - Bag Buddy Brand Colors

    /// Primary brand red — #E43945
    static let bbAccent        = Color(hex: "#E43945")
    /// Dimmed version of brand red for inactive states
    static let bbAccentDim     = Color(hex: "#B02D38")

    // MARK: - Background & Surfaces

    static let bbBackground    = Color(hex: "#FFFFFF")
    static let bbSurface       = Color(hex: "#FAFAFA")
    static let bbSurfaceRaised = Color(hex: "#F2F2F2")
    static let bbBorder        = Color(hex: "#EEEEEE")

    // MARK: - Text

    static let bbTextPrimary   = Color(hex: "#111111")
    static let bbTextSecondary = Color(hex: "#999999")

    // MARK: - Combo Chip Colors

    static let bbStrikeChip    = Color(hex: "#F5F5F5")
    static let bbDefenseChip   = Color(hex: "#FFF0F1")  // faint red tint for defense
    static let bbSeparator     = Color(hex: "#EEEEEE")
}

// MARK: - Hex Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int & 0xFF0000) >> 16) / 255
        let g = Double((int & 0x00FF00) >> 8)  / 255
        let b = Double(int & 0x0000FF)          / 255
        self.init(red: r, green: g, blue: b)
    }
}
