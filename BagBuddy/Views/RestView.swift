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

                VStack(spacing: 12) {
                    Text("REST")
                        .font(.bbDisplay)
                        .foregroundColor(.bbAccent)
                        .kerning(-1)

                    RoundTimerView(secondsRemaining: secondsRemaining)
                }

                Spacer()

                if afterRound < vm.config.numberOfRounds {
                    VStack(spacing: 8) {
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
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .stroke(Color.bbBorder, lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 28)
                .padding(.bottom, 48)
            }
        }
    }
}
