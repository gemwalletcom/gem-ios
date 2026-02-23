// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style

public struct AssetImageTitleView: View {
    private let model: AssetImageTitleViewModel

    public init(model: AssetImageTitleViewModel) {
        self.model = model
    }

    public var body: some View {
        VStack(spacing: .medium) {
            AssetImageView(assetImage: model.assetImage, size: .image.semiLarge)

            HStack(alignment: .bottom, spacing: .tiny) {
                Text(model.name)
                    .textStyle(.headline)
                if let symbol = model.symbol {
                    Text(symbol)
                        .textStyle(TextStyle(font: .subheadline, color: Colors.secondaryText, fontWeight: .medium))
                }
            }
            .lineLimit(1)
        }
    }
}
