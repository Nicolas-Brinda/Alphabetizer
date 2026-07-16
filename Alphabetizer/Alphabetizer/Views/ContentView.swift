import SwiftUI


struct ContentView: View {
    var body: some View {
        GeometryReader { geometry in
            let metrics = layoutMetrics(for: geometry.size)

            VStack(spacing: metrics.spacing) {
                ScoreView()
                MessageView()
                WordCanvas()
                    .frame(maxHeight: metrics.canvasHeight)
                SubmitButton()
            }
            .padding(.horizontal, metrics.horizontalPadding)
            .padding(.vertical, metrics.verticalPadding)
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }

    private func layoutMetrics(for size: CGSize) -> LayoutMetrics {
        let shortestSide = min(size.width, size.height)
        let isLandscape = size.width > size.height
        let isPad = shortestSide >= 744
        let verticalPadding = isLandscape ? (isPad ? 24.0 : 8.0) : (isPad ? 40.0 : 20.0)
        let horizontalPadding = isPad ? 48.0 : 16.0
        let spacing = isLandscape ? (isPad ? 18.0 : 8.0) : (isPad ? 28.0 : 16.0)
        let canvasHeightRatio = isLandscape ? (isPad ? 0.46 : 0.38) : (isPad ? 0.56 : 0.52)

        return LayoutMetrics(
            spacing: spacing,
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding,
            canvasHeight: size.height * canvasHeightRatio
        )
    }
}

private struct LayoutMetrics {
    let spacing: CGFloat
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let canvasHeight: CGFloat
}

#Preview {
    ContentView()
        .environment(Alphabetizer())
}
