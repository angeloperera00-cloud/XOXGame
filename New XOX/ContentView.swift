import SwiftUI

struct ConfettiView: View {
    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<28, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: 8, height: 10)
                    .rotationEffect(.degrees(Double.random(in: 0...360)))
                    .position(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: animate ? geo.size.height + 60 : -60
                    )
                    .opacity(0.9)
                    .animation(
                        .easeIn(duration: Double.random(in: 1.2...2.3))
                            .repeatForever(autoreverses: false)
                            .delay(Double.random(in: 0...0.25)),
                        value: animate
                    )
            }
        }
        .ignoresSafeArea()
        .onAppear { animate = true }
    }
}

#Preview("Confetti Preview - Dark Only") {
    ZStack {
        Color.black.ignoresSafeArea()
        GameView()
    }
}
