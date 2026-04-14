import UIKit

/// Centralised haptic feedback for Bag Buddy.
/// All methods are no-ops when `isEnabled` is false.
@MainActor
final class HapticsEngine {
    static let shared = HapticsEngine()
    var isEnabled: Bool = true

    private let light    = UIImpactFeedbackGenerator(style: .light)
    private let medium   = UIImpactFeedbackGenerator(style: .medium)
    private let heavy    = UIImpactFeedbackGenerator(style: .heavy)
    private let notify   = UINotificationFeedbackGenerator()

    private init() {
        light.prepare()
        medium.prepare()
        heavy.prepare()
        notify.prepare()
    }

    /// Heavy thud — round start bell
    func roundStart() {
        guard isEnabled else { return }
        heavy.impactOccurred()
    }

    /// Medium thud — round end bell
    func roundEnd() {
        guard isEnabled else { return }
        medium.impactOccurred()
    }

    /// Warning notification — fires at N seconds remaining
    func warning() {
        guard isEnabled else { return }
        notify.notificationOccurred(.warning)
    }

    /// Light tick — each countdown beep (3-2-1)
    func countdownTick() {
        guard isEnabled else { return }
        light.impactOccurred()
    }

    /// Light tap — new combo delivered
    func comboDelivered() {
        guard isEnabled else { return }
        light.impactOccurred(intensity: 0.5)
    }
}
