// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import WidgetKit
import Style
import Components
import Formatters

public struct PriceWidgetView: View {
    public let entry: PriceWidgetEntry
    
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
    }
    
    private var headerView: some View {
        HStack {
            Text("Top Crypto")
                .font(.headline)
            
            Spacer()
            
            Text(entry.date, style: .time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var emptyView: some View {
        VStack {
            Spacer()
            Text("No price data available")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
    
    private var coinPricesView: some View {
        VStack(spacing: Spacing.extraSmall) {
            ForEach(displayedCoins, id: \.assetId) { coin in
                CoinPriceView(coin: coin, currency: entry.currency)
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
