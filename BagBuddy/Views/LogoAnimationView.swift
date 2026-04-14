import SwiftUI
import AVFoundation

/// Full-screen logo animation that plays once on launch, then calls `onFinished`.
struct LogoAnimationView: View {
    let onFinished: () -> Void

    var body: some View {
        VideoPlayerView(onFinished: onFinished)
            .ignoresSafeArea()
            .background(Color.white)
    }
}

// MARK: - UIKit bridge

private struct VideoPlayerView: UIViewRepresentable {
    let onFinished: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onFinished: onFinished)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .white

        guard let url = Bundle.main.url(forResource: "logoanimation", withExtension: "mp4") else {
            // File missing — skip straight to home
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { self.onFinished() }
            return view
        }

        let player = AVPlayer(url: url)
        player.isMuted = true

        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(layer)
        context.coordinator.playerLayer = layer
        context.coordinator.player = player

        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.playerDidFinish),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )

        player.play()
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.playerLayer?.frame = uiView.bounds
        }
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject {
        var player: AVPlayer?
        var playerLayer: AVPlayerLayer?
        let onFinished: () -> Void

        init(onFinished: @escaping () -> Void) {
            self.onFinished = onFinished
        }

        @objc func playerDidFinish() {
            DispatchQueue.main.async { self.onFinished() }
        }
    }
}
