// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import WidgetKit
import Style
import Formatters

struct WidgetContentView: View {
    private let viewModel: PriceWidgetViewModel
    private let showErrorMessage: Bool
    
    init(viewModel: PriceWidgetViewModel, showErrorMessage: Bool = true) {
        self.viewModel = viewModel
        self.showErrorMessage = showErrorMessage
    }
    
    @ViewBuilder
    var body: some View {
        if viewModel.entry.error != nil {
            WidgetErrorView(error: viewModel.entry.error, showMessage: showErrorMessage)
        } else if !viewModel.prices.isEmpty {
            switch viewModel.widgetFamily {
            case .systemSmall:
                if let bitcoin = viewModel.prices.first {
                    SmallCoinView(
                        model: CoinPriceRowViewModel(
                            coin: bitcoin,
                            currencyFormatter: CurrencyFormatter(
                                type: .abbreviated,
                                currencyCode: viewModel.entry.currency
                            ),
                            percentFormatter: CurrencyFormatter.percent
                        )
                    )
                }
            default:
                ForEach(viewModel.prices) { coin in
                    CoinPriceRow(
                        model: CoinPriceRowViewModel(
                            coin: coin,
                            currencyFormatter: CurrencyFormatter(
                                currencyCode: viewModel.entry.currency
                            ),
                            percentFormatter: CurrencyFormatter.percent
                        )
                    )
                }
            }
        } else {
            WidgetEmptyView(message: viewModel.emptyMessage)
        }
    }
}
