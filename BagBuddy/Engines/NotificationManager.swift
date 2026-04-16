import UserNotifications
import Foundation

/// Schedules daily training reminder notifications that rotate through coach messages.
final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    // MARK: - Messages (coach voice, fight culture)

    private let messages: [(title: String, body: String)] = [
        (
            title: "BAG BUDDY",
            body: "\"My back is broken. Spinal. Yours isn't. Get on the bag.\""
        ),
        (
            title: "BAG BUDDY",
            body: "Your hands are getting slow. Fix it."
        ),
        (
            title: "BAG BUDDY",
            body: "Stop thinking. Start punching."
        ),
        (
            title: "BAG BUDDY",
            body: "You're soft right now. Get on the bag and fix that."
        ),
        (
            title: "BAG BUDDY",
            body: "I've seen you work. This ain't it. Get in there."
        ),
        (
            title: "BAG BUDDY",
            body: "Tired? Good. That means it's working. Get on the bag."
        ),
        (
            title: "BAG BUDDY",
            body: "You want it or you don't. The bag doesn't care."
        ),
        (
            title: "BAG BUDDY",
            body: "Your footwork is garbage when you don't train. Let's go."
        ),
        (
            title: "BAG BUDDY",
            body: "Every fighter I ever made showed up every day. Simple as that."
        ),
        (
            title: "BAG BUDDY",
            body: "Pain is temporary. Quitting is forever. Move."
        ),
        (
            title: "BAG BUDDY",
            body: "You got three minutes in you. That's all I'm asking."
        ),
    ]

    // MARK: - Authorization

    func requestAuthorization() async {
        _ = try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])
    }

    // MARK: - Scheduling

    /// Schedules daily notifications at the given hour/minute, cycling through all messages.
    /// Call this whenever notifications are enabled or the time changes.
    func scheduleDailyReminders(hour: Int = 17, minute: Int = 0) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        // iOS allows max 64 pending notifications — schedule 60 days out, cycling messages
        for dayOffset in 1...60 {
            let messageIndex = (dayOffset - 1) % messages.count
            let msg = messages[messageIndex]

            let content = UNMutableNotificationContent()
            content.title = msg.title
            content.body = msg.body
            content.sound = .default

            var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            components.day! += dayOffset
            components.hour = hour
            components.minute = minute
            components.second = 0

            guard let fireDate = Calendar.current.date(from: components) else { continue }
            let triggerComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: fireDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
            let request = UNNotificationRequest(
                identifier: "bagbuddy.daily.\(dayOffset)",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
