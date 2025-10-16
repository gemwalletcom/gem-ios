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

    public var text: String? {
        guard let pnl else { return nil }
        let pnlAmount = currencyFormatter.string(abs(pnl))
        let percentText = percentFormatter.string(percent)

        if pnl >= 0 {
            return "+\(pnlAmount) (\(percentText))"
        } else {
            return "-\(pnlAmount) (\(percentText))"
        }
    }

    public var percent: Double {
        guard let pnl, marginAmount > 0 else { return 0 }
        return (pnl / marginAmount) * 100
    }

    public var color: Color {
        guard let pnl else { return .secondary }
        return PriceChangeColor.color(for: pnl)
    }

    public var textStyle: TextStyle {
        TextStyle(font: .callout, color: color)
    }
}
