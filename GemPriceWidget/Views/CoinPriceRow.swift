// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components

struct CoinPriceRow: View {
    private let model: CoinPriceRowViewModel

    init(model: CoinPriceRowViewModel) {
        self.model = model
    }

    var body: some View {
        HStack(spacing: Spacing.small) {
            AssetImageView(assetImage: model.assetImage, size: .list.assets.widget)

            VStack(alignment: .leading, spacing: Spacing.extraSmall) {
                Text(model.name)
                    .font(.system(size: Constants.textFontSize, weight: .medium))
                    .foregroundColor(Colors.black)

                Text(model.symbol)
                    .font(.caption)
                    .foregroundColor(Colors.secondaryText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: Spacing.extraSmall) {
                Text(model.priceText)
                    .font(.system(size: Constants.textFontSize, weight: .medium))
                    .foregroundColor(Colors.black)

                Text(model.percentageText)
                    .font(.caption)
                    .foregroundColor(model.percentageColor)
            }
        }
        .padding(.vertical, Spacing.tiny)
    }
}

// MARK: - Constants

extension CoinPriceRow {
    enum Constants {
        static let textFontSize: CGFloat = 14
    }
}
