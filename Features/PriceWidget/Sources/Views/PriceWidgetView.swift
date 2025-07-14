// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import WidgetKit
import Style
import Components
import Formatters

public struct PriceWidgetView: View {
    private let viewModel: PriceWidgetViewModel
    
    public init(entry: PriceWidgetEntry) {
        self.viewModel = PriceWidgetViewModel(entry: entry, widgetFamily: .systemMedium)
    }
    
    init(viewModel: PriceWidgetViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: Spacing.small) {
            headerView
            
            if !viewModel.hasData {
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
            
            Text(viewModel.entry.date, style: .time)
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
            ForEach(viewModel.displayedCoins, id: \.assetId) { coin in
                CoinPriceRow(coin: coin, currency: viewModel.entry.currency)
            }
        }
    }
}

// MARK: - Widget Extension

public extension PriceWidgetView {
    init(entry: PriceWidgetEntry, widgetFamily: WidgetFamily) {
        self.viewModel = PriceWidgetViewModel(entry: entry, widgetFamily: widgetFamily)
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
