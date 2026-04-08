import SwiftUI

struct DifficultyPickerView: View {
    @Binding var selected: DifficultyLevel

    var body: some View {
        HStack(spacing: 0) {
            ForEach(DifficultyLevel.allCases) { level in
                Button {
                    selected = level
                } label: {
                    Text(level.rawValue.uppercased())
                        .font(.bbLabel)
                        .kerning(1.5)
                        .foregroundColor(selected == level ? .bbTextPrimary : .bbTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selected == level
                                ? Color.bbAccent
                                : Color.bbSurface
                        )
                }
                .buttonStyle(.plain)

                if level != DifficultyLevel.allCases.last {
                    Rectangle()
                        .fill(Color.bbBackground)
                        .frame(width: 1)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(Color.bbSurface, lineWidth: 1)
        )
    }
}
