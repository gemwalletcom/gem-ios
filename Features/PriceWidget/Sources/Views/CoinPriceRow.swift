// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style

struct CoinPriceRow: View {
    let viewModel: CoinPriceRowViewModel
    
    init(coin: CoinPrice, currency: String) {
        self.viewModel = CoinPriceRowViewModel(coin: coin, currency: currency)
    }
    
    var body: some View {
        HStack(spacing: Spacing.small) {
            if let imageURL = viewModel.imageURL {
                AsyncImageView(url: imageURL)
                    .frame(width: 32, height: 32)
                    .cornerRadius(16)
            } else {
                Circle()
                    .fill(Colors.grayLight)
                    .frame(width: 32, height: 32)
            }
    
            VStack(alignment: .leading, spacing: Spacing.extraSmall) {
                Text(viewModel.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Colors.black)
                
                Text(viewModel.symbol)
                    .font(.caption)
                    .foregroundColor(Colors.gray)
            }
            
            Spacer()
        
            VStack(alignment: .trailing, spacing: Spacing.extraSmall) {
                Text(viewModel.priceText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Colors.black)
                
                Text(viewModel.percentageText)
                    .font(.caption)
                    .foregroundColor(viewModel.percentageColor)
            }
        }
        .padding(.vertical, Spacing.extraSmall)
    }
}
