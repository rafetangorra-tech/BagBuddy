import SwiftUI

extension Color {
    static let bbBackground    = Color(hex: "#1A1A1A")
    static let bbSurface       = Color(hex: "#252525")
    static let bbSurfaceRaised = Color(hex: "#2E2E2E")
    static let bbAccent        = Color(hex: "#C0392B")
    static let bbAccentDim     = Color(hex: "#7B241C")
    static let bbTextPrimary   = Color(hex: "#E8E0D5")
    static let bbTextSecondary = Color(hex: "#8A7F75")
    static let bbDefenseChip   = Color(hex: "#3A3228")
    static let bbStrikeChip    = Color(hex: "#2A2A2A")
    static let bbSeparator     = Color(hex: "#8A7F75").opacity(0.3)
}

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
