import SwiftUI

struct ComboDisplayView: View {
    let combo: Combo
    let currentMoveIndex: Int?
    let isExecutionWindow: Bool

    var body: some View {
        VStack(spacing: 24) {
            // Move chips row
            moveChipsRow

            // Beat indicator dots
            BeatIndicatorView(
                combo: combo,
                currentMoveIndex: currentMoveIndex,
                isExecutionWindow: isExecutionWindow
            )

            // Full combo text below
            Text(combo.displayText)
                .font(.bbLabel)
                .foregroundColor(.bbTextSecondary)
                .multilineTextAlignment(.center)
                .kerning(1.5)
                .textCase(.uppercase)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Move Chips

    private var moveChipsRow: some View {
        let moves = combo.moves
        return FlowLayout(spacing: 8) {
            ForEach(Array(moves.enumerated()), id: \.offset) { index, move in
                MoveChipView(
                    move: move,
                    isActive: currentMoveIndex == index,
                    isPast: currentMoveIndex.map { index < $0 } ?? isExecutionWindow
                )
            }
        }
    }
}

// MARK: - Move Chip

struct MoveChipView: View {
    let move: Move
    let isActive: Bool
    let isPast: Bool

    var body: some View {
        Text(move.displayName)
            .font(move.type == .strike ? .bbComboStrike : .bbComboDefense)
            .foregroundColor(textColor)
            .padding(.horizontal, move.type == .strike ? 14 : 12)
            .padding(.vertical, move.type == .strike ? 8 : 6)
            .background(
                RoundedRectangle(cornerRadius: move.type == .strike ? 6 : 20, style: .continuous)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: move.type == .strike ? 6 : 20, style: .continuous)
                    .stroke(borderColor, lineWidth: isActive ? 1.5 : 0)
            )
            .scaleEffect(isActive ? 1.08 : 1.0)
            .animation(.easeOut(duration: 0.08), value: isActive)
    }

    private var textColor: Color {
        if isActive { return .bbTextPrimary }
        if isPast   { return .bbTextSecondary }
        return .bbTextSecondary.opacity(0.5)
    }

    private var backgroundColor: Color {
        if isActive {
            return move.type == .strike ? .bbAccent : .bbDefenseChip
        }
        return move.type == .strike ? .bbStrikeChip : .bbDefenseChip.opacity(0.6)
    }

    private var borderColor: Color {
        isActive ? .bbAccent : .clear
    }
}

// MARK: - Simple Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentY += rowHeight + spacing
                totalHeight = currentY
                currentX = 0
                rowHeight = 0
            }
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        totalHeight += rowHeight

        return CGSize(width: maxWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX && currentX > bounds.minX {
                currentY += rowHeight + spacing
                currentX = bounds.minX
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
