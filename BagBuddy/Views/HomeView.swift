import SwiftUI

struct HomeView: View {
    @ObservedObject var vm: SessionViewModel
    var onStart: () -> Void = {}
    @State private var showSettings = false
    @State private var showInfo = false

    var body: some View {
        ZStack {
            Color.bbBackground.ignoresSafeArea()

            // Top buttons
            VStack {
                HStack {
                    // Info button — top-left
                    Button {
                        showInfo = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.bbTextSecondary)
                            .padding(16)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    // Settings button — top-right
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.bbTextSecondary)
                            .padding(16)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 52)
                Spacer()
            }

            // Main layout
            VStack(spacing: 0) {
                logoHeader
                    .padding(.top, 52)

                Spacer(minLength: 16)

                // Discipline selector
                VStack(alignment: .leading, spacing: 8) {
                    sectionLabel("DISCIPLINE")
                    disciplineSelector
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 16)

                // Mode selector
                VStack(alignment: .leading, spacing: 8) {
                    sectionLabel("MODE")
                    modeSelector
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 16)

                sessionSummary
                    .padding(.horizontal, 24)

                Spacer(minLength: 16)

                startButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 44)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(vm: vm)
        }
        .fullScreenCover(isPresented: $showInfo) {
            OnboardingView(includeHealthSlide: true) {
                showInfo = false
            }
        }
    }

    // MARK: - Logo Header

    private var logoHeader: some View {
        VStack(spacing: 6) {
            Image("BagBuddyLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 72)

            Text("BAG BUDDY")
                .font(.custom("Oswald-SemiBold", size: 26))
                .foregroundColor(.bbTextPrimary)
                .kerning(3)

            Text("BEEN HIT. STILL GRINNING.")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.bbTextSecondary)
                .kerning(2)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Discipline Selector

    private var disciplineSelector: some View {
        HStack(spacing: 0) {
            ForEach(Discipline.allCases) { discipline in
                Button {
                    vm.config.discipline = discipline
                } label: {
                    Text(discipline.displayName.uppercased())
                        .font(.bbLabel)
                        .kerning(1.5)
                        .foregroundColor(vm.config.discipline == discipline ? .white : .bbTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(vm.config.discipline == discipline ? Color.bbAccent : Color.bbSurface)
                }
                .buttonStyle(.plain)
                .animation(.easeInOut(duration: 0.15), value: vm.config.discipline)

                if discipline != Discipline.allCases.last {
                    Rectangle()
                        .fill(Color.bbBorder)
                        .frame(width: 1)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(Color.bbBorder, lineWidth: 1)
        )
    }

    // MARK: - Mode Selector

    private var modeSelector: some View {
        VStack(spacing: 6) {
            ForEach(WorkoutMode.allCases) { mode in
                Button {
                    vm.config.mode = mode
                } label: {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(vm.config.mode == mode ? Color.bbAccent : Color.bbBorder)
                            .frame(width: 9, height: 9)

                        VStack(alignment: .leading, spacing: 1) {
                            Text(mode.displayName.uppercased())
                                .font(.custom("Oswald-Medium", size: 16))
                                .foregroundColor(vm.config.mode == mode ? .bbTextPrimary : .bbTextSecondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)

                            Text(mode.description)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.bbTextSecondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(vm.config.mode == mode ? Color.bbAccent.opacity(0.06) : Color.bbSurface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(
                                        vm.config.mode == mode ? Color.bbAccent.opacity(0.3) : Color.bbBorder,
                                        lineWidth: 1
                                    )
                            )
                    )
                }
                .buttonStyle(.plain)
                .animation(.easeInOut(duration: 0.15), value: vm.config.mode)
            }
        }
    }

    // MARK: - Session Summary

    private var sessionSummary: some View {
        HStack(spacing: 0) {
            statItem(value: "\(vm.config.numberOfRounds)", label: "ROUNDS")
            dividerLine
            statItem(value: formatTime(vm.config.roundDurationSeconds), label: "WORK")
            dividerLine
            statItem(value: formatTime(vm.config.restDurationSeconds), label: "REST")
            dividerLine
            statItem(value: vm.config.pacing.displayName.uppercased(), label: "PACE")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.bbSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.bbBorder, lineWidth: 1)
                )
        )
    }

    private var dividerLine: some View {
        Rectangle()
            .fill(Color.bbBorder)
            .frame(width: 1, height: 28)
            .padding(.horizontal, 12)
    }

    // MARK: - Start Button

    private var startButton: some View {
        Button {
            onStart()
        } label: {
            Text("START SESSION")
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

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.bbLabel)
            .foregroundColor(.bbTextSecondary)
            .kerning(2)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.custom("Oswald-SemiBold", size: 16))
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
