// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Formatters
import Style
import Components

public struct PriceChangeViewModel {
    private let value: Double?
    private let currencyFormatter: CurrencyFormatter

    public init(value: Double?, currencyFormatter: CurrencyFormatter) {
        self.value = value
        self.currencyFormatter = currencyFormatter
    }

    public var text: String? {
        guard let value else { return nil }
        let formatted = currencyFormatter.string(abs(value))
        return value >= 0 ? "+\(formatted)" : "-\(formatted)"
    }

    public var color: Color {
        guard let value else { return .secondary }
        return PriceChangeColor.color(for: value)
    }

    public var textStyle: TextStyle {
        TextStyle(font: .callout, color: color)
    }
}
