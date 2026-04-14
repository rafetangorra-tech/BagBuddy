import SwiftUI

struct SessionView: View {
    @ObservedObject var vm: SessionViewModel
    let roundNumber: Int
    let secondsRemaining: Int

    private var isDrillMode: Bool { vm.config.mode == .drill }

    private var timerProgress: Double {
        let total = vm.config.roundDurationSeconds
        guard total > 0 else { return 0 }
        return Double(secondsRemaining) / Double(total)
    }

    @State private var showExitAlert = false

    var body: some View {
        VStack(spacing: 0) {
            headerArea
            modePillsRow
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
            comboCard
                .padding(.horizontal, 16)
            timerBar
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 10)
            controlsRow
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bbBackground.ignoresSafeArea())
        .onAppear  { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
        .alert("End Workout?", isPresented: $showExitAlert) {
            Button("End Workout", role: .destructive) { vm.stopSession() }
            Button("Keep Going", role: .cancel) {}
        } message: {
            Text("Your session progress will not be saved.")
        }
    }

    // MARK: - Header

    private var headerArea: some View {
        HStack(spacing: 10) {
            Image("BagBuddyLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text("BAG BUDDY")
                    .font(.custom("Oswald-SemiBold", size: 22))
                    .foregroundColor(.bbAccent)
                    .kerning(2)
                Text(vm.config.discipline.displayName.uppercased())
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(Color(hex: "#BBBBBB"))
                    .kerning(3)
            }

            Spacer()

            // Round badge — keeps round number visible at a glance
            VStack(spacing: 1) {
                Text("ROUND")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundColor(.bbTextSecondary)
                    .kerning(1)
                Text("\(roundNumber) / \(vm.config.numberOfRounds)")
                    .font(.custom("Oswald-SemiBold", size: 16))
                    .foregroundColor(.bbTextPrimary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Mode Pills

    private var modePillsRow: some View {
        HStack(spacing: 6) {
            ForEach(WorkoutMode.allCases) { mode in
                Text(mode.pillLabel)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(mode == vm.config.mode ? .white : .bbTextSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(mode == vm.config.mode ? Color.bbAccent : Color(hex: "#F5F5F5"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(
                                        mode == vm.config.mode ? Color.bbAccent : Color.bbBorder,
                                        lineWidth: 1
                                    )
                            )
                    )
            }
        }
    }

    // MARK: - Combo Card

    private var comboCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.bbSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.bbBorder, lineWidth: 1)
                )

            Group {
                if let combo = vm.currentCombo {
                    comboCardContent(combo)
                        .id(combo.id)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .bottom)),
                            removal: .opacity
                        ))
                } else {
                    Text("READY")
                        .font(.bbHeadline)
                        .foregroundColor(.bbTextSecondary)
                        .kerning(3)
                }
            }
            .animation(.easeOut(duration: 0.2), value: vm.currentCombo?.id)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func comboCardContent(_ combo: Combo) -> some View {
        VStack(spacing: 6) {
            Spacer()

            // Combo code
            Text(combo.code)
                .font(.custom("Oswald-Medium", size: 12))
                .foregroundColor(.bbAccent)
                .kerning(2)

            // Combination display
            if isDrillMode {
                drillComboText(combo)
            } else {
                callOutComboText(combo)
            }

            // Expanded names subtitle
            Text(combo.expandedCombination)
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.bbTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.top, 4)

            // Drill countdown inside card
            if isDrillMode {
                drillCountdown
                    .padding(.top, 12)
            }

            Spacer()
        }
        .padding(16)
    }

    /// Call-out mode: defense segments smaller (30pt), strike segments larger (42pt)
    private func callOutComboText(_ combo: Combo) -> some View {
        VStack(spacing: 2) {
            ForEach(combo.segments.indices, id: \.self) { i in
                let seg = combo.segments[i]
                Text(seg.text)
                    .font(.custom("Oswald-SemiBold", size: seg.isDefense ? 30 : 42))
                    .foregroundColor(.bbTextPrimary)
                    .kerning(seg.isDefense ? 2 : 4)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
        }
    }

    /// Drill mode: all segments at 24pt (combos can be complex and multi-line)
    private func drillComboText(_ combo: Combo) -> some View {
        VStack(spacing: 2) {
            ForEach(combo.segments.indices, id: \.self) { i in
                let seg = combo.segments[i]
                Text(seg.text)
                    .font(.custom("Oswald-SemiBold", size: 24))
                    .foregroundColor(.bbTextPrimary)
                    .kerning(1)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
        }
    }

    // MARK: - Drill Countdown

    private var drillCountdown: some View {
        let remain = vm.drillSecondsRemaining
        let timeString = String(format: "%d:%02d", remain / 60, remain % 60)

        return HStack(alignment: .lastTextBaseline, spacing: 8) {
            Text(timeString)
                .font(.custom("Oswald-SemiBold", size: 32))
                .foregroundColor(.bbAccent)
            Text("remaining")
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(Color(hex: "#BBBBBB"))
        }
    }

    // MARK: - Timer Bar

    private var timerBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.bbBorder)
                    .frame(height: 3)

                Capsule()
                    .fill(Color.bbAccent)
                    .frame(width: max(0, geo.size.width * timerProgress), height: 3)
                    .animation(.linear(duration: 1.0), value: timerProgress)
            }
        }
        .frame(height: 3)
    }

    // MARK: - Controls

    private var controlsRow: some View {
        HStack(spacing: 16) {
            // Stop
            Button { showExitAlert = true } label: {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#F5F5F5"))
                        .overlay(Circle().stroke(Color.bbBorder, lineWidth: 1))
                        .frame(width: 40, height: 40)
                    RoundedRectangle(cornerRadius: 1, style: .continuous)
                        .fill(Color(hex: "#CCCCCC"))
                        .frame(width: 10, height: 10)
                }
            }
            .buttonStyle(.plain)

            // Play / Pause
            Button {
                vm.isPaused ? vm.resumeSession() : vm.pauseSession()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.bbAccent)
                        .frame(width: 48, height: 48)
                    if vm.isPaused {
                        Image(systemName: "play.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .offset(x: 2)
                    } else {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)

            // Skip
            Button { vm.skipCombo() } label: {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#F5F5F5"))
                        .overlay(Circle().stroke(Color.bbBorder, lineWidth: 1))
                        .frame(width: 40, height: 40)
                    Text("SKIP")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.bbTextSecondary)
                }
            }
            .buttonStyle(.plain)
        }
    }
}
