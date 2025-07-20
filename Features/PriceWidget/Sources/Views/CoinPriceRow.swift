// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style

struct CoinPriceRow: View {
    private let model: CoinPriceRowViewModel
    
    init(model: CoinPriceRowViewModel) {
        self.model = model
    }
    
    var body: some View {
        HStack(spacing: Spacing.small) {
            AsyncImageView(url: model.imageURL)
    
            VStack(alignment: .leading, spacing: Spacing.extraSmall) {
                Text(model.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Text(model.symbol)
                    .font(.caption)
                    .foregroundColor(Colors.grayLight)
            }
            
            Spacer()
        
            VStack(alignment: .trailing, spacing: Spacing.extraSmall) {
                Text(model.priceText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Text(model.percentageText)
                    .font(.caption)
                    .foregroundColor(model.percentageColor)
            }
        }
        .padding(.vertical, Spacing.tiny)
    }
}
