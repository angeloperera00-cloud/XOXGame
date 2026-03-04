import SwiftUI
import Combine   // REQUIRED for ObservableObject + @Published

final class GameViewModel: ObservableObject {
    // MARK: - Published UI State
    @Published var board: [Tile] = Array(repeating: .empty, count: 9)
    @Published var currentTurn: Tile = .cross

    @Published var winner: Tile? = nil
    @Published var isDraw: Bool = false
    @Published var winningLine: [Int] = []

    @Published var xScore: Int = 0
    @Published var oScore: Int = 0

    @Published var mode: GameMode = .playerVsAI
    @Published var difficulty: AIDifficulty = .medium

    @Published var hapticsOn: Bool = true {
        didSet { FeedbackManager.shared.hapticsEnabled = hapticsOn }
    }
    @Published var soundOn: Bool = true {
        didSet { FeedbackManager.shared.soundEnabled = soundOn }
    }

    // MARK: - Private
    private let aiTile: Tile = .nought
    private let humanTile: Tile = .cross

    private let winPatterns: [[Int]] = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8],     // rows
        [0, 3, 6], [1, 4, 7], [2, 5, 8],     // cols
        [0, 4, 8], [2, 4, 6]                 // diagonals
    ]

    init() {
        FeedbackManager.shared.hapticsEnabled = hapticsOn
        FeedbackManager.shared.soundEnabled = soundOn
    }

    // MARK: - Public API
    func tapCell(_ index: Int) {
        guard index >= 0 && index < 9 else { return }
        guard board[index].isPlayable, winner == nil, !isDraw else { return }
        guard !(mode == .playerVsAI && currentTurn == aiTile) else { return }

        FeedbackManager.shared.tap()
        place(tile: currentTurn, at: index)

        if checkGameOver(for: currentTurn) { return }
        switchTurn()

        if mode == .playerVsAI && currentTurn == aiTile {
            scheduleAIMove()
        }
    }

    func resetRound() {
        board = Array(repeating: .empty, count: 9)
        currentTurn = .cross
        winner = nil
        isDraw = false
        winningLine = []
    }

    func resetAll() {
        xScore = 0
        oScore = 0
        resetRound()
    }

    // MARK: - Core game
    private func place(tile: Tile, at index: Int) {
        board[index] = tile
    }

    private func switchTurn() {
        currentTurn = (currentTurn == .cross) ? .nought : .cross
    }

    private func checkGameOver(for tile: Tile) -> Bool {
        if let line = findWinningLine(for: tile, on: board) {
            winner = tile
            winningLine = line

            if tile == .cross { xScore += 1 }
            if tile == .nought { oScore += 1 }

            FeedbackManager.shared.win()
            return true
        }

        if board.allSatisfy({ !$0.isPlayable }) {
            isDraw = true
            FeedbackManager.shared.draw()
            return true
        }

        return false
    }

    private func findWinningLine(for tile: Tile, on board: [Tile]) -> [Int]? {
        for pattern in winPatterns {
            if pattern.allSatisfy({ board[$0] == tile }) {
                return pattern
            }
        }
        return nil
    }

    // MARK: - AI
    private func scheduleAIMove() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.makeAIMove()
        }
    }

    private func makeAIMove() {
        guard winner == nil, !isDraw else { return }

        let move: Int
        switch difficulty {
        case .easy:
            move = randomMove()
        case .medium:
            move = mediumMove()
        case .hard:
            move = hardMove()
        }

        FeedbackManager.shared.tap()
        place(tile: aiTile, at: move)

        if checkGameOver(for: aiTile) { return }
        switchTurn()
    }

    private func randomMove() -> Int {
        let available = board.indices.filter { board[$0].isPlayable }
        return available.randomElement() ?? 0
    }

    private func mediumMove() -> Int {
        if let winSpot = winningSpot(for: aiTile) { return winSpot }
        if let blockSpot = winningSpot(for: humanTile) { return blockSpot }
        if board[4].isPlayable { return 4 } // center
        let corners = [0,2,6,8].filter { board[$0].isPlayable }
        if let corner = corners.randomElement() { return corner }
        return randomMove()
    }

    private func winningSpot(for tile: Tile) -> Int? {
        for i in 0..<9 where board[i].isPlayable {
            var test = board
            test[i] = tile
            if findWinningLine(for: tile, on: test) != nil {
                return i
            }
        }
        return nil
    }

    private func hardMove() -> Int {
        var bestScore = Int.min
        var bestMove = randomMove()

        for i in 0..<9 where board[i].isPlayable {
            var test = board
            test[i] = aiTile
            let score = minimax(board: test, isMaximizing: false)
            if score > bestScore {
                bestScore = score
                bestMove = i
            }
        }
        return bestMove
    }

    private func minimax(board: [Tile], isMaximizing: Bool) -> Int {
        if findWinningLine(for: aiTile, on: board) != nil { return 10 }
        if findWinningLine(for: humanTile, on: board) != nil { return -10 }
        if board.allSatisfy({ !$0.isPlayable }) { return 0 }

        if isMaximizing {
            var best = Int.min
            for i in 0..<9 where board[i].isPlayable {
                var newBoard = board
                newBoard[i] = aiTile
                best = max(best, minimax(board: newBoard, isMaximizing: false))
            }
            return best
        } else {
            var best = Int.max
            for i in 0..<9 where board[i].isPlayable {
                var newBoard = board
                newBoard[i] = humanTile
                best = min(best, minimax(board: newBoard, isMaximizing: true))
            }
            return best
        }
    }
}

#Preview("ViewModel Preview") {
    GameView()
        .preferredColorScheme(.dark)
}
