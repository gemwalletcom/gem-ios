// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct ChartPriceView: View {
    let date: String?
    let price: String
    let priceChange: String?
    let priceChangeTextColor: Color

    public init(
        date: String?,
        price: String,
        priceChange: String?,
        priceChangeTextColor: Color
    ) {
        self.date = date
        self.price = price
        self.priceChange = priceChange
        self.priceChangeTextColor = priceChangeTextColor
    }

    public var body: some View {
        VStack(spacing: Spacing.tiny) {
            HStack(alignment: .center, spacing: Spacing.tiny) {
                Text(price)
                    .font(.title2)
                    .foregroundColor(Colors.black)

                if let priceChange {
                    Text(priceChange)
                        .font(.callout)
                        .foregroundColor(priceChangeTextColor)
                }
            }

            HStack {
                if let date {
                    Text(date)
                        .font(.footnote)
                        .foregroundColor(Colors.gray)
                }
            }.frame(height: 16)
        }
    }
}
