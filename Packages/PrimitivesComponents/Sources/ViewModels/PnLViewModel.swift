// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Formatters
import Localization
import Style
import SwiftUI
import Components

public struct PnLViewModel {
    private let pnl: Double?
    private let marginAmount: Double
    private let currencyFormatter: CurrencyFormatter
    private let percentFormatter: CurrencyFormatter

    public init(
        pnl: Double?,
        marginAmount: Double,
        currencyFormatter: CurrencyFormatter,
        percentFormatter: CurrencyFormatter
    ) {
        self.pnl = pnl
        self.marginAmount = marginAmount
        self.currencyFormatter = currencyFormatter
        self.percentFormatter = percentFormatter
    }

    public var title: String { Localized.Perpetual.pnl }

    private var valueChange: PriceChangeViewModel {
        PriceChangeViewModel(value: pnl, currencyFormatter: currencyFormatter)
    }

    public var text: String? {
        guard let amountText = valueChange.text else { return nil }
        return "\(amountText) (\(percentFormatter.string(percent)))"
    }

    public var percent: Double {
        guard let pnl, marginAmount > 0 else { return 0 }
        return (pnl / marginAmount) * 100
    }

    public var color: Color { valueChange.color }

    public var textStyle: TextStyle { valueChange.textStyle }
}
