// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import Primitives
import Formatters

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

    private var unitValueText: String {
        switch unit.type {
        case .satVb:
            return IntegerFormatter().string(Int(unit.value))
        case .gwei:
            guard let value = try? ValueFormatter.full.double(from: unit.value, decimals: 9) else {
                return ""
            }
            return currencyFormatter.string(double: value)
        case .native:
            return String(
                format: "%@ %@",
                valueFormatter.string(unit.value, decimals: decimals),
                symbol
            )
        }
    }
}
