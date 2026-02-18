// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Formatters
import Style
import Components

public struct TotalValueViewModel {
    private let totalValue: TotalFiatValue
    private let currencyFormatter: CurrencyFormatter

    public init(totalValue: TotalFiatValue, currencyFormatter: CurrencyFormatter) {
        self.totalValue = totalValue
        self.currencyFormatter = currencyFormatter
    }

    public var title: String {
        currencyFormatter.string(totalValue.value)
    }

    public var pnlAmountText: String? {
        guard totalValue.pnlAmount != 0 else { return nil }
        return PriceChangeViewModel(value: totalValue.pnlAmount, currencyFormatter: currencyFormatter).text
    }

    public var pnlPercentageText: String? {
        guard totalValue.pnlAmount != 0 else { return nil }
        return CurrencyFormatter.percentSignLess.string(totalValue.pnlPercentage)
    }

    public var pnlColor: Color {
        PriceChangeColor.color(for: totalValue.pnlAmount)
    }
}
