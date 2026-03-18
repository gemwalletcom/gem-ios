// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style

public protocol AssetPreviewable {
    var assetImage: AssetImage { get }
    var name: String { get }
    var subtitleSymbol: String? { get }
}

public struct AssetPreviewView<Model: AssetPreviewable>: View {
    private let model: Model

    public init(model: Model) {
        self.model = model
    }

    public var body: some View {
        VStack(spacing: .medium) {
            AssetImageView(assetImage: model.assetImage, size: .image.semiLarge)

            HStack(alignment: .lastTextBaseline, spacing: .tiny) {
                Text(model.name)
                    .textStyle(.headline)
                if let symbol = model.subtitleSymbol {
                    Text(symbol)
                        .textStyle(TextStyle(font: .subheadline, color: Colors.secondaryText, fontWeight: .medium))
                }
            }
            .lineLimit(1)
        }
    }
}
