// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct AutocloseFormatter: Sendable {
    private let currencyFormatter: CurrencyFormatter

    public init(currencyFormatter: CurrencyFormatter = CurrencyFormatter(type: .currency, currencyCode: Currency.usd.rawValue)) {
        self.currencyFormatter = currencyFormatter
    }

    public func format(
        takeProfit: Double?,
        stopLoss: Double?,
        takeProfitCanceled: Bool = false,
        stopLossCanceled: Bool = false
    ) -> (subtitle: String, subtitleExtra: String?) {
        let tp: String? = {
            if takeProfitCanceled { return "TP: -" }
            return takeProfit.map { "TP: \(currencyFormatter.string($0))" }
        }()

        let sl: String? = {
            if stopLossCanceled { return "SL: -" }
            return stopLoss.map { "SL: \(currencyFormatter.string($0))" }
        }()

        switch (tp, sl) {
        case (.some(let tpText), .some(let slText)):
            return (subtitle: tpText, subtitleExtra: slText)
        case (.some(let tpText), .none):
            return (subtitle: tpText, subtitleExtra: nil)
        case (.none, .some(let slText)):
            return (subtitle: slText, subtitleExtra: nil)
        case (.none, .none):
            return (subtitle: "-", subtitleExtra: nil)
        }
    }
}
