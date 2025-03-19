// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

struct CornerBracketsView: View {
    let configuration: QRScannerDisplayConfiguration
    let boxSize: CGFloat
    let geometrySize: CGSize

    var body: some View {
        CornerBracketsShape(
            cornerRadius: configuration.cornerRadius,
            cornerLength: configuration.cornerLength,
            boxSize: boxSize,
            containerSize: geometrySize
        )
        .stroke(
            configuration.bracketColor,
            style: StrokeStyle(
                lineWidth: configuration.lineWidth,
                lineCap: .round,
                lineJoin: .round
            )
        )
    }
}

#Preview {
    GeometryReader { geometry in
        ZStack {
            Color.red
                .ignoresSafeArea()
            CornerBracketsView(
                configuration: .default,
                boxSize: 200,
                geometrySize: geometry.size
            )
        }
    }
}
