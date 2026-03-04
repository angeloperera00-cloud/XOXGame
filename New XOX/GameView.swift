import SwiftUI

struct GameView: View {
    @StateObject private var vm = GameViewModel()
    @Environment(\.colorScheme) private var scheme

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    var body: some View {
        ZStack {
            background

            VStack(spacing: 16) {
                titleBar
                scoreBar
                statusBar
                boardCard
                controlsCard
                actionButtons
            }
            .padding()

            if vm.winner != nil {
                ConfettiView()
                    .transition(.opacity)
            }
        }
        .animation(.spring(), value: vm.winner)
    }

    private var background: some View {
        let darkColors = [
            Color(red: 0.03, green: 0.05, blue: 0.12),
            Color.purple.opacity(0.9)
        ]
        let lightColors = [
            Color(red: 0.90, green: 0.93, blue: 0.98),
            Color.purple.opacity(0.35)
        ]
        return LinearGradient(
            colors: scheme == .dark ? darkColors : lightColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var titleBar: some View {
        Text("XOX")
            .font(.largeTitle.bold())
            .foregroundStyle(scheme == .dark ? .white : .black)
    }

    private var scoreBar: some View {
        HStack(spacing: 12) {
            ScoreChip(title: "X", score: vm.xScore, color: .cyan, isActive: vm.currentTurn == .cross)
            ScoreChip(title: "O", score: vm.oScore, color: .pink, isActive: vm.currentTurn == .nought)
        }
    }

    private var statusBar: some View {
        Group {
            if let winner = vm.winner {
                Text("\(winner.rawValue) Wins!")
                    .font(.title2.bold())
                    .padding(.vertical, 6)
                    .padding(.horizontal, 14)
                    .foregroundStyle(.white)
                    .background(.black.opacity(0.6))
                    .clipShape(Capsule())
                    .transition(.scale.combined(with: .opacity))

            } else if vm.isDraw {
                Text("Draw!")
                    .font(.title2.bold())
                    .padding(.vertical, 6)
                    .padding(.horizontal, 14)
                    .foregroundStyle(.white)
                    .background(.black.opacity(0.6))
                    .clipShape(Capsule())

            } else if vm.board.allSatisfy({ $0 == .empty }) {
                Text("Tap any square to start")
                    .font(.headline)
                    .foregroundStyle((scheme == .dark ? Color.white : .black).opacity(0.7))

            } else {
                HStack(spacing: 6) {
                    Text("Turn:")
                        .font(.headline)
                        .foregroundStyle((scheme == .dark ? Color.white : .black).opacity(0.8))
                    Text(vm.currentTurn.rawValue)
                        .font(.title.bold())
                        .foregroundStyle(vm.currentTurn.color)
                        .transition(.scale.combined(with: .opacity))
                                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: vm.currentTurn)
                        }
            }
        }
        .animation(.spring(), value: vm.isDraw)
    }

    // ✅ FIXED: Button + PressScaleStyle (taps work)
    private var boardCard: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let cellSize = (size - 24) / 3

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(0..<9, id: \.self) { i in
                    Button {
                        vm.tapCell(i)
                    } label: {
                        CellView(tile: vm.board[i],
                                 isWinning: vm.winningLine.contains(i),
                                 size: cellSize)
                    }
                    .buttonStyle(PressScaleStyle())
                    .disabled(!vm.board[i].isPlayable || vm.winner != nil || vm.isDraw)
                }
            }
            .frame(width: size, height: size)
            .padding(12)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.45), radius: 14, y: 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var controlsCard: some View {
        VStack(spacing: 12) {
            Picker("Mode", selection: $vm.mode) {
                ForEach(GameMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: vm.mode) { _ in vm.resetRound() }

            if vm.mode == .playerVsAI {
                Picker("Difficulty", selection: $vm.difficulty) {
                    ForEach(AIDifficulty.allCases) { d in
                        Text(d.rawValue).tag(d)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: vm.difficulty) { _ in vm.resetRound() }
            }

            Toggle("Haptics", isOn: $vm.hapticsOn).tint(.cyan)
            Toggle("Sound", isOn: $vm.soundOn).tint(.pink)
        }
        .font(.headline)
        .padding()
        .background((scheme == .dark ? Color.white : .black).opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button { withAnimation { vm.resetRound() } } label: {
                Label("Play Again", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background((scheme == .dark ? Color.white : .black).opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Button { withAnimation { vm.resetAll() } } label: {
                Label("Reset All", systemImage: "trash")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background((scheme == .dark ? Color.white : .black).opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .font(.title3.weight(.semibold))
        .foregroundStyle(scheme == .dark ? .white : .black)
    }
}

// MARK: - UI Components

private struct ScoreChip: View {
    let title: String
    let score: Int
    let color: Color
    let isActive: Bool

    var body: some View {
        HStack(spacing: 6) {
            Text(title).font(.headline.bold()).foregroundStyle(color)
            Text("\(score)").font(.headline).foregroundStyle(.white)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 14)
        .background(.white.opacity(isActive ? 0.18 : 0.10))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(isActive ? color.opacity(0.9) : .clear, lineWidth: 2)
                .scaleEffect(isActive ? 1.05 : 1)
                .animation(.easeInOut(duration: 0.8).repeatForever(), value: isActive)
        )
    }
}

private struct CellView: View {
    let tile: Tile
    let isWinning: Bool
    let size: CGFloat

    @State private var drawProgress: CGFloat = 0

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(isWinning ? .yellow : .white.opacity(0.15), lineWidth: 2)
                )

            if tile == .cross {
                XShape()
                    .trim(from: 0, to: drawProgress)
                    .stroke(tile.color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .padding(18)
                    .onAppear { withAnimation(.easeOut(duration: 0.25)) { drawProgress = 1 } }

            } else if tile == .nought {
                Circle()
                    .trim(from: 0, to: drawProgress)
                    .stroke(tile.color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .padding(18)
                    .onAppear { withAnimation(.easeOut(duration: 0.25)) { drawProgress = 1 } }
            }
        }
        .frame(width: size, height: size)
    }
}

private struct XShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return p
    }
}

private struct PressScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.6),
                       value: configuration.isPressed)
    }
}

#Preview("GameView - Dark") {
    GameView().preferredColorScheme(.dark)
}

