// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Localization
import Style
import Primitives
import Formatters
import Components

struct AutocloseViewModel {
    private let type: TpslType
    private let price: Double?
    private let estimator: AutocloseEstimator
    private let currencyFormatter: CurrencyFormatter
    private let percentFormatter: CurrencyFormatter

    init(
        type: TpslType,
        price: Double?,
        estimator: AutocloseEstimator,
        currencyFormatter: CurrencyFormatter,
        percentFormatter: CurrencyFormatter
    ) {
        self.type = type
        self.price = price
        self.estimator = estimator
        self.currencyFormatter = currencyFormatter
        self.percentFormatter = percentFormatter
    }

    var priceTitle: String { Localized.Asset.price }

    var title: String {
        switch type {
        case .takeProfit: Localized.Perpetual.AutoClose.takeProfit
        case .stopLoss: Localized.Perpetual.AutoClose.stopLoss
        }
    }

    var profitTitle: String {
        let isProfit = price.map { estimator.calculatePnL(price: $0) >= 0 } ?? (type == .takeProfit)
        return isProfit ? Localized.Perpetual.AutoClose.expectedProfit : Localized.Perpetual.AutoClose.expectedLoss
    }

    var expectedPnL: String {
        guard let price else { return "-" }
        let pnl = estimator.calculatePnL(price: price)
        let roe = estimator.calculateROE(price: price)

        let amount = currencyFormatter.string(abs(pnl))
        let percentText = percentFormatter.string(roe)
        let sign = pnl >= 0 ? "+" : "-"

        return "\(sign)\(amount) (\(percentText))"
    }

    var pnlColor: Color {
        guard let price else { return Colors.secondaryText }
        let pnl = estimator.calculatePnL(price: price)
        return PriceChangeColor.color(for: pnl)
    }
}
