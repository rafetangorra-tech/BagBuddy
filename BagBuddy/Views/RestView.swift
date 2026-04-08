import SwiftUI

struct RestView: View {
    @ObservedObject var vm: SessionViewModel
    let afterRound: Int
    let secondsRemaining: Int

    var body: some View {
        ZStack {
            Color.bbBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // REST label
                VStack(spacing: 8) {
                    Text("REST")
                        .font(.bbDisplay)
                        .foregroundColor(.bbAccent)
                        .kerning(-1)

                    RoundTimerView(secondsRemaining: secondsRemaining)
                }

                Spacer()

                // Next round info
                if afterRound < vm.config.numberOfRounds {
                    VStack(spacing: 6) {
                        Text("NEXT")
                            .font(.bbLabel)
                            .foregroundColor(.bbTextSecondary)
                            .kerning(3)

                        RoundBadgeView(
                            current: afterRound + 1,
                            total: vm.config.numberOfRounds,
                            prefix: "RND"
                        )
                    }
                    .padding(.bottom, 60)
                }

                // Stop button
                Button {
                    vm.stopSession()
                } label: {
                    Text("END SESSION")
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
                .padding(.horizontal, 28)
                .padding(.bottom, 48)
            }
        }
    }
}
