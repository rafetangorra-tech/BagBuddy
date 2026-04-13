import SwiftUI

struct CompleteView: View {
    @ObservedObject var vm: SessionViewModel

    var body: some View {
        ZStack {
            Color.bbBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 6) {
                    Text("SESSION")
                        .font(.bbDisplay)
                        .foregroundColor(.bbTextPrimary)
                        .kerning(-1)
                    Text("COMPLETE")
                        .font(.bbDisplay)
                        .foregroundColor(.bbAccent)
                        .kerning(-1)
                }

                Spacer()

                HStack(spacing: 40) {
                    statItem(value: "\(vm.config.numberOfRounds)", label: "ROUNDS")
                    statItem(value: "\(vm.combosDelivered)", label: "COMBOS")
                }

                Spacer()

                Button {
                    vm.stopSession()
                } label: {
                    Text("DONE")
                        .font(.bbHeadline)
                        .kerning(3)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Color.bbAccent)
                        )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 28)
                .padding(.bottom, 50)
            }
        }
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.bbDisplay)
                .foregroundColor(.bbTextPrimary)
            Text(label)
                .font(.bbLabel)
                .foregroundColor(.bbTextSecondary)
                .kerning(2)
        }
    }
}
