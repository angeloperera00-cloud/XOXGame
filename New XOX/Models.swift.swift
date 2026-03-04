import SwiftUI

enum Tile: String, CaseIterable {
    case cross = "X"
    case nought = "O"
    case empty = ""

    var color: Color {
        switch self {
        case .cross: return .cyan
        case .nought: return .pink
        case .empty: return .clear
        }
    }

    var isPlayable: Bool { self == .empty }
}

enum GameMode: String, CaseIterable, Identifiable {
    case playerVsPlayer = "Player vs Player"
    case playerVsAI = "Player vs AI"

    var id: String { rawValue }
}

enum AIDifficulty: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var id: String { rawValue }
}

#Preview("Models Preview") {
    GameView()
        .preferredColorScheme(.dark)
}
