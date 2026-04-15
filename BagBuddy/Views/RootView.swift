import SwiftUI

struct RootView: View {
    @StateObject private var vm = SessionViewModel()
    @State private var showLaunchAnimation = true
    @State private var showOnboarding = false
    @State private var showSessionIntro = false

    private var hasSeenOnboarding: Bool {
        UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    }

    var body: some View {
        ZStack {
            Color.bbBackground.ignoresSafeArea()

            if !showLaunchAnimation && !showOnboarding {
                switch vm.phase {
                case .idle:
                    TabView {
                        HomeView(vm: vm, onStart: { showSessionIntro = true })
                            .tabItem {
                                Label("Train", systemImage: "figure.boxing")
                            }
                        HistoryView()
                            .tabItem {
                                Label("History", systemImage: "clock.fill")
                            }
                    }
                    .tint(.bbAccent)
                    .transition(.opacity)

                case .countdown(let remaining):
                    CountdownView(secondsRemaining: remaining, onStop: { vm.stopSession() })
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

            // Launch animation — crossfades into onboarding when done
            if showLaunchAnimation {
                LogoAnimationView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showLaunchAnimation = false
                        if !hasSeenOnboarding {
                            showOnboarding = true
                        }
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            }

            // Onboarding — fades in after launch animation completes
            if showOnboarding {
                OnboardingView(includeHealthSlide: true) {
                    UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showOnboarding = false
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            }

            // Session intro animation — plays when Start Session is tapped
            if showSessionIntro {
                LogoAnimationView {
                    showSessionIntro = false
                    vm.startSession()
                }
                .transition(.opacity)
                .zIndex(2)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: vm.phase)
        .animation(.easeInOut(duration: 0.5), value: showLaunchAnimation)
        .animation(.easeInOut(duration: 0.4), value: showOnboarding)
        .animation(.easeInOut(duration: 0.5), value: showSessionIntro)
        .preferredColorScheme(.light)
    }
}
