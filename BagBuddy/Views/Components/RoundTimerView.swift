import SwiftUI

struct RoundTimerView: View {
    let secondsRemaining: Int

    private var minutes: Int { secondsRemaining / 60 }
    private var seconds: Int { secondsRemaining % 60 }

    var body: some View {
        Text(String(format: "%d:%02d", minutes, seconds))
            .font(.bbTimer)
            .foregroundColor(timerColor)
            .monospacedDigit()
    }

    private var timerColor: Color {
        secondsRemaining <= 10 ? .bbAccent : .bbTextPrimary
    }
}
