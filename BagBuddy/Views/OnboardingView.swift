import SwiftUI

struct OnboardingView: View {
    var includeHealthSlide: Bool = false
    let onDismiss: () -> Void

    @State private var currentPage = 0

    private var pages: [OnboardingPage] {
        var base: [OnboardingPage] = [
            OnboardingPage(
                icon: "figure.boxing",
                title: "STAND AND BANG",
                subtitle: "Pure offense.",
                body: "Back-to-back strike combinations are called out loud. No defense — just commit to every punch and keep moving forward."
            ),
            OnboardingPage(
                icon: "shield.lefthalf.filled",
                title: "STICK AND MOVE",
                subtitle: "Hit and don't get hit.",
                body: "Every combo includes a defensive move — a slip, roll, or cover. You'll be coached to strike and move like a smart fighter."
            ),
            OnboardingPage(
                icon: "repeat.circle.fill",
                title: "DRILLERS MAKE KILLERS",
                subtitle: "One combo. Perfect it.",
                body: "A single complex combination is selected and drilled for the full round. Repetition builds muscle memory that holds up under pressure."
            )
        ]
        if includeHealthSlide {
            base.append(OnboardingPage(
                icon: "heart.text.square.fill",
                title: "TRACK YOUR PROGRESS",
                subtitle: "Apple Health + WHOOP.",
                body: "Every session is logged to Apple Health automatically — duration, calories, and workout type. If you use WHOOP, your bag work will sync through Health with no extra setup needed."
            ))
        }
        return base
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.bbBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { i in
                        pageView(pages[i])
                            .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                VStack(spacing: 24) {
                    HStack(spacing: 8) {
                        ForEach(pages.indices, id: \.self) { i in
                            Capsule()
                                .fill(i == currentPage ? Color.bbAccent : Color.bbBorder)
                                .frame(width: i == currentPage ? 20 : 6, height: 6)
                                .animation(.easeInOut(duration: 0.2), value: currentPage)
                        }
                    }

                    Button {
                        if currentPage < pages.count - 1 {
                            currentPage += 1
                        } else {
                            onDismiss()
                        }
                    } label: {
                        Text(currentPage < pages.count - 1 ? "NEXT" : "LET'S GO")
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
                    .padding(.horizontal, 28)
                }
                .padding(.bottom, 52)
            }

            // Dismiss X
            Button(action: onDismiss) {
                ZStack {
                    Circle()
                        .fill(Color.bbSurfaceRaised)
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.bbTextPrimary)
                }
                .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            .padding(.top, 60)
            .padding(.trailing, 20)
        }
    }

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: page.icon)
                .font(.system(size: 64, weight: .light))
                .foregroundColor(.bbAccent)
                .padding(.bottom, 32)

            Text(page.title)
                .font(.custom("Oswald-SemiBold", size: 28))
                .foregroundColor(.bbTextPrimary)
                .kerning(2)
                .multilineTextAlignment(.center)

            Text(page.subtitle.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.bbAccent)
                .kerning(2)
                .padding(.top, 6)
                .padding(.bottom, 20)

            Text(page.body)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.bbTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 36)

            Spacer()
        }
    }
}

private struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
    let body: String
}
