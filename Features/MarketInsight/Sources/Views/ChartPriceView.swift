// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

struct ChartPriceView: View {
    let date: String?
    let price: String
    let priceChange: String?
    let priceChangeTextColor: Color

    var body: some View {
        VStack(spacing: .tiny) {
            HStack(alignment: .center, spacing: .tiny) {
                Text(price)
                    .font(.title2)
                    .foregroundStyle(Colors.black)

                if let priceChange {
                    Text(priceChange)
                        .font(.callout)
                        .foregroundStyle(priceChangeTextColor)
                }
            }

            HStack {
                if let date {
                    Text(date)
                        .font(.footnote)
                        .foregroundStyle(Colors.gray)
                }
            }.frame(height: 16)
        }
    }
}
