// Copyright (c). Gem Wallet. All rights reserved.

import Components
import SwiftUI
import Style

public struct ChartPriceView: View {
    let model: ChartPriceViewModel

    public init(model: ChartPriceViewModel) {
        self.model = model
    }

    public var body: some View {
        VStack(spacing: Spacing.tiny) {
            HStack(alignment: .center, spacing: Spacing.tiny) {
                Text(model.priceText)
                    .font(.title2)
                    .foregroundStyle(model.priceColor)
                    .numericTransition(for: model.priceText)

                if let priceChange = model.priceChangeText {
                    Text(priceChange)
                        .font(.callout)
                        .foregroundStyle(model.priceChangeTextColor)
                        .numericTransition(for: priceChange)
                }
            }

            HStack {
                if let date = model.dateText {
                    Text(date)
                        .font(.footnote)
                        .foregroundStyle(Colors.gray)
                }
            }.frame(height: 16)
        }
    }
}
