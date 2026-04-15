import SwiftUI

struct HistoryView: View {
    @State private var records: [WorkoutRecord] = []
    @State private var streak: Int = 0

    var body: some View {
        ZStack {
            Color.bbBackground.ignoresSafeArea()

            if records.isEmpty {
                emptyState
            } else {
                recordsList
            }
        }
        .onAppear {
            records = HistoryStore.shared.records
            streak = HistoryStore.shared.currentStreak
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.boxing")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(.bbBorder)

            Text("NO SESSIONS YET")
                .font(.custom("Oswald-SemiBold", size: 18))
                .foregroundColor(.bbTextSecondary)
                .kerning(2)

            Text("Complete a workout and it'll show up here.")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.bbTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    // MARK: - Records List

    private var recordsList: some View {
        ScrollView {
            VStack(spacing: 12) {
                if streak > 0 {
                    streakBanner
                }
                ForEach(records) { record in
                    recordCard(record)
                }
            }
            .padding(16)
        }
    }

    // MARK: - Streak Banner

    private var streakBanner: some View {
        HStack(spacing: 14) {
            Text("🔥")
                .font(.system(size: 32))

            VStack(alignment: .leading, spacing: 2) {
                Text("\(streak) DAY STREAK")
                    .font(.custom("Oswald-SemiBold", size: 20))
                    .foregroundColor(.bbTextPrimary)
                    .kerning(1)
                Text(streak == 1 ? "You trained today. Keep it going." : "You've shown up \(streak) days in a row.")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.bbTextSecondary)
            }
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.bbSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.bbAccent.opacity(0.4), lineWidth: 1)
                )
        )
    }

    private func recordCard(_ record: WorkoutRecord) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(record.discipline.uppercased())
                        .font(.custom("Oswald-SemiBold", size: 16))
                        .foregroundColor(.bbTextPrimary)
                        .kerning(1)
                    Text(record.mode.uppercased())
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.bbAccent)
                        .kerning(1.5)
                }
                Spacer()
                Text(record.formattedDate)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.bbTextSecondary)
            }

            Rectangle()
                .fill(Color.bbBorder)
                .frame(height: 1)

            HStack(spacing: 0) {
                statCell(value: "\(record.numberOfRounds)", label: "ROUNDS")
                statCell(value: formatTime(record.roundDurationSeconds), label: "WORK")
                statCell(value: "\(record.combosDelivered)", label: "COMBOS")
                statCell(value: record.formattedDuration, label: "TOTAL")
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.bbSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.bbBorder, lineWidth: 1)
                )
        )
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.custom("Oswald-SemiBold", size: 15))
                .foregroundColor(.bbTextPrimary)
                .minimumScaleFactor(0.8)
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
