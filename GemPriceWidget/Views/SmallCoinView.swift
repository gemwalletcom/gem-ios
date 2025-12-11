// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components

struct SmallCoinView: View {
    private let model: CoinPriceRowViewModel

    init(model: CoinPriceRowViewModel) {
        self.model = model
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            HStack {
                AssetImageView(assetImage: model.assetImage, size: .list.assets.widget)
                Spacer()
                Images.Logo.logo
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Constants.logoSize, height: Constants.logoSize)
            }

            Spacer()
                .frame(height: Spacing.small)

            Text(model.name)
                .font(.system(size: Constants.nameFontSize, weight: .regular))
                .foregroundColor(Colors.black)

            Spacer()
                .frame(height: Spacing.tiny)

            Text(model.priceText)
                .font(.system(size: Constants.priceFontSize, weight: .bold))
                .foregroundColor(Colors.black)
                .minimumScaleFactor(Constants.priceMinScaleFactor)
                .lineLimit(1)

            Spacer()
                .frame(height: Spacing.tiny)

            HStack {
                Text(model.percentageText)
                    .font(.system(size: Constants.percentageFontSize, weight: .semibold))
                    .foregroundColor(Colors.black)
                    .padding(.vertical, Spacing.tiny + Spacing.extraSmall)
                    .padding(.horizontal, Spacing.tiny + Spacing.extraSmall)
                    .background(model.percentageColor)
                    .cornerRadius(Constants.percentageCornerRadius)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Constants

extension SmallCoinView {
    enum Constants {
        static let logoSize: CGFloat = 32
        static let nameFontSize: CGFloat = 16
        static let priceFontSize: CGFloat = 32
        static let priceMinScaleFactor: CGFloat = 0.5
        static let percentageFontSize: CGFloat = 16
        static let percentageCornerRadius: CGFloat = 10
    }
}
