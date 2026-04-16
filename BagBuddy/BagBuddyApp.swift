import SwiftUI

@main
struct BagBuddyApp: App {
    init() {
        // Eagerly initialize AudioEngine so the audio session is configured with
        // .mixWithOthers BEFORE AVPlayer (logo animation) or any other audio is created.
        // Without this, the launch video would take audio focus and pause the user's music.
        _ = AudioEngine.shared
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
