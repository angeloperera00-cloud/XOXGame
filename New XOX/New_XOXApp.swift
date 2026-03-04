import SwiftUI

@main
struct XOXApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
                .preferredColorScheme(.dark)
        }
    }
}

#Preview("App Root - Dark Only") {
    GameView()
        .preferredColorScheme(.dark)
}
