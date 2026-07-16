import SwiftUI


struct WordCanvas: View {
    @Environment(Alphabetizer.self) private var alphabetizer
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var dragTouchOffsets = [UUID: CGSize]()


    private var tiles: [Tile] {
        alphabetizer.tiles
    }

    private func tileSpacingIn(frame: GeometryProxy) -> CGFloat {
        let shortestSide = min(frame.size.width, frame.size.height)
        let isPad = horizontalSizeClass == .regular && verticalSizeClass == .regular
        let maximumSpacing = isPad ? 50.0 : 24.0
        return min(max(shortestSide * 0.06, 8.0), maximumSpacing)
    }

    private func tileSizeIn(frame: GeometryProxy,
                            tileSpacing: CGFloat) -> CGSize {
        guard !tiles.isEmpty else {
            return .zero
        }

        let totalSpacing = tileSpacing * CGFloat(tiles.count - 1)
        let tileWidth = (frame.size.width - totalSpacing) / CGFloat(tiles.count)
        let tileHeight = (frame.size.height - tileSpacing) / 2.0
        let tileSize = max(min(tileWidth, tileHeight), 44.0)
        return CGSize(width: tileSize, height: tileSize)
    }

    var body: some View {
        GeometryReader { frame in
            let tileSpacing = tileSpacingIn(frame: frame)
            let tileSize = tileSizeIn(frame: frame, tileSpacing: tileSpacing)

            VStack(spacing: tileSpacing) {
                Spacer()
                HStack(spacing: tileSpacing) {
                    ForEach(tiles) { _ in
                        Rectangle()
                            .fill(Color.purple.opacity(0.2))
                            .frame(
                                width: tileSize.width,
                                height: tileSize.height
                            )
                    }
                }
                HStack(spacing: tileSpacing) {
                    ForEach(Array(tiles.enumerated()), id: \.element.id) { index, tile in
                        TileView(tile: tile)
                            .frame(
                                width: tileSize.width,
                                height: tileSize.height
                            )
                            .background(Color.purple.opacity(0.5))
                            .offset(tileOffset(
                                for: tile,
                                at: index,
                                in: frame,
                                tileSize: tileSize,
                                tileSpacing: tileSpacing
                            ))
                            .gesture(
                                DragGesture(coordinateSpace: .named("wordCanvas"))
                                    .onChanged { value in
                                        updatePosition(for: tile, with: value)
                                    }
                                    .onEnded { _ in
                                        dragTouchOffsets[tile.id] = nil
                                    }
                            )
                    }
                }
                Spacer()
            }
            .frame(width: frame.size.width, height: frame.size.height)
            .coordinateSpace(name: "wordCanvas")
            .onAppear {
                setInitialTilePositions(in: frame, tileSize: tileSize, tileSpacing: tileSpacing)
            }
            .onChange(of: frame.size) { _, _ in
                setInitialTilePositions(in: frame, tileSize: tileSize, tileSpacing: tileSpacing, force: true)
            }
            .onChange(of: alphabetizer.message) { oldValue, newValue in
                switch (oldValue, newValue) {
                case (.youWin, .instructions):
                    withAnimation {
                        setInitialTilePositions(in: frame, tileSize: tileSize, tileSpacing: tileSpacing, force: true)
                    }
                default:
                    break
                }
            }
        }
    }
}

extension WordCanvas {
    private func rowWidth(tileSize: CGSize, tileSpacing: CGFloat) -> CGFloat {
        guard !tiles.isEmpty else {
            return 0
        }

        return CGFloat(tiles.count) * tileSize.width + CGFloat(tiles.count - 1) * tileSpacing
    }


    private func homeCenter(for index: Int,
                            in frame: GeometryProxy,
                            tileSize: CGSize,
                            tileSpacing: CGFloat) -> CGPoint {
        let rowStart = (frame.size.width - rowWidth(tileSize: tileSize, tileSpacing: tileSpacing)) / 2.0
        let contentHeight = tileSize.height * 2.0 + tileSpacing
        let contentStartY = (frame.size.height - contentHeight) / 2.0
        let centerX = rowStart + tileSize.width / 2.0 + CGFloat(index) * (tileSize.width + tileSpacing)
        let centerY = contentStartY + tileSize.height + tileSpacing + tileSize.height / 2.0

        return CGPoint(x: centerX, y: centerY)
    }


    private func tileOffset(for tile: Tile,
                            at index: Int,
                            in frame: GeometryProxy,
                            tileSize: CGSize,
                            tileSpacing: CGFloat) -> CGSize {
        let homeCenter = homeCenter(for: index, in: frame, tileSize: tileSize, tileSpacing: tileSpacing)
        let position = tile.position == .zero ? homeCenter : tile.position

        return CGSize(
            width: position.x - homeCenter.x,
            height: position.y - homeCenter.y
        )
    }


    private func updatePosition(for tile: Tile, with value: DragGesture.Value) {
        if dragTouchOffsets[tile.id] == nil {
            dragTouchOffsets[tile.id] = CGSize(
                width: value.startLocation.x - tile.position.x,
                height: value.startLocation.y - tile.position.y
            )
        }

        let touchOffset = dragTouchOffsets[tile.id] ?? .zero
        tile.position = CGPoint(
            x: value.location.x - touchOffset.width,
            y: value.location.y - touchOffset.height
        )
    }


    private func setInitialTilePositions(in frame: GeometryProxy,
                                         tileSize: CGSize,
                                         tileSpacing: CGFloat,
                                         force: Bool = false) {
        tiles.enumerated().forEach { index, tile in
            if force || tile.position == .zero {
                tile.position = homeCenter(
                    for: index,
                    in: frame,
                    tileSize: tileSize,
                    tileSpacing: tileSpacing
                )
            }
        }
    }
}

#Preview {
    WordCanvas()
        .environment(Alphabetizer())
}
