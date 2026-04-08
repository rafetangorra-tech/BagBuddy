import SwiftUI

struct RoundBadgeView: View {
    let current: Int
    let total: Int
    var prefix: String = "RND"

    var body: some View {
        HStack(spacing: 4) {
            Text("\(prefix) \(current)")
                .font(.bbLabel)
                .foregroundColor(.bbAccent)
                .kerning(2)
                .textCase(.uppercase)
            Text("/")
                .font(.bbLabel)
                .foregroundColor(.bbTextSecondary)
            Text("\(total)")
                .font(.bbLabel)
                .foregroundColor(.bbTextSecondary)
                .kerning(2)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(Color.bbSurface)
        )
    }
}
