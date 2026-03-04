import Foundation
import UIKit
import AudioToolbox
import SwiftUI

final class FeedbackManager {
    static let shared = FeedbackManager()
    private init() {}

    var hapticsEnabled: Bool = true
    var soundEnabled: Bool = true

    func tap() {
        if hapticsEnabled {
            let gen = UIImpactFeedbackGenerator(style: .light)
            gen.impactOccurred()
        }
        if soundEnabled {
            AudioServicesPlaySystemSound(1104) // subtle tap
        }
    }

    func win() {
        if hapticsEnabled {
            let gen = UINotificationFeedbackGenerator()
            gen.notificationOccurred(.success)
        }
        if soundEnabled {
            AudioServicesPlaySystemSound(1025) // success
        }
    }

    func draw() {
        if hapticsEnabled {
            let gen = UINotificationFeedbackGenerator()
            gen.notificationOccurred(.warning)
        }
        if soundEnabled {
            AudioServicesPlaySystemSound(1152) // neutral
        }
    }
}

#Preview("Feedback Preview") {
    GameView()
        .preferredColorScheme(.dark)
}
