import SwiftUI

struct CompleteView: View {
    @ObservedObject var vm: SessionViewModel

    private let closingLines = [
        "That's how it's done.",
        "Your opponent didn't work that hard today.",
        "Every round counts. You put them in.",
        "That's the work. Now recover.",
        "Drillers make killers. Proven.",
        "You showed up. That's already half the battle.",
        "Same time tomorrow.",
    ]

    private var closingLine: String {
        closingLines.randomElement() ?? closingLines[0]
    }

    private var totalWorkSeconds: Int {
        vm.config.roundDurationSeconds * vm.config.numberOfRounds
    }

    private var formattedTotalTime: String {
        let total = (vm.config.roundDurationSeconds * vm.config.numberOfRounds)
            + (vm.config.restDurationSeconds * max(0, vm.config.numberOfRounds - 1))
        let m = total / 60
        let s = total % 60
        return s == 0 ? "\(m)m" : "\(m)m \(s)s"
    }

    private var estimatedCalories: Int {
        let calPerMin: Double = vm.config.discipline == .muayThai ? 11 : 10
        let mins = Double(totalWorkSeconds) / 60.0
        return Int(calPerMin * mins)
    }

    private var shareText: String {
        """
        Just finished a Bag Buddy session 🥊
        \(vm.config.discipline.displayName.uppercased()) · \(vm.config.mode.displayName.uppercased())
        \(vm.config.numberOfRounds) rounds · \(formatTime(vm.config.roundDurationSeconds)) work · \(vm.combosDelivered) combos
        ~\(estimatedCalories) cal · \(formattedTotalTime) total
        #BagBuddy #Boxing #MartialArts
        """
    }

    var body: some View {
        ZStack {
            Color.bbBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Icon
                ZStack {
                    Circle()
                        .fill(Color.bbAccent.opacity(0.08))
                        .frame(width: 100, height: 100)
                    Image(systemName: "checkmark")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(.bbAccent)
                }
                .padding(.bottom, 28)

                // Header
                VStack(spacing: 4) {
                    Text("SESSION")
                        .font(.bbDisplay)
                        .foregroundColor(.bbTextPrimary)
                        .kerning(-1)
                    Text("COMPLETE")
                        .font(.bbDisplay)
                        .foregroundColor(.bbAccent)
                        .kerning(-1)
                }
                .padding(.bottom, 8)

                // Discipline + mode
                Text("\(vm.config.discipline.displayName.uppercased()) · \(vm.config.mode.displayName.uppercased())")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.bbTextSecondary)
                    .kerning(2)
                    .padding(.bottom, 36)

                // Stats grid
                HStack(spacing: 0) {
                    statItem(value: "\(vm.config.numberOfRounds)", label: "ROUNDS")
                    divider
                    statItem(value: "\(vm.combosDelivered)", label: "COMBOS")
                    divider
                    statItem(value: "~\(estimatedCalories)", label: "CAL")
                    divider
                    statItem(value: formattedTotalTime, label: "TIME")
                }
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.bbSurface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color.bbBorder, lineWidth: 1)
                        )
                )
                .padding(.horizontal, 28)
                .padding(.bottom, 28)

                // Closing line
                Text(closingLine.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.bbTextSecondary)
                    .kerning(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    // Share
                    ShareLink(item: shareText) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14, weight: .semibold))
                            Text("SHARE WORKOUT")
                                .font(.custom("Oswald-SemiBold", size: 16))
                                .kerning(2)
                        }
                        .foregroundColor(.bbAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Color.bbAccent.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .stroke(Color.bbAccent.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }

                    // Done
                    Button { vm.stopSession() } label: {
                        Text("DONE")
                            .font(.custom("Oswald-SemiBold", size: 18))
                            .kerning(3)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(Color.bbAccent)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 50)
            }
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.bbBorder)
            .frame(width: 1, height: 36)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.custom("Oswald-SemiBold", size: 22))
                .foregroundColor(.bbTextPrimary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.bbTextSecondary)
                .kerning(1)
        }
        .frame(maxWidth: .infinity)
    }

    private func formatTime(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
