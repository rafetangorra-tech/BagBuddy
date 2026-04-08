import SwiftUI

struct RootView: View {
    @StateObject private var vm = SessionViewModel()

    var body: some View {
        ZStack {
            Color.bbBackground.ignoresSafeArea()

            switch vm.phase {
            case .idle:
                HomeView(vm: vm)
                    .transition(.opacity)

            case .countdown(let remaining):
                CountdownView(secondsRemaining: remaining)
                    .transition(.opacity)

            case .round(let number, let remaining):
                SessionView(vm: vm, roundNumber: number, secondsRemaining: remaining)
                    .transition(.opacity)

            case .rest(let afterRound, let remaining):
                RestView(vm: vm, afterRound: afterRound, secondsRemaining: remaining)
                    .transition(.opacity)

            case .complete:
                CompleteView(vm: vm)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: vm.phase)
        .preferredColorScheme(.dark)
    }
}
