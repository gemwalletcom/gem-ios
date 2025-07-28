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
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                AsyncImageView(url: model.imageURL)
                Spacer()
                Images.Logo.logo
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
            }
            
            Spacer()
                .frame(height: Spacing.small)
            
            Text(model.name)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Colors.black)
            
            Spacer()
                .frame(height: Spacing.tiny)
            
            Text(model.priceText)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Colors.black)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            
            Spacer()
                .frame(height: Spacing.tiny)
            
            HStack {
                Text(model.percentageText)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Colors.black)
                    .padding(.vertical, Spacing.tiny + Spacing.extraSmall)
                    .padding(.horizontal, Spacing.tiny + Spacing.extraSmall)
                    .background(model.percentageColor)
                    .cornerRadius(10)
            }
        }
        .padding(0)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
