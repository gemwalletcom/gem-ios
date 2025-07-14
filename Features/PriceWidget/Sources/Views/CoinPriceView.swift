// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import Formatters

public struct CoinPriceView: View {
    private let viewModel: CoinPriceViewModel
    
    public init(coin: CoinPrice, currency: String) {
        self.viewModel = CoinPriceViewModel(coin: coin, currency: currency)
    }
    
    public var body: some View {
        HStack(spacing: Spacing.small) {
            // Coin icon
            if let imageURL = viewModel.imageURL {
                AsyncImageView(url: imageURL)
                    .frame(width: 32, height: 32)
                    .cornerRadius(16)
            } else {
                Circle()
                    .fill(Colors.grayLight)
                    .frame(width: 32, height: 32)
            }
            
            // Name and symbol
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.name)
                    .font(.system(size: 14, weight: .medium))
                
                Text(viewModel.symbol)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Price and change
            VStack(alignment: .trailing, spacing: 2) {
                Text(viewModel.priceText)
                    .font(.system(size: 14, weight: .medium))
                
                Text(viewModel.percentageText)
                    .font(.caption)
                    .foregroundColor(viewModel.percentageColor)
            }
        }
        .padding(.vertical, Spacing.extraSmall)
    }
}
