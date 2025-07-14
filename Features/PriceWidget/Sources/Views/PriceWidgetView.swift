// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import WidgetKit
import Style
import Components
import Formatters

public struct PriceWidgetView: View {
    let entry: PriceWidgetEntry
    
    @Environment(\.widgetFamily) var widgetFamily
    
    public init(entry: PriceWidgetEntry) {
        self.entry = entry
    }
    
    public var body: some View {
        VStack(spacing: Spacing.small) {
            headerView
            
            if entry.coinPrices.isEmpty {
                emptyView
            } else {
                coinPricesView
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Colors.white)
    }
    
    private var headerView: some View {
        HStack {
            Text("Top Crypto")
                .font(.headline)
                .foregroundColor(Colors.black)
            
            Spacer()
            
            Text(entry.date, style: .time)
                .font(.caption)
                .foregroundColor(Colors.gray)
        }
    }
    
    private var emptyView: some View {
        VStack {
            Spacer()
            Text("No price data available")
                .font(.caption)
                .foregroundColor(Colors.gray)
            Spacer()
        }
    }
    
    private var coinPricesView: some View {
        VStack(spacing: Spacing.extraSmall) {
            ForEach(displayedCoins, id: \.assetId) { coin in
                CoinPriceRow(coin: coin, currency: entry.currency)
            }
        }
    }
    
    private var displayedCoins: [CoinPrice] {
        switch widgetFamily {
        case .systemMedium:
            return Array(entry.coinPrices.prefix(3))
        case .systemLarge:
            return entry.coinPrices
        default:
            return entry.coinPrices
        }
    }
}

struct CoinPriceRow: View {
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
                    .foregroundColor(Colors.black)
                
                Text(coin.symbol)
                    .font(.caption)
                    .foregroundColor(Colors.gray)
            }
            
            Spacer()
            
            // Price and change
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatPrice(coin.price))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Colors.black)
                
                Text(formatPercentage(coin.priceChangePercentage24h))
                    .font(.caption)
                    .foregroundColor(percentageColor(coin.priceChangePercentage24h))
            }
        }
        .padding(.vertical, Spacing.extraSmall)
    }
    
    private func formatPrice(_ price: Double) -> String {
//        return currencyFormatter.string(
//            price,
//            currency: currency,
//            style: .currency
//        )
        return ""
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

struct PriceWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PriceWidgetView(entry: .placeholder())
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Medium")
            
            PriceWidgetView(entry: .placeholder())
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("Large")
        }
    }
}
