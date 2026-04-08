import SwiftUI

struct SettingsView: View {
    @ObservedObject var vm: SessionViewModel
    @Environment(\.dismiss) private var dismiss

    private var bpmRange: ClosedRange<Double> {
        vm.config.difficulty.bpmRange
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bbBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {

                        // ROUNDS
                        settingsSection(title: "ROUNDS") {
                            stepperRow(
                                label: "Number of Rounds",
                                value: $vm.config.numberOfRounds,
                                range: 1...12
                            )
                        }

                        // TIMING
                        settingsSection(title: "TIMING") {
                            VStack(spacing: 16) {
                                durationRow(
                                    label: "Round Duration",
                                    seconds: $vm.config.roundDurationSeconds,
                                    step: 30,
                                    range: 30...600
                                )
                                Divider().background(Color.bbSeparator)
                                durationRow(
                                    label: "Rest Duration",
                                    seconds: $vm.config.restDurationSeconds,
                                    step: 15,
                                    range: 15...300
                                )
                            }
                        }

                        // TEMPO
                        settingsSection(title: "TEMPO") {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("BPM")
                                        .font(.bbBody)
                                        .foregroundColor(.bbTextPrimary)
                                    Spacer()
                                    Text("\(Int(vm.config.bpm))")
                                        .font(.bbHeadline)
                                        .foregroundColor(.bbAccent)
                                }
                                Slider(
                                    value: $vm.config.bpm,
                                    in: bpmRange,
                                    step: 1
                                )
                                .accentColor(.bbAccent)

                                Text("Range for \(vm.config.difficulty.rawValue): \(Int(bpmRange.lowerBound))–\(Int(bpmRange.upperBound)) BPM")
                                    .font(.bbLabel)
                                    .foregroundColor(.bbTextSecondary)
                                    .kerning(0.5)
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
        .presentationBackground(Color.bbBackground)
        .preferredColorScheme(.dark)
    }

    // MARK: - Building Blocks

    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.bbLabel)
                .foregroundColor(.bbTextSecondary)
                .kerning(2)

            VStack(spacing: 0) {
                content()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.bbSurface)
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
                .foregroundColor(.bbTextPrimary)

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
