import SwiftUI

struct CountdownView: View {
    let secondsRemaining: Int
    var onStop: (() -> Void)? = nil

    private var displayText: String {
        secondsRemaining > 0 ? "\(secondsRemaining)" : "FIGHT"
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.bbBackground.ignoresSafeArea()

            VStack(spacing: 16) {
                Text(displayText)
                    .font(.bbDisplay)
                    .foregroundColor(secondsRemaining > 0 ? .bbTextPrimary : .bbAccent)
                    .kerning(-2)
                    .contentTransition(.numericText())
                    .animation(.easeOut(duration: 0.2), value: secondsRemaining)

                if secondsRemaining > 0 {
                    Text("GET READY")
                        .font(.bbLabel)
                        .foregroundColor(.bbTextSecondary)
                        .kerning(3)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if let onStop {
                Button(action: onStop) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.bbTextSecondary)
                        .padding(16)
                }
                .buttonStyle(.plain)
                .padding(.top, 52)
                .padding(.leading, 8)
            }
        }
    }
}
