import SwiftUI


struct TileView: View {
    var tile: Tile

    private let borderWidth = 5.0

    var body: some View {
        GeometryReader { geometry in
            let contentSize = min(geometry.size.width, geometry.size.height)
            let padding = max(contentSize * 0.08, 4)
            let iconSize = contentSize * 0.42
            let wordSize = contentSize * 0.16
            let checkmarkSize = contentSize * 0.55

            ZStack {
                if tile.flipped {
                    Image(systemName: "checkmark")
                        .font(.system(size: checkmarkSize, weight: .semibold))
                        .foregroundStyle(Color.green)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: contentSize * 0.04) {
                        Text(tile.icon)
                            .font(.system(size: iconSize))
                            .lineLimit(1)

                        Text(tile.word)
                            .font(.system(size: wordSize, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                    .padding(padding)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.purple.opacity(0.5))
            .rotation3DEffect(.degrees(tile.flipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            .animation(.default, value: tile.flipped)
        }
    }

}


#Preview {
    let tile = Tile(word: "Bear")
    return TileView(tile: tile)
        .onTapGesture {
            tile.flipped.toggle()
        }
}
