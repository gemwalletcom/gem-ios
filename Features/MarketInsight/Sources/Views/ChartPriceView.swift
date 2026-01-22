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
