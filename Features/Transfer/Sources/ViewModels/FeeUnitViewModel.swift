// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import Primitives

public struct FeeUnitViewModel {
    private let unit: FeeUnit
    private let decimals: Int
    private let symbol: String
    private let currencyFormatter: CurrencyFormatter
    private let valueFormatter = ValueFormatter.full

    public init(
        unit: FeeUnit,
        decimals: Int,
        symbol: String,
        formatter: CurrencyFormatter
    ) {
        self.unit = unit
        self.decimals = decimals
        self.symbol = symbol
        self.currencyFormatter = formatter
    }

    public var value: String {
        switch unit.type {
        case .satVb: Localized.FeeRate.satvB(unitValueText)
        case .gwei: Localized.FeeRate.gwei(unitValueText)
        case .native: unitValueText
        }
    }

    private var conversionFactor: Double {
        switch unit.type {
        case .satVb: 1 / 1_000
        case .gwei: 1 / 1_000_000_000
        case .native: 0
        }
    }

    private var unitValueText: String {
        switch unit.type {
        case .satVb, .gwei:
            return currencyFormatter.string(decimal: Decimal(Double(unit.value) * conversionFactor)).replacingOccurrences(of: " ", with: "")
        case .native:
            return String(
                format: "%@ %@",
                valueFormatter.string(unit.value, decimals: decimals),
                symbol
            )
        }
    }
}
