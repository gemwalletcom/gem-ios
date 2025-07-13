// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import Formatters

struct CoinPriceView: View {
    let coin: CoinPrice
    let currency: String
    
    private let currencyFormatter = CurrencyFormatter()
    private let percentFormatter = CurrencyFormatter.percent
    
    var body: some View {
        HStack(spacing: Spacing.small) {
            // Coin icon
            if let imageURL = coin.imageURL {
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
                Text(coin.name)
                    .font(.system(size: 14, weight: .medium))
                
                Text(coin.symbol)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Price and change
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatPrice(coin.price))
                    .font(.system(size: 14, weight: .medium))
                
                Text(formatPercentage(coin.priceChangePercentage24h))
                    .font(.caption)
                    .foregroundColor(percentageColor(coin.priceChangePercentage24h))
            }
        }
        .padding(.vertical, Spacing.extraSmall)
    }
    
    private func formatPrice(_ price: Double) -> String {
        return currencyFormatter.string(
            price,
            currency: currency,
            style: .currency
        )
    }
    
    private func formatPercentage(_ percentage: Double) -> String {
        return percentFormatter.string(percentage)
    }
    
    private func percentageColor(_ percentage: Double) -> Color {
        if percentage > 0 {
            return Colors.green
        } else if percentage < 0 {
            return Colors.red
        } else {
            return Colors.gray
        }
    }
}