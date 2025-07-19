// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import WidgetKit
import Style
import Components
import Formatters

public struct PriceWidgetView: View {
    private let viewModel: PriceWidgetViewModel
    
    public init(entry: PriceWidgetEntry, widgetFamily: WidgetFamily) {
        self.viewModel = PriceWidgetViewModel(entry: entry, widgetFamily: widgetFamily)
    }
    
    init(viewModel: PriceWidgetViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            if let error = viewModel.entry.error {
                VStack {
                    Spacer()
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title2)
                        .foregroundColor(Colors.gray)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(Colors.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.small)
                    Spacer()
                }
            } else if !viewModel.prices.isEmpty {
                ForEach(viewModel.prices, id: \.assetId) { coin in
                    CoinPriceRow(model: CoinPriceRowViewModel(coin: coin, currencyFormatter: viewModel.currencyFormatter))
                }
            } else {
                VStack {
                    Spacer()
                    Text("No price data available")
                        .font(.caption)
                        .foregroundColor(Colors.gray)
                    Spacer()
                }
            }
        }
        .padding(0)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

// MARK: - Widget Extension


struct PriceWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PriceWidgetView(entry: .placeholder(), widgetFamily: .systemMedium)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Medium")
            
            PriceWidgetView(entry: .placeholder(), widgetFamily: .systemMedium)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("Large")
        }
    }
}
