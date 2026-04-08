import SwiftUI

struct HomeView: View {
    @ObservedObject var vm: SessionViewModel
    @State private var showSettings = false

    var body: some View {
        ZStack {
            Color.bbBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                header
                    .padding(.top, 60)

                Spacer()

                // Difficulty picker
                VStack(alignment: .leading, spacing: 10) {
                    sectionLabel("DIFFICULTY")
                    DifficultyPickerView(selected: $vm.config.difficulty)
                        .onChange(of: vm.config.difficulty) { _, newLevel in
                            vm.config.bpm = newLevel.defaultBPM
                        }
                }
                .padding(.horizontal, 28)

                Spacer()

                // Session summary
                sessionSummary
                    .padding(.horizontal, 28)

                Spacer()

                // Start button
                startButton
                    .padding(.horizontal, 28)
                    .padding(.bottom, 50)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(vm: vm)
        }
    }

    // MARK: - Sub-Views

    private var header: some View {
        VStack(spacing: 4) {
            Text("BAG")
                .font(.bbDisplay)
                .foregroundColor(.bbTextPrimary)
                .kerning(-1)
            Text("BUDDY")
                .font(.bbDisplay)
                .foregroundColor(.bbAccent)
                .kerning(-1)
        }
    }

    private var sessionSummary: some View {
        Button {
            showSettings = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    sectionLabel("SESSION")
                    HStack(spacing: 20) {
                        statItem(value: "\(vm.config.numberOfRounds)", label: "ROUNDS")
                        statItem(value: formatTime(vm.config.roundDurationSeconds), label: "WORK")
                        statItem(value: formatTime(vm.config.restDurationSeconds), label: "REST")
                        statItem(value: "\(Int(vm.config.bpm))", label: "BPM")
                    }
                }
                Spacer()
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.bbTextSecondary)
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.bbSurface)
            )
        }
        .buttonStyle(.plain)
    }

    private var startButton: some View {
        Button {
            vm.startSession()
        } label: {
            Text("START SESSION")
                .font(.bbHeadline)
                .kerning(3)
                .foregroundColor(.bbTextPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.bbAccent)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.bbLabel)
            .foregroundColor(.bbTextSecondary)
            .kerning(2)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.bbHeadline)
                .foregroundColor(.bbTextPrimary)
            Text(label)
                .font(.bbLabel)
                .foregroundColor(.bbTextSecondary)
                .kerning(1)
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
