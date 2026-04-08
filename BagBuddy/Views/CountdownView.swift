import SwiftUI

struct CountdownView: View {
    let secondsRemaining: Int

    private var displayText: String {
        secondsRemaining > 0 ? "\(secondsRemaining)" : "FIGHT"
    }

    var body: some View {
        ZStack {
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
        }
    }
}
