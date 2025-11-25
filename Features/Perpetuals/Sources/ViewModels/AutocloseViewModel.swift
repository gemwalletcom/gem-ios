// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Localization
import Style
import Primitives
import Formatters
import Components

public struct AutocloseViewModel {
    private let type: TpslType
    private let price: Double?
    private let estimator: AutocloseEstimator
    private let currencyFormatter: CurrencyFormatter
    private let percentFormatter: CurrencyFormatter

    public init(
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

    public var priceTitle: String { Localized.Asset.price }

    public var title: String {
        switch type {
        case .takeProfit: Localized.Perpetual.AutoClose.takeProfit
        case .stopLoss: Localized.Perpetual.AutoClose.stopLoss
        }
    }

    public var profitTitle: String {
        let isProfit = price.map { estimator.calculatePnL(price: $0) >= 0 } ?? (type == .takeProfit)
        return isProfit ? Localized.Perpetual.AutoClose.expectedProfit : Localized.Perpetual.AutoClose.expectedLoss
    }

    public var expectedPnL: String {
        guard let price else { return "-" }
        let pnl = estimator.calculatePnL(price: price)
        let roe = estimator.calculateROE(price: price)

        let amount = currencyFormatter.string(abs(pnl))
        let percentText = percentFormatter.string(roe)
        let sign = pnl >= 0 ? "+" : "-"

        return "\(sign)\(amount) (\(percentText))"
    }

    public var pnlColor: Color {
        guard let price else { return Colors.secondaryText }
        let pnl = estimator.calculatePnL(price: price)
        return PriceChangeColor.color(for: pnl)
    }

    public var percents: [Int] {
        switch estimator.leverage {
        case 0...3: [5, 10, 15]
        case 4...10: [10, 15, 25]
        case _: [25, 50, 100]
        }
    }
}
