import SwiftUI

struct BeatIndicatorView: View {
    let combo: Combo
    let currentMoveIndex: Int?
    let isExecutionWindow: Bool

    var body: some View {
        HStack(spacing: 10) {
            ForEach(Array(combo.moves.enumerated()), id: \.offset) { index, _ in
                let isActive = currentMoveIndex == index
                let isPast   = currentMoveIndex.map { index < $0 } ?? isExecutionWindow

                Circle()
                    .fill(dotColor(isActive: isActive, isPast: isPast))
                    .frame(width: 10, height: 10)
                    .scaleEffect(isActive ? 1.5 : 1.0)
                    .animation(.easeOut(duration: 0.08), value: currentMoveIndex)
            }
        }
    }

    private func dotColor(isActive: Bool, isPast: Bool) -> Color {
        if isActive { return .bbAccent }
        if isPast   { return .bbAccentDim }
        return .bbTextSecondary.opacity(0.4)
    }
}
