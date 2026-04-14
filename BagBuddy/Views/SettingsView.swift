import SwiftUI

struct SettingsView: View {
    @ObservedObject var vm: SessionViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bbBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {

                        // ROUNDS
                        settingsSection(title: "ROUNDS") {
                            stepperRow(label: "Number of Rounds",
                                       value: $vm.config.numberOfRounds,
                                       range: 1...12)
                        }

                        // TIMING
                        settingsSection(title: "TIMING") {
                            VStack(spacing: 16) {
                                durationRow(label: "Round Duration",
                                            seconds: $vm.config.roundDurationSeconds,
                                            step: 30, range: 30...600)
                                divider
                                durationRow(label: "Rest Duration",
                                            seconds: $vm.config.restDurationSeconds,
                                            step: 15, range: 15...300)
                            }
                        }

                        // PACING
                        settingsSection(title: "PACING") {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Combo Pacing")
                                        .font(.bbBody)
                                        .foregroundColor(.bbTextPrimary)
                                    Spacer()
                                }
                                HStack(spacing: 0) {
                                    ForEach(PacingPreset.allCases) { preset in
                                        Button {
                                            vm.config.pacing = preset
                                        } label: {
                                            Text(preset.displayName.uppercased())
                                                .font(.bbLabel)
                                                .kerning(1)
                                                .foregroundColor(vm.config.pacing == preset ? .white : .bbTextSecondary)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .background(vm.config.pacing == preset ? Color.bbAccent : Color.bbSurfaceRaised)
                                        }
                                        .buttonStyle(.plain)
                                        .animation(.easeInOut(duration: 0.15), value: vm.config.pacing)

                                        if preset != PacingPreset.allCases.last {
                                            Rectangle().fill(Color.bbBorder).frame(width: 1)
                                        }
                                    }
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .stroke(Color.bbBorder, lineWidth: 1)
                                )

                                Text("Controls the execution window between combos")
                                    .font(.bbCaption)
                                    .foregroundColor(.bbTextSecondary)
                            }
                        }

                        // DRILL
                        settingsSection(title: "DRILL MODE") {
                            VStack(spacing: 16) {
                                durationRow(label: "Drill Duration",
                                            seconds: $vm.config.drillDurationSeconds,
                                            step: 15, range: 30...120)
                                divider
                                durationRow(label: "Audio Replay Interval",
                                            seconds: $vm.config.drillReplayIntervalSeconds,
                                            step: 5, range: 10...30)
                            }
                        }

                        // AUDIO
                        settingsSection(title: "AUDIO") {
                            VStack(spacing: 16) {
                                Toggle(isOn: $vm.config.backgroundMusicEnabled) {
                                    Text("Background Music")
                                        .font(.bbBody)
                                        .foregroundColor(.bbTextPrimary)
                                }
                                .tint(.bbAccent)

                                divider

                                warningTimePicker
                            }
                        }

                        // HAPTICS
                        settingsSection(title: "HAPTICS") {
                            Toggle(isOn: $vm.config.hapticsEnabled) {
                                Text("Round Vibration")
                                    .font(.bbBody)
                                    .foregroundColor(.bbTextPrimary)
                            }
                            .tint(.bbAccent)
                        }

                        // NOTIFICATIONS
                        settingsSection(title: "NOTIFICATIONS") {
                            VStack(alignment: .leading, spacing: 8) {
                                Toggle(isOn: $vm.config.notificationsEnabled) {
                                    Text("Daily Training Reminder")
                                        .font(.bbBody)
                                        .foregroundColor(.bbTextPrimary)
                                }
                                .tint(.bbAccent)
                                Text("Your coach will check in every day at 5 PM.")
                                    .font(.bbCaption)
                                    .foregroundColor(.bbTextSecondary)
                            }
                        }

                        // Reset
                        Button {
                            vm.config = .default
                        } label: {
                            Text("RESET TO DEFAULTS")
                                .font(.bbLabel)
                                .kerning(2)
                                .foregroundColor(.bbTextSecondary)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 8)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("SETTINGS")
                        .font(.bbHeadline)
                        .foregroundColor(.bbTextPrimary)
                        .kerning(2)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("DONE") { dismiss() }
                        .font(.bbLabel)
                        .foregroundColor(.bbAccent)
                }
            }
            .toolbarBackground(Color.bbBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.light)
    }

    // MARK: - Warning Time Picker

    private static let warningOptions: [(label: String, value: Int)] = [
        ("OFF", 0), ("10s", 10), ("15s", 15), ("30s", 30)
    ]

    private var warningTimePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Round Warning Bell")
                    .font(.bbBody)
                    .foregroundColor(.bbTextPrimary)
                Spacer()
            }
            HStack(spacing: 0) {
                ForEach(Self.warningOptions, id: \.value) { option in
                    Button {
                        vm.config.warningTimeSeconds = option.value
                    } label: {
                        Text(option.label)
                            .font(.bbLabel)
                            .kerning(1)
                            .foregroundColor(vm.config.warningTimeSeconds == option.value ? .white : .bbTextSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(vm.config.warningTimeSeconds == option.value ? Color.bbAccent : Color.bbSurfaceRaised)
                    }
                    .buttonStyle(.plain)
                    .animation(.easeInOut(duration: 0.15), value: vm.config.warningTimeSeconds)

                    if option.value != Self.warningOptions.last?.value {
                        Rectangle().fill(Color.bbBorder).frame(width: 1)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(Color.bbBorder, lineWidth: 1)
            )
            Text(vm.config.warningTimeSeconds == 0
                    ? "Warning bell is off."
                    : "Plays a warning bell \(vm.config.warningTimeSeconds)s before round end.")
                .font(.bbCaption)
                .foregroundColor(.bbTextSecondary)
        }
    }

    // MARK: - Building Blocks

    private var divider: some View {
        Rectangle()
            .fill(Color.bbBorder)
            .frame(height: 1)
    }

    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.bbLabel)
                .foregroundColor(.bbTextSecondary)
                .kerning(2)

            content()
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.bbSurface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color.bbBorder, lineWidth: 1)
                        )
                )
        }
    }

    private func stepperRow(label: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        HStack {
            Text(label)
                .font(.bbBody)
                .foregroundColor(.bbTextPrimary)
            Spacer()
            Stepper("\(value.wrappedValue)", value: value, in: range)
                .labelsHidden()
            Text("\(value.wrappedValue)")
                .font(.bbHeadline)
                .foregroundColor(.bbAccent)
                .frame(width: 36, alignment: .trailing)
        }
    }

    private func durationRow(label: String, seconds: Binding<Int>, step: Int, range: ClosedRange<Int>) -> some View {
        HStack {
            Text(label)
                .font(.bbBody)
                .foregroundColor(.bbTextPrimary)
            Spacer()
            Stepper(
                formatTime(seconds.wrappedValue),
                onIncrement: { seconds.wrappedValue = min(seconds.wrappedValue + step, range.upperBound) },
                onDecrement: { seconds.wrappedValue = max(seconds.wrappedValue - step, range.lowerBound) }
            )
            .labelsHidden()

            Text(formatTime(seconds.wrappedValue))
                .font(.bbHeadline)
                .foregroundColor(.bbAccent)
                .frame(width: 56, alignment: .trailing)
        }
    }

    private func formatTime(_ s: Int) -> String {
        String(format: "%d:%02d", s / 60, s % 60)
    }
}
