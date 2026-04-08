import SwiftUI

struct SessionView: View {
    @ObservedObject var vm: SessionViewModel
    let roundNumber: Int
    let secondsRemaining: Int

    var body: some View {
        ZStack {
            Color.bbBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                topBar
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                Spacer()

                // Combo area
                if let combo = vm.currentCombo {
                    VStack(spacing: 32) {
                        ComboDisplayView(
                            combo: combo,
                            currentMoveIndex: vm.currentMoveIndex,
                            isExecutionWindow: vm.isExecutionWindow
                        )

                        executionLabel
                    }
                } else {
                    waitingLabel
                }

                Spacer()

                // Stop button
                stopButton
                    .padding(.horizontal, 28)
                    .padding(.bottom, 48)
            }
        }
        .onAppear  { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
    }

    // MARK: - Sub-Views

    private var topBar: some View {
        HStack {
            RoundBadgeView(current: roundNumber, total: vm.config.numberOfRounds)
            Spacer()
            RoundTimerView(secondsRemaining: secondsRemaining)
        }
    }

    private var executionLabel: some View {
        Group {
            if vm.isExecutionWindow {
                Text("GO")
                    .font(.bbHeadline)
                    .foregroundColor(.bbAccent)
                    .kerning(4)
                    .transition(.opacity)
            } else if vm.currentMoveIndex != nil {
                Text("LISTEN")
                    .font(.bbLabel)
                    .foregroundColor(.bbTextSecondary)
                    .kerning(3)
                    .transition(.opacity)
            } else {
                Color.clear.frame(height: 20)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: vm.isExecutionWindow)
    }

    private var waitingLabel: some View {
        Text("LOADING...")
            .font(.bbHeadline)
            .foregroundColor(.bbTextSecondary)
            .kerning(3)
    }

    private var stopButton: some View {
        Button {
            vm.stopSession()
        } label: {
            Text("STOP")
                .font(.bbLabel)
                .kerning(3)
                .foregroundColor(.bbTextSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.bbSurface)
                )
        }
        .buttonStyle(.plain)
    }
}
